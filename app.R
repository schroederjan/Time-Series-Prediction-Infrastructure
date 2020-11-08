## app.R ##

###
#Sources
###

config = yaml.load_file("modules/config.yml") #password from yml file 

source("modules/packages.R")
source("modules/functions.R")

source("modules/loadModule.R")
#source("modules/predictModule.R")


###
#UI
###

ui <- dashboardPage(
  dashboardHeader(title = "Interactive Analytics with TimescaleDB"),
  
  #SIDEBAR
  dashboardSidebar(
    sidebarMenu(
      menuItem("Step 1: Load", tabName = "load", icon = icon("upload")),
      menuItem("Step 2: Test", tabName = "test", icon = icon("vials")),
      menuItem("Step 3: Predict", tabName = "predict", icon = icon("chart-line"))
    )
  ),
  
  #BODY
  dashboardBody(
    tabItems(
      
      #####
      # First tab content
      #####
      tabItem(tabName = "load",
              
              fluidPage(
                
                fluidRow(
                  column(3,
                         h4("Database Configurations"),
                         loadUI("config")),
                  
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
              ),
      
      #####
      # Second tab content
      #####
      
      tabItem(tabName = "test",
              h2("Work in progress:")
              ),
      
      #####
      # Third tab content
      #####
      
      tabItem(tabName = "predict",
              h2("Work in progress:")
              ),
      
    ), #tabitems.end
  ) #dashboardbody.end
) #ui.end

###
#SERVER
###

server <- function(input, output, session) {
  
  ###
  #Step 1
  #LOADED DATA
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
  
  ###
  #Step 3
  #PREDICTION
  ###
    
}

shinyApp(ui, server)