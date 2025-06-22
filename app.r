library(shiny)
library(tidyverse)
library(lubridate)
library(pins)
library(DT)

# Initialize shared board (replace with your board)
board <- board_folder("shared_data")

ui <- fluidPage(
  titlePanel("Fixed-Income Loan Data Portal"),
  sidebarLayout(
    sidebarPanel(
      h4("Data Entry"),
      textInput("loanid", "Loan ID", placeholder = "LOAN-001"),
      dateInput("disb_date", "Disbursement Date"),
      numericInput("disb_amt", "Disbursement Amount", value = 0, min = 0),
      h4("Repayments"),
      dateInput("rep_date", "Repayment Date"),
      numericInput("rep_amt", "Repayment Amount", value = 0, min = 0),
      actionButton("add_repayment", "Add Repayment"),
      actionButton("save", "Save Loan", class = "btn-primary")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Cash Flows", 
                 DTOutput("cashflow_table")),
        tabPanel("Portfolio", 
                 DTOutput("portfolio_table"))
      )
    )
  )
)

server <- function(input, output, session) {
  # Synthetic example data
  synthetic_loans <- tibble(
    loanid = c("LOAN-001", "LOAN-001", "LOAN-002", "LOAN-002"),
    date = as.Date(c("2024-01-01", "2024-02-01", "2024-03-01", "2024-04-01")),
    amount = c(-10000, 2000, -5000, 1000),
    type = c("Disbursement", "Repayment", "Disbursement", "Repayment")
  )
  synthetic_repayments <- tibble(
    loanid = character(),
    date = as.Date(character()),
    amount = numeric(),
    type = character()
  )

  # Reactive values storage
  rv <- reactiveValues(
    loans = synthetic_loans,
    repayments = synthetic_repayments
  )
  
  # Add repayment entries
  observeEvent(input$add_repayment, {
    req(input$loanid, input$rep_date, input$rep_amt > 0)
    
    new_repayment <- tibble(
      loanid = input$loanid,
      date = input$rep_date,
      amount = input$rep_amt,
      type = "Repayment"
    )
    
    rv$repayments <- bind_rows(rv$repayments, new_repayment)
  })
  
  # Save loan to portfolio
  observeEvent(input$save, {
    req(input$loanid, input$disb_date, input$disb_amt > 0)
    
    disb_entry <- tibble(
      loanid = input$loanid,
      date = input$disb_date,
      amount = -input$disb_amt,  # Negative for disbursement
      type = "Disbursement"
    )
    
    # Combine disbursement and repayments
    new_loan <- bind_rows(disb_entry, rv$repayments) %>% 
      filter(!is.na(loanid))
    
    rv$loans <- bind_rows(rv$loans, new_loan)
    rv$repayments <- tibble()  # Reset repayments
    
    # Update pin
    board %>% pin_write(rv$loans, "loan_portfolio")
  })
  
  # Construct cash flows
  cashflow_data <- reactive({
    rv$loans %>%
      arrange(loanid, date) %>%
      group_by(loanid) %>%
      mutate(
        cumulative = accumulate(amount, ~ .x + .y),
        cumulative = cumsum(amount)  # Alternative using base R
      ) %>%
      ungroup()
  })
  
  # Render tables with Excel-like styling
  output$cashflow_table <- renderDT({
    cashflow_data() %>%
      datatable(
        rownames = FALSE,
        extensions = "Buttons",
        options = list(
          dom = "Bfrtip",
          buttons = c("copy", "csv", "excel"),
          pageLength = 10,
          autoWidth = TRUE
        ),
        class = "cell-border stripe"
      ) %>%
      formatCurrency("amount", currency = "$") %>%
      formatCurrency("cumulative", currency = "$")
  })
  
  output$portfolio_table <- renderDT({
    rv$loans %>%
      datatable(
        rownames = FALSE,
        options = list(scrollX = TRUE),
        class = "display compact"
      ) %>%
      formatCurrency("amount", currency = "$")
  })
}

shinyApp(ui, server)
