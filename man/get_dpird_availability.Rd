% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_dpird_availability.R
\name{get_dpird_availability}
\alias{get_dpird_availability}
\title{Get DPIRD weather station availability metadata}
\usage{
get_dpird_availability(
  station_code = NULL,
  start_date = NULL,
  end_date = NULL,
  which_values = "availability",
  api_key
)
}
\arguments{
\item{station_code}{A \code{character} string of the \acronym{DPIRD} station code
for the station of interest. Defaults to \code{NULL}, returning metadata for
all stations during the requested \code{start_date} and \code{end_date} interval.}

\item{start_date}{A \code{character} string representing the beginning of the
range to query in the format 'yyyy-mm-dd' (ISO8601).  Will return data
inclusive of this range.  Defaults to \code{NULL}, returning data for the
current year-to-date.  Must be sent along with an \code{end_date}.}

\item{end_date}{A \code{character} string representing the end of the range query
in the format 'yyyy-mm-dd' (ISO8601).  Will return data inclusive of this
range.  Defaults to \code{NULL}, returning data for the current year-to-date.
Must be sent with a \code{start_date}.}

\item{which_values}{A \code{character} string with the type of availability
metadata to return.  See \strong{Available Values} for a full list of valid
values.  Defaults to 'availability', returning metadata for all stations.}

\item{api_key}{A \code{character} string containing your \acronym{API} key from
\acronym{DPIRD}, \url{https://www.agric.wa.gov.au/web-apis}, for the
\acronym{DPIRD} Weather 2.0 \acronym{API}.
\subsection{Available Values for \code{which_values}:}{
\itemize{
\item availability (which will return all of the following values),
\item availabilityCurrentHour,
\item availabilityLast7DaysSince9AM,
\item availabilityLast7DaysSince12AM,
\item availabilityLast14DaysSince9AM,
\item availabilityLast14DaysSince12AM,
\item availabilityLast24Hours,
\item availabilityMonthToDateSince12AM,
\item availabilityMonthToDateTo9AM,
\item availabilitySince9AM,
\item availabilitySince12AM,
\item availabilityTo9AM,
\item availabilityYearToDateSince12AM, and
\item availabilityYearToDateTo9AM
}
}}
}
\value{
a \link[data.table:data.table]{data.table::data.table}  with 'station_code' and the requested
metadata.
}
\description{
Get the availability metadata of weather stations in the \acronym{DPIRD}
weather station network.
}
\examples{
\dontrun{
# You must have a DPIRD API key to proceed
# Use default for end data (current system date)
output <- get_dpird_availability(
            station_code = "BI",
            start_date = "20170101",
            end_date = "20171231",
            api_key = "YOUR API KEY")
}

}
