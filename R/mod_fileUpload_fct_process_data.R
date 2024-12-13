load_file <- function(name, datapath){
  ext <- tools::file_ext(name)
  if( length(name) == 1){
  loadedFile <- switch(ext,
         csv = vroom::vroom(datapath, delim = ",", quote = '"', escape_double = F, show_col_types = FALSE),
         json = jsonlite::fromJSON(datapath , simplifyVector = FALSE),
         validate("Could not process file. Please check the file format.")
  )
    if(!is.null(names(loadedFile)) && ext == "json"){
      loadedFile <- list(loadedFile)
    }
    return(loadedFile)
  }else if(length(name) > 1){
    ext <- unique(ext)
    stopifnot("Different file types detected!"=length(ext) == 1)
  switch(ext,
         json = map(datapath, \(x) jsonlite::fromJSON(x , simplifyVector = FALSE)),
         validate("Could not process file. Please check the file format.")
  )
  }
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
      purrr::map_dfr(stringr::str_replace_all, pattern = "\n|\r|\r\n", replacement = "; ")
    dataframe <- dataframe %>%
      purrr::map_dfr(stringr::str_replace_all, pattern = "\t", replacement = " ")
    names(dataframe) <- lookup[match(names(dataframe), lookup[["original_title"]]),"endnote_title"] |> pull()
    dataframe <- create_URL(dataframe = dataframe,
                            trial_number = "Accession Number")
    dataframe$`Name of Database` <- "CTIS"
    dataframe <- utils::capture.output(utils::write.table(dataframe, sep = "\t", na = "", quote = F, row.names = F, col.names= T, eol = "\r\n"))
    tab_delim <- c("*Web Page", dataframe)
    return(tab_delim)
  } else if (source == "DRKS"){
   # if(is.null(names(rawdata))){
      DRKSjson <- purrr::map(rawdata, \(study) pull_DRKS_data(study))
    #}else if(names(rawdata)[1] == "drksId"){
    #  DRKSjson <- pull_DRKS_data(rawdata)
    #}
    ris <- drks_json_to_ris(DRKSjson)
    return(ris)
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

pull_DRKS_data <- function(study){
  JSONpaths <- list(AccessionNumber = c("drksId"),
                    LastUpdate = c("lastUpdate"),
                    Title = c("trialDescriptions"),
                    # Conditions = c("studiedHelathConditions"),
                    Sponsor = c("trialContacts" ),
                    SecondaryIDs = c("secondaryIds"))

  registryEntry <- vector(mode = "list", length = length(JSONpaths))

  for (i in seq_along(JSONpaths)) {
    path <- JSONpaths[[i]]
    registryEntry[[i]] <- pluck(study, !!!path)
  }
  names(registryEntry) <- names(JSONpaths)
  registryEntry[["Title"]] <- extract_title(registryEntry[["Title"]])
  registryEntry[["Sponsor"]] <- extract_sponsor(registryEntry[["Sponsor"]])
  registryEntry["URL"] <- paste0("https://drks.de/search/de/trial/",registryEntry["AccessionNumber"])
  registryEntry["Year"] <- registryEntry[["Last_Update"]] # |>  lubridate::year()
  registryEntry[["SecondaryIDs"]] <- extract_secondary_ids(registryEntry[["SecondaryIDs"]])
  registryEntry["Database"] <- paste0("DRKS")
  registryEntry <- map_depth(registryEntry, 1, unlist)
  return(registryEntry)
}

drks_json_to_ris <- function(json){

  ris_fields <- list("AccessionNumber" = "AN  - ",
                     "LastUpdate" = "PY  - ",
                     "Title" = "TI  - ",
                     # "Conditions" = "KW  - ",
                     "Sponsor" = "AU  - ",
                     "SecondaryIDs" = "C4  - ",
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
  URL <- paste0("https://euclinicaltrials.eu/search-for-clinical-trials/?lang=en&EUCT=",dataframe[[eval(trial_number)]])
  dataframe$URL <- URL
  return(dataframe)
}

# Extract the German title and Acronym in DRKS
extract_title <- function(trialDescriptions){
  locales <- trialDescriptions |>
    map(pluck, "idLocale", "locale")
  index <- which(locales == "de")
  if(all(is.na(pluck(trialDescriptions,index, "acronym")))){
    return(pluck(trialDescriptions, index, "title"))
  }else {
  paste0(pluck(trialDescriptions, index, "title"),
         " (", pluck(trialDescriptions, index, "acronym"), ")")
  }
}

# Extract secondary IDs in DRKS
extract_secondary_ids <- function(secondaryIds) {
  if(pluck( secondaryIds, "noOtherIdentificationNumbersAvailable") ==  TRUE){
    return("N/A")
  }else {
    ids <- secondaryIds[c("otherPrimaryRegisterId",
                        "otherPrimaryRegisterName",
                        "universalTrialNumber",
                        "eudraCtNumber",
                        "eudamedNumber")]
   ids <- map(ids, purrr::discard, \(x) x == "")
      }
      }

# Extract the sponsor name in DRKS
extract_sponsor <- function(trialContacts){
  idContactTypes <- trialContacts |>
    map(pluck, "idContactIdType", "type")
  index <- which(idContactTypes == "PRIMARY_SPONSOR")
  trialContacts |>
    pluck(index,"contact", "affiliation")
}
