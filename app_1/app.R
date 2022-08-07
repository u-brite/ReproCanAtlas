library(shiny)
library(shinythemes)


ui <- fluidPage(
  shinythemes::themeSelector(),
  navbarPage(
    "ReproCanAtlas",
    tabPanel("Start",
             sidebarPanel(
               textInput("tissue_type", "Tissue Type:", "Endometrial"),
               textInput("project", "Project:", "UCEC"),
               textInput("data_source", "Data Source:", "TCGA"),
               sliderInput("alpha", "Alpha:", 0.001, 0.05, 0.05),
               actionButton("analyze", "Analyze", class = "btn-primary")
             ),
             mainPanel(
               tabsetPanel(
                 tabPanel("DESeq Summary", verbatimTextOutput("deseq_summary")),
                 tabPanel("MA Plot", plotOutput("maplot")),
                 tabPanel("Counts", plotOutput("countplot")),
                 tabPanel("Log2 Fold Change", plotOutput("lfcplot")),
                 tabPanel("Mean SD", plotOutput("sdplot")),
                 tabPanel("Groups", plotOutput("groupsplot"))
               )
             )
    ),
    tabPanel("Mutation Analysis", 
             mainPanel(
               tabsetPanel(
                 tabPanel("MAF Summary", plotOutput("maf_summary")),
                 tabPanel("Oncoplot", plotOutput("oncoplot")),
                 tabPanel("Transition and Transversion Ratios", plotOutput("titv")),
                 tabPanel("Amino Acid Changes", textInput("gene_input", label="Gene:", value="PTEN"), plotOutput("aa_lollipop")),
                 tabPanel("Inter Variant Distance", plotOutput("ivd")),
                 tabPanel("Somatic Interactions", plotOutput("somatic_interactions")),
                 tabPanel("Oncodrive", plotOutput("oncodrive"))
               )
             )
    )
  )
)


server <- function(input, output) {
  output$deseq_summary <- renderPrint({
    summary(results(dds, alpha=input$alpha))
  })
  
  output$maplot <- renderPlot({
    plotMA(res, ylim= c(-2,2))
  })
  
  output$countplot <- renderPlot({
    plotCounts(dds, gene=which.min(res$padj), intgroup="condition")
  })
  
  output$lfcplot <- renderPlot({
    plotMA(resLFC, ylim= c(-2,2))
  })
  
  output$sdplot <- renderPlot({
    meanSdPlot(assay(ntd))
  })
  
  output$groupsplot <- renderPlot({
    q
  })
  
  output$maf_summary <- renderPlot({
    plotmafSummary(maf = endometrial_maf, rmOutlier = TRUE, addStat = 'median', dashboard = TRUE, titvRaw = FALSE)
  })
  
  output$oncoplot <- renderPlot({
    oncoplot(maf = endometrial_maf, top = 10)
  })
  
  output$titv <- renderPlot({
    plotTiTv(res = laml.titv)
  })
  
  output$ivd <- renderPlot({
    rainfallPlot(maf = endometrial_maf, detectChangePoints = TRUE, pointSize = 0.4)
  })
  
  output$aa_lollipop <- renderPlot({
    lollipopPlot(
      maf = endometrial_maf,
      gene = input$gene_input,
      AACol = 'HGVSp_Short',
      showMutationRate = TRUE
    )
  })
  
  output$somatic_interactions <- renderPlot({
    somaticInteractions(maf = endometrial_maf, top = 25, pvalue = c(0.05, 0.1))
  })
  
  output$oncodrive <- renderPlot({
    plotOncodrive(res = laml.sig, fdrCutOff = 0.1, useFraction = TRUE, labelSize = 0.5)
  })

} 
  

shinyApp(ui = ui, server = server)
