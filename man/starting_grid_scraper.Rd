% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/grand_prix_scraper.R
\name{starting_grid_scraper}
\alias{starting_grid_scraper}
\title{Scrape the formula1.com website for starting grids for each Grand Prix for a given year.}
\usage{
starting_grid_scraper(year)
}
\arguments{
\item{year}{A numeric value.}
}
\value{
A dataframe.
}
\description{
Scrape the formula1.com website for starting grids for each Grand Prix for a given year.
}
\examples{
year <- 2022
starting_grid_scraper(year)
}
