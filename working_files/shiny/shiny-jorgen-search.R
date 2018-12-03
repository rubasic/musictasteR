
library(shiny)
library(spotifyr)
library(stringr)
library(DT)

ui <- shinyUI(fluidPage(
    
    titlePanel("Search Spotify"),
    
    sidebarLayout(
        sidebarPanel(
            textInput("artist", "1. Name an artist:"),
            htmlOutput("artistImage")
        ),
        
        mainPanel(
            h3("Artists matching your search"),
            tableOutput("artistTable")
        )
    )
))


server <- shinyServer(function(input, output) {
    
    # Get access token 
    Sys.setenv(SPOTIFY_CLIENT_ID = 'a98864ad510b4af6851331638eec170f')
    Sys.setenv(SPOTIFY_CLIENT_SECRET = '6445326414dd4bf381afbc779b182223')
    access_token <- get_spotify_access_token()
    
    
    artists <- reactive({
        req(input$artist)
        get_artists(artist_name = input$artist, access_token = access_token) 
    })
    
    
    output$artistTable <- renderTable({
        artists()$artist_name
    },
    colnames = FALSE)
    
    output$artistImage <- renderUI({
        image_url <- artists()$artist_img[1]
        tags$img(src = image_url, height = 200, width = 200)
    })
    
})

# Run the application 
shinyApp(ui = ui, server = server)

