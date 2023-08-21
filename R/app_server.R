#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {

  mod_01_CTgovConverter_server("01_CTgovConverter_1")
  mod_02_CTISConverter_server("02_CTISConverter_2")
}
