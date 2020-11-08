## app.R ##

###
#Sources
###

source("modules/packages.R")
source("modules/functions.R")
config = yaml.load_file("modules/config.yml") #password from yml file 
source("modules/loadModule.R")
source("modules/predictModule.R")

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
              h2("COMING SOON")
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
  
  #COMING SOON
  
  ###
  #Step 3
  #PREDICTION
  ###
  
  result.list  <- reactive({
    data <- data()
    result <- predictServer("predictModule", data)
  })
  
  output$dygraph.fc <- renderDygraph({
    results <- result.list()
    visualize_ts(results()[[1]])
  })
  
  output$acc.tr <- renderTable({
    results <- result.list()
    ts.acc <- results()[[2]]
  })
  
  output$plot.fc <- renderPlot({
    results <- result.list()
    ts.plot <- plot(results()[[4]])
  })
  
  output$plot.res <- renderPlot({
    results <- result.list()
    results()[[3]] %>% checkresiduals()
  })
  
  
}

shinyApp(ui, server)