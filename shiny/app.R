
library(shiny)
library(ggplot2)
library(dplyr)
library(plotly)
library(DT)

prizes <- read.csv("~/Desktop/MA615/shiny project/shiny/prizes.csv", stringsAsFactors = FALSE)
prizes <- prizes %>%
  mutate(uk_residence_display = ifelse(uk_residence, "Yes", "No"))

# Define UI:
ui <- navbarPage(
  title = "😎UK Literary Prizes Analysis",
  
# Tab 1: Overview
tabPanel("🤓Overview",
           fluidRow(
             column(12,
                    h2("Dataset Overview"),
                    p("This app explores diversity patterns in UK literary prizes from 1991-2022."),
                    hr()
             )
           ),
           fluidRow(
             column(3,
                    div(class = "well text-center",
                        h3(textOutput("total_prizes_text"), style = "color: #3498db;"),
                        p("Total Awards")
                    )
             ),
             column(3,
                    div(class = "well text-center",
                        h3(textOutput("total_institutions_text"), style = "color: #e74c3c;"),
                        p("Degree Institutions")
                    )
             ),
             column(3,
                    div(class = "well text-center",
                        h3(textOutput("total_genres_text"), style = "color: #2ecc71;"),
                        p("Prize Genres")
                    )
             ),
             column(3,
                    div(class = "well text-center",
                        h3(textOutput("year_range_text"), style = "color: #f39c12;"),
                        p("Year Range")
                    )
             )
           ),
           fluidRow(
             column(4,
                    div(class = "well text-center",
                        h3(textOutput("total_prize_names_text"), style = "color: #9b59b6;"),
                        p("Unique Prize Names")
                    )
             ),
             column(4,
                    div(class = "well text-center",
                        h3(textOutput("total_prize_aliases_text"), style = "color: #1abc9c;"),
                        p("Prize Aliases")
                    )
             ),
             column(4,
                    div(class = "well text-center",
                        h3(textOutput("total_ethnicities_text"), style = "color: #34495e;"),
                        p("Ethnicity Categories")
                    )
             )
           ),
           fluidRow(
             column(6,
                    plotlyOutput("ethnicity_overview", height = "400px")
             ),
             column(6,
                    plotlyOutput("year_trend", height = "400px")
             )
           ),
           fluidRow(
             column(12,
                    h4("Data Summary by Demographics"),
                    DTOutput("summary_table")
             )
           )
  ),
  
# Tab 2: Ethnicity analysis:
  tabPanel("🥸Ethnicity Analysis",
           sidebarLayout(
             sidebarPanel(
               h4("Filters"),
               selectInput("eth_year_filter", "Select Year Range:",
                           choices = c("All Years", "1991-2000", "2001-2010", "2011-2022"),
                           selected = "All Years"),
               selectInput("eth_genre_filter", "Prize Genre:",
                           choices = c("All", sort(unique(prizes$prize_genre))),
                           selected = "All"),
               selectInput("eth_role_filter", "Person Role:",
                           choices = c("All", unique(prizes$person_role)),
                           selected = "All"),
               hr(),
               checkboxInput("show_percentages", "Show Percentages", TRUE)
             ),
             mainPanel(
               tabsetPanel(
                 tabPanel("Distribution",
                          plotlyOutput("ethnicity_dist", height = "500px"),
                          br(),
                          p("This chart shows the distribution of awards across different ethnic groups.")
                 ),
                 tabPanel("By Prize Genre",
                          plotlyOutput("ethnicity_by_genre", height = "500px"),
                          br(),
                          p("Compare ethnic representation across different types of prizes.")
                 ),
                 tabPanel("Trends Over Time",
                          plotlyOutput("ethnicity_trend", height = "500px"),
                          br(),
                          p("Track how ethnic diversity in awards has changed over the years.")
                 )
               )
             )
           )
  ),
  
# Tab 3: Institutional analysis:
tabPanel("🧐Institutional Analysis",
           sidebarLayout(
             sidebarPanel(
               h4("Filters"),
               selectInput("inst_ethnicity", "Ethnicity:",
                           choices = c("All", sort(unique(prizes$ethnicity_macro))),
                           selected = "All"),
               sliderInput("top_n_institutions", "Show Top N Institutions:",
                           min = 5, max = 20, value = 10, step = 1),
               selectInput("inst_metric", "Metric:",
                           choices = c("Total Awards" = "total", 
                                       "Diversity Score" = "diversity"),
                           selected = "total")
             ),
             mainPanel(
               plotlyOutput("institution_plot", height = "600px"),
               br(),
               h4("Institutional Details"),
               DTOutput("institution_table")
             )
           )
  ),
  
# Tab 4: Prize analysis:
tabPanel("🤩Prize Analysis",
           fluidRow(
             column(4,
                    selectInput("prize_ethnicity_filter", "Filter by Ethnicity:",
                                choices = c("All", sort(unique(prizes$ethnicity_macro))),
                                selected = "All")
             ),
             column(4,
                    selectInput("prize_gender_filter", "Filter by Gender:",
                                choices = c("All", unique(prizes$gender)),
                                selected = "All")
             ),
             column(4,
                    selectInput("prize_uk_filter", "UK Residence:",
                                choices = c("All", "Yes", "No"),
                                selected = "All")
             )
           ),
           fluidRow(
             column(6,
                    h4("Awards by Prize Genre"),
                    plotlyOutput("prize_genre_plot", height = "400px")
             ),
             column(6,
                    h4("Awards by Person Role"),
                    plotlyOutput("person_role_plot", height = "400px")
             )
           ),
           fluidRow(
             column(12,
                    h4("Detailed Prize Information"),
                    DTOutput("prize_detail_table")
             )
           )
  ),
  
# Tab 5: Interactive Data Explorer:
tabPanel("😫Data Explorer",
           fluidRow(
             column(12,
                    h3("Filter and Explore the Full Dataset"),
                    p("Use the filters below to explore specific subsets of the data.")
             )
           ),
           fluidRow(
             column(3,
                    selectInput("explore_ethnicity", "Ethnicity:",
                                choices = c("All", sort(unique(prizes$ethnicity_macro))),
                                selected = "All", multiple = TRUE)
             ),
             column(3,
                    selectInput("explore_genre", "Prize Genre:",
                                choices = c("All", sort(unique(prizes$prize_genre))),
                                selected = "All", multiple = TRUE)
             ),
             column(3,
                    selectInput("explore_institution", "Institution:",
                                choices = c("All", sort(unique(prizes$degree_institution))),
                                selected = "All", multiple = TRUE)
             ),
             column(3,
                    selectInput("explore_year", "Year:",
                                choices = c("All", sort(unique(prizes$prize_year))),
                                selected = "All", multiple = TRUE)
             )
           ),
           fluidRow(
             column(12,
                    downloadButton("download_data", "Download Filtered Data"),
                    hr(),
                    DTOutput("explorer_table")
             )
           )
  ),
  
# Tab 6: Key Insights:
tabPanel("🤔Key Insights",
           fluidRow(
             column(12,
                    h2("Key Findings on Diversity in UK Literary Prizes"),
                    br()
             )
           ),
           fluidRow(
             column(6,
                    div(class = "well",
                        h4("Disparities Identified"),
                        tags$ul(
                          tags$li("Representation gaps exist across different ethnic groups"),
                          tags$li("Certain institutions show more diverse award recipients"),
                          tags$li("Award types vary in their ethnic diversity"),
                          tags$li("Trends over time show changing patterns in diversity")
                        )
                    ),
                    br(),
                    div(class = "well",
                        h4("Diversity Trends"),
                        plotlyOutput("insight_trend", height = "300px")
                    )
             ),
             column(6,
                    div(class = "well",
                        h4("Key Statistics"),
                        tags$ul(
                          tags$li(strong("Total Awards: "), textOutput("stat_total", inline = TRUE)),
                          tags$li(strong("Year Range: "), textOutput("stat_years", inline = TRUE)),
                          tags$li(strong("Prize Types: "), textOutput("stat_genres", inline = TRUE)),
                          tags$li(strong("Ethnic Groups: "), textOutput("stat_ethnicities", inline = TRUE)),
                          tags$li(strong("Winners: "), textOutput("stat_winners", inline = TRUE)),
                          tags$li(strong("UK Residents: "), textOutput("stat_uk", inline = TRUE))
                        )
                    ),
                    br(),
                    div(class = "well",
                        h4("Diversity Index by Genre"),
                        plotlyOutput("diversity_index", height = "300px")
                    )
             )
           ),
           fluidRow(
             column(12,
                    hr(),
                    h4("About This Analysis"),
                    p("This analysis examines diversity patterns in UK literary prizes from 1991-2022. 
          The data includes information about award recipients, their backgrounds, 
          the types of prizes, and demographic information."),
                    p(strong("Data Source:"), "TidyTuesday 2025-10-28 - UK Literary Prizes"),
                    p(strong("Dataset:"), "952 awards across multiple literary prizes including Booker Prize, 
          James Tait Black Prize, Costa Awards, and others.")
             )
           )
  )
)

# Define Server:
server <- function(input, output, session) {
  
  # Overview - Statistics
  output$total_prizes_text <- renderText({
    as.character(nrow(prizes))
  })
  
  output$total_institutions_text <- renderText({
    as.character(length(unique(prizes$degree_institution)))
  })
  
  output$total_genres_text <- renderText({
    as.character(length(unique(prizes$prize_genre)))
  })
  
  output$year_range_text <- renderText({
    paste(min(prizes$prize_year), "-", max(prizes$prize_year))
  })
  
  output$total_prize_names_text <- renderText({
    as.character(length(unique(prizes$prize_name)))
  })
  
  output$total_prize_aliases_text <- renderText({
    as.character(length(unique(prizes$prize_alias)))
  })
  
  output$total_ethnicities_text <- renderText({
    as.character(length(unique(prizes$ethnicity_macro)))
  })
  
# Overview visualizations
output$ethnicity_overview <- renderPlotly({
    eth_counts <- prizes %>%
      count(ethnicity_macro) %>%
      arrange(desc(n))
    
    plot_ly(eth_counts, x = ~reorder(ethnicity_macro, n), y = ~n, type = 'bar',
            marker = list(color = ~n, colorscale = 'Viridis')) %>%
      layout(title = "Awards by Ethnicity",
             xaxis = list(title = "Ethnicity", tickangle = -45),
             yaxis = list(title = "Number of Awards"),
             margin = list(b = 120))
  })
  
output$year_trend <- renderPlotly({
    year_counts <- prizes %>%
      count(prize_year) %>%
      arrange(prize_year)
    
    plot_ly(year_counts, x = ~prize_year, y = ~n, type = 'scatter', mode = 'lines+markers',
            line = list(color = '#3498db', width = 3),
            marker = list(size = 8, color = '#e74c3c')) %>%
      layout(title = "Awards Over Time",
             xaxis = list(title = "Year"),
             yaxis = list(title = "Number of Awards"))
  })
  
output$summary_table <- renderDT({
    summary_data <- prizes %>%
      count(ethnicity_macro, person_role, uk_residence_display) %>%
      arrange(desc(n))
    
    datatable(summary_data, 
              options = list(pageLength = 10),
              colnames = c("Ethnicity", "Role", "UK Residence", "Count"))
  })
  
# Ethnicity:
filtered_ethnicity_data <- reactive({
    data <- prizes
    if (input$eth_year_filter != "All Years") {
      year_ranges <- list(
        "1991-2000" = c(1991, 2000),
        "2001-2010" = c(2001, 2010),
        "2011-2022" = c(2011, 2022)
      )
      range <- year_ranges[[input$eth_year_filter]]
      data <- data %>% filter(prize_year >= range[1] & prize_year <= range[2])
    }
    if (input$eth_genre_filter != "All") {
      data <- data %>% filter(prize_genre == input$eth_genre_filter)
    }
    if (input$eth_role_filter != "All") {
      data <- data %>% filter(person_role == input$eth_role_filter)
    }
    
    data
  })
  
  output$ethnicity_dist <- renderPlotly({
    data <- filtered_ethnicity_data() %>%
      count(ethnicity_macro) %>%
      arrange(desc(n))
    
    if (input$show_percentages) {
      data <- data %>%
        mutate(percentage = n / sum(n) * 100,
               label = paste0(n, " (", round(percentage, 1), "%)"))
    } else {
      data <- data %>%
        mutate(label = as.character(n))
    }
    
    plot_ly(data, labels = ~ethnicity_macro, values = ~n, type = 'pie',
            textinfo = 'label+percent') %>%
      layout(title = "Ethnic Distribution of Awards")
  })
  
output$ethnicity_by_genre <- renderPlotly({
    data <- filtered_ethnicity_data() %>%
      count(ethnicity_macro, prize_genre) %>%
      arrange(prize_genre, desc(n))
    
    plot_ly(data, x = ~prize_genre, y = ~n, color = ~ethnicity_macro, type = 'bar') %>%
      layout(title = "Awards by Ethnicity and Genre",
             xaxis = list(title = "Prize Genre", tickangle = -45),
             yaxis = list(title = "Number of Awards"),
             barmode = 'stack',
             margin = list(b = 120))
  })
  
output$ethnicity_trend <- renderPlotly({
    data <- filtered_ethnicity_data() %>%
      count(prize_year, ethnicity_macro) %>%
      arrange(prize_year)
    
    plot_ly(data, x = ~prize_year, y = ~n, color = ~ethnicity_macro, 
            type = 'scatter', mode = 'lines+markers') %>%
      layout(title = "Ethnic Diversity Trends Over Time",
             xaxis = list(title = "Year"),
             yaxis = list(title = "Number of Awards"))
  })
  
# Institutional:
output$institution_plot <- renderPlotly({
    data <- prizes %>%
      filter(degree_institution != "none" & degree_institution != "unknown")
    
    if (input$inst_ethnicity != "All") {
      data <- data %>% filter(ethnicity_macro == input$inst_ethnicity)
    }
    
    if (input$inst_metric == "total") {
      inst_data <- data %>%
        count(degree_institution) %>%
        arrange(desc(n)) %>%
        head(input$top_n_institutions)
      
      plot_ly(inst_data, y = ~reorder(degree_institution, n), x = ~n, type = 'bar',
              orientation = 'h',
              marker = list(color = ~n, colorscale = 'Blues')) %>%
        layout(title = "Top Institutions by Total Awards",
               yaxis = list(title = ""),
               xaxis = list(title = "Number of Awards"),
               margin = list(l = 200))
    } else {
      inst_data <- data %>%
        group_by(degree_institution) %>%
        summarise(
          total = n(),
          diversity_score = 1 - sum((table(ethnicity_macro)/n())^2),
          .groups = 'drop'
        ) %>%
        filter(total >= 3) %>%  
        arrange(desc(diversity_score)) %>%
        head(input$top_n_institutions)
      
      plot_ly(inst_data, y = ~reorder(degree_institution, diversity_score), 
              x = ~diversity_score, type = 'bar',
              orientation = 'h',
              marker = list(color = ~diversity_score, colorscale = 'Greens')) %>%
        layout(title = "Top Institutions by Diversity Score",
               yaxis = list(title = ""),
               xaxis = list(title = "Diversity Score (0-1)"),
               margin = list(l = 200))
    }
  })
  
  output$institution_table <- renderDT({
    data <- prizes %>%
      filter(degree_institution != "none" & degree_institution != "unknown")
    
    if (input$inst_ethnicity != "All") {
      data <- data %>% filter(ethnicity_macro == input$inst_ethnicity)
    }
    
    inst_summary <- data %>%
      group_by(degree_institution) %>%
      summarise(
        Total_Awards = n(),
        Ethnicities = n_distinct(ethnicity_macro),
        Prize_Types = n_distinct(prize_genre),
        .groups = 'drop'
      ) %>%
      arrange(desc(Total_Awards)) %>%
      head(input$top_n_institutions)
    
    datatable(inst_summary, options = list(pageLength = 10))
  })
  
# Prize Analysis Tab
  filtered_prize_data <- reactive({
    data <- prizes
    
    if (input$prize_ethnicity_filter != "All") {
      data <- data %>% filter(ethnicity_macro == input$prize_ethnicity_filter)
    }
    
    if (input$prize_gender_filter != "All") {
      data <- data %>% filter(gender == input$prize_gender_filter)
    }
    
    if (input$prize_uk_filter != "All") {
      uk_value <- (input$prize_uk_filter == "Yes")
      data <- data %>% filter(uk_residence == uk_value)
    }
    
    data
  })
  
  output$prize_genre_plot <- renderPlotly({
    data <- filtered_prize_data() %>%
      count(prize_genre) %>%
      arrange(desc(n))
    
    plot_ly(data, x = ~reorder(prize_genre, n), y = ~n, type = 'bar',
            marker = list(color = '#3498db')) %>%
      layout(xaxis = list(title = "", tickangle = -45),
             yaxis = list(title = "Number of Awards"),
             margin = list(b = 120))
  })
  
  output$person_role_plot <- renderPlotly({
    data <- filtered_prize_data() %>%
      count(person_role) %>%
      arrange(desc(n))
    
    plot_ly(data, labels = ~person_role, values = ~n, type = 'pie') %>%
      layout(showlegend = TRUE)
  })
  
  output$prize_detail_table <- renderDT({
    data <- filtered_prize_data() %>%
      select(prize_name, prize_genre, ethnicity_macro, gender, 
             degree_institution, prize_year, book_title) %>%
      arrange(desc(prize_year))
    
    datatable(data, 
              options = list(pageLength = 15, scrollX = TRUE),
              filter = 'top')
  })
  
# Data Explorer:
explorer_filtered_data <- reactive({
    data <- prizes
    
    if (!"All" %in% input$explore_ethnicity && length(input$explore_ethnicity) > 0) {
      data <- data %>% filter(ethnicity_macro %in% input$explore_ethnicity)
    }
    
    if (!"All" %in% input$explore_genre && length(input$explore_genre) > 0) {
      data <- data %>% filter(prize_genre %in% input$explore_genre)
    }
    
    if (!"All" %in% input$explore_institution && length(input$explore_institution) > 0) {
      data <- data %>% filter(degree_institution %in% input$explore_institution)
    }
    
    if (!"All" %in% input$explore_year && length(input$explore_year) > 0) {
      data <- data %>% filter(prize_year %in% as.numeric(input$explore_year))
    }
    
    data
  })
  
output$explorer_table <- renderDT({
    datatable(explorer_filtered_data(), 
              options = list(pageLength = 25, scrollX = TRUE),
              filter = 'top')
  })
  
output$download_data <- downloadHandler(
    filename = function() {
      paste("literary_prizes_filtered_", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(explorer_filtered_data(), file, row.names = FALSE)
    }
  )
  
# Key Insights:
output$insight_trend <- renderPlotly({
    diversity_by_year <- prizes %>%
      group_by(prize_year) %>%
      summarise(
        diversity_score = 1 - sum((table(ethnicity_macro)/n())^2),
        .groups = 'drop'
      )
    
    plot_ly(diversity_by_year, x = ~prize_year, y = ~diversity_score, 
            type = 'scatter', mode = 'lines+markers',
            line = list(color = '#2ecc71', width = 3),
            marker = list(size = 8)) %>%
      layout(title = "Diversity Score Over Time",
             xaxis = list(title = "Year"),
             yaxis = list(title = "Diversity Score", range = c(0, 1)))
  })
  
output$diversity_index <- renderPlotly({
    diversity_by_genre <- prizes %>%
      group_by(prize_genre) %>%
      summarise(
        diversity_score = 1 - sum((table(ethnicity_macro)/n())^2),
        .groups = 'drop'
      ) %>%
      arrange(desc(diversity_score))
    
    plot_ly(diversity_by_genre, y = ~reorder(prize_genre, diversity_score), 
            x = ~diversity_score, type = 'bar', orientation = 'h',
            marker = list(color = ~diversity_score, 
                          colorscale = list(c(0, 'red'), c(1, 'green')))) %>%
      layout(title = "Diversity by Prize Genre",
             yaxis = list(title = ""),
             xaxis = list(title = "Diversity Score", range = c(0, 1)))
  })
  
# Key Statistics outputs:
  output$stat_total <- renderText({
    as.character(nrow(prizes))
  })
  
  output$stat_years <- renderText({
    paste(min(prizes$prize_year), "-", max(prizes$prize_year))
  })
  
  output$stat_genres <- renderText({
    as.character(length(unique(prizes$prize_genre)))
  })
  
  output$stat_ethnicities <- renderText({
    as.character(length(unique(prizes$ethnicity_macro)))
  })
  
  output$stat_winners <- renderText({
    winners <- prizes %>% filter(person_role == "winner")
    as.character(nrow(winners))
  })
  
  output$stat_uk <- renderText({
    uk_residents <- prizes %>% filter(uk_residence == TRUE)
    paste0(nrow(uk_residents), " (", round(nrow(uk_residents)/nrow(prizes)*100, 1), "%)")
  })
}

# Run the app
shinyApp(ui = ui, server = server)
