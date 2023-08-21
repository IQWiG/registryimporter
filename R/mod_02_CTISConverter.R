#' 02_CTISConverter UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_02_CTISConverter_ui <- function(id){
  ns <- NS(id)
  tagList(
    mod_fileUpload_ui(ns("upload"), placeholder = ".csv", accept = ".csv"),
    fluidRow(column(3, mod_fileDownload_ui(ns("download"))),
             column(9, mod_uploadInfo_ui(ns("info")))
    ),
    h4("Download preview"),
    mod_downloadPreview_ui(ns("preview"))
  )
}

#' 02_CTISConverter Server Functions
#'
#' @noRd
mod_02_CTISConverter_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    CTIS <- mod_fileUpload_server("upload", source = "CTIS")
    mod_fileDownload_server("download", processedData = CTIS$processedData, filename = CTIS$input, source = "CTIS")
    mod_uploadInfo_server("info", rawdata = CTIS$rawdata)
    mod_downloadPreview_server("preview", processedData = CTIS$processedData)

  })
}

## To be copied in the UI
# mod_02_CTISConverter_ui("02_CTISConverter_1")

## To be copied in the server
# mod_02_CTISConverter_server("02_CTISConverter_1")
