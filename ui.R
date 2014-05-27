
library(shiny)
library(ggmap)
library(mapproj)
library(RMySQL)
library(ggplot2)
library(ggthemes)


shinyUI(fluidPage(
  titlePanel("NSFMap: Keyword search of NSF Award Titles"),
  
  sidebarLayout(
    sidebarPanel(
      textInput('keyword1',
                label="Keyword",""),
      br(),
      actionButton('get',"Search"),
      h4("This tool generates a choropleth map indicating NSF funding as a function of geography.  It searches the keyword strings exactly."),
      h6("This is for demonstration purposes only.  As in all scientific research, context is important.  The context of the these keywords has not been taken into account.")
    ),
    
    mainPanel(
      plotOutput("distPlot")
    )
  )
))
