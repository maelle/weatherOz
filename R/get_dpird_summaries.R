
# file: /R/get_dpird_summaries.R
#
# This file is part of the R-package weatherOz
#
# Copyright (C) 2023 DPIRD
#	<https://www.dpird.wa.gov.au>

#' Get weather data from DPIRD Weather 2.0 API summarised by time interval
#'
#' Nicely formatted individual station weather summaries from the
#'   \acronym{DPIRD} weather station network.
#'
#' @param station_code A `character` string of the \acronym{DPIRD} station code
#'   for the station of interest.
#' @param start_date A `character` string representing the beginning of the
#'   range to query in the format 'yyyy-mm-dd' (ISO8601).  Will return data
#'   inclusive of this range.
#' @param end_date A `character` string representing the end of the range query
#'   in the format 'yyyy-mm-dd' (ISO8601).  Will return data inclusive of this
#'   range.  Defaults to the current system date.
#' @param interval A `character` string that indicates the time interval to
#'   summarise over.  Default is 'daily'; others are '15min', '30min', 'hourly',
#'   'monthly' or 'yearly'.  For intervals shorter than 1 day, the time period
#'   covered will be midnight to midnight, with the end_date time interval being
#'   before midnight - hour/minute values are for the end of the time period.
#'   Data for shorter intervals ('15min', '30min') are available from January of
#'   the previous year.
#' @param which_values A `character` string with the type of summarised weather
#'   to return.  See **Available Values** for a full list of valid values.
#'   Defaults to 'all' with all available values being returned.
#' @param api_group Filter the stations to a predefined group one of 'all',
#'   'web' or 'rtd'; 'all' returns all stations, 'api' returns the default
#'   stations in use with the \acronym{API} and 'web' returns the list in use by
#'   the <https:://weather.agric.wa.gov.au> and 'rtd' returns stations with
#'   scientifically complete data sets. Defaults to 'rtd'.
#' @param include_closed A `Boolean` value that defaults to `FALSE`. If set to
#'   `TRUE` the query returns closed and open stations. Closed stations are
#'   those that have been turned off and no longer report data. They may be
#'   useful for historical purposes.
#' @param api_key A `character` string containing your \acronym{API} key from
#'   \acronym{DPIRD}, <https://www.agric.wa.gov.au/web-apis>, for the
#'   \acronym{DPIRD} Weather 2.0 \acronym{API}.
#'
#' ## Available Values for `which_values`:
#'
#'   * all (which will return all of the following values),
#'   * airTemperature,
#'   * airTemperatureAvg,
#'   * airTemperatureMax,
#'   * airTemperatureMaxTime,
#'   * airTemperatureMin,
#'   * airTemperatureMinTime,
#'   * apparentAirTemperature,
#'   * apparentAirTemperatureAvg,
#'   * apparentAirTemperatureMax,
#'   * apparentAirTemperatureMaxTime,
#'   * apparentAirTemperatureMin,
#'   * apparentAirTemperatureMinTime,
#'   * barometricPressure,
#'   * barometricPressureAvg,
#'   * barometricPressureMax,
#'   * barometricPressureMaxTime,
#'   * barometricPressureMin,
#'   * barometricPressureMinTime,
#'   * battery,
#'   * batteryMinVoltage,
#'   * batteryMinVoltageDateTime,
#'   * chillHours,
#'   * deltaT,
#'   * deltaTAvg,
#'   * deltaTMax,
#'   * deltaTMaxTime,
#'   * deltaTMin,
#'   * deltaTMinTime,
#'   * dewPoint,
#'   * dewPointAvg,
#'   * dewPointMax,
#'   * dewPointMaxTime,
#'   * dewPointMin,
#'   * dewPointMinTime,
#'   * erosionCondition,
#'   * erosionConditionMinutes,
#'   * erosionConditionStartTime,
#'   * errors,
#'   * etoShortCrop,
#'   * etoTallCrop,
#'   * evapotranspiration,
#'   * frostCondition,
#'   * frostConditionMinutes,
#'   * frostConditionStartTime,
#'   * heatCondition,
#'   * heatConditionMinutes,
#'   * heatConditionStartTime,
#'   * observations,
#'   * observationsCount,
#'   * observationsPercentage,
#'   * panEvaporation,
#'   * rainfall,
#'   * relativeHumidity,
#'   * relativeHumidityAvg,
#'   * relativeHumidityMax,
#'   * relativeHumidityMaxTime,
#'   * relativeHumidityMin,
#'   * relativeHumidityMinTime,
#'   * richardsonUnits,
#'   * soilTemperature,
#'   * soilTemperatureAvg,
#'   * soilTemperatureMax,
#'   * soilTemperatureMaxTime,
#'   * soilTemperatureMin,
#'   * soilTemperatureMinTime,
#'   * solarExposure,
#'   * wetBulb,
#'   * wetBulbAvg,
#'   * wetBulbMax,
#'   * wetBulbMaxTime,
#'   * wetBulbMin,
#'   * wetBulbMinTime,
#'   * wind,
#'   * windAvgSpeed, and
#'   * windMaxSpeed
#'
#' @return a [data.table::data.table] with 'station_code' and date interval
#'   queried together with the requested weather variables in alphabetical
#'   order. The first ten columns will always be:
#'
#'   * 'station_code',
#'   * 'station_name',
#'   * 'period_year',
#'   * 'period_month',
#'   * 'period_day',
#'   * 'period_hour',
#'   * 'period_minute' and if 'period_month' or finer is present,
#'   * 'date' (a combination of year, month, day, hour, minute as appropriate).
#'
#' @note Please note this function converts date-time columns from Coordinated
#'   Universal Time 'UTC' to Australian Western Standard Time 'AWST'.
#'
#' @family DPIRD
#'
#' @examples
#' \dontrun{
#' # You must have a DPIRD API key to proceed
#' # Set date interval for yearly request
#' # Get rainfall summary
#' start_date <- "20171028"
#'
#' # Use default for end data (current system date)
#' output <- get_dpird_summaries(
#'             station_code = "CL001",
#'             start_date = start_date,
#'             api_key = "YOUR API KEY",
#'             interval = "yearly",
#'             which_values = "rainfall")
#'
#' # Only for wind and erosion conditions for daily time interval
#' # define start and end date
#' start_date <- "20220501"
#' end_date <- "20220502"
#'
#' output <- get_dpird_summaries(
#'             station_code = "BI",
#'             start_date = start_date,
#'             end_date = end_date,
#'             api_key = "YOUR API KEY",
#'             interval = "daily",
#'             which_values = "wind")
#' }
#' @export get_dpird_summaries

