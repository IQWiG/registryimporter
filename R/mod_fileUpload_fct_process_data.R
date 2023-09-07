load_file <- function(name, datapath){
  ext <- tools::file_ext(name)
  switch(ext,
         csv = vroom::vroom(datapath, delim = ",", quote = '"', escape_double = F, show_col_types = FALSE),
         json = jsonlite::fromJSON(datapath, simplifyVector = FALSE),
         validate("Could not process file. Please check the file format.")
  )
}

process_data <- function(rawdata, source){
  if(source == "CTgov"){
      json <- purrr::map(rawdata, \(study) pull_json_data(study))
      ris <- ctgov_json_to_ris(json)
      return(ris)

  }else if(source == "CTIS"){
    required_cols <- lookup %>%
      dplyr::filter(.data$endnote_title != "Unused") %>%
      dplyr::select("original_title") %>%
      pull()

    if(all(required_cols %in% names(rawdata)) == FALSE) {
      validate("Not all required columns have been imported. Check the 'Display options' in CTIS to ensure, that all necessary information are exported into the csv-file.")
      }
    dataframe <- rawdata %>%
      purrr::map_dfr(stringr::str_replace_all, pattern = "\n|\r\n", replacement = ";")
    names(dataframe) <- rename_cols_for_endnote(dataframe)
    dataframe <- create_URL(dataframe = dataframe,
                            trial_number = "Accession Number")
    dataframe <- utils::capture.output(utils::write.table(dataframe, sep = "\t", quote = F, row.names = F, col.names= T))
    tab_delim <- c("*#Web Page", dataframe)
    return(tab_delim)
  }

}

pull_json_data <- function(study) {

  JSONpaths <- list(NCT = c("protocolSection", "identificationModule", "nctId"),
                    Last_Update = c("protocolSection", "statusModule", "lastUpdatePostDateStruct", "date"),
                    Title = c( "protocolSection", "identificationModule", "briefTitle"),
                    Acronym = c("protocolSection", "identificationModule", "acronym"),
                    Conditions = c("protocolSection", "conditionsModule", "conditions"),
                    Sponsor = c("protocolSection", "sponsorCollaboratorsModule", "leadSponsor", "name"),
                    SecondaryIDs = c("protocolSection", "identificationModule", "secondaryIdInfos"),
                    HasResults = c("hasResults"))

  registryEntry <- vector(mode = "list", length = length(JSONpaths))

  for (i in seq_along(JSONpaths)) {
    path <- JSONpaths[[i]]
    registryEntry[[i]] <- pluck(study, !!!path)
  }
  names(registryEntry) <- names(JSONpaths)
  if (!is.null(registryEntry[["Acronym"]])) {
  registryEntry["Title"] <- paste0(registryEntry["Title"]," (", registryEntry["Acronym"], ")" )
  }
  registryEntry["Acronym"] <- NULL
  registryEntry["URL"] <- paste0("https://clinicaltrials.gov/study/",registryEntry["NCT"])
  registryEntry["Year"] <- registryEntry[["Last_Update"]] %>% year()
  registryEntry[["SecondaryIDs"]] <- registryEntry[["SecondaryIDs"]] %>% map(pluck, "id")
  registryEntry["Database"] <- paste0("CT.gov")
  registryEntry <- map_depth(registryEntry, 1, unlist)
  return(registryEntry)
}

ctgov_json_to_ris <- function(json) {

  ris_fields <- list("NCT" = "AN  - ",
                     "Year" = "PY  - ",
                     "Last_Update" = "DA  - ",
                     "Title" = "TI  - ",
                     "Conditions" = "KW  - ",
                     "Sponsor" = "AU  - ",
                     "SecondaryIDs" = "C4  - ",
                     "HasResults" = "OP  - Results posted: ",
                     "URL" = "UR  - ",
                     "Database" = "DB  - ")

  for (ris_field in seq_along(ris_fields)) {
    json <- json %>%  map(\(study_index) modify_in(study_index,
                                                   names(ris_fields)[ris_field],
                                                   \(vectorObj) paste0(ris_fields[ris_field], vectorObj)))

  }
  json <- map(json, \(study) c(Type = "TY  - WEB", study, EndRef = "ER  - ", "")) %>%
    unlist()
  return(json)
}


#'Create URL for references
#'
#' @description creates an extra column in the data frame, generating the reference-specific CTIS URL.
#'
#' @return A tibble with one additional column "URL"
#'
#' @noRd
create_URL <- function(dataframe, trial_number) {
  if(anyNA(dataframe[[eval(trial_number)]])) {
    stop("Trial numbers are missing, cannot create URLS", call. = F)
  }
  URL <- paste0("https://euclinicaltrials.eu/app/#/view/",dataframe[[eval(trial_number)]],"?lang=en")
  dataframe$URL <- URL
  return(dataframe)
}

#'Rename Column Names for Endnote
#'
#' @description Prepare the column names for Endnote.
#' @importFrom dplyr filter
#' @importFrom dplyr pull
#' @return A character vector with the new column names
#'
#' @noRd
rename_cols_for_endnote <- function(dataframe) {
  endnote_names <- lookup %>%
    dplyr::filter( .data$original_title %in% names(dataframe)) %>%
    pull(.data$endnote_title)
  return(endnote_names)
}
