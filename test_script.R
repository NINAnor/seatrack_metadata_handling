renv::restore()
#source("R/functions.R")

start_logging("C:\\Users\\julian.evans\\Documents\\repositories\\seatrack_functions")
dir = "C:\\Users\\julian.evans\\Documents\\repositories\\seatrack_functions\\test_data\\test_seatrack_folder"

# For maximum verbosity log_threshold(TRACE), less verbosity log_threshold(INFO) or log_threshold(SUCCESS)
log_threshold(TRACE)

set_sea_track_folder(dir)

new_metadata <- load_partner_metadata("C:\\Users\\julian.evans\\Documents\\repositories\\seatrack_functions\\test_data\\Metadata_SEATRACK_2025-Jan Mayen.xlsx")
master_sheets <- load_master_import("Jan Mayen")
new_master_sheets <- handle_partner_metadata("Jan Mayen", new_metadata, master_sheets)


new_metadata <- load_partner_metadata("C:\\Users\\julian.evans\\Documents\\repositories\\seatrack_functions\\test_data\\Treshnish_metadata_SEATRACK_2023-2025.xlsx")
master_sheets <- load_master_import("Treshnish Isles")
new_master_sheets <- handle_partner_metadata("Treshnish Isles", new_metadata, master_sheets)

new_metadata <- load_partner_metadata("C:\\Users\\julian.evans\\Documents\\repositories\\seatrack_functions\\test_data\\Metadata_SEATRACK_2025_GPS_Tvärminne.xlsx")
master_sheets <- load_master_import("Tvärminne")
new_master_sheets <- handle_partner_metadata("Tvärminne", new_metadata, master_sheets)

save_master_sheet(new_master_sheets, "test.xlsx")
