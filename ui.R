
library(shiny)
library(stringr)

# Define UI for application that draws a histogram

shinyUI(
  navbarPage("RATtle SNAKE",
             tabPanel("Buyer Groups",#"Buyer Groups",
                      fluidPage(
                        titlePanel("Buyer Groups"),
                      
                        sidebarLayout(
                          sidebarPanel(
                            radioButtons("dist", "Distribution type:",
                                         list("Normal" = "norm",
                                              "Uniform" = "unif",
                                              "Log-normal" = "lnorm",
                                              "Exponential" = "exp")),
                            br(),
                            
                            sliderInput("n", 
                                        "Number of observations:", 
                                        value = 500,
                                        min = 1, 
                                        max = 1000),
                          
                          
                          selectInput("variable", "Variable:",
                                      list("Cylinders" = "cyl", 
                                           "Transmission" = "am", 
                                           "Gears" = "gear")),
                          
                          checkboxInput("outliers", "Show outliers", FALSE),
                          
                          submitButton("Run")
                          ), 
                          
                          
                         mainPanel(
                            tabsetPanel(
                              tabPanel("Code",verbatimTextOutput("summary")),
                              tabPanel("Results",tableOutput("table")),
                              tabPanel("Summary",plotOutput("plot"))
                            )
                        )
                      )
                      )
                      
                      
                      ),
             tabPanel("HML",
                      
                       fluidPage(
                         titlePanel("HML Segmentation"),#"HML Segmentation"),
                         
                         sidebarLayout(
                           sidebarPanel(
                            
                      textInput("HMLThreshold1", label = "Percentile Threshold",
                               value = "20"
                      ),
                      textInput("HMLThreshold2", label = "",
                                value = "50"
                      ),
                      
                      textInput("HMLCategoryList", label = "Categories (comma delimited)",
                                value = "0552204, 0552206, 02304572345,..."
                      ),

                      
                      dateInput("HMLendDate", label = "Final Date",
                                value = Sys.Date() - 2*7
                      ),
                      
                      numericInput("HMLweeks", label = "Weeks of data", 
                                 value = 52
                      ),
                       
                      
                       textInput("HMLdivision", label = "Division Number",
                                 value = 1005
                       ),
                      
                      submitButton("Run HML Segmentation")
                      ),
                      
                       mainPanel(
                         
                         tabsetPanel(
                           tabPanel("Code",code(verbatimTextOutput("hmlcode"))),
                           tabPanel("Results"),
                           tabPanel("Summary")
                         )
                       )
                         )
                       )
              ),
             navbarMenu("More",
                        tabPanel("Sub-Component A"),
                        tabPanel("Sub-Component B"))
             
             
  )
)
  
  #fluidPage(
  #titlePanel("Standardised Approach"),
  

   # )*/
    
    #mainPanel("main panel")
  

