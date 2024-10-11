test_that("Incomplete columns in CTIS csv throw correct error", {
  csv <- load_file("ctis_fals_file.csv", test_path("fixtures", "ctis_false_file.csv"))
  expect_error(process_data(csv, source = "CTIS"), "Not all required columns have been imported. Check the 'Display options' in CTIS to ensure, that all necessary information are exported into the csv-file.")
})

test_that("CTIS csv can be processed correctly", {
  csv <- load_file("ctis_test_file.csv", test_path("fixtures", "ctis_test_file.csv"))
  expect_vector(process_data(csv, source = "CTIS"), ptype = character(), size = 19)
  })


test_that("CTgov json can be processed correctly", {
  json <- load_file("ctgov_test_file3.json", test_path("fixtures", "ctgov_test_file3.json"))
  ris <- process_data(json, source = "CTgov")
  expect_equal(ris[1:2], c(Type = "TY  - WEB",  NCT = "AN  - NCT02658019" ))
  expect_vector(ris, ptype = character(), size = 42)
})
