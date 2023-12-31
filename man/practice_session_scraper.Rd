% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/grand_prix_scraper.R
\name{practice_session_scraper}
\alias{practice_session_scraper}
\title{Scrape the formula1.com website for practice sessions for each Grand Prix for a given year.}
\usage{
practice_session_scraper(year, practice_session_number)
}
\arguments{
\item{year}{A numeric value.}

\item{practice_session_number}{A numeric value.}
}
\value{
A dataframe.
}
\description{
Scrape the formula1.com website for practice sessions for each Grand Prix for a given year.
}
\examples{
year <- 2022
practice_session_number <- 3
practice_session_scraper(year, practice_session_number)
}
