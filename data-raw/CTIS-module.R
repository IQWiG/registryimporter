## code to prepare `CTIS-module` dataset goes here
# lookup
temp <- vroom::vroom("inst/extdata/allfields.csv", delim = ",")
lookup <-tibble::tibble(original_title = names(temp), endnote_title = c("Title",
                                                                        "Accession Number",
                                                                        rep("Unused", 8),
                                                                        "Author",
                                                                        rep("Unused",11 ),
                                                                        "Year")
)
#bzw. lookup <- readRDS("C:/Users/[anonymous]/Desktop/lookup.Rda")
use_data(lookup, internal = T)
