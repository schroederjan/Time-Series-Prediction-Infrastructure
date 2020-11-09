# Predict Module

#uncomment for testing
source("packages.R")
source("loadModule.R")
source("functions.R")
#get password information from yml file
config = yaml.load_file("config.yml")

#
#USER INTERFACE
#

predictUI <- function(id) {
  ns <- NS(id)

  tagList(
    numericInput(ns("h"), label = "Time horizon for train/test split in 'x' steps forward", min = 1, value = 10),
    checkboxInput(ns("pi"), label = "Activate prediction intervals (PI)?", value = F),
    numericInput(ns("npaths"), label = "How many times will the model be run (only possible when 'PI' is ON)?", min = 1, value = 100)
    )
}

#
#SERVER
#

predictServer <- function(id, data) {
  moduleServer(
    id,
    function(input, output, session) {
      
      h <- input$h
      pi <- input$pi
      npaths <- input$npaths
      
      result.list <- reactive({
        
        # split into train-test data according to prediction horizon
        data_train <- head(data, round(length(data) - h))
        data_test <- tail(data, h)
        
        # transform data into time-series
        ts_data.test <- prepare_for_prediction(data_test)
        ts_data.train <- prepare_for_prediction(data_train)
        
        # forecast model
        fit <- nnetar(ts_data.train)
        fc.fit <- forecast(fit, h = h, PI = pi, npaths = npaths)
        
        # prepare results for visuals
        list.data.visual <- prepare_for_visual(fc.fit, ts_data.train, ts_data.test, h)
        
        # Results
        fit.residuals <- fit
        ts.extended <- list.data.visual[[2]] 
        df.accuracy <- list.data.visual[[1]] 
        
        #save as list
        result.list <- list(ts.extended, df.accuracy, fit.residuals, fc.fit)
        return(result.list)
        
        })
      
      return(result.list)
      
    })
  }

### FOR TESTING

ui <- fluidPage(

  fluidRow(
    column(12,
           h3("Interactive Plot for the Overview"),
           dygraphOutput("dygraph.fc")
    )
  ),

  hr(),

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

server <- function(input, output, session) {

  #
  # TESTING VARIABLES AREA START -----------------------------------------------
  #

  # database configurations
  con <- dbConnect(RPostgres::Postgres(),
                   dbname = 'nyc_data',
                   host = 'localhost',
                   port = 5432,
                   user = 'postgres',
                   password = config$TIMESCALEDB$PW)

  # import configurations
  time_config = "60" #choose input for time_bucket_gapfill function from timescaledb in minutes
  index_config = "pickup_datetime" #choose a table that contains the index
  value_config = "COUNT(*)" #choose the function/table that contains the values
  table_config = "rides" #choose table in database
  
  data <- import_data_from_db(con, time_config, index_config, value_config, table_config)
  
  #
  # TESTING VARIABLES END  -----------------------------------------------------
  #
  
  result.list  <- reactive({
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
