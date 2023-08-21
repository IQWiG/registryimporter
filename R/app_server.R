#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {

  mod_01_CTgovConverter_server("01_CTgovConverter_1")
  output$test <- renderText({"app server"})

# rawdata <- reactive({
#   req(input$upload)
#   ext <- tools::file_ext(input$upload$name)
#   switch(ext,
#          json = jsonlite::fromJSON(input$upload$datapath, simplifyVector = FALSE),# add json-upload
#          validate("Invalid file, Please upload a json-file exported from ClinicalTrial.gov")
#   )
# })
# processeddata <- reactive({
#   req(input$upload)
#   process_data(rawdata())
# })
# output$downloadpreview <- renderText({
#   paste0(processeddata(), sep = "\n")}
# )
# output$download <- downloadHandler(
#   filename = function(){
#     paste0("test",".ris") # change output name
#   },
#   content = function(file) { #check content
#     write(processeddata(),
#           sep = "\r\n",
#           file)
#    }
#  )
}
