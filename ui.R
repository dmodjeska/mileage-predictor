# ui.R -- Create front end for Mileage Prediction app

library(shiny)
library(shinythemes)
library(shinyBS)

# define UI
shinyUI(fluidPage(

    # style screen as minimal and neutral
    theme = shinytheme("spacelab"),
    includeCSS("styles.css"),

    # show title
    titlePanel("Predict your car's gas mileage in 1974"),
    br(),
    br(),

    # define panels
    sidebarLayout(

        # define input panel
        sidebarPanel(

            # display prompt text
            helpText(
                h4("What kind of car will you drive?",
                   style = "font-weight:700; color:#333")
            ),
            br(),

            # define slider for number of cylinders
            sliderInput(
                inputId = "cylinders", label = "Number of Cylinders:",
                min = 4, max = 8, step = 2, ticks = FALSE, round = TRUE, value = 6
            ),

            # define slider for weight
            sliderInput(
                inputId = "weight", label = "Weight (in Tons)",
                min = 1.5, max = 5.5, ticks = TRUE, value = 3.5
            ),

            # define radio buttons for transmission type
            radioButtons(
                inputId = "transmission", label = "Transmission Type:",
                c("Automatic" = "auto",
                  "Manual" = "man"),
                selected = "auto"
            )
        ),

        # define output panel
        mainPanel(

            # show prediction result as text
            div(style = "text-align:center; font-size:1.25em; font-weight:700; color:#555",
                p(
                    "The predicted gas mileage of your car is ",
                    span(textOutput("mpg_text", inline = TRUE), style = "font-size:1.25em"),
                    span(" mpg.", style = "font-size:1.25em;font-variant:small-caps")
                )),

            # show prediction result and trends as graph
            plotOutput("trend_plot"),
            br(),

            # define documentation panels
            tabsetPanel(

                # define introductory panel
                tabPanel(
                    "Introduction",
                    br(),

                    p(
                        "Notice how your choice of car type moves the black dot around the trend graphs.",
                        style = "font-size:1.1em"
                    ),

                    p(
                        "By moving the dot, you can get a sense of how different car features affect gas mileage.",
                        style = "font-size:1.1em"
                    ),

                    p(
                        "The data comes from US", em("Motor Trend"), " magazine in 1974. ",
                        style = "font-size:1.1em"
                    )
                ),

                # define panel about this app, including summary statistics
                tabPanel(
                    "About this App",
                    br(),

                    p(
                        "This app was developed to help consumers decide
                        which model of car is best for their needs and budget.
                        If you were buying a car in 1974,
                        you were probably concerned about gas prices.
                        After all, an oil crisis had started in October 1973:
                        the Organization of Arab Oil Exporting Countries
                        declared an oil embargo.
                        By March 1974, the price of oil had risen from USD 3 per barrel
                        to almost USD 12 per barrel.
                        So what was a car shopper supposed to do?"
                    ),

                    p(
                        "It turns out that certain car features have a significant effect
                        on gas mileage.
                        For example, lower weight, few cylinders, and manual transmission
                        all tend to increase gas mileage.
                        To quantify these trade-offs, a model was created
                        using multiple linear regression.
                        The results are shown above in graphical form,
                        and the details follow at the bottom of this page."
                    ),

                    p(
                        "By playing around with the model in the app,
                        you can get a sense of how each of the input car features
                        affects gas mileage.
                        The black dot moves around in response to your choices.
                        For example, if you choose a 6-cylinder car
                        that weighs 3.5 tons with an automatic transmission,
                        your expected gas mileage is 19 MPG."
                    ),

                    p(
                        "Data for this application come from US ",
                        em("Motor Trend"), " magazine in 1974.
                        For more information, please see the ",
                        code("mtcars"), "data set that comes with RStudio."
                    ),
                    br(),

                    p(
                        "The source code for this app can be found on GitHub ",
                        a(href = "https://github.com/dmodjeska/mileage-predictor", "here"),
                        "."
                    ),
                    br(),

                    verbatimTextOutput("model_summary_text"),
                    br()
                    )
                )
            )
        )
))