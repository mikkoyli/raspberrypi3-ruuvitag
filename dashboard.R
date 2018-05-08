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

df2 <- data.frame(timestamp=rep(0, N), deviceId=rep("", N), temperature=rep(0, N), pressure=rep(0, N), humidity=rep(0, N),  # as many cols as you need
                  stringsAsFactors=FALSE) 

json_data <- df[,c("data")]
json_data
for (i in 1:N) {
  timestamp <- anytime(strtoi(df$timestamp[i]))
  deviceId <- df$deviceId[i]
  temperature <- fromJSON(json_data[i])$temperature
  pressure <- fromJSON(json_data[i])$pressure
  humidity <- fromJSON(json_data[i])$humidity

  if(is.null(timestamp)){
    timestamp <- ""
  }
  if(is.null(temperature)){
    temperature <- ""
  }
  if(is.null(pressure)){
    pressure <- ""
  }
  if(is.null(humidity)){
    humidity <- ""
  }
  df2[i, ] <- list(anytime(timestamp), deviceId, temperature, pressure, humidity)
}

dbDisconnect(con)
sapply(df2, typeof)
df2[,"timestamp"] = anytime(df2[,"timestamp"])
last_day_time <- Sys.time() - as.difftime(24, unit="hours")
last_month_time <- Sys.time() - as.difftime(30, unit="days")
last_day <- subset(df2, timestamp > last_day_time )
last_month <- subset(df2, timestamp > last_month_time )

sidebar <- dashboardSidebar(
  sidebarMenu(
    # Create two `menuItem()`s, "Dashboard" and "Inputs"
    menuItem(text = "Temperature",
             tabName = "temperature"
    ),
    menuItem(text = "Pressure",
             tabName = "pressure"
    ),
    menuItem(text = "Humidity",
             tabName = "humidity"
    ),
    id = "sbMenu"
  ),
  selectInput(inputId = "time", 
              label = "Time:",
              choices = c("Month" = "last_month", 
                          "Day" = "last_day"),
              selected = "last_month")
)
header <- dashboardHeader()
body <- dashboardBody(
  
  h2("Plot"),
  plotOutput(outputId = "linePlot")

  
)

# Create the UI using the header, sidebar, and body
ui <- dashboardPage(header = header,
                    sidebar = sidebar,
                    body = body)

server <- function(input, output) {
  
  output$linePlot <- renderPlot({
    
    ggplot(data = eval(parse(text = input$time)), aes_string(x = "timestamp", y = input$sbMenu, color= "deviceId")) +
      geom_point() + geom_line() + theme(axis.text.x = element_text(angle = 90, hjust = 1)) + facet_wrap(~deviceId)
  })

}

shinyApp(ui, server)
