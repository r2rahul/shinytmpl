# shinytmpl

A Shiny template for sharing fixed-income loan data across teams in a standardized format.

## Overview

This project provides a Shiny web application for entering, storing, and visualizing loan and repayment data. It enables teams to collaborate and share data using a common structure, with data persistence via the `pins` package and a shared folder.

## Features

- Enter new loan disbursements and repayments via a user-friendly interface
- View and export cash flow tables with cumulative calculations
- Maintain a portfolio of all loans and transactions
- Data is stored in a shared folder using the `pins` package for easy team access
- Download data in CSV or Excel format

## Getting Started

### Prerequisites

- R (>= 4.0)
- [Shiny](https://shiny.rstudio.com/)
- [tidyverse](https://www.tidyverse.org/)
- [lubridate](https://lubridate.tidyverse.org/)
- [pins](https://pins.rstudio.com/)
- [DT](https://rstudio.github.io/DT/)

Install required packages in R:

```r
install.packages(c("shiny", "tidyverse", "lubridate", "pins", "DT"))
```
Running the App
Clone this repository.
Ensure the shared_data/ directory exists in the project root.
Open app.r in RStudio or your preferred R environment.

Run the app:

```r
shiny::runApp("app.r")
```

Usage
Enter loan details and repayments in the sidebar.
Click Add Repayment to add multiple repayments before saving.
Click Save Loan to add the loan and its repayments to the portfolio.
View cash flows and portfolio in the main panel.
Export tables using the provided buttons.

License
This project is licensed under the MIT License. See LICENSE for details. 