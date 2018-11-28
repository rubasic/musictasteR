
library(shiny)


# Define UI for application that draws a histogram
ui <- fluidPage(
  
  titlePanel("Analyze your song"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("dropdown_name",label="Select the name", selected="Vincent",choices=NULL),
      
      selectInput("color",label="Color the graph", selected="pink",choices=c("pink","red","yellow","grey") ),
      sliderInput("range", "Range:",
                  min = 1900, max = 2017,
                  value = c(1900,2017))
      
    ),
    
    mainPanel(
      textOutput("text"),
      
      plotOutput("plot_popularity"),
      
      
      # plotOutput("plot_popularity"),
      dataTableOutput("data")
    )
  )
)

server <- function(input, output,session) {
  
  library(prenoms)
  library(glue)
  library(tidyverse)
  
  data(prenoms)
  
  draw_a_name <- function(nom,color,beginning) {
    prenoms %>%
      filter(name == nom) %>%
      group_by(year, name) %>%
      summarise(total = sum(n)) %>%
      ungroup() %>%
      complete(year = 1900:2017, name, fill = list(total = 0)) %>%
      # replace_na(list(total = 0)) %>%
      ggplot() +
      aes(x = year, y = total) +
      geom_line(color=color) + xlim(beginning)
  }
  
  count_a_name <- function(nom){
    prenoms %>% 
      filter(name == nom) %>% 
      summarise(total = sum(n)) %>% 
      pull(total)
  }
  
  get_list<- function(){
    prenoms %>% 
      filter(name == nom) %>% 
      summarise(total = sum(n)) %>% 
      pull(total)
  }
  
  
  
  output$data  <- reactive({renderDataTable(prenoms %>% filter(name == input$name) )
  })
  
  test <- unique(prenoms$name)
  
  observe({
    updateSelectInput(session=session, 
                      selected = "Vincent",
                      inputId="dropdown_name",
                      choices=test)
  })
  
  output$text <- renderText({  glue('There are {count_a_name(input$dropdown_name)} {input$dropdown_name}.') 
  })
  
  output$plot_popularity <- renderPlot({
    draw_a_name(input$dropdown_name, input$color,input$range)
  })
  
  
}

# Run the application 
shinyApp(ui = ui, server = server)

