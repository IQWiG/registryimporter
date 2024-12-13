# Building a Prod-Ready, Robust Shiny Application.
#
# README: each step of the dev files is optional, and you don't have to
# fill every dev scripts before getting started.
# 01_start.R should be filled at start.
# 02_dev.R should be used to keep track of your development during the project.
# 03_deploy.R should be used once you need to deploy your app.
#
#
###################################
#### CURRENT FILE: DEV SCRIPT #####
###################################

# Engineering
#Dependencies
use_import_from("jsonlite", "read_json")
use_import_from("lubridate", "year")
use_import_from("purrr", "map")
use_import_from("purrr", "map_depth")
use_import_from("purrr", "map_dfr")
use_import_from("purrr", "modify_in")
use_import_from("purrr", "pluck")
# use_import_from("shinyFeedback", "useShinyFeedback")
# use_import_from("shinyFeedback", "feedbackDanger")
use_import_from("utils", "capture.output")
use_import_from("utils", "write.table")
use_import_from("dplyr", "pull")
use_import_from("dplyr", "filter")
use_import_from("rlang", ".data")
use_import_from("tools", "file_ext")
use_import_from("tools", "file_path_sans_ext")

golem::add_module("01_CTgovConverter")
golem::add_module("fileUpload")
golem::add_module("fileDownload")
golem::add_module("downloadPreview")
golem::add_module("uploadInfo")

golem::add_module("02_CTISConverter")
golem::add_module("03_DRKSConverter")

## Dependencies ----
## Amend DESCRIPTION with dependencies read from package code parsing
## install.packages('attachment') # if needed.
#  attachment::att_amend_desc()

## Tests ----
## Add one line by test you want to create
usethis::use_test("app")
golem::use_module_test("mod_fileUpload")
# Documentation

## (You'll need GitHub there)
usethis::use_github(private = TRUE)

# You're now set! ----
# go to dev/03_deploy.R
rstudioapi::navigateToFile("dev/03_deploy.R")
