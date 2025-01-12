% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_station_metadata.R
\name{get_station_metadata}
\alias{get_station_metadata}
\title{Get the latest DPIRD and SILO weather station metadata}
\usage{
get_station_metadata(which_api = "all", api_key, status = FALSE, rich = FALSE)
}
\arguments{
\item{which_api}{A \code{string} value that indicates which \acronym{API} to use.
Valid values are 'all', for both \acronym{SILO} (\acronym{BOM} data) and
\acronym{DPIRD} \acronym{API}s; 'silo' for only stations from the
\acronym{SILO} \acronym{API} (\acronym{BOM} data); or 'dpird' for stations
from the \acronym{DPIRD} Weather 2.0 \acronym{API}.  Defaults to "all".}

\item{api_key}{A \code{character} string containing your \acronym{API} key from
\acronym{DPIRD}, \url{https://www.agric.wa.gov.au/web-apis}, for the
\acronym{DPIRD} Weather 2.0 \acronym{API}.}

\item{status}{A \code{Boolean} string indicating whether to include closed
stations' metadata.  Use \code{TRUE} to include.  Defaults to \code{FALSE}.}

\item{rich}{A \code{Boolean} string indicating whether to return rich information
about DPIRD's weather station(s), this does not affect the SILO stations'
metadata, the variables for these observations will be \code{NA}.  Defaults to
\code{FALSE}.}
}
\value{
a \link[data.table:data.table]{data.table::data.table} of \acronym{BOM} weather stations'
metadata for stations available from \acronym{SILO} and weather stations'
metadata for stations available from \acronym{DPIRD}'s Weather 2.0
\acronym{API} with the following columns sorted by 'state' and
'station_name'.
\tabular{rl}{
\strong{station_code}:\tab Unique station code. \code{factor}\cr
\strong{station_name}:\tab Unique station name. \code{character}\cr
\strong{start}:\tab Date observations start. \code{date}\cr
\strong{end}:\tab Date observations end. \code{date}\cr
\strong{latitude}:\tab Latitude in decimal degrees. \code{numeric}\cr
\strong{longitude}:\tab Longitude in decimal degrees. \code{numeric}\cr
\strong{state}:\tab State in which the station is located. \code{character}\cr
\strong{elev_m}:\tab Station elevation in metres. \code{numeric}\cr
\strong{source}:\tab Organisation responsible for the data or station
maintenance. \code{character}\cr
\strong{status}:\tab Station status, one of 'open' or 'closed'. \code{character}\cr
\strong{wmo}:\tab World Meteorological Organisation, (\acronym{WMO}), number
if applicable. \code{numeric}\cr
\strong{\code{rich} values}\tab\cr
\strong{capabilities}:\tab a list of the station's capabilities (data that it
records). \code{character}\cr
\strong{probe_height}:\tab temperature probe height in metres. \code{double}\cr
\strong{rain_gauge_height}\tab rain gauge height in metres. \code{double}\cr
\strong{wind_probe_heights}:\tab wind probe heights always 3 metres, although
some have 10 metre probes. \code{integer}\cr
}
}
\description{
Download the latest station locations and metadata for stations in the
\acronym{SILO} and \acronym{DPIRD} \acronym{API}s.
}
\note{
For stations in the \acronym{SILO} \acronym{API}, \acronym{BOM} does
not report the exact date on which stations opened or closed, only the
year. Therefore the 'start' and 'end' columns will indicate January 1 of
the year that a station opened or closed, whereas stations in the
\acronym{DPIRD} network have the date to the day. For \acronym{BOM}
stations that are closed for the current year, this indicates that the
station closed sometime during the current year prior to the request being
made. \code{NA} in the current year indicates a station is still open.
}
\examples{
\dontshow{if (interactive()) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
# fetch SILO metadata
get_station_metadata()
\dontshow{\}) # examplesIf}
}
\references{
Station location and other metadata are sourced from the Australian Bureau of
Meteorology (\acronym{BOM}) webpage, Bureau of Meteorology Site Numbers:\cr
\url{http://www.bom.gov.au/climate/cdo/about/site-num.shtml} and
\url{http://www.bom.gov.au/climate/data/lists_by_element/stations.txt} and the
\acronym{DPIRD} Weather 2.0 \acronym{API}.
}
\author{
Adam H. Sparks, \email{adam.sparks@dpird.wa.gov.au}
}
