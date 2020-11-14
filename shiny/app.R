## app.R ##

###
#Sources
###

source("modules/packages.R")
source("modules/functions.R")
source("modules/loadModule.R")
source("modules/predictModule.R")
source("modules/crossvalidationModule.R")

###
#UI
###
  
ui <- dashboardPage(
  skin = "black",
  dashboardHeader(title = "Interactive Prediction Dashboard with TimescaleDB", titleWidth = 350),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Step 1: Load", tabName = "load", icon = icon("upload")),
      menuItem("Step 2: Test", tabName = "test", icon = icon("vials")),
      menuItem("Step 3: Predict", tabName = "predict", icon = icon("chart-line"))
    )
  ),
  
  dashboardBody(
    tabItems(
      
      #####
      # First tab content
      #####
      
      tabItem(tabName = "load",
              fluidPage(
                
                #ROW 1
                fluidRow(
                  column(3,
                         h4("Database Configurations"),
                         loadUI("config")),
                  
                  column(9,
                         h4("Interactive Data Exploration"),
                         dygraphOutput("overview_dygraph"))
                ),
                
                #ROW 2
                fluidRow(
                  column(6,
                         h4("Test 1: Autcorrelation Function"),
                         plotOutput("test.acf")
                  ),
                  
                  column(6,
                         h4("Test 2: Partial Autcorrelation Function"),
                         plotOutput("test.pacf")
                         )
                  
                  )
                )
              ), #tabitem.end
      
      #####
      # Second tab content
      #####
      
      tabItem(tabName = "test",
              fluidPage(
                
                #ROW 1
                fluidRow(
                  column(12,
                         h3("Crossvalidation Interactive Plot"),
                         dygraphOutput("dygraph.cv")
                  )
                ),
                
                #ROW 2
                fluidRow(
                  column(4,
                         h3("Crossvalidation Configurations"),
                         crossvalidationUI("crossvalidationModule")
                  ),
                  column(8,
                         h3("Crossvalidation Training & Testing Accuracy"),
                         tableOutput("acc.cv")
                  )
                )
                
              )
              ),
      
      #####
      # Third tab content
      #####
      
      tabItem(tabName = "predict",
              fluidPage(
                
                #ROW 1
                fluidRow(
                  column(12,
                         h3("Interactive Plot for the Overview"),
                         dygraphOutput("dygraph.fc")
                  )
                ),
                
                hr(),
                
                #ROW 2
                fluidRow(
                  column(4,
                         h3("Model Configurations"),
                         predictUI("predictModule")
                  ),
                  column(8,
                         h3("Prediction Interval Plot (PI)"),
                         plotOutput("plot.fc")
                  )
                ),
                
                #ROW 3
                fluidRow(
                  column(6,
                         h3("Model Residuals"),
                         plotOutput("plot.res")
                  ),
                  column(6,
                         h3("Training & Testing Accuracy"),
                         tableOutput("acc.tr")
                  )
                )
              )
      )
      
      ) #tabitems.end
    ) #dashboardbody.end
  ) #ui.end

###
#SERVER
###

server <- function(input, output) {
  
  ###
  #Step 1
  #LOAD
  ###
  
  data <- loadServer("config")
  
  output$overview_dygraph <- renderDygraph({
    overview.data <- prepare_for_prediction(data())
    visualize_ts(overview.data)
  })
  
  output$test.acf <- renderPlot({
    data.acf <- Acf(data()$value, plot = F)
    autoplot(data.acf)
  })
  
  output$test.pacf <- renderPlot({
    data.pacf <- Pacf(data()$value, plot = F)
    autoplot(data.pacf)
  })
  
  ###
  #Step 2
  #DATA Testing
  ###
  
  #
  # TESTING VARIABLES END  -----------------------------------------------------
  #
  
  result.list_crossvalidation  <- reactive({
    result <- crossvalidationServer("crossvalidationModule", data())
  })
  
  output$dygraph.cv <- renderDygraph({
    results <- result.list_crossvalidation()
    ts_data <- results()[[1]]
    
    #DETERMIN HIGHLIGHTS IN VISUALIZATION
    df_data <- data.frame(ts_data)
    shade_1.start <- df_data[3] %>% na.omit() %>% head(1) %>% row.names()
    shade_2.start <- df_data[2] %>% na.omit() %>% head(1) %>% row.names()
    shade_3.start <- df_data[1] %>% na.omit() %>% head(1) %>% row.names()
    shade_1.end <- df_data[3] %>% na.omit() %>% tail(1) %>% row.names()
    shade_2.end <- df_data[2] %>% na.omit() %>% tail(1) %>% row.names()
    shade_3.end <- df_data[1] %>% na.omit() %>% tail(1) %>% row.names()
    
    dygraph(ts_data) %>% 
      dyRangeSelector() %>% 
      dyOptions(drawPoints = F, pointSize = 2, colors = c("red", "blue","green","black")) %>% 
      dyUnzoom() %>% 
      dyCrosshair(direction = "vertical") %>% 
      dyLegend(width = 400) %>% 
      dyShading(from = shade_1.start, to = shade_1.end, color = "#CCEBD6") %>% 
      dyShading(from = shade_2.start, to = shade_2.end, color = "#CCE5FF") %>% 
      dyShading(from = shade_3.start, to = shade_3.end, color = "#FFE6E6")
    
  })
  
  output$acc.cv <- renderTable({
    results <- result.list_crossvalidation()
    df_accuracy <- results()[[2]]
  })
  
  ###
  #Step 3
  #PREDICTION
  ###
  
  result.list_prediction  <- reactive({
    result <- predictServer("predictModule", data())
  })
  
  output$dygraph.fc <- renderDygraph({
    results <- result.list_prediction()
    visualize_ts(results()[[1]])
  })
  
  output$acc.tr <- renderTable({
    results <- result.list_prediction()
    ts.acc <- results()[[2]]
  })
  
  output$plot.fc <- renderPlot({
    results <- result.list_prediction()
    ts.plot <- plot(results()[[4]])
  })
  
  output$plot.res <- renderPlot({
    results <- result.list_prediction()
    results()[[3]] %>% checkresiduals()
  })
  
  
}

shinyApp(ui, server)