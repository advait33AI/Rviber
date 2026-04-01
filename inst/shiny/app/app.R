# rviber Shiny App entry point
# This file is used when the app is launched via shinyAppDir()

library(rviber)
shinyApp(ui = rviber_ui(), server = rviber_server)
