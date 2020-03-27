library(shiny)
library(XML)
library(RCurl)
library(readxl)
library(httr)
library(dplyr)
library(plyr)
library(ggplot2)
library(leaflet)

#read longitude and latitude database
url1 <- getURL("https://developers.google.com/public-data/docs/canonical/countries_csv")
df <- readHTMLTable(url1, header = T)

#read covid-19 database
#url2 <- paste("https://www.ecdc.europa.eu/sites/default/files/documents/COVID-19-geographic-disbtribution-worldwide-",format(Sys.time(), "%Y-%m-%d"), ".xlsx", sep = "")
#GET(url2, authenticate(":", ":", type="ntlm"), write_disk(tf <- tempfile(fileext = ".xlsx")))
#data <- read_excel(tf)
data <- read_excel('C:/Users/ivemado/Downloads/COVID-19-geographic-disbtribution-worldwide-2020-03-24.xlsx')

#merge databases, sort and create summary variables
df <- data.frame(Reduce(rbind, df))
df_all <- merge(x = data, y = df, by.x = "GeoId", by.y = "country", all.x = TRUE)
df_all <- arrange(df_all, GeoId, DateRep)
df_all <- transform(df_all, cases_all = ave(Cases, GeoId, FUN=cumsum))
df_all <- transform(df_all, deaths_all = ave(Deaths, GeoId, FUN=cumsum))
df_all <- df_all %>% dplyr::group_by(GeoId) %>% dplyr::mutate(days_all = dplyr::row_number())


shinyServer(function(input, output) {
    
    #output$documentation <- renderText(
    #    if(input$doc){
    #        h3("Documentation")
    #        print("teste")
    #    }
    #)
    
    newData <- reactive({
        newdf <- subset(df_all, name %in% input$selectCountry)
        newdf <- subset(newdf, days_all <= input$sliderPeriod)
    })
    
    output$plot1 <- renderPlot({
        p1 <- ggplot(newData(), aes(x=days_all, y=cases_all, col=GeoId)) + labs(y = "Cases", x = "Days") + geom_point(size = 1.0)
        print(p1)
        if(input$model1){
            p1 <- p1 + geom_smooth(method = "loess", formula = y~x, se = FALSE)
            print(p1)
        }
    })
    
    output$plot2 <- renderPlot({
        p2 <- ggplot(newData(), aes(x=days_all, y=deaths_all, col=GeoId)) + labs(y = "Deaths", x = "Days") + geom_point(size = 1.0)
        print(p2)
        if(input$model2){
            p2<- p2 + geom_smooth(method = "loess", formula = y~x, se = FALSE)
            print(p2)
        }
    })

})
