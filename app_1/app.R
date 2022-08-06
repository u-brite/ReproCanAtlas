
library(maftools)

endometrial_maf <- tcgaLoad(study= "UCEC")



# Define UI for app that draws a histogram ----
ui <- fluidPage(
  
  # App title ----
  titlePanel("ReproCanAtlas"),
    
    # Main panel for displaying outputs ----
    mainPanel("Genomic Analysis Selection"), 
      
      # Output:
  splitLayout(plotOutput("plot1"), plotOutput("plot2"))
  
  
)


# Define server logic required to ----
server <- function(input, output) {
  output$plot1 <- renderPlot(plotmafSummary(maf = endometrial_maf, rmOutlier = TRUE, addStat = 'median', dashboard = TRUE, titvRaw = FALSE),
  output$plot2 <- renderPlot(oncoplot(maf = endometrial_maf, top = 10))
                             )
     }
  

shinyApp(ui = ui, server = server)