get_dpird_summaries <- function(station_code,
                                start_date,
                                end_date = Sys.Date(),
                                interval = "daily",
                                which_values = "all",
                                api_group = "rtd",
                                include_closed = FALSE,
                                api_key) {
  if (missing(station_code)) {
    stop(call. = FALSE,
         "Please supply a valid `station_code`.")
  }

  if (missing(start_date))
    stop(call. = FALSE,
         "Please supply a valid start date as `start_date`.")

  # Error if api_key is not provided
  if (missing(api_key)) {
    stop(
      "A valid DPIRD API key must be provided, please visit\n",
      "<https://www.agric.wa.gov.au/web-apis> to request one.\n",
      call. = FALSE
    )
  }

  if (any(which_values == "all")) {
    which_values <- dpird_summary_values
  } else {
    if (any(which_values %notin% dpird_summary_values)) {
      stop(call. = FALSE,
           "You have specified invalid weather values.")
    }
    which_values <-
      c("stationCode", "stationName", "period", which_values)
  }

  # validate user provided dates
  start_date <- .check_date(start_date)
  end_date <- .check_date(end_date)
  .check_date_order(start_date, end_date)

  # Use `agrep()` to fuzzy match the user-requested time interval
  approved_intervals <- c("15min",
                          "30min",
                          "hourly",
                          "daily",
                          "monthly",
                          "yearly")

  likely_interval <- agrep(
    pattern = interval,
    x = approved_intervals
  )

  # Match time interval query to user requests
  checked_interval <- try(match.arg(approved_intervals[likely_interval],
                            approved_intervals,
                            several.ok = FALSE),
                  silent = TRUE
  )

  # Error if summary interval is not available. API only allows for daily,
  # 15 min, 30 min, hourly, monthly or yearly
  if (methods::is(checked_interval, "try-error")) {
    stop(call. = FALSE,
         "\"", interval, "\" is not a supported time interval")
  }

  # check API group
  api_group <- tolower(api_group)
  if (api_group %notin% c("rtd", "all", "web")) {
    stop(call. = FALSE,
         "The `api_group` should be one of 'rtd', 'all' or 'web'."
    )
  }

  request_interval <- lubridate::interval(start_date,
                                          end_date,
                                          tzone = "Australia/Perth")

  # Stop if query is for 15 and 30 min intervals and date is more than one
  # year in the past
  this_year <- lubridate::year(lubridate::today())

  if (checked_interval %in% c("15min", "30min") & lubridate::year(start_date) <
      this_year - 1 |
      checked_interval %in% c("15min", "30min") & lubridate::year(end_date) <
      this_year - 1) {
    stop(
      call. = FALSE,
      "Start date is too early. Data in 15 and 30 min intervals are only ",
      "available from the the 1st day of ", this_year - 1, "."
    )
  }

  # determine how many records are being requested. Default here is 'daily' as
  # with default user arguments
  total_records_req <- data.table::fcase(
    interval == "yearly",
    floor(lubridate::time_length(request_interval, unit = "year")),
    interval == "monthly",
    floor(lubridate::time_length(request_interval, unit = "month")),
    interval == "hourly",
    floor(lubridate::time_length(request_interval, unit = "hour")),
    interval == "30min",
    floor(lubridate::time_length(request_interval, unit = "hour")) * 2,
    interval == "15min",
    floor(lubridate::time_length(request_interval, unit = "hour")) * 4,
    default = floor(lubridate::time_length(request_interval, unit = "day"))
  )

  query_list <- .build_query(
    station_code = station_code,
    start_date_time = start_date,
    end_date_time = end_date,
    interval = checked_interval,
    which_values = which_values,
    api_group = api_group,
    include_closed = include_closed,
    api_key = api_key,
    limit = total_records_req
  )

  # set base URL according to interval
  end_point <- data.table::fcase(
    checked_interval == "15min", "summaries/15min",
    checked_interval == "30min", "summaries/30min",
    checked_interval == "hourly", "summaries/hourly",
    checked_interval == "daily", "summaries/daily",
    checked_interval == "monthly", "summaries/monthly",
    default = "summaries/yearly")

  out <-
    .parse_summary(
      .ret_list = .query_dpird_api(
        .end_point = end_point,
        .query_list = query_list,
        .limit = total_records_req
      ),
      .which_values = which_values
    )

  out[, period.from := NULL]
  out[, period.to := NULL]

  if (interval == "monthly") {
    out[, date := lubridate::ym(sprintf("%s-%s",
                                        out$period.year,
                                        out$period.month))]
  }
  if (interval == "daily") {
    out[, date := lubridate::ymd(sprintf("%s-%s-%s",
                                         out$period.year,
                                         out$period.month,
                                         out$period.day))]
  }
  if (interval == "hourly") {
    out[, date := lubridate::ymd_h(
      sprintf(
        "%s-%s-%s-%s",
        out$period.year,
        out$period.month,
        out$period.day,
        out$period.hour
      ),
      tz = "Australia/West"
    )]
  }
  if (interval == "30min" || interval == "15min") {
    out[, date := lubridate::ymd_hm(
      sprintf(
        "%s-%s-%s-%s-%s",
        out$period.year,
        out$period.month,
        out$period.day,
        out$period.hour,
        out$period.minute
      ),
      tz = "Australia/West"
    )]
  }

  if (any(grep("time", colnames(out)))) {
    out[, grep("time", colnames(out)) := suppressMessages(lapply(
      .SD,
      lubridate::ymd_hms,
      truncated = 3,
      tz = "Australia/West"
    )),
    .SDcols = grep("time", colnames(out))]
  }

  .set_snake_case_names(out)

  data.table::setcolorder(out, order(names(out)))
  data.table::setcolorder(
    out,
    c(
      "station_code",
      "station_name",
      "period_year",
      "period_month",
      "period_day",
      "period_hour",
      "period_minute"
    )
  )

  data.table::setkey(x = out, cols = station_code)

  return(out)
}


