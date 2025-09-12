# Test script for functions in R/functions.R

# Create a temporary directory for file-based tests
tmp_dir <- tempdir()
# Create some fake versions of the tables
colony <- "TestColony"
master_startup <- tibble(
              logger_serial_no = "L1",
              logger_model = "birdTracker5000",
              producer = "loggerMcLogface",
              production_year = 2024,
              project = "seatrack",
              starttime_gmt = as.Date("2025-01-01"),
              logging_mode = NA,
              started_by = NA,
              started_where = colony,
              days_delayed = NA,
              programmed_gmt_time = NA,
              intended_species = "bird",
              intended_location = colony,
              intended_deployer = NA,
              shutdown_session = NA,
              field_status = NA,
              downloaded_by = NA,
              download_type = NA,
              download_date = NA,
              decomissioned = NA,
              shutdown_date = NA,
              comment = "",
              )
  logger_returns <- tibble(
    logger_id = "L1",
    status = "Downloaded",
    `download / stop_date` = as.Date("2025-01-10"),
    `downloaded by` = "User",
    comment = "Logger returned",
    `stored or sent to?` = ""
  )
  restart_times <- tibble(
    logger_id = character(),
    startdate_GMT = as.Date(character()),
    starttime_GMT = as.POSIXct(character()),
    `Logging mode` = character(),
    intended_species = character(),
    comment = character()
  )



# Test start_logging
test_that("start_logging creates log file", {
  log_file <- paste0("seatrack_functions_log_", Sys.Date(), ".txt")
  start_logging(tmp_dir, log_file)
  expect_true(file.exists(file.path(tmp_dir, log_file)))
})

# Test set_sea_track_folder
test_that("set_sea_track_folder sets global variable and logs", {
  expect_error(set_sea_track_folder("nonexistent_dir"))
  set_sea_track_folder(tmp_dir)
  expect_true(exists(".sea_track_folder", envir = .GlobalEnv))
  
})

# Test get_master_import_path (requires .sea_track_folder and test files)
test_that("get_master_import_path errors if folder not set", {
  .sea_track_folder <<- NULL
  expect_error(get_master_import_path("ColonyA"))
})

# Test get_startup_paths (requires .sea_track_folder)
test_that("get_startup_paths returns xlsx files", {
  .sea_track_folder <<- tmp_dir
  dir.create(file.path(tmp_dir, "Starttime files and stored loggers", 2025), recursive = TRUE, showWarnings = FALSE)
  file.create(file.path(tmp_dir, "Starttime files and stored loggers", 2025, "test.xlsx"))
  expect_type(get_startup_paths(), "character")
})

# Test load_sheets_as_list (requires a test xlsx file)
test_that("load_sheets_as_list loads sheets", {
  test_file <- file.path(tmp_dir, "test.xlsx")
  wb <- openxlsx2::wb_workbook()
  wb$add_worksheet("Sheet1")
  wb$add_worksheet("Sheet2")
  wb$add_data("Sheet1", data.frame(a = 1:3, b = 4:6))
  wb$add_data("Sheet2", data.frame(x = 7:9, y = 10:12))
  openxlsx2::wb_save(wb, test_file)
  sheets <- load_sheets_as_list(test_file, c("Sheet1", "Sheet2"))
  expect_equal(length(sheets), 2)
  expect_true(all(sapply(sheets, is.data.frame)))
})

# Test save_master_sheet
# (write and read back to check)
test_that("save_master_sheet writes xlsx file", {
  df <- data.frame(a = 1:3, b = 4:6)
  out_file <- file.path(tmp_dir, "out.xlsx")
  expect_silent(save_master_sheet(df, out_file))
  expect_true(file.exists(out_file))
})

# Additional tests

# Test append_encounter_data
test_that("append_encounter_data appends non-duplicate rows", {
  master <- data.frame(ring_number = NA, logger_id_deployed = c("A", "B"), logger_id_retrieved = NA, date = as.Date(c("2025-01-01", "2025-01-02")), nest_latitude = NA, nest_longitude = NA)
  encounter <- data.frame(ring_number = NA, logger_id_deployed = c("C", "B"), logger_id_retrieved = NA,  date = as.Date(c("2025-01-03", "2025-01-02")), nest_latitude = NA, nest_longitude = NA)
  result <- append_encounter_data(master, encounter)
  expect_equal(nrow(result), 3) # Only non-duplicate appended
})

# Test set_master_startup_value
test_that("set_master_startup_value updates cell value", {
  df <- data.frame(a = 1:3, b = 4:6)
  updated <- set_master_startup_value(df, 2, "b", 99)
  expect_equal(updated$b[2], 99)
})

# Test set_comments
test_that("set_comments sets and appends comments", {
  df <- data.frame(comment = c("", "Existing"))
  df1 <- set_comments(df, 1, "New")
  expect_equal(df1$comment[1], "New")
  df2 <- set_comments(df1, 2, "Another")
  expect_equal(df2$comment[2], "Existing | Another")
})

# Test handle_returned_loggers
test_that("handle_returned_loggers updates master_startup with logger_returns", {


  updated <- handle_returned_loggers(colony, master_startup, logger_returns, restart_times)
  expect_true(any(!is.na(updated$download_date)))
  expect_true(any(updated$comment == "Logger returned"))
})
