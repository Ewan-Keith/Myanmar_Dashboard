#### load necessary packages ####
library(shiny)
library(rCharts) # used for interactive charts, not hosted on CRAN so must be installed from github, see http://ramnathv.github.io/rCharts/
library(dplyr) # used for data handling
library(DT) # used for interactive tables
library(shinydashboard) # used for the 'boxes' around several plots

#### read and prepare data ####

full_data <- read.csv('myanmar dash data.csv', stringsAsFactors = FALSE)
income_data <- filter(full_data, flow == 'income')
expenditure_data <- filter(full_data, flow == 'expenditure')

#### set income budget entity options for later use ####

income_budget_entity_table <- unique(income_data$entity)
income_budget_item_table <- unique(income_data$budget_item)

#### preset Disclaimer Text for use on each tab ####

disclaimer <- tagList(
  
  p(""),
  
  p(""),
  
  p(
    "Figures presented are budgeted amounts published in Myanmar's 2013-14 state and region budget
    laws. Because numbers represent budgeted amounts rather than actuals and should be interpreted
    with caution. Users interested in a more detailed treatment of the topic are directed towards",
    a("State and Region Public Finances in Myanmar",
      href = "http://asiafoundation.org/publications/pdf/1544"),
    class = 'disclaim'
  ), 
  
  tags$head(includeCSS("styles.css"))
  
  )

#### setup a toolbar shiny page ####

shinyUI(
  navbarPage(
    "Myanmar Budget Dashboard", id = "nav",


#### Regional Summary Tab #####
    
    tabPanel(
      "State and Region Budget Summary",
      
      column(width = 3,
             wellPanel(
               selectInput(
                 'region_summary_select', 'Select Region or State to View',
                 unique(as.character(full_data$region)),
                 width = 375
               ),
               
               p(
                 "This page provides a summary of income sources and major
                 expenditure items for individual states and regions for the
                 2013-14 financial year by classification (in millions of kyat).
                 Income source categories have been based on accounting classifications
                 used in published budgets."
               ),
               
               hr()
               
               )),
      
      column(
        align = "center", width = 9,
        
        showOutput("summary_pie",  "highcharts"),
        
        fluidRow(box(plotOutput("top_income_items")),
                 
                 box(plotOutput("top_exp_items"))),
        
        
        hr(),
        
        fluidRow(disclaimer)
      )
      ),

#### Budget Item Breakdown #####
    tabPanel("Budget Item Breakdown",
             fluidPage(
               column(3,
                      wellPanel(
                        selectInput(
                          'item_select', 'Select Budget item', income_budget_item_table,
                          width = 375
                        ),
                        
                        p(
                          "This page provides summaries of state and region budgeted expenditure
                          and income for the 2013-14 financial year by classification (in millions of kyat)."
                        ),
                        
                        hr()
                        
                        )),
               
               column(9,
                      fluidRow(showOutput(
                        "item_income_chart", "nvd3"
                      )),
                      
                      
                      br(),
                      
                      
                      fluidRow(
                        showOutput("item_expenditure_chart", "nvd3")
                      ),
                      
                      br(),
                      br(),
                      
                      fluidRow(disclaimer)
                      
                      )
             )),

#### Data Table #####
    tabPanel(
      "Data Table",
      
      fluidRow(
        column(4,
               wellPanel(
                 h5(strong("Myanmar Budget Data Table")),
                 p(
                   "This page allows for the 2013-14 state and region budget data to be viewed in greater detail.
                   Data can also be downloaded in full or as specified by the chosen filters."
                 )
                 )),
        
        column(
          4,
          selectInput("table_region",
                      "State or Region:",
                      c("All",
                        unique(
                          as.character(full_data$region)
                        ))),
          
          selectInput("table_flow",
                      "Expenditure or Revenue:",
                      c("All",
                        unique(
                          as.character(full_data$flow)
                        )))
        ),
        column(
          4,
          selectInput("table_budget_item",
                      "Subnational Entity",
                      c("All",
                        unique(
                          as.character(full_data$budget_item)
                        ))),
          
          selectInput("table_entity",
                      "Budget Category",
                      c("All",
                        unique(
                          as.character(full_data$entity)
                        )))
        )
               ),
      
      hr(),
      
      # add data table
      dataTableOutput("budget_table"),
      
      # add filtered and full download buttons
      downloadButton('download_table_data', 'Download table budget data'),
      downloadButton('download_full_data', 'Download full budget data'),
      
      hr(),
      
      disclaimer
    )
)                   
)