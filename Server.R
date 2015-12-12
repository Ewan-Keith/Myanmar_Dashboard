#### load necessary packages ####
library(shiny) # underlies the whole application
library(dplyr) # used for data handling
library(tidyr) # used for tidying some data for presentation
library(rCharts) # used for interactive charts, not hosted on CRAN so must be installed from github, see http://ramnathv.github.io/rCharts/
library(DT) # used for interactive tables
library(ggplot2)
library(ggthemes)

#### Define Region/State allocation function for use later ####
region_state <- function(raw_data){
  
  for(i in 1:nrow(raw_data)){
    
    if(raw_data[i,"region"] == "Ayeyawady"){
      raw_data[i,"region"] <- "Ayeyawady Region"
    }
    
    if(raw_data[i,"region"] == "Bago"){
      raw_data[i,"region"] <- "Bago Region"
    }
    
    
    if(raw_data[i,"region"] == "Chin"){
      raw_data[i,"region"] <- "Chin State"
    }
    
    if(raw_data[i,"region"] == "Kachin"){
      raw_data[i,"region"] <- "Kachin State"
    }
    
    if(raw_data[i,"region"] == "Kayah"){
      raw_data[i,"region"] <- "Kayah State"
    }
    
    if(raw_data[i,"region"] == "Kayin"){
      raw_data[i,"region"] <- "Kayin State"
    }
    
    if(raw_data[i,"region"] == "Magway"){
      raw_data[i,"region"] <- "Magway Region"
    }
    
    if(raw_data[i,"region"] == "Mandalay"){
      raw_data[i,"region"] <- "Mandalay Region"
    }
    
    if(raw_data[i,"region"] == "Mon"){
      raw_data[i,"region"] <- "Mon State"
    }
    
    if(raw_data[i,"region"] == "Rakhine"){
      raw_data[i,"region"] <- "Rakhine State"
    }
    
    if(raw_data[i,"region"] == "Sagaing"){
      raw_data[i,"region"] <- "Sagaing Region"
    }
    
    if(raw_data[i,"region"] == "Shan"){
      raw_data[i,"region"] <- "Shan State"
    }
    
    if(raw_data[i,"region"] == "Tanintharyi"){
      raw_data[i,"region"] <- "Tanintharyi Region"
    }
    
    if(raw_data[i,"region"] == "Yangon"){
      raw_data[i,"region"] <- "Yangon Region"
    }
    
    
    
    
  }
  raw_data
}

#### read in and prep data ####
full_data <- read.csv('myanmar dash data.csv', stringsAsFactors = FALSE)
income_data <- filter(full_data, flow == 'income')
expenditure_data <- filter(full_data, flow == 'expenditure')

#### server code ####