#' Parse DPIRD API summary data
#'
#' Internal function that parses and tidy up data as returned by
#'  `.query_dpird_api()`
#'
#' @param .ret_list a list with the DPIRD weather API response
#' @param .which_values a character vector with the variables to query. See the
#' `get_dpird_summaries()` for further details.
#'
#' @return a tidy `data.table` with station id and requested weather summaries
#'
#' @noRd
#' @keywords Internal
#'
.parse_summary <- function(.ret_list,
                           .which_values) {

  for (i in seq_len(length(.ret_list))) {
    x <- jsonlite::fromJSON(.ret_list[[i]]$parse("UTF8"))
    if ("summaries" %in% names(x$collection)) {
      nested_list_objects <-
        data.table::as.data.table(x$collection$summaries)
      # insert `station_name` and `station_code` into the nested_list_objects df
      nested_list_objects[, station_code := x$collection$stationCode]
      nested_list_objects[, station_name := x$collection$stationName]
    }
  }

  # get the nested list columns and convert them to data.table objects
  col_classes <-
    vapply(nested_list_objects, class, FUN.VALUE = character(1))

  col_lists <- which(col_classes == "list")

  new_df_list <- vector(mode = "list", length = length(col_lists))
  names(new_df_list) <- names(col_lists)
  j <- 1
  for (i in col_lists) {
    new_df_list[[j]] <-
      data.table::rbindlist(lapply(X = nested_list_objects[[i]],
                                   FUN = data.table::as.data.table))

    # drop the list column from the org data.table
    nested_list_objects[, names(new_df_list[j]) := NULL]

    j <- j + 1
  }

  return(cbind(nested_list_objects, do.call(what = cbind, args = new_df_list)))
}
