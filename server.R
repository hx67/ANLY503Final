library(shiny)
library(plotly)
library(leaflet)
library(DT)
library(dplyr)
library(reshape)
library(countrycode)

terrorism <- read.csv("./Data/terrorism_short.csv", stringsAsFactors = FALSE)

attacks_by_country <-as.data.frame(sort(table(terrorism$Country),decreasing = TRUE))
names(attacks_by_country) <- c("Country","Count")

unique_countries <- as.data.frame(unique(attacks_by_country$Country))
names(unique_countries) <- "Country"
unique_countries$Country <- as.character(unique_countries$Country)
unique_countries$Country <- sort(unique_countries$Country)

unique_weapons <- as.data.frame(unique(terrorism$WeaponType))
names(unique_weapons) <- "Weapons"
unique_weapons$Weapons <- as.character(unique_weapons$Weapons)
unique_weapons$Weapons <- sort(unique_weapons$Weapons)

unique_attacks <- as.data.frame(unique(terrorism$AttackType))
names(unique_attacks) <- "Attacks"
unique_attacks$Attacks <- as.character(unique_attacks$Attacks)
unique_attacks$Attacks <- sort(unique_attacks$Attacks)

shinyServer(function(input, output) {
    
    values <- reactiveValues()
    
    values$unique_countries <- unique_countries$Country
    
    values_w <- reactiveValues()
    values_w$unique_weapons <- unique_weapons$Weapons
    
    output$countryControls <- renderUI({
        selectizeInput('unique_countries', 'Countries:', unique_countries$Country, selected = "United States", multiple = TRUE, options = list(placeholder = 'Please select 1 or more countries'))
    })
    
    output$countryControls_d <- renderUI({
        selectizeInput('unique_countries_d', 'Countries:', unique_countries$Country, selected = "United States", multiple = TRUE, options = list(placeholder = 'Please select 1 or more countries'))
    })
    
    filtered <- reactive({
        attacks_by_country <- filter(terrorism, Year >= input$range[1] & Year <= input$range[2])
        attacks_by_country <-as.data.frame(sort(table(attacks_by_country$Country),decreasing = TRUE))
        names(attacks_by_country) <- c("Country","Count")
        attacks_by_country$Code <- countrycode(attacks_by_country$Country,'country.name','iso3c')
        attacks_by_country[attacks_by_country$Country=='Kosovo','Code'] <- 'KSV'
        attacks_by_country[attacks_by_country$Country=='Yugoslavia','Code'] <- 'YUG'
        attacks_by_country[attacks_by_country$Country=='North Yemen','Code'] <- 'YEM'
        attacks_by_country[attacks_by_country$Country=='South Yemen','Code'] <- 'YEM'
        attacks_by_country[attacks_by_country$Country=='Czechoslovakia','Code'] <- 'CSK'
        attacks_by_country[attacks_by_country$Country=='East Germany (GDR)','Code'] <- 'DEU'
        attacks_by_country[attacks_by_country$Country=='Serbia-Montenegro','Code'] <- 'SCG'
        attacks_by_country
    })
    
    
    
    
    filtered_c <- eventReactive(input$display,{
        info_marks <- filter(terrorism, Year >= input$range_c[1] & Year <= input$range_c[2] & Country %in%  input$unique_countries)
        info_marks
    })
    
    output$plotly_map <- renderPlotly({
        l <- list(color = toRGB("grey"), width = 0.5)
        
        g <- list(
            showframe = TRUE,
            showcoastlines = FALSE,
            projection = list(type = 'Mercator'),
            lataxis = list(
                range = c(-60, 90),
                showgrid = TRUE,
                tickmode = "linear",
                dtick = 10
            ),
            lonaxis = list(
                range = c(-180, 180),
                showgrid = TRUE,
                tickmode = "linear",
                dtick = 20
            )
        )
        
        p <- plot_geo(filtered()) %>%
            add_trace(
                z = ~Count, color = ~Count, colors = 'blues',
                text = ~Country, locations = ~Code, marker = list(line = l)
            ) %>%
            colorbar(title = '<br><br><br><br><br><br><br><br><br><br>Number of  <br>Terrorist Attacks') %>%
            layout(
                geo = g
            )
        p
    })
    
        output$leaflet_map <- renderLeaflet({
        leaflet(data = filtered_c()) %>% addTiles() %>%
            addMarkers(~Longitude, ~Latitude, popup = ~as.character(paste0("<span style = 'color:#2874A6;'>Date: </span><span style = 'color:#FF9473;'>",Month,"/",Day,"/",Year,
                                                                           "</span><br><span style = 'color:#2874A6;'>Group: </span><span style = 'color:#FF9473;'>",Group,
                                                                           "</span><br><span style = 'color:#2874A6;'>Type: </span><span style = 'color:#FF9473;'>",AttackType,
                                                                           "</span><br><span style = 'color:#2874A6;'>Target: </span><span style = 'color:#FF9473;'>",TargetType,
                                                                           "</span><br><span style = 'color:#2874A6;'>People Killed: </span><span style = 'color:#FF9473;'>",Killed,
                                                                           "</span><br><span style = 'color:#2874A6;'>People Hurted: </span><span style = 'color:#FF9473;'>",Wounded,"</span>")))
    })
        
})