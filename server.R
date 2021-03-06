#install.packages("stringr")
library(shiny)
library(stringr)

# Clean up
rm(list = ls())
gc()
cat("\014")

HML_qry_01_01 <- ""

# Define server logic for random distribution application
shinyServer(function(input, output) {
  
  # Reactive expression to generate the requested distribution. This is 
  # called whenever the inputs change. The renderers defined 
  # below then all use the value computed from this expression
  data <- reactive({  
    dist <- switch(input$dist,
                   norm = rnorm,
                   unif = runif,
                   lnorm = rlnorm,
                   exp = rexp,
                   rnorm)
    
    dist(input$n)
  })
  
  # Generate a plot of the data. Also uses the inputs to build the 
  # plot label. Note that the dependencies on both the inputs and
  # the 'data' reactive expression are both tracked, and all expressions 
  # are called in the sequence implied by the dependency graph
  output$plot <- renderPlot({
    dist <- input$dist
    n <- input$n
    
    hist(data(), 
         main=paste('r', dist, '(', n, ')', sep=''))
  })
  
  # Generate a summary of the data
  output$summary <- renderPrint({
    summary(data())
  })
  
  # Generate an HTML table view of the data
  output$table <- renderTable({
    data.frame(x=data())
  })
  #################################  #################################
  ##### DO IT FOR HML #####
  ################################  #################################


  output$hmlcode <- renderText({

          
          RunCode <- input$HMLrun
          # Define the flexible parameters
          inp_par_percentile_threshold          <- c(input$HMLThreshold1, input$HMLThreshold2)
          inp_par_hml_category                  <- c(as.vector(unlist(strsplit(input$HMLCategoryList, ","))))
          inp_par_end_transaction_date          <- as.character(c(input$HMLendDate))
          inp_par_end_transaction_period_weeks  <- c(input$HMLweeks)
          inp_par_division_nbr                  <- as.character(c(input$HMLdivision)) # Should be the same as the product hierarchy
               
          #  Build query sequentially
          HMLCode <- list()
          HMLCode$P1P1    <-
            paste0(c(
              "SELECT   LINKED_LYLTY_CARD_NBR,"
              ,c(paste0("   CASE WHEN PERCENTILE >= 0 AND PERCENTILE <= ", inp_par_percentile_threshold[1], " THEN 'Heavy'")
                , paste0("         WHEN (PERCENTILE > ", inp_par_percentile_threshold[1], " AND PERCENTILE <= ", inp_par_percentile_threshold[2], " THEN 'Medium'")
                , paste0("         WHEN (PERCENTILE > ", inp_par_percentile_threshold[2], " THEN 'Medium'")
                , "    END AS HML_Segment"
              ),
              "FROM
              (")
              , collapse = "\n"
            )
#             c("SELECT
#               LINKED_LYLTY_CARD_NBR
#               ,  CASE WHEN PERCENTILE<= ",inp_par_percentile_threshold[1], "THEN 'Heavy'
#               WHEN PERCENTILE <= ",inp_par_percentile_threshold[2], "THEN 'Medium'
#               WHEN ",inp_par_percentile_threshold[2],"< PERCENTILE THEN 'Light'
#               END AS HML_Segment
#               
#               FROM
#               (")
#           
          HMLCode$P2P1    <-
            c("SELECT
              LINKED_LYLTY_CARD_NBR
              ,  SALES
              ,  (ROW_NUMBER() OVER (ORDER BY A.SALES DESC) - 1) *100 / COUNT (*) OVER () AS PERCENTILE
              
              FROM
              (")
          
          # View(HML_qry_02_01)
          
          # INNER QUERY
          
          HMLCode$P3P1    <-
            c("SELECT
              LINKED_LYLTY_CARD_NBR
              ,	SUM(TOT_AMT_INCLD_GST) AS SALES")
          
          # View(HML_qry_03_01)
          
          HMLCode$P3P2    <-
            c("FROM PROD_EDW_WIL.IDX_CUST_PROD_SALE_SUMMARY_V IDX
              INNER JOIN PROD_EDW_WIL.DIM_PROD_ARTICLE_CURR_V PROD
              ON IDX.PROD_NBR = PROD.PROD_NBR")
          
          
          # WHERE CONDITION - subquery
          
          HMLCode$P3P4 <-
            c(paste0(c("WHERE IDX.DIVISION_NBR IN ("
                       , paste0(c("'"), paste0(inp_par_division_nbr, collapse = "', '"), c("'"), collapse = "")
                       , ")")
                     , collapse = ""))
          
          # View(HML_qry_03_04)
          
          HMLCode$P3P5 <-
            c(paste0(c("AND PROD.DIVISION_NBR IN ("
                       , paste0(c("'"), paste0(inp_par_division_nbr, collapse = "', '"), c("'"), collapse = "")
                       , ")")
                     , collapse = ""))
          
          # View(HML_qry_03_05)
          
          HMLCode$P3P6 <-
            c(paste0("AND IDX.START_TXN_DATE BETWEEN (DATE "
                     , paste0("'", inp_par_end_transaction_date, "' - (", inp_par_end_transaction_period_weeks, "*7)) AND DATE ", "'", inp_par_end_transaction_date, "'", sep = "")
            )
            )
          
          # View(HML_qry_03_06)
          
          HMLCode$P3P17 <-
            c(paste0("AND PROD.SUBCAT_CODE IN ("
                     , paste0(c("'"), paste0(inp_par_hml_category, collapse = "', '"), c("'"), collapse = "")
                     , ")")
            )
          
          # View(HML_qry_03_07)
          
          HMLCode$P3P8 <- c("AND TOT_AMT_INCLD_GST > 0")
          
          # View(HML_qry_03_08)
          
          HMLCode$P13P8 <- c("AND PROD_QTY > 0")
          
          # View(HML_qry_03_09)
          
          HMLCode$P3P10 <-
            c("GROUP BY 1
        ) A")
          
          # View(HML_qry_03_10)
          
          HMLCode$P4P1 <-
            c("GROUP BY 1, 2
        ) B")
          
          # View(HML_qry_04_01)
          
          #qry_varnames_sorted    <- sort(unique(as.vector(ls())[grep(pattern = "^HML", x = ls())]), decreasing = FALSE)
          #qry_varnames_sorted
          #qry_values_sorted      <- as.vector(sapply(qry_varnames_sorted, FUN = get))
          
          # Final query
          qry_final              <- paste0(HMLCode, collapse = "\n")
          
          qry_final
  })

  

 
})
