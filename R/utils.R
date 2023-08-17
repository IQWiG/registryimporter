process_data <-  function(json) {
  json <- map(json, \(study) create_ris_entry(study))
  json <- ctgov_json_to_ris(json)
}
create_ris_entry <- function(study) {

  JSONpaths <- list(NCT = c("protocolSection", "identificationModule", "nctId"),
                    Year = c("protocolSection", "statusModule", "lastUpdatePostDateStruct", "date"),
                    Title = c( "protocolSection", "identificationModule", "officialTitle"),
                    OtherTitles = c( "protocolSection", "identificationModule", "briefTitle"),
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
  registryEntry["URL"] <- paste0("https://clinicaltrials.gov/study/",registryEntry["NCT"])
  registryEntry["Year"] <- registryEntry[["Year"]] %>% year()
  registryEntry[["SecondaryIDs"]] <- registryEntry[["SecondaryIDs"]] %>% map(pluck, "id")
  registryEntry <- map_depth(registryEntry, 1, unlist)
  return(registryEntry)
}

ctgov_json_to_ris <- function(json) {

  ris_fields <- list("NCT" = "AN  - ",
                     "Year" = "PY  - ",
                     "Title" = "TI  - ",
                     "OtherTitles" = "AB  - Other Titles: ",
                     "Acronym" = "AB  - Acronym: ",
                     "Conditions" = "AB  - Conditions: ",
                     "Sponsor" = "AU  - ",
                     "SecondaryIDs" = "C4  - ",
                     "HasResults" = "AB  - Results posted: ",
                     "URL" = "UR  - ")

  for (ris_field in seq_along(ris_fields)) {
    # position <- map(json, \(study) names(study) == names(ris_fields)[ris_field]) %>%
    #    unique() %>%
    #    unlist()
    #  stopifnot("errror in parsing json file" = length(position) == length(ris_fields))
    # json <- registryEntries[1:3]
    #  json %>% map(\(string) paste0(ris_fields[[i]],"  - ", string))

    #  map(json[position], \(string) paste0(ris_fields[i],"  - ", string))

    #  modify_in(json, list(1, names(ris_fields)[i]), \(vectorObj) paste0("PY  - ", vectorObj))

    json <- json %>%  map(\(study_index) modify_in(study_index, names(ris_fields)[ris_field], \(vectorObj) paste0(ris_fields[ris_field], vectorObj)))

  }
  json <- map(json, \(study) c(Type = "TY  - WEB", study, EndRef = "ER  - ", "")) %>%
    unlist()
  return(json)
}
