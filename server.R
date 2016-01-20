# server.R -- Create back end for Mileage Prediction app

library(datasets)
library(ggplot2)
library(grid)
library(GGally)
library(dplyr)

library(ggplot2)
library(gridExtra)

# define function to allocate graph colors algorithmically
# from http://stackoverflow.com/questions/8197559/emulate-ggplot2-default-color-palette
ggplot_colors <- function(n = 6, h = c(0, 360) + 15) {
    if ((diff(h) %% 360) < 1)
        h[2] <- h[2] - (360 / n)
    hcl(h = (seq(h[1], h[2], length = n)), c = 100, l = 65)
}

# read and clean data
data(mtcars)
mtcars1 <- mtcars %>%
    rename(Transmission = am)  %>%
    mutate(Transmission = gsub("0", "Automatic", Transmission)) %>%
    mutate(Transmission = gsub("1", "Manual", Transmission)) %>%
    mutate(Transmission = factor(Transmission)) %>%
    mutate(cyl = paste(cyl, " Cylinder", sep = "")) %>%
    mutate(cyl = factor(cyl)) %>%
    select(Transmission, cyl, wt, mpg)

# fit model - multiple linear regression
fit <-
    lm(data = mtcars1, mpg ~ cyl + wt + Transmission + wt:Transmission - 1)

# define server
shinyServer(function(input, output) {

    # define reactive variable to hold user input
    user_data <- reactive({
        cyl = as.factor(paste(input$cylinders, " Cylinder", sep = ""))
        is_manual <-
            ifelse(input$transmission == "man", "Manual", "Automatic")
        Transmission = as.factor(is_manual)
        data.frame(cyl = cyl, wt = input$weight, Transmission = Transmission)
    })

    # define reactive variable to hold prediction
    predict_mpg <- reactive({
        predict(fit, newdata = user_data())[1]
    })

    # create output for prediction as text
    output$mpg_text <- renderText({
        round(predict_mpg())
    })

    # create output for prediction and trends as graph
    output$trend_plot <- renderPlot({

        # create data frame to hold prediction and user input
        new_data <- data.frame(
            cyl = user_data()$cyl,
            wt = user_data()$wt,
            Transmission = user_data()$Transmission,
            mpg = predict_mpg()
        )

        # create plot
        coeff <- fit$coeff
        plot_colors <- ggplot_colors(3)
        ggplot(mtcars1, aes(x = wt, y = mpg, color = Transmission)) +
            geom_blank() +
            geom_abline(data = subset(mtcars1, cyl == '4 Cylinder' &
                                          Transmission == 'Manual'),
                        aes(color = Transmission), size = 1.5,
                        intercept = coeff[1], slope = coeff[4]
                        ) +
            geom_abline(data = subset(mtcars1, cyl == '4 Cylinder' &
                                          Transmission == 'Automatic'),
                        aes(color = Transmission), size = 1.5,
                        intercept = coeff[1] + coeff[5],
                        slope = coeff[4] + coeff[6]
                        ) +
            geom_abline(data = subset(mtcars1, cyl == '6 Cylinder' &
                                          Transmission == 'Manual'),
                        aes(color = Transmission), size = 1.5,
                        intercept = coeff[2], slope = coeff[4]
                        ) +
            geom_abline(data = subset(mtcars1, cyl == '6 Cylinder' &
                                          Transmission == 'Automatic'),
                        aes(color = Transmission), size = 1.5,
                        intercept = coeff[2] + coeff[5],
                        slope = coeff[4] + coeff[6]
                        ) +
            geom_abline(data = subset(mtcars1, cyl == '8 Cylinder' &
                                          Transmission == 'Manual'),
                        aes(color = Transmission), size = 1.5,
                        intercept = coeff[3], slope = coeff[4]
                        ) +
            geom_abline(data = subset(mtcars1, cyl == '8 Cylinder' &
                                          Transmission == 'Automatic'),
                        aes(color = Transmission), size = 1.5,
                        intercept = coeff[3] + coeff[5],
                        slope = coeff[4] + coeff[6]
                        ) +
            facet_wrap( ~ cyl, ncol = 3) +
            # the following point is a dummy that causes the legend to display
            geom_point(data = subset(mtcars1,
                                     cyl == "4 Cylinder" &
                                         Transmission == "Automatic" &
                                         wt == 1.5 &
                                         mpg == 23)
                       ) +
            geom_point(data = new_data, pch = 21,
                       fill = plot_colors[1], color = "white", size = 8
                       ) +
            ggtitle("Your Car and General Mileage Trends\n") +
            xlab("Weight (Tons)") +
            ylab("Mileage (MPG)") +
            theme(axis.title.x = element_text(vjust = -0.5)) +
            theme(axis.title.y = element_text(vjust = 1.5)) +
            theme(legend.position = "bottom", legend.margin = unit(1.5, "lines")) +
            scale_color_manual(
                values = plot_colors[2:3],
                breaks = mtcars1$Transmission,
                labels = mtcars1$Transmission,
                name = "Legend"
            )
    })

    # define reactive variable to hold model summary
    summarize_model <- reactive({
        summary(fit)
    })

    # create output for model summary
    output$model_summary_text <- renderPrint({
        summarize_model()
    })

})