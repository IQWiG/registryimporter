#' downloadPreview UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_downloadPreview_ui <- function(id){
  ns <- NS(id)
  tagList(
    verbatimTextOutput(ns("downloadpreview"))
  )
}

#' downloadPreview Server Functions
#'
#' @noRd
mod_downloadPreview_server <- function(id, processedData){
  stopifnot(is.reactive(processedData))
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    output$downloadpreview <- renderText({
      paste0(head(processedData(), n = 30 ), sep = "\n")
      })

  })
}

## To be copied in the UI
# mod_downloadPreview_ui("downloadPreview_1")

## To be copied in the server
# mod_downloadPreview_server("downloadPreview_1")
