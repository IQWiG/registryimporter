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
    downloadButton(ns("download"), "Download")
  )
}

#' fileDownload Server Functions
#' cave: maximum upload size: 5 MB
#' @noRd
mod_fileDownload_server <- function(id, processedData, filename){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
     output$download <- downloadHandler(
       filename = function(){
         paste0(tools::file_path_sans_ext(filename()),".ris") # change output name
       },
       content = function(file) { #check content
         write(processedData(),
               sep = "\r\n",
               file)
        }
      )

  })
}

## To be copied in the UI
# mod_fileDownload_ui("fileDownload_1")

## To be copied in the server
# mod_fileDownload_server("fileDownload_1")
