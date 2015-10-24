library(shiny)
library(rCharts) # used for interactive charts, not hosted on CRAN so must be installed from github, see http://ramnathv.github.io/rCharts/
library(dplyr) # used for data handling
library(DT) # used for interactive tables

full_data <- read.csv('myanmar dash data.csv', stringsAsFactors = FALSE)
income_data <- filter(full_data, flow == 'income')
expenditure_data <- filter(full_data, flow == 'expenditure')

# set income budget entity options
income_budget_entity_table <- unique(income_data$entity)



## page type has a toolbar at the top for different pages
shinyUI(navbarPage("Myanmar Budget Dashboard", id = "nav",
                   
                   #### Front Page ####                       
                   tabPanel("Front Page"        
                            
                   ),
                   
                   #### Regional Summary #####
                   tabPanel("Regional Summary"
                            
                   ),
                   
                   #### Flow Breakdown #####
                   tabPanel("Flow Breakdown",
                            fluidPage(
                              column(2, 
                              selectInput('entity_select', 'Select Budget Entity', income_budget_entity_table,
                                          width = 375)),
                             
                              
                              fluidRow(
                                showOutput("FB_income_chart", "nvd3")
                              ),
                              
                              hr(),
                            
                            fluidRow(
                              showOutput("FB_expenditure_chart", "nvd3")
                            )
                   )
                   ),
                   
                   #### Budget Item Breakdown #####
                   tabPanel("Budget Item Breakdown"
                            
                   ),
                   
                   #### Indepth Revenue Analysis #####
                   tabPanel("Indepth Revenue Analysis"
                            
                   ),
                   
                   #### Data Table #####
                   tabPanel("Data Table",
                            # add data table
                            dataTableOutput("budget_table"),
                            
                            # add download button
                            downloadButton('download_data', 'Download full budget data')
                   )
)                   
)