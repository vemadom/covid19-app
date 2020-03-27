library(shiny)

library(XML)
library(RCurl)
library(plyr)

#read longitude and latitude database
url1 <- getURL("https://developers.google.com/public-data/docs/canonical/countries_csv")
df <- readHTMLTable(url1, header = T)
df <- data.frame(Reduce(rbind, df))
lt <- as.character(unique(df$name))


shinyUI(fluidPage(
    navbarPage("Covid-19 Prediction",
        tabPanel("App",
            titlePanel("Cases and Deaths"),
        
            # Sidebar with a slider input for number of days
            sidebarLayout(
                sidebarPanel(
                    sliderInput("sliderPeriod", "Number of Days:", min = 1, max = 365, value = 90),
                    selectInput("selectCountry", "Choose the Countries:", choices = lt, multiple = TRUE, selected = c("China","Brazil")),
                    checkboxInput("model1","Predict cases", value = TRUE),
                    checkboxInput("model2","Predict deaths", value = TRUE),
                ),
                
                # Show a plot of Covid-19
                mainPanel(
                    tabsetPanel(type = "tabs",
                        tabPanel("Cases", br(),
                            h3("Confirmed Cases"),
                            plotOutput("plot1")
                        ),
                        tabPanel("Deaths", br(),
                            h3("Confirmed Deaths"),
                            plotOutput("plot2")
                        )
                    )
                )
            )
        ),
        tabPanel("Documentation",
            fluidRow(includeMarkdown("documentation.md"))
        )
    )
))
