#' 01_CTgovConverter UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_01_CTgovConverter_ui <- function(id){
  ns <- NS(id)
  tagList(
    mod_fileUpload_ui(ns("upload"), placeholder = ".json", accept = ".json"),
    fluidRow(column(3, mod_fileDownload_ui(ns("download"))),
             column(9, mod_uploadInfo_ui(ns("info")))
             ),
    h4("Download preview"),
    mod_downloadPreview_ui(ns("preview")),
    # verbatimTextOutput(ns("test"))
  )
}

#' 01_CTgovConverter Server Functions
#'
#' @noRd
mod_01_CTgovConverter_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    CTgov <- mod_fileUpload_server("upload", source = "CTgov")
    mod_fileDownload_server("download", processedData = CTgov$processedData, filename = CTgov$input)
    mod_uploadInfo_server("info", json = CTgov$rawdata)
    mod_downloadPreview_server("preview", processedData = CTgov$processedData)
   #output$test <- renderText({CTgov$processedData()})
  })
}

## To be copied in the UI
# mod_01_CTgovConverter_ui("01_CTgovConverter_1")

## To be copied in the server
# mod_01_CTgovConverter_server("01_CTgovConverter_1")
