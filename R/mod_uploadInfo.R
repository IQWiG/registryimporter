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
mod_uploadInfo_server <- function(id, rawdata ){
  stopifnot(is.reactive(rawdata))
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    references <- reactive({
      if(is.data.frame(rawdata())){
        nrow(rawdata())
      } else if(is.list(rawdata())){
        length(rawdata())
      }
    })
    output$uploadInfo <- renderText({paste(references(), "reference(s) uploaded.")})


  })
}

## To be copied in the UI
# mod_uploadInfo_ui("uploadInfo_1")

## To be copied in the server
# mod_uploadInfo_server("uploadInfo_1")
