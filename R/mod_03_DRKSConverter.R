#' 03_DRKSConverter UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_03_DRKSConverter_ui <- function(id){
  ns <- NS(id)
  tagList(
    mod_fileUpload_ui(ns("upload"), placeholder = ".json", accept = ".json", multiple = TRUE),
    fluidRow(column(3, mod_fileDownload_ui(ns("download"))),
             column(9, mod_uploadInfo_ui(ns("info")))
    ),
    h4("Download preview"),
    mod_downloadPreview_ui(ns("preview"))
    # verbatimTextOutput(ns("test"))
  )
}

#' 03_DRKSConverter Server Functions
#'
#' @noRd
mod_03_DRKSConverter_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    DRKS <- mod_fileUpload_server("upload", source = "DRKS")
    mod_fileDownload_server("download", processedData = DRKS$processedData, filename = reactiveVal("DRKS-search-result"), source = "DRKS")
    mod_uploadInfo_server("info", rawdata = DRKS$rawdata)
    mod_downloadPreview_server("preview", processedData = DRKS$processedData)

  })
}

## To be copied in the UI
# mod_03_DRKSConverter_ui("03_DRKSConverter_1")

## To be copied in the server
# mod_03_DRKSConverter_server("03_DRKSConverter_1")
