#
#Load Module
#

#PACKAGES
#uncomment when testing standalone
#source("packages.R")
#source("functions.R")

#CONFIGURATIONS
#uncomment when testing standalone
#config = yaml.load_file("config.yml") #password from yml file 
# database configurations
con <- dbConnect(RPostgres::Postgres(),
                 dbname = 'nyc_data', 
                 host = 'localhost',
                 port = 5432,
                 user = 'postgres',
                 password = config$TIMESCALEDB$PW)

#
#USER INTERFACE
#

# Module UI function
loadUI <- function(id, label = "load_data") {

  ns <- NS(id)
  
  tagList(
    numericInput(ns("time_config"), "Aggregate to 'x minutes' time periods", min = 10, value = 60),
    textInput(ns("table_config"), "Choose table in database", value = "rides"),
    textInput(ns("value_config"), "Choose aggregation function for values", value = "COUNT(*)"),
    textInput(ns("index_config"), "Choose index column (datetime)", value = "pickup_datetime")
  )
}

#
#SERVER
#

# Module server function
loadServer <- function(id, stringsAsFactors) {
  moduleServer(
    id,
    ## Below is the module function
    function(input, output, session) {
      
      # The user's data, parsed into a data frame
      data <- reactive({
        
        time_config = input$time_config
        index_config = input$index_config 
        value_config = input$value_config 
        table_config = input$table_config 
        
        data <- import_data_from_db(con, time_config, index, value, table)
        
        return(data)
        
      })
      return(data)
    }
  )    
}

### FOR TESTING

ui <- fluidPage(
  fluidRow(
    column(3,
           h4("Database Configurations"),
           loadUI("config", "CONFIGURATIONS")),
    column(9,
           h4("Interactive Data Exploration"),
           dygraphOutput("overview_dygraph"))
    
  ),
  
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

server <- function(input, output, session) {

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
  
}

shinyApp(ui, server)