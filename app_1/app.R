library(shiny)
library(shinythemes)
library(shinycssloaders)

source("install.R")
library("recount3")
library(tximport)
library(GenomicFeatures)
library(TxDb.Hsapiens.UCSC.hg19.knownGene)
library(DESeq2)
library(tibble)
library(ggplot2)
library("vsn")
library("hexbin")
library(maftools)


APP_CITATION <- "Emily Page, Fion Chan, Ryan Strickland, Kaytlyn McNeal. (2022) ReproCanAtlas. U-Brite Hackin' Nomics. https://github.com/u-brite/ReproCanAtlas"

# Set to TRUE to load demo ready data
DEMO <- TRUE


ui <- fluidPage(
  shinythemes::themeSelector(),
  navbarPage(
    "ReproCanAtlas",
    tabPanel("Start",
             sidebarPanel(
               textInput("tissue_type", "Tissue Type:", "Endometrial"),
               textInput("project", "Project:", "UCEC"),
               renderText("Data source is TCGA"),
               sliderInput("alpha", "Alpha:", 0.001, 0.05, 0.05),
               actionButton("analyze", "Analyze", class = "btn-primary")
             ),
             mainPanel(
               uiOutput("start_panel") %>% withSpinner()
             )
    ),
    tabPanel("Mutations Analysis", 
             mainPanel(
               uiOutput("wxs_panel") %>% withSpinner()
             )
    )
  ),
  fluidRow(
    mainPanel(
      h4("Citations:"),
      verbatimTextOutput("citations_output")
    )
  )
)


