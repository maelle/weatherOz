
#' Get a listing of available BOM radar imagery
#'
#' Fetch a listing of available \acronym{BOM} \acronym{radar} imagery from
#'   <ftp://ftp.bom.gov.au/anon/gen/radar/> to determine which files are
#'   currently available for download.  The files available are the most recent
#'   \acronym{radar} imagery for each location, which are updated approximately
#'   every 6 to 10 minutes by the \acronym{BOM}.  Ported from \pkg{bomrang}.
#'
#' @param radar_id `Numeric`. \acronym{BOM} radar of interest for which a list
#'   of available images will be returned.  Defaults to all images currently
#'   available.
#'
#' @details Valid \acronym{BOM} \acronym{radar} ID for each location required.
#'
#' @return
#' A [data.table::data.table] of all selected \acronym{radar} locations with location
#'   information and \var{product_ids}.
#'
#' @references
#' Australian Bureau of Meteorology (BOM) radar image
#'   <http://www.bom.gov.au/australia/radar/>.
#'
#' @examplesIf interactive()
#'
#' # Check availability radar imagery for Wollongong (radar_id = 3)
#' imagery <- get_available_radar(radar_id = 3)
#'
#' @family bomrang-ported
#'
#' @author Dean Marchiori, \email{deanmarchiori@@gmail.com}
#'
#' @export get_available_radar

get_available_radar <- function(radar_id = "all") {
  ftp_base <- "ftp://ftp.bom.gov.au/anon/gen/radar/"
  radar_locations <- NULL #nocov
  load(system.file("extdata", "radar_locations.rda", package = "weatherOz"))
  list_files <- curl::new_handle()
  curl::handle_setopt(
    handle = list_files,
    TCP_KEEPALIVE = 200000,
    CONNECTTIMEOUT = 90,
    ftp_use_epsv = TRUE,
    dirlistonly = TRUE
  )
  con <- curl::curl(url = ftp_base, "r", handle = list_files)
  files <- readLines(con)
  close(con)
  gif_files <- files[grepl("^.*\\.gif", files)]
  product_id <- substr(gif_files, 1, nchar(gif_files) - 4)
  LocationID <- substr(product_id, 4, 5)
  range <- substr(product_id, 6, 6)
  dat <- data.table::data.table(cbind(product_id,
                                      LocationID,
                                      range),
                                key = "LocationID")

  dat <- dat[radar_locations, on = "LocationID"]
  dat[, range := data.table::fcase(range == 1,
                                   "512km",
                                   range == 2,
                                   "256km",
                                   range == 3,
                                   "128km",
                                   range == 4,
                                   "64km")]

  if (radar_id[1] == "all") {
    dat <- dat
  } else if (is.numeric(radar_id) && radar_id %in% dat$Radar_id) {
    dat <- dat[dat$Radar_id %in% radar_id, ]
  } else{
    stop("`radar_id` was not found",
         call. = FALSE)
  }
  return(dat)
}

#' Get \acronym{BOM} radar imagery
#'
#' Fetch \acronym{BOM} radar imagery from <ftp://ftp.bom.gov.au/anon/gen/radar/>
#'   and return a [terra::SpatRaster()] layer object.  Files available are the
#'   most recent radar snapshot which are updated approximately every 6 to 10
#'   minutes.
#' Suggested to check file availability first by using [get_available_radar()].
#'
#' @param product_id Character. \acronym{BOM} product ID to download and import
#'   as a \CRANpkg{magick} object.  Value is required.
#'
#' @param path Character. A character string with the name where the downloaded
#'   file is saved.  If not provided, the default value `NULL` is used which
#'   saves the file in an \R session temp directory.
#'
#' @param download_only Logical. Whether the radar image is loaded into the
#'   environment as a \CRANpkg{magick} object or just downloaded.
#'
#' @details Valid \acronym{BOM} \acronym{Radar} Product IDs for radar imagery
#'   can be obtained from [get_available_radar()].
#'
#'@seealso
#'[get_available_radar()]
#'
#' @return
#' A \CRANpkg{magick} object of the most recent \acronym{radar} image snapshot
#'   published by the \acronym{BOM}. If `download_only = TRUE` there will be
#'   a `NULL` return value with the download path printed in the console as a
#'   message.
#'
#' @references
#' Australian Bureau of Meteorology (\acronym{BOM}) radar images\cr
#'   <http://www.bom.gov.au/australia/radar/>
#'
#' @examplesIf interactive()
#'
#' # Fetch most recent radar image for Wollongong 256km radar
#' imagery <- get_radar_imagery(product_id = "IDR032")
#' imagery
#'
#' @author Dean Marchiori, \email{deanmarchiori@@gmail.com}
#' @rdname get_radar_imagery
#' @export get_radar_imagery

get_radar_imagery <- get_radar <-
  function(product_id,
           path = NULL,
           download_only = FALSE) {
    if (length(product_id) != 1) {
      stop(
        "\nweatherOz only supports working with one Product ID at a time",
        "for radar images\n",
        call. = FALSE
      )
    }

    ftp_base <- "ftp://ftp.bom.gov.au/anon/gen/radar"
    fp <- file.path(ftp_base, sprintf("%s.gif", product_id))

    if (is.null(path)) {
      path <- tempfile(fileext = ".gif", tmpdir = tempdir())
    }
    h <- curl::new_handle()
    curl::handle_setopt(
      handle = h,
      TCP_KEEPALIVE = 200000,
      CONNECTTIMEOUT = 90
    )
    tryCatch({
      if (download_only == TRUE) {
        curl::curl_download(
          url = fp,
          destfile = path,
          mode = "wb",
          quiet = TRUE,
          handle = h
        )
        message("file downloaded to:", path)
      } else {
        curl::curl_download(
          url = fp,
          destfile = path,
          mode = "wb",
          quiet = TRUE,
          handle = h
        )
        message("file downloaded to:", path)
        y <- magick::image_read(path = path)
        return(y)
      }
    },
    error = function() {
      return(magick::image_read(
        path = system.file("error_image",
                           "error_message.png",
                           package = "weatherOz")
      ))
    })
  }
