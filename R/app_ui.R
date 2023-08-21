#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic
    navbarPage("Registry Importer",
      tabPanel("CT.gov",
               h2("ClinicalTrials.gov JSON to RIS Converter"),
               mod_01_CTgovConverter_ui("01_CTgovConverter_1"),
               textOutput("test")
      )

#      fileInput("upload", NULL, buttonLabel = "Upload...", width = "50%"),
#      downloadButton("download", "Download"),
#      h4("Download preview"),
#      verbatimTextOutput("downloadpreview")
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "registryimporter"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
