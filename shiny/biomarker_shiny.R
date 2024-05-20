library(shiny)
library(RSQLite)
library(DBI)
library(DT)

df <- read.csv('~/Downloads/biomarker_data.csv', sep=',', header=TRUE)
con <- dbConnect(RSQLite::SQLite(), ":memory:")
dbWriteTable(con, "biomarker", df)
column_names <- dbListFields(con, "biomarker")

ui <- fluidPage(
  title="Biological Biomarker Database",
  sidebarLayout(
    sidebarPanel(
      style = "color: #FF007F;",
      checkboxGroupInput("columns", "Select Table Columns to View:", choices = column_names),
      actionButton("load", "Load Data", style = "color: #32127A; background-color: white; border-color: #00FF80;")
    ),
    mainPanel(
      DTOutput("table_results")
    )
  )
)

server <- function(input, output, session){
  observeEvent(input$load, {
    req(input$load)
    columns <- paste(input$columns, collapse=',')
    sql_query <- paste0("SELECT ", columns, " FROM biomarker")
    data_output <- dbGetQuery(con, sql_query)
    output$table_results <- renderDT({
      datatable(data_output) %>%
        formatStyle(names(data_output), color="#B81466")
  })
  })
  session$onSessionEnded(function(){
    dbDisconnect(con)
  })
}

shinyApp(ui, server)
