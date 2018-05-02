library("shiny")
library("shinydashboard")
library(ggplot2)
library(RMySQL)
library(jsonlite)
load(url("http://s3.amazonaws.com/assets.datacamp.com/production/course_4850/datasets/movies.Rdata"))

con = dbConnect(MySQL(),
                dbname = "mikko",
                host = "127.0.0.1", 
                port = 3306, 
                user = "mikko", 
                password = "")

myQuery <- "SELECT * FROM RuuviTag"
df <- dbGetQuery(con, myQuery)

names(df)
class(df)
N <- nrow(df)

df2 <- data.frame(timestamp=rep("", N), deviceId=rep("", N), temperature=rep("", N), pressure=rep("", N), humidity=rep("", N),  # as many cols as you need
                  stringsAsFactors=FALSE) 

json_data <- df[,c("data")]
json_data
for (i in 1:N) {
  timestamp <- df$timestamp[i]
  deviceId <- df$deviceId[i]
  temperature <- fromJSON(json_data[i])$temperature
  pressure <- fromJSON(json_data[i])$pressure
  humidity <- fromJSON(json_data[i])$humidity
  print(temperature)
  print(pressure)
  print(humidity)
  if(is.null(temperature)){
    temperature <- ""
  }
  if(is.null(pressure)){
    pressure <- ""
  }
  if(is.null(humidity)){
    humidity <- ""
  }
  df2[i, ] <- list(timestamp, deviceId, temperature, pressure, humidity)
}

dbDisconnect(con)

sidebar <- dashboardSidebar(
  sidebarMenu(
    # Create two `menuItem()`s, "Dashboard" and "Inputs"
    menuItem(text = "Dashboard",
             tabName = "dashboard"
    ), 
    menuItem(text = "Inputs", 
             tabName = "inputs"
    )
  )
)
header <- dashboardHeader()
body <- dashboardBody(
  
  sidebarPanel(
    
    # Select variable for y-axis
    selectInput(inputId = "y", 
                label = "Y-axis:",
                choices = c("timestamp"          = "timestamp", 
                            "deviceId" = "deviceId", 
                            "temperature"        = "temperature", 
                            "pressure"       = "pressure", 
                            "humidity"              = "humidity"), 
                selected = "temperature"),
    
    # Select variable for x-axis
    selectInput(inputId = "x", 
                label = "X-axis:",
                choices = c("timestamp"          = "timestamp", 
                            "deviceId" = "deviceId", 
                            "temperature"        = "temperature", 
                            "pressure"       = "pressure", 
                            "humidity"              = "humidity"), 
                selected = "timestamp"),
    
    # Select variable for color
    selectInput(inputId = "z", 
                label = "Color by:",
                choices = c("timestamp"          = "timestamp", 
                            "deviceId" = "deviceId", 
                            "temperature"        = "temperature", 
                            "pressure"       = "pressure", 
                            "humidity"              = "humidity"), 
                selected = "temperature")
  ),
  
  # Outputs
  mainPanel(
    plotOutput(outputId = "scatterplot")
  )
  
)

# Create the UI using the header, sidebar, and body
ui <- dashboardPage(header = header,
                    sidebar = sidebar,
                    body = body)

server <- function(input, output) {
  
  # Create the scatterplot object the plotOutput function is expecting
  output$scatterplot <- renderPlot({
    
    ggplot(data = df2, aes_string(x = input$x, y = input$y,
                                     color = input$z)) +
      geom_point() + theme(axis.text.x = element_text(angle = 90, hjust = 1))
  })
}

shinyApp(ui, server)
