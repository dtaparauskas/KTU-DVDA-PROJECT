library(shinydashboard)
library(shiny)
library(shinyjs)
library(tidyverse)
library(h2o)
library(tibble)
h2o.init()

loan_model <- h2o.loadModel("GBM_grid_1_AutoML_1_20231228_190523_model_9")

ui <- dashboardPage(
  dashboardHeader(
    title = "Bank Loan Evaluation Application",
    titleWidth = 250
  ),
  dashboardSidebar(
    sidebarMenu(
      id = "sidebar",
      menuItem("Inputs", tabName = "inputs", icon = icon("home")),
      menuItem("Results", tabName = "results", icon = icon("chart-line")),
      menuItem("Model Info", tabName = "model_info", icon = icon("info-circle"))
    )
  ),
  dashboardBody(
    useShinyjs(),
    tags$head(
      tags$style(HTML('
                    body, label, .navbar, .sidebar-menu {
                  font-family: "YourBrandFont", sans-serif;
                    }
              .red-background {
              background-color: red;
              }
              .green-background {
              background-color: green;
              }
              @keyframes blinker {
              20% {opacity: 0.5; }
              }
              .blink {
              animation: blinker 1s linear 1;
              }
              
  '))
    ),
    tabItems(
      tabItem(tabName = "inputs",
              fluidRow(
                column(6, numericInput("amount_current_loan", "Current Loan Amount", value = 0)),
                column(6, selectInput("term", "Term", choices = c("short", "long")))
              ),
              fluidRow(
                column(6, selectInput("credit_score", "Credit Score", choices = c("very_good", "good", "fair"))),
                column(6, textInput("loan_purpose", "Loan Purpose", placeholder = "Purpose of the loan", value = "buy_a_car"))
              ),
              fluidRow(
                column(6, numericInput("yearly_income", "Yearly Income", value = 0)),
                column(6, selectInput("home_ownership", "Home Ownership", choices = c("own", "rent", "mortgage")))
              ),
              fluidRow(
                column(6, numericInput("bankruptcies", "Bankruptcies", value = 0)),
                column(6, numericInput("years_current_job", "Years at Current Job", value = 0))
              ),
              fluidRow(
                column(6, numericInput("monthly_debt", "Monthly Debt", value = 0)),
                column(6, numericInput("years_credit_history", "Years of Credit History", value = 0))
              ),
              fluidRow(
                column(6, numericInput("months_since_last_delinquent", "Months Since Last Delinquent", value = 0)),
                column(6, numericInput("open_accounts", "Number of Open Accounts", value = 0))
              ),
              fluidRow(
                column(6, numericInput("credit_problems", "Number of Credit Problems", value = 0)),
                column(6, numericInput("credit_balance", "Credit Balance", value = 0))
              ),
              fluidRow(
                column(6, numericInput("max_open_credit", "Maximum Open Credit", value = 0)),
                column(6, actionButton("submit", "Evaluate", class = "btn-primary"))
              )
      ),
      tabItem(tabName = "results",
              fluidRow(
                box(title = "Input Data", status = "warning", solidHeader = T, width = 12,
                    div(class = "table-responsive",
                        tableOutput("table")
                    )
                ),
                box(title = "Classification Results", status = "primary", solidHeader = T, width = 12,
                    h3(textOutput("classificationResult", container = span))
                )
              )
      ),
      tabItem(tabName = "model_info",
              fluidRow(
                box(title = "Variable Importance Plot", status = "primary", solidHeader = T, collapsible = T,
                    plotOutput("varImportancePlot")
                ),
                box(title = "Model Information", status = "info", solidHeader = T, collapsible = T,
                    verbatimTextOutput("modelDetails")
                )
              )
      )
    )
    )
  )

server <- function(input, output, session) {
  observeEvent(input$submit, {
    inputData <- data.frame(
      amount_current_loan = input$amount_current_loan,
      term = input$term,
      credit_score = factor(input$credit_score),
      loan_purpose = factor(input$loan_purpose),
      yearly_income = input$yearly_income,
      home_ownership = input$home_ownership,
      bankruptcies = input$bankruptcies,
      years_current_job = input$years_current_job,
      monthly_debt = input$monthly_debt,
      years_credit_history = input$years_credit_history,
      months_since_last_delinquent = input$months_since_last_delinquent,
      open_accounts = input$open_accounts,
      credit_problems = input$credit_problems,
      credit_balance = input$credit_balance,
      max_open_credit = input$max_open_credit
    )
    
    h2oInputData <- as.h2o(inputData)
    prediction <- h2o.predict(loan_model, h2oInputData)
    updateTabItems(session, "sidebar", "results")
    output$table <- renderTable(inputData)
    output$classificationResult <- renderText({
      result <- ifelse(as.character(as_tibble(prediction)$predict) == "0", "Loan Approved", "Loan Denied")
      if (result == "Loan Denied") {
        shinyjs::addClass(selector = "body", class = "red-background blink")
        } else {
        shinyjs::addClass(selector = "body", class = "green-background blink")
      }
      return(result)
    })
    
    updateTabItems(session, "sidebar", "results")
  })
  
  output$modelDetails <- renderPrint({
    model_info <- h2o::h2o.getModel(loan_model@model_id)
    summary(model_info)
  })
  
  output$varImportancePlot <- renderPlot({
    model_info <- h2o.getModel(loan_model@model_id)
    var_imp <- h2o.varimp(model_info)
    var_imp_df <- as.data.frame(var_imp)
    ggplot(var_imp_df, aes(
      x = reorder(variable, scaled_importance),
      y = scaled_importance
    )) +
      geom_bar(stat = "identity") + coord_flip() +
      labs(title = "Variable Importance", x = "Variables", y = "Importance")
  })
}

shinyApp(ui, server)

