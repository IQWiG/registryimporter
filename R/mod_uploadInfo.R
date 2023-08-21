#' uploadInfo UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_uploadInfo_ui <- function(id){
  ns <- NS(id)
  tagList(
 textOutput(ns("uploadInfo"))
  )
}

#' uploadInfo Server Functions
#'
#' @noRd
mod_uploadInfo_server <- function(id, json ){
  stopifnot(is.reactive(json))
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    output$uploadInfo <- renderText({paste(length(json()), "references uploaded.")})

  })
}

## To be copied in the UI
# mod_uploadInfo_ui("uploadInfo_1")

## To be copied in the server
# mod_uploadInfo_server("uploadInfo_1")
