
library(maftools)

endometrial_maf <- tcgaLoad(study= "UCEC")



# Define UI for app that draws a histogram ----
ui <- fluidPage(
  #Sidebar panel for inputs ----
    sidebarPanel( 
      checkboxGroupInput("Data_Types", label = h3("Data Types to View"), choices = c("WXS", "RNAseq", "scRNAseq", "Cell Line"), selected = NULL)),
  # App title ----
  titlePanel("ReproCanAtlas"),
    
    # Main panel for displaying outputs ----
  
  mainPanel(
  splitLayout(plotOutput(outputId = "summary"),  
    plotOutput(outputId = "oncoplot"))
  )
) 


# Define server logic required to ----
server <- function(input, output) {

   output$summary <- renderPlot(plotmafSummary(maf = endometrial_maf, rmOutlier = TRUE, addStat = 'median', dashboard = TRUE, titvRaw = FALSE))   

  output$oncoplot <- renderPlot(oncoplot(maf = endometrial_maf, top = 10))

  } 
  

shinyApp(ui = ui, server = server)
