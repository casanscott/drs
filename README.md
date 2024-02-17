
<img src="drs_logo.png" align="right" height="212" alt="" />

<br /> <br /> <br />

# DRS

<br /> <br />

**drs** (**D**ata for **R**acing **S**imulations) is an R package that
utilizes functions from the **rvest** and **dplyr** packages to scrape
and tidy data from the formula1.com website. It is designed to scrape
data for all Grand Prix weekends during a given year. A Grand Prix
weekend consists of practice sessions, qualifying, and a race.
Additionally, some weekends will also include a sprint race (an
abbreviated sprint race that is typically about 1/3 the length of a
normal race). If you currently follow Formula 1, you will recognize that
**DRS** also stands for *Drag Reduction System*, which is a crucial
component of Formula 1 cars that opens space in the rear wing thereby
reducing drag.

A typical Formula 1 weekend begins with three practice sessions. The
first two practice sessions (FP1 and FP2) are held on Friday. On
Saturday, the third practice session (FP3) is held, followed by
Qualifying. Qualifying determines the grid for the race on Sunday.
Currently, there are three heats in qualifying (Q1, Q2, and Q3). All
cars compete in the first heat (*Q1*), and the top 15 fastest times
advance to the 2nd heat, *Q2*. From there, the top 10 fastest times
during heat 2 advance to *Q3* (heat 3). The starting grid is determined
by a driver’s final qualifying position (sans penalties). The race takes
place on Sunday.

**drs** currently consists of four scraping functions:

- `practice_session_scraper()`: Scrapes the best times for a given
  practice session.
- `qualifying_scraper()`: Scrapes the best qualifying times during Q1,
  Q2, and Q3.
- `starting_grid_scraper()`: Scrapes the final starting grid positions
  for the Grand Prix.
- `race_result_scraper()()`: Scrapes the race results for a Grand Prix
  (i.e. finishing position and total time).

<br />

## Installation

You can install the development version of **drs** here:

``` r
install_github("casanscott/drs")
```

## Examples

These functions from **drs** require both the **tidyverse** and
**rvest** packages. The `practice_session_scraper()` requires two
arguments: `year` and `practice_session_number`. After loading those
libraries, along with **drs**, you can easily scrape data using a
function call like this:

``` r
library(tidyverse)
library(rvest)
library(drs)

# pull FP3 practice data
p32022 <- practice_session_scraper(2022, 3)

# View the first 6 rows
head(p32022)
#>   Position CarNumber   First       Last Driver                  Car     Time
#> 1        1         1     Max Verstappen    VER Red Bull Racing RBPT 1:32.544
#> 2        2        16 Charles    Leclerc    LEC              Ferrari 1:32.640
#> 3        3        11  Sergio      Perez    PER Red Bull Racing RBPT 1:32.791
#> 4        4        63  George    Russell    RUS             Mercedes 1:32.935
#> 5        5        55  Carlos      Sainz    SAI              Ferrari 1:33.053
#> 6        6        44   Lewis   Hamilton    HAM             Mercedes 1:33.121
#>      Race Circuit Year Time_secs
#> 1 bahrain bahrain 2022    92.544
#> 2 bahrain bahrain 2022    92.640
#> 3 bahrain bahrain 2022    92.791
#> 4 bahrain bahrain 2022    92.935
#> 5 bahrain bahrain 2022    93.053
#> 6 bahrain bahrain 2022    93.121
```

The rest of the **drs** web scraping functions require a single
argument: `year`.

The following function will scrape all qualifying results from 2022:

``` r

# pull qualifying data
quali2022 <- qualifying_scraper(2022)

# View the first 6 rows
head(quali2022)
#>   Position CarNumber    First       Last Driver                  Car Laps
#> 1        1        16  Charles    Leclerc    LEC              Ferrari   15
#> 2        2         1      Max Verstappen    VER Red Bull Racing RBPT   14
#> 3        3        55   Carlos      Sainz    SAI              Ferrari   15
#> 4        4        11   Sergio      Perez    PER Red Bull Racing RBPT   18
#> 5        5        44    Lewis   Hamilton    HAM             Mercedes   17
#> 6        6        77 Valtteri     Bottas    BOT   Alfa Romeo Ferrari   15
#>         Q1       Q2       Q3    Race Circuit Year Q1_secs Q2_secs Q3_secs
#> 1 1:31.471 1:30.932 1:30.558 bahrain bahrain 2022  91.471  90.932  90.558
#> 2 1:31.785 1:30.757 1:30.681 bahrain bahrain 2022  91.785  90.757  90.681
#> 3 1:31.567 1:30.787 1:30.687 bahrain bahrain 2022  91.567  90.787  90.687
#> 4 1:32.311 1:31.008 1:30.921 bahrain bahrain 2022  92.311  91.008  90.921
#> 5 1:32.285 1:31.048 1:31.238 bahrain bahrain 2022  92.285  91.048  91.238
#> 6 1:31.919 1:31.717 1:31.560 bahrain bahrain 2022  91.919  91.717  91.560
```

To scrape the starting grids for every Grand Prix during 2022, use the
following function call:

``` r

# pull starting grids
grids2022 <- starting_grid_scraper(2022)

# View the first 6 rows
head(grids2022)
#>   Position CarNumber    First       Last Driver                  Car     Time
#> 1        1        16  Charles    Leclerc    LEC              Ferrari 1:30.558
#> 2        2         1      Max Verstappen    VER Red Bull Racing RBPT 1:30.681
#> 3        3        55   Carlos      Sainz    SAI              Ferrari 1:30.687
#> 4        4        11   Sergio      Perez    PER Red Bull Racing RBPT 1:30.921
#> 5        5        44    Lewis   Hamilton    HAM             Mercedes 1:31.238
#> 6        6        77 Valtteri     Bottas    BOT   Alfa Romeo Ferrari 1:31.560
#>      Race Circuit Year Time_secs
#> 1 bahrain bahrain 2022    90.558
#> 2 bahrain bahrain 2022    90.681
#> 3 bahrain bahrain 2022    90.687
#> 4 bahrain bahrain 2022    90.921
#> 5 bahrain bahrain 2022    91.238
#> 6 bahrain bahrain 2022    91.560
```

To scrape the race results for every Grand Prix during 2022, use the
following function call:

``` r

# Pull race results
races2022 <- race_result_scraper(2022)

# View the first 6 rows
head(races2022)
#> # A tibble: 6 × 13
#>   Position CarNumber First   Last  Driver Car    Laps Time  Points Race  Circuit
#>   <chr>        <int> <chr>   <chr> <chr>  <chr> <int> <chr>  <int> <chr> <chr>  
#> 1 1               16 Charles Lecl… LEC    Ferr…    57 1:37…     26 bahr… bahrain
#> 2 2               55 Carlos  Sainz SAI    Ferr…    57 +5.5…     18 bahr… bahrain
#> 3 3               44 Lewis   Hami… HAM    Merc…    57 +9.6…     15 bahr… bahrain
#> 4 4               63 George  Russ… RUS    Merc…    57 +11.…     12 bahr… bahrain
#> 5 5               20 Kevin   Magn… MAG    Haas…    57 +14.…     10 bahr… bahrain
#> 6 6               77 Valtte… Bott… BOT    Alfa…    57 +16.…      8 bahr… bahrain
#> # ℹ 2 more variables: Year <dbl>, Time_secs <dbl>
```