shinyServer(function(input, output, session) {
  ## see the bottom of ShinyServer() function for definitions of all reactive functions used 

#### Region Budget Summary Code ####
  
  ## pie chart function
  output$summary_pie <- renderChart2({
    
    # prep pie chart data
    pie_data <- select(income_data, region, source, value) %>%
      complete(region, source, fill = list(value = 0)) %>%
      group_by(source) %>%
      filter(region %in% input$region_summary_select) %>%
      summarise(value = sum(value))
    
    # produce Rcharts pie chart
    income_pie <- hPlot(
      x = "source",
      y = "value",
      data = pie_data,
      type = "pie",
      title = "Region/State Income by Source",
      subtitle = input$region_summary_select
    )
    
    # set pie chart tool tip options
    income_pie$tooltip(useHTML = T,
                       formatter = "#! function() { return Highcharts.numberFormat(this.y,0) + 'm Kyat from ' + this.key ; } !#")
    
    # return pie chart object
    income_pie
  })
  
  ## Top ten income barchart function
  output$top_income_items <- renderPlot({
    
    # prepare top ten income barchart data
    top_10 <- income_data  %>%
      filter(region == input$region_summary_select) %>%
      group_by(region, budget_item)  %>%
      summarise(value = sum(value))  %>%
      top_n(value, n = 10)  %>%
      arrange(desc(value))
    
    # produce ggplot top ten income barchart
    top_plot <- ggplot(top_10,
                       aes(
                         x = reorder(budget_item, value),
                         y = value,
                         fill = region
                       )) +
      geom_bar(stat = 'identity') +
      coord_flip() +
      theme_hc() +
      ggtitle(paste("Top 10 Income Budget Items in", input$region_summary_select)) +
      scale_fill_manual(values = c("#492970", "#6789483")) +
      labs(x = NULL, y = "Million Kyat") +
      theme(
        axis.text.x = element_text(colour = "black"),
        axis.text.y = element_text(colour = "black"),
        legend.position = "none"
      )
    
    # return top ten income barchart
    print(top_plot)
    
  })
  
  ## Top ten expenditure barchart function
  output$top_exp_items <- renderPlot({
    
    # prepare top ten expenditure barchart data
    top_10 <- expenditure_data  %>%
      filter(region == input$region_summary_select) %>%
      group_by(region, budget_item)  %>%
      summarise(value = sum(value))  %>%
      top_n(value, n = 10)  %>%
      arrange(desc(value))
    
    # produce ggplot top ten expenditure barchart
    top_plot <- ggplot(top_10,
                       aes(
                         x = reorder(budget_item, value),
                         y = value,
                         fill = region
                       )) +
      geom_bar(stat = 'identity') +
      coord_flip() +
      theme_hc() +
      ggtitle(paste(
        "Top 10 Expenditure Budget Items in", input$region_summary_select
      )) +
      scale_fill_manual(values = c("#492970", "#6789483")) +
      labs(x = NULL, y = "Million Kyat") +
      theme(
        axis.text.x = element_text(colour = "black"),
        axis.text.y = element_text(colour = "black"),
        legend.position = "none"
      )
    
    #return top ten expenditure barchart
    print(top_plot)
    
  })
  

#### Budget Item Code ####
  
  ## produce NVD3 income chart (function code at bottom of app)
  output$item_income_chart <- renderChart2({
    
    # prepare NVD3 income chart data
    item_income_data <-
      budget_item_data_prep()(income_data)   # see https://github.com/rstudio/shiny/issues/858 for why two sets of brackets are used
    
    # produce NVD3 income Chart
    budget_item_Chart(item_income_data, "Income")
    
  })
  
  ## produce NVD3 expenditure chart (function code at bottom of app)
  output$item_expenditure_chart <- renderChart2({
    
    # prepare NVD3 expenditure chart data
    item_expenditure_data <-
      budget_item_data_prep()(expenditure_data)
    
    # produce NVD3 expenditure Chart
    budget_item_Chart(item_expenditure_data, "Expenditure")
    
  })

#### Data Table Code ####
  
  ## Select table data in response to user specifications
  table_data <- reactive({
    
    # switches set appropriate values for 'All' selections
    region_switched <- switch(input$table_region,
                              All = unique(as.character(full_data$region)),
                              input$table_region)
    
    flow_switched <- switch(input$table_flow,
                            All = unique(as.character(full_data$flow)),
                            input$table_flow)
    
    item_switched <- switch(input$table_budget_item,
                            All = unique(as.character(full_data$budget_item)),
                            input$table_budget_item)
    
    entity_switched <- switch(input$table_entity,
                              All = unique(as.character(full_data$entity)),
                              input$table_entity)
    
    # filter data for the table based on user input
    temp_table_data <- filter(
      full_data,
      entity %in% entity_switched,
      region %in% region_switched,
      flow %in% flow_switched,
      budget_item %in% item_switched
    )
    
    # create identical 'data source' variable for all entries
    temp_table_data$Data_Source <-
      rep("2013-14 published state and region budget laws", nrow(temp_table_data))
    
    # add the appropriate region/state specification to each area in the tables
    temp_table_data <- region_state(temp_table_data)
    
    # return table data
    temp_table_data
  })
    
  ## produce DataTable object from selected data
  output$budget_table <- renderDataTable({
    
    datatable(table_data(), options = list(searching = FALSE))
    
  })

#### Download Button Code ####  
  
  ## use selected table data for the appropriate download button
  output$download_table_data <- downloadHandler(
    
    filename = 'Myanmar Budget Data (Filtered).csv',
    content = function(file) {
      write.csv(table_data(), file)
    }
  )
    
  ## prepare full data frame appropriate for download
  
  # add appropriate area title (region or date)
  full_table_data <- region_state(full_data)
  
  # add data source variable
  full_table_data$Data_Source <- rep("2013-14 published state and region budget laws", nrow(full_table_data))
  
  ## Produce full data download button
  output$download_full_data <- downloadHandler(
    filename = 'Myanmar Budget Data (Full).csv',
    content = function(file) {
      write.csv(full_table_data, file)
    }
  )

#### set up reactive functions used multiple times above ####
  
  ## prep data for budget_item NVD3 Barcharts
  budget_item_data_prep <- reactive({
    
    # function to return formatted data
    function(unformatted_data) {
      
      unformatted_data %>%
        filter(budget_item == input$item_select) %>%
        group_by(region, source) %>%
        summarise(value = sum(value)) %>%
        ungroup() %>%
        complete(region, source, fill = list(value = 0))
      
    }
  })
  
  ## plot NVD3 barcharts for budget_item Tab
  
  budget_item_Chart <- function(chart_data, Title) {
    item_rchart <- nPlot(value ~ region, group = 'source',
                         data = chart_data,
                         type = 'multiBarChart')
    
    item_rchart$chart(reduceXTicks = FALSE)
    item_rchart$xAxis(rotateLabels = -45)
    item_rchart$xAxis(axisLabel = 'Region')
    item_rchart$yAxis(axisLabel = 'Kyat (Millions)', width = 61)
    item_rchart$templates$script <-
      "http://timelyportfolio.github.io/rCharts_nvd3_templates/chartWithTitle.html"
    item_rchart$set(title = Title)
    item_rchart$params$width <- 1000
    item_rchart$params$height <- 310
    item_rchart$chart(stacked = TRUE)
    item_rchart$chart(margin = list(left = 75,bottom = 75))
    
    item_rchart$chart(tooltipContent = "#! function(key, x, y){
                      return '<h3>' + key + '</h3>' +
                      '<p>' + y + 'm Kyat spent in ' + x + '</p>'
  } !#")
    
    return(item_rchart)
}
  
})