server <- function(input, output) {
  # Start log --------------------------
  # file.create("commands.sh", "output.log")
  # Sys.chmod("commands.sh", mode = "0777", use_umask = TRUE)
  # log <- reactiveFileReader(200, session, filePath = "output.log", readLines)
  
  
  # Reactive Values --------------------
  val <- reactiveValues(
    dds = NULL,
    res = NULL,
    data_maf = NULL,
    resLFC = NULL,
    lamlsig = NULL,
    tcga_citation = NULL,
    lfc_citation = NULL
    )

  # initialize values for demo
  if (DEMO) {
    load("data/endometrial_workspace.RData")
    val$dds <- endometrial_dds 
    val$res <- endometrial_res 
    val$data_maf <- endometrial_maf 
    val$lamlsig <- laml.sig
    val$resLFC <- endometrial_resLFC
    val$lfc_citation <- lfc_citation
    val$tcga_citation <- tcga_citation
  }

  
  # Analyze data and set val -----------
  observeEvent(input$analyze, {
    withProgress(message="Downloading and analyzing data.", detail="This may take a while...", min=0, max=100, value=0, {
      data_recount3 <- recount3::create_rse_manual(
        project = input$project,
        project_home = paste("data_sources/tcga"),
        organism = "human",
        annotation = "gencode_v26",
        type = "gene"
      )
      incProgress(amount=30, message="RangedSummarizedExperiment created. Factoring normal vs. tumor condition...")

      data_meta <- data_recount3@colData@listData
      data_counts <- data_recount3@assays@data@listData$raw_counts
      Normal_vs_Tumor <- data_meta[["tcga.gdc_cases.samples.sample_type"]]
      sampleTable <- data.frame(sampleName = data_meta[["tcga.gdc_cases.case_id"]],
                                condition = Normal_vs_Tumor)
      sampleTable$condition <- factor(sampleTable$condition)
      incProgress(amount=10, message="Conditions factored. Performing DESeq2...", detail="This may take a while...")

      dds <- DESeqDataSetFromMatrix(data_counts, sampleTable, ~condition)
      dds <- DESeq(dds)
      val$dds <- dds
      val$res <- results(dds)
      incProgress(amount=40, message="DESeq2 completed. Loading MAF data...")

      val$tcga_citation <- capture.output(
        val$data_maf <- tcgaLoad(study=input$project)
      )
      incProgress(amount=20, message="MAF loaded. Analysis ready. Click on tabs to load plots and summaries.")
    })
  })
  
  # Citations output---------------------
  output$citations_output <- renderPrint({
    citations <- c(APP_CITATION, val$tcga_citation, val$lfc_citation)
    for (i in 1:length(citations)) {
      print(citations[[i]])
    }
  })

  
  #----------------
  # Start Page
  #----------------
  output$start_panel <- renderUI({
    if (!is.null(val$res)) {
      tabsetPanel(
        tabPanel("Sample Summary", dataTableOutput("sample_summary"), textOutput("project_citation")),
        tabPanel("Clinical Data", dataTableOutput("clinical_data")),
        tabPanel("DESeq2 Summary", verbatimTextOutput("deseq_summary")),
        tabPanel("MA Plot", plotOutput("maplot") %>% withSpinner()),
        tabPanel("Min P-adj Gene Count", plotOutput("min_padj_countplot") %>% withSpinner()),
        tabPanel("Gene Count", textInput("gene_to_count", label="Gene (HUGO):", value="HIGD1AP17"), plotOutput("countplot") %>% withSpinner()),
        tabPanel("Log2 Fold Change", plotOutput("lfcplot") %>% withSpinner(), textOutput("lfcplot_citation")),
        tabPanel("Mean SD", plotOutput("sdplot") %>% withSpinner())
      )
    }
    else {
      renderText("Please press 'Analyze' to begin.")
    }
  })
  
  output$sample_summary <- renderDataTable({
    getSampleSummary(val$data_maf)
  })
  
  output$project_citation <- renderText({
    val$tcga_citation
  })
  
  output$clinical_data <- renderDataTable({
    getClinicalData(val$data_maf)
  })
  
  output$deseq_summary <- renderPrint({
    summary(results(val$dds, alpha=input$alpha))
  })
  
  output$maplot <- renderPlot({
    plotMA(val$res, ylim= c(-2,2))
  })
  
  output$min_padj_countplot <- renderPlot({
    plotCounts(val$dds, gene=which.min(val$res$padj), intgroup="condition")
  })
  
  output$countplot <- renderPlot({
    col = c("Primary Tumor"= "#481567FF", "Recurrent Tumor"= "#2D708EFF", "Solid Tissue Normal"= "#29AF7FFF")
    gene_hugo <- input$gene_to_count
    gene_ensembl <- 'ENSG00000258886.2' #TODO: convert user input of gene ID in hugo format to ensembl ID
    counts <- counts(val$dds[gene_ensembl,], normalized = TRUE)
    m <- list(counts = as.numeric(counts), group= sampleTable$condition)
    m <- as_tibble(m)
    q <- ggplot(m, aes(group, counts)) + geom_boxplot(aes(fill= group)) + geom_jitter(width = 0.1) + aes(color= group) + scale_fill_manual(values = alpha(col,.3)) +scale_color_manual(values = alpha(col, 1.0)) + theme(text = element_text(size = 13)) + theme(axis.text.y = element_text(size = 17)) + theme(legend.position="none")
    q <- q + labs(y = "Normalized Counts ", title = paste("Expression of", gene_hugo, sep=" "))
    q
  })
  
  output$lfcplot <- renderPlot({
    if (is.null(val$resLFC)){
      val$lfc_citation <- capture.output(
        val$resLFC <- lfcShrink(val$dds, coef="condition_Solid.Tissue.Normal_vs_Primary.Tumor")
      )
    }
    plotMA(val$resLFC, ylim= c(-2,2))
  })
  
  output$lfcplot_citation <- renderText({
    val$lfc_citation
  })
  
  output$sdplot <- renderPlot({
    ntd <- normTransform(val$dds)
    meanSdPlot(assay(ntd))
  })
  
  
  #--------------------------
  # Mutations Analysis Page
  #--------------------------
  output$wxs_panel <- renderUI({
    if (!is.null(val$data_maf)) {
      tabsetPanel(
        tabPanel("Gene Summary", dataTableOutput("gene_summary")),
        tabPanel("MAF Summary", plotOutput("maf_summary") %>% withSpinner()),
        tabPanel("Oncoplot", plotOutput("oncoplot") %>% withSpinner()),
        tabPanel("Transition and Transversion Ratios", plotOutput("titv") %>% withSpinner()),
        tabPanel("Amino Acid Changes", textInput("gene_input", label="Gene:", value="PTEN"), plotOutput("aa_lollipop") %>% withSpinner()),
        tabPanel("Inter Variant Distance", plotOutput("ivd") %>% withSpinner()),
        tabPanel("Somatic Interactions", plotOutput("somatic_interactions") %>% withSpinner()),
        tabPanel("Oncodrive", plotOutput("oncodrive") %>% withSpinner())
      )
    }
    else {
      renderText("Please go to 'Start' and press 'Analyze' to begin.")
    }
  })
  
  output$gene_summary <- renderDataTable({
    getGeneSummary(val$data_maf)
  })
  
  output$maf_summary <- renderPlot({
    plotmafSummary(maf = val$data_maf, rmOutlier = TRUE, addStat = 'median', dashboard = TRUE, titvRaw = FALSE)
  })
  
  output$oncoplot <- renderPlot({
    oncoplot(maf = val$data_maf, top = 10)
  })
  
  output$titv <- renderPlot({
    laml.titv = titv(maf = val$data_maf, plot = FALSE, useSyn = TRUE)
    plotTiTv(res = laml.titv)
  })
  
  output$ivd <- renderPlot({
    rainfallPlot(maf = val$data_maf, detectChangePoints = TRUE, pointSize = 0.4)
  })
  
  output$aa_lollipop <- renderPlot({
    lollipopPlot(
      maf = val$data_maf,
      gene = input$gene_input,
      AACol = 'HGVSp_Short',
      showMutationRate = TRUE
    )
  })
  
  output$somatic_interactions <- renderPlot({
    somaticInteractions(maf = val$data_maf, top = 25, pvalue = c(0.05, 0.1))
  })
  
  output$oncodrive <- renderPlot({
    if (is.null(val$lamlsig)) {
      val$lamlsig <- oncodrive(maf = val$data_maf, AACol = 'HGVSp_Short', minMut = 5, pvalMethod = 'zscore')
    }
    plotOncodrive(res = val$lamlsig, fdrCutOff = 0.1, useFraction = TRUE, labelSize = 0.5)
  })

} 
  

shinyApp(ui = ui, server = server)
