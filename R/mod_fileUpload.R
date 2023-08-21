#' fileUpload UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_fileUpload_ui <- function(id, placeholder, accept){
  ns <- NS(id)
  tagList(
    fileInput(ns("upload"), NULL, buttonLabel = "Upload ...", width = "50%", placeholder = placeholder, accept = accept)
  )
}

#' fileUpload Server Functions
#'
#' @noRd
mod_fileUpload_server <- function(id, source){
  stopifnot(!is.reactive(source))
  moduleServer( id, function(input, output, session){
    ns <- session$ns
     rawdata <- reactive({
       req(input$upload)
       load_file(input$upload$name, input$upload$datapath)
     })
     processedData <- reactive({process_data(rawdata(), source = source)})

   list(
     input = reactive(input$upload),
     rawdata = reactive(rawdata()),
     processedData = reactive(processedData())
   )
  })
}

## To be copied in the UI
# mod_fileUpload_ui("fileUpload_1")

## To be copied in the server
# mod_fileUpload_server("fileUpload_1")
