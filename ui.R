library(shiny)
library(plotly)
library(leaflet)
library(DT)

# Define UI for application that draws a histogram
shinyUI(
  navbarPage("Global Terrorism",
    tabPanel(p(icon("map-marker","fa-2x"), " Attacks Map"),
      sidebarPanel(
          h3(icon("map-marker","fa-2x"), " Attacks Map", align = 'center'),
          tags$hr(),
          h5("Displays the geo-coordinates of ",tags$em('terrorist attacks'), "based on the the selected country."),
          tags$ul(tags$li("Use the slider to change the range of years, and use the drop down box to filter by country."),
          tags$li("Click ", tags$em("Calculate"), "to display the map.")),
          tags$hr(),
        sliderInput("range_c",
                    "Years:",
                    min = 1970,
                    max=2018,
                    value = c(2001,2018)),
        uiOutput("countryControls"),
        actionButton("display","Calculate", class = "btn-primary")
        ),
        mainPanel(
            h2("Geo-Coordinates of Terrorist Attacks"),
            tags$hr(),
            leafletOutput("leaflet_map")
        )
    )
  )
)