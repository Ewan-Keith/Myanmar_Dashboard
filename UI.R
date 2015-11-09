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
                   tabPanel("Front Page",
                            
                            div(class="outer",
                                
                                img(src="Myanmar_Flag.png", width="100%", height="100%"),
                                
                                div(class="inner",
                                    tags$head(
                                      includeCSS("styles.css")
                                      )
                                )
                            )
                            
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
                            
                            fluidRow(
                              column(4, 
                                     selectInput("table_region", 
                                                 "State or Region:", 
                                                 c("All", 
                                                   unique(as.character(full_data$region))))
                              ),
                              
                              column(4, 
                                     selectInput("table_flow", 
                                                 "Expenditure or Revenue:", 
                                                 c("All", 
                                                   unique(as.character(full_data$flow))))
                              ),
                              column(4, 
                                     selectInput("table_budget_item", 
                                                 "Subnational Entity", 
                                                 c("All", 
                                                   unique(as.character(full_data$budget_item))))
                              ),        
                              column(4, 
                                     selectInput("table_entity", 
                                                 "Budget Category", 
                                                 c("All",  
                                                   unique(as.character(full_data$entity))))
                              )        
                            ),
                            
                            
                            # add data table
                            dataTableOutput("budget_table"),
                            
                            # add filtered and full download buttons
                            downloadButton('download_table_data', 'Download table budget data'),
                            downloadButton('download_full_data', 'Download full budget data')
                   )
)                   
)