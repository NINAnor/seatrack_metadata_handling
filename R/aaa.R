if (getRversion() >= "4.4.3")  globalVariables(c(".sea_track_folder"))

the <- new.env(parent = emptyenv())
the$sea_track_folder <- NULL