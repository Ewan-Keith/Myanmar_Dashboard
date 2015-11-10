# load necessary packages
library(shiny) # underlies the whole application
library(dplyr) # used for data handling
library(tidyr) # used for tidying some data for presentation
library(rCharts) # used for interactive charts, not hosted on CRAN so must be installed from github, see http://ramnathv.github.io/rCharts/
library(DT) # used for interactive tables

# read in data, done outside Server command for faster running
full_data <- read.csv('myanmar dash data.csv', stringsAsFactors = FALSE)
income_data <- filter(full_data, flow == 'income')
expenditure_data <- filter(full_data, flow == 'expenditure')

#### server code ####

shinyServer(function(input, output) {
  ## see the bottom of ShinyServer() function for definitions of all functions used 
  
#### Flow Breakdown Code ####
  
  output$FB_income_chart <- renderChart2({
    FB_income_data <- FB_data_prep()(income_data)   # see https://github.com/rstudio/shiny/issues/858 for why two sets of brackets are used
    FB_Chart(FB_income_data, "Income")
    })
  
  output$FB_expenditure_chart <- renderChart2({
    FB_expenditure_data <- FB_data_prep()(expenditure_data)   
    FB_Chart(FB_expenditure_data, "Expenditure")
    })
  
  
#### Data Table Code ####  
  table_data <- reactive({
    
    # switches set appropriate values for 'All' selections
    region_switched <- switch(input$table_region,
                              All = unique(as.character(full_data$region)),
                              input$table_region
                              )
    
    flow_switched <- switch(input$table_flow,
                              All = unique(as.character(full_data$flow)),
                              input$table_flow
                              )
    
    item_switched <- switch(input$table_budget_item,
                            All = unique(as.character(full_data$budget_item)),
                            input$table_budget_item
                            )
    
    entity_switched <- switch(input$table_entity,
                              All = unique(as.character(full_data$entity)),
                              input$table_entity
                              )
    
    # filter data for the table based on user input
    filter(full_data,
                         entity %in% entity_switched,
                         region %in% region_switched,
                         flow %in% flow_switched,
                         budget_item %in% item_switched
                         )
  })
    
    output$budget_table <- renderDataTable({
      datatable(table_data(), options = list(searching = FALSE))
  })
  
  #### Download Button Code ####  
  output$download_table_data <- downloadHandler(
    filename = 'Myanmar Budget Data (Filtered).csv',
    content = function(file) {
      write.csv(table_data(), file)
    }
  )
  
  output$download_full_data <- downloadHandler(
    filename = 'Myanmar Budget Data (Full).csv',
    content = function(file) {
      write.csv(full_data, file)
    }
  )
  
#### set up functions used multiple times above ####
  
  # prep data for Flow Breakdown Tab
  FB_data_prep <- reactive({
    function(unformatted_data){
      
      unformatted_data %>% 
        filter(entity == input$entity_select) %>% 
        group_by(region, source) %>% 
        summarise(value = sum(value)) %>%
        ungroup() %>% 
        complete(region, source, fill = list(value = 0))
      }
    })
  
  # plot charts for Flow Breakdown Tab
  
  FB_Chart <- function(chart_data, Title){
  
    FB_rchart <- nPlot(value ~ region, group = 'source', 
                     data = chart_data, 
                     type = 'multiBarChart')
  
    FB_rchart$chart(reduceXTicks = FALSE)
    FB_rchart$xAxis(rotateLabels=-45)
    FB_rchart$xAxis(axisLabel = 'Region')
    FB_rchart$templates$script <- "http://timelyportfolio.github.io/rCharts_nvd3_templates/chartWithTitle.html"
    FB_rchart$set(title = Title)
    FB_rchart$params$width <- 1000
    FB_rchart$params$height <- 300
    FB_rchart$chart(stacked = TRUE)
  
    return(FB_rchart)
    }
  
  
  
})