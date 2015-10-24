# load necessary packages
library(shiny) # underlies the whole application
library(dplyr) # used for data handling
library(rCharts) # used for interactive charts, not hosted on CRAN so must be installed from github, see http://ramnathv.github.io/rCharts/
library(DT) # used for interactive tables

# read in data, done outside Server command for faster running
full_data <- read.csv('myanmar dash data.csv', stringsAsFactors = FALSE)
income_data <- filter(full_data, flow == 'income')
expenditure_data <- filter(full_data, flow == 'expenditure')


shinyServer(function(input, output) {
  
  #### Flow Breakdown Code ####
  
  output$FB_income_chart <- renderChart2({
    
    FB_income_data <- filter(income_data, entity == input$entity_select)
    
    FB_rchart <- nPlot(value ~ region, group = 'source', 
                       data = FB_income_data, 
                       type = 'multiBarChart')
    
    FB_rchart$chart(reduceXTicks = FALSE)
    FB_rchart$xAxis(rotateLabels=-45)
    FB_rchart$xAxis(axisLabel = 'Region')
    FB_rchart$templates$script <- "http://timelyportfolio.github.io/rCharts_nvd3_templates/chartWithTitle.html"
    FB_rchart$set(title = "Income")
    FB_rchart$params$width <- 1000
    FB_rchart$params$height <- 300
    
    return(FB_rchart)
  })
  
  output$FB_expenditure_chart <- renderChart2({
    
    FB_expenditure_data <- filter(expenditure_data, entity == input$entity_select)
    
    FB_rchart <- nPlot(value ~ region, group = 'source', 
                       data = FB_expenditure_data, 
                       type = 'multiBarChart')
    
    FB_rchart$chart(reduceXTicks = FALSE)
    FB_rchart$xAxis(rotateLabels=-45)
    FB_rchart$xAxis(axisLabel = 'Region')
    FB_rchart$templates$script <- "http://timelyportfolio.github.io/rCharts_nvd3_templates/chartWithTitle.html"
    FB_rchart$set(title = "Expenditure")
    FB_rchart$params$width <- 1000
    FB_rchart$params$height <- 300
    
    return(FB_rchart)
  })
  
  
  #### Data Table Code ####  
  output$budget_table <- renderDataTable({
    datatable(full_data)
  })
  
  #### Download Button Code ####  
  output$download_data <- downloadHandler(
    filename = 'Myanmar Budget Data.csv',
    content = function(file) {
      write.csv(full_data, file)
    }
  )
  
})