#' fileDownload UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_fileDownload_ui <- function(id){
  ns <- NS(id)
  tagList(
    downloadButton("download", "Download")
  )
}

#' fileDownload Server Functions
#'
#' @noRd
mod_fileDownload_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

  })
}

## To be copied in the UI
# mod_fileDownload_ui("fileDownload_1")

## To be copied in the server
# mod_fileDownload_server("fileDownload_1")
