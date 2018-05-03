library("shiny")
library("shinydashboard")
library(ggplot2)
library(RMySQL)
library(jsonlite)
library(anytime)

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
  #print(temperature)
  #print(pressure)
  #print(humidity)
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

print(df2[,"timestamp"])

sidebar <- dashboardSidebar(
  sidebarMenu(
    # Create two `menuItem()`s, "Dashboard" and "Inputs"
    menuItem(text = "Humidity",
             tabName = "humidity"
    ), 
    menuItem(text = "Temperature", 
             tabName = "temperature"

    ),
    menuItem(text = "Pressure", 
             tabName = "pressure"
             )
  )
)
header <- dashboardHeader()
body <- dashboardBody(
  
  # Outputs
  mainPanel(
    plotOutput(outputId = "humidity"),
    plotOutput(outputId = "temperature"),
    plotOutput(outputId = "pressure")
  )
  
)

# Create the UI using the header, sidebar, and body
ui <- dashboardPage(header = header,
                    sidebar = sidebar,
                    body = body)

server <- function(input, output) {
  
  # Create the scatterplot object the plotOutput function is expecting
  output$humidity <- renderPlot({
    
    ggplot(data = df2, aes_string(x = "timestamp", y = "humidity")) +
      geom_point() + theme(axis.text.x = element_text(angle = 90, hjust = 1))
  })
  
  output$temperature <- renderPlot({
    
    ggplot(data = df2, aes_string(x = "timestamp", y = "temperature")) +
      geom_point() + theme(axis.text.x = element_text(angle = 90, hjust = 1))
  })
  
  output$pressure <- renderPlot({
    
    ggplot(data = df2, aes_string(x = "timestamp", y = "pressure")) +
      geom_point() + theme(axis.text.x = element_text(angle = 90, hjust = 1))
  })
}

shinyApp(ui, server)
