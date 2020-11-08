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
config = yaml.load_file("modules/config.yml") #password from yml file 

#
#USER INTERFACE
#

# Module UI function
loadUI <- function(id, label = "load_data") {

  ns <- NS(id)
  
  tagList(
    sliderInput(ns("time_config"), "time_config", min = 10, max = 120, value = 60, step = 10),
    textInput(ns("table_config"), "table_config", value = "rides"),
    textInput(ns("value_config"), "value_config", value = "COUNT(*)"),
    textInput(ns("index_config"), "index_config", value = "pickup_datetime")
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