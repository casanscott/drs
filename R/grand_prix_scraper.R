#' Scrape the formula1.com website for starting grids for each Grand Prix for a given year.
#'
#' @param year A numeric value.
#'
#' @return A dataframe.
#' @import tidyverse
#' @import rvest
#' @import dplyr
#' @import tidyr
#' @import stringr
#' @import lubridate
#' @export
#'
#' @examples
#' year <- 2022
#' starting_grid_scraper(year)
starting_grid_scraper <- function(year) {

  temp_year <- year

  f1_races_starts <- data.frame(
    empty_1 <- integer(),
    Pos <- integer(),
    No <- integer(),
    Driver <- character(),
    Car <- character(),
    Time <- character(),
    empty_2 <- integer(),
    race <- character(),
    year <- integer())


  temp_df <- grid_urls %>%
    dplyr::filter(year == temp_year)

  for (i in 1:length(temp_df$year_index)){

    tryCatch({

    temp_circuit <- temp_df$circuit[i]

    url_num <- temp_df$url[i]

    url <- paste0("https://www.formula1.com/en/results.html/",temp_year,"/races/", url_num, "/",
                  temp_circuit,"/starting-grid.html")

    f1_races_html <- read_html(url)

    temp_start <- f1_races_html %>%
      html_nodes(xpath = '//*[@id="maincontent"]/div/div[2]/div/div[2]/div[2]/div/div[3]/div[2]/table') %>%
      html_table(fill = TRUE) %>%
      as.data.frame()

    names(temp_start) <- c("Pos", "No", "Driver",  "Car", "Time")

    temp_race <- temp_df$race[i]

    temp_start <- temp_start %>%
      mutate(Race = temp_race,
             Circuit = temp_circuit,
             Year = temp_year)





    f1_races_starts <- rbind(f1_races_starts, temp_start)

     }, error=function(e){})

  }

  qualifying_times <- f1_races_starts %>%
    mutate(Driver = str_replace(Driver, 'De Vries', 'DeVries')) %>%
    separate(Driver, c("First", "Lastname")) %>%
    mutate(Last = str_sub(Lastname, 1, nchar(Lastname) - 3),
           Driver = str_sub(Lastname, -3)) %>%
    dplyr::select(-Lastname) %>%  # Remove the original column
    relocate(Last, Driver, .after = First) %>%  # Relocate after "First" column
    dplyr::rename('Position' = 'Pos',
                  'CarNumber' = 'No') %>%
    mutate(Driver = ifelse(Driver == 'ikk', 'RAI', Driver),
           Driver = ifelse(Driver == 'Resta', 'DIV', Driver),
           Driver = ifelse(Driver == 'Vergne', 'JEV', Driver)) %>%
    mutate(Last = ifelse(Driver == 'RAI', "Raikkonen", Last),
           Last = ifelse(Driver == 'DIV', 'di Resta', Last),
           Last = ifelse(Driver == 'JEV', 'Eric Vergne', Last)) %>%
    dplyr::select(Position, CarNumber, First, Last, Driver, Car, Time, Race, Circuit, Year) %>%
    mutate(Time_secs = ifelse(Race == 'sakhir', paste0("0:", Time), Time),
           Time_secs = period_to_seconds(ms(Time_secs)))

  return(qualifying_times)
}



#' Scrape the formula1.com website for race results for each Grand Prix for a given year.
#'
#' @param year A numeric value.
#'
#' @return A dataframe.
#' @import tidyverse
#' @import rvest
#' @import dplyr
#' @import tidyr
#'@import lubridate
#' @export
#'
#' @examples
#' year <- 2022
#' race_result_scraper(year)
race_result_scraper <- function(year) {

  temp_year <- year

  f1_races_starts <- data.frame(
    empty_1 <- integer(),
    Pos <- integer(),
    No <- integer(),
    Driver <- character(),
    Car <- character(),
    Time <- character(),
    empty_2 <- integer(),
    race <- character(),
    year <- integer())


  temp_df <- race_urls %>%
    dplyr::filter(year == temp_year)

  for (i in 1:length(temp_df$year_index)){

    tryCatch({

    temp_circuit <- temp_df$circuit[i]

    url_num <- temp_df$url[i]

    url <- paste0("https://www.formula1.com/en/results.html/",temp_year,"/races/", url_num, "/",
                  temp_circuit,"/race-result.html")

    f1_races_html <- read_html(url)

    temp_start <- f1_races_html %>%
      html_nodes(xpath = '//*[@id="maincontent"]/div/div[2]/div/div[2]/div[2]/div/div[3]/div[2]/table') %>%
      html_table(fill = TRUE) %>%
      as.data.frame()

    names(temp_start) <- c("Pos", "No", "Driver",  "Car", "laps", "Time", "pts")

    temp_race <- temp_df$race[i]

    temp_start <- temp_start %>%
      mutate(Race = temp_race,
             Circuit = temp_circuit,
             Year = temp_year)





    f1_races_starts <- rbind(f1_races_starts, temp_start)

     }, error=function(e){})

  }

  race_times <- f1_races_starts %>%
    mutate(Driver = str_replace(Driver, 'De Vries', 'DeVries')) %>%
    separate(Driver, c("First", "Lastname")) %>%
    mutate(Last = str_sub(Lastname, 1, nchar(Lastname) - 3),
           Driver = str_sub(Lastname, -3)) %>%
    dplyr::select(-Lastname) %>%  # Remove the original column
    relocate(Last, Driver, .after = First) %>%  # Relocate after "First" column
    dplyr::rename('Position' = 'Pos',
                  'CarNumber' = 'No',
                  'Laps' = 'laps',
                  'Points' = 'pts') %>%
    mutate(Driver = ifelse(Driver == 'ikk', 'RAI', Driver),
           Driver = ifelse(Driver == 'Resta', 'DIV', Driver),
           Driver = ifelse(Driver == 'Vergne', 'JEV', Driver)) %>%
    mutate(Last = ifelse(Driver == 'RAI', "Raikkonen", Last),
           Last = ifelse(Driver == 'DIV', 'di Resta', Last),
           Last = ifelse(Driver == 'JEV', 'Eric Vergne', Last)) %>%
    dplyr::select(Position, CarNumber, First, Last, Driver, Car, Laps, Time, Points,
                  Race, Circuit, Year) %>%
    mutate(Time_secs = ifelse(Race == 'sakhir', paste0("0:", Time), Time),
           Time_secs = period_to_seconds(ms(Time_secs))) %>%
    group_by(Race) %>%
    mutate(fastest_time = ifelse(Position == 1,
                                 lubridate::period_to_seconds(hms(str_replace(Time, "0 days 0", ""))),
                                 NA),
           fastest_time = ifelse(Position == 1, fastest_time, min(fastest_time, na.rm = T)),
           Time_secs = ifelse(Position == 1, fastest_time, Time_secs + fastest_time)) %>%
    dplyr::select(-fastest_time) %>%
    ungroup() %>%
    dplyr::filter(!str_detect(Position, "Note"))




  return(race_times)
}

#' Scrape the formula1.com website for sprint grids for each sprint weekend for a given year.
#'
#' @param year A numeric value.
#'
#' @return A dataframe.
#' @import tidyverse
#' @import rvest
#' @import dplyr
#' @import tidyr
#' @import lubridate
#' @export
#'
#' @examples
#' year <- 2022
#' sprint_grid_scraper(year)
sprint_grid_scraper <- function(year) {

  temp_year <- year

  f1_races_starts <- data.frame(
    Pos <- integer(),
    No <- integer(),
    Driver <- character(),
    Car <- character(),
    Time <- character(),
    race <- character(),
    year <- integer())


  temp_df <- race_urls %>%
    dplyr::filter(is.na(year_index)) %>%
    dplyr::filter(year == temp_year)

  for (i in 1:length(temp_df$year_index)){

    tryCatch({

    temp_circuit <- temp_df$circuit[i]

    url_num <- temp_df$url[i]

    url <- paste0("https://www.formula1.com/en/results.html/",temp_year,"/races/", url_num, "/",
                  temp_circuit,"/starting-grid.html")

    f1_races_html <- read_html(url)

    temp_start <- f1_races_html %>%
      html_nodes(xpath = '//*[@id="maincontent"]/div/div[2]/div/div[2]/div[2]/div/div[3]/div[2]/table') %>%
      html_table(fill = TRUE) %>%
      as.data.frame()

    names(temp_start) <- c("Pos", "No", "Driver",  "Car")

    temp_race <- temp_df$race[i]

    temp_start <- temp_start %>%
      mutate(Race = temp_race,
             Circuit = temp_circuit,
             Year = temp_year)





    f1_races_starts <- rbind(f1_races_starts, temp_start)

    }, error=function(e){})

  }

  sprint_grid <- f1_races_starts %>%
    mutate(Driver = str_replace(Driver, 'De Vries', 'DeVries')) %>%
    separate(Driver, c("First", "Lastname")) %>%
    mutate(Last = str_sub(Lastname, 1, nchar(Lastname) - 3),
           Driver = str_sub(Lastname, -3)) %>%
    dplyr::select(-Lastname) %>%  # Remove the original column
    relocate(Last, Driver, .after = First) %>%
    dplyr::rename('Position' = 'Pos',
                  'CarNumber' = 'No') %>%
    mutate(Driver = ifelse(Driver == 'ikk', 'RAI', Driver),
           Driver = ifelse(Driver == 'Resta', 'DIV', Driver),
           Driver = ifelse(Driver == 'Vergne', 'JEV', Driver)) %>%
    mutate(Last = ifelse(Driver == 'RAI', "Raikkonen", Last),
           Last = ifelse(Driver == 'DIV', 'di Resta', Last),
           Last = ifelse(Driver == 'JEV', 'Eric Vergne', Last)) %>%
    dplyr::select(Position, CarNumber, First, Last, Driver, Car, Time, Race, Circuit, Year) %>%
      ungroup() %>%
      dplyr::filter(!str_detect(Position, "Note"))





  return(sprint_grid)
}

#' Scrape the formula1.com website for practice sessions for each Grand Prix for a given year.
#'
#' @param year A numeric value.
#' @param practice_session_number A numeric value.
#'
#' @return A dataframe.
#' @import tidyverse
#' @import rvest
#' @import dplyr
#' @import tidyr
#' @import lubridate
#' @export
#'
#' @examples
#' year <- 2022
#' practice_session_number <- 3
#' practice_session_scraper(year, practice_session_number)
practice_session_scraper <- function(year, practice_session_number) {

  temp_practice_session_number <- practice_session_number

  temp_year <- year

  f1_races_starts <- data.frame(
    Pos <- integer(),
    No <- integer(),
    Driver <- character(),
    Car <- character(),
    Time <- character(),
    race <- character(),
    year <- integer())


  temp_df <- grid_urls %>%
    dplyr::filter(year == temp_year)

  for (i in 1:length(temp_df$year_index)){

    tryCatch({

    temp_circuit <- temp_df$circuit[i]

    url_num <- temp_df$url[i]

    url <- paste0("https://www.formula1.com/en/results.html/",temp_year,"/races/", url_num, "/",
                  temp_circuit,"/practice-", temp_practice_session_number,".html")

    f1_races_html <- read_html(url)


    temp_start <- f1_races_html %>%
      html_nodes(xpath = '//*[@id="maincontent"]/div/div[2]/div/div[2]/div[2]/div/div[3]/div[2]/table') %>%
      html_table(fill = TRUE) %>%
      as.data.frame()

    if(length(names(temp_start)) > 9) next

    names(temp_start) <- c("Pos", "No", "Driver",  "Car", "Time", "Gap", "Laps")

    temp_race <- temp_df$race[i]

    temp_start <- temp_start %>%
      mutate(Race = temp_race,
             Circuit = temp_circuit,
             Year = temp_year)





    f1_races_starts <- rbind(f1_races_starts, temp_start)

      }, error=function(e){})

  }

  practice_times <- f1_races_starts %>%
    mutate(Driver = str_replace(Driver, 'De Vries', 'DeVries')) %>%
    separate(Driver, c("First", "Lastname")) %>%
    mutate(Last = str_sub(Lastname, 1, nchar(Lastname) - 3),
           Driver = str_sub(Lastname, -3)) %>%
    dplyr::select(-Lastname) %>%  # Remove the original column
    relocate(Last, Driver, .after = First) %>%
    dplyr::rename('Position' = 'Pos',
                  'CarNumber' = 'No') %>%
    mutate(Driver = ifelse(Driver == 'ikk', 'RAI', Driver),
           Driver = ifelse(Driver == 'Resta', 'DIV', Driver),
           Driver = ifelse(Driver == 'Vergne', 'JEV', Driver)) %>%
    mutate(Last = ifelse(Driver == 'RAI', "Raikkonen", Last),
           Last = ifelse(Driver == 'DIV', 'di Resta', Last),
           Last = ifelse(Driver == 'JEV', 'Eric Vergne', Last)) %>%
    dplyr::select(Position, CarNumber, First, Last, Driver, Car, Time, Race, Circuit, Year) %>%
    mutate(Time_secs = ifelse(Race == 'sakhir', paste0("0:", Time), Time),
           Time_secs = period_to_seconds(ms(Time_secs)))

  return(practice_times)
}


#' Scrape the formula1.com website for qualifying results for each Grand Prix for a given year.
#'
#' @param year A numeric value.
#'
#' @return A dataframe.
#' @import tidyverse
#' @import rvest
#' @import dplyr
#' @import tidyr
#' @import lubridate
#' @export
#'
#' @examples
#' year <- 2022
#' sprint_grid_scraper(year)
qualifying_scraper <- function(year) {

  temp_year <- year

  f1_races_starts <- data.frame(
    empty_1 <- integer(),
    Pos <- integer(),
    No <- integer(),
    Driver <- character(),
    Car <- character(),
    Time <- character(),
    empty_2 <- integer(),
    race <- character(),
    year <- integer())


  temp_df <- grid_urls %>%
    dplyr::filter(year == temp_year)

  for (i in 1:length(temp_df$year_index)){

    tryCatch({

    temp_circuit <- temp_df$circuit[i]

    url_num <- temp_df$url[i]

    url <- paste0("https://www.formula1.com/en/results.html/",temp_year,"/races/", url_num, "/",
                  temp_circuit,"/qualifying.html")

    f1_races_html <- read_html(url)

    temp_start <- f1_races_html %>%
      html_nodes(xpath = '//*[@id="maincontent"]/div/div[2]/div/div[2]/div[2]/div/div[3]/div[2]/table') %>%
      html_table(fill = TRUE) %>%
      as.data.frame()

    names(temp_start) <- c("Pos", "No", "Driver",  "Car", "Q1", "Q2", "Q3", "Laps")

    temp_race <- temp_df$race[i]

    temp_start <- temp_start %>%
      mutate(Race = temp_race,
             Circuit = temp_circuit,
             Year = temp_year)





    f1_races_starts <- rbind(f1_races_starts, temp_start)

      }, error=function(e){})

  }

  qualifying_times <- f1_races_starts %>%
    mutate(Driver = str_replace(Driver, 'De Vries', 'DeVries')) %>%
    separate(Driver, c("First", "Lastname")) %>%
    mutate(Last = str_sub(Lastname, 1, nchar(Lastname) - 3),
           Driver = str_sub(Lastname, -3)) %>%
    dplyr::select(-Lastname) %>%  # Remove the original column
    relocate(Last, Driver, .after = First) %>%
    dplyr::rename('Position' = 'Pos',
                  'CarNumber' = 'No') %>%
    mutate(Driver = ifelse(Driver == 'ikk', 'RAI', Driver),
           Driver = ifelse(Driver == 'Resta', 'DIV', Driver),
           Driver = ifelse(Driver == 'Vergne', 'JEV', Driver)) %>%
    mutate(Last = ifelse(Driver == 'RAI', "Raikkonen", Last),
           Last = ifelse(Driver == 'DIV', 'di Resta', Last),
           Last = ifelse(Driver == 'JEV', 'Eric Vergne', Last)) %>%
    dplyr::select(Position, CarNumber, First, Last, Driver, Car, Laps, Q1, Q2, Q3, Race, Circuit, Year) %>%
    mutate(Q1_secs = ifelse(Race == 'sakhir', paste0("0:", Q1), Q1),
           Q1_secs = period_to_seconds(ms(Q1_secs)),
           Q2_secs = ifelse(Race == 'sakhir', paste0("0:", Q2), Q2),
           Q2_secs = period_to_seconds(ms(Q2_secs)),
           Q3_secs = ifelse(Race == 'sakhir', paste0("0:", Q3), Q3),
           Q3_secs = period_to_seconds(ms(Q3_secs))) %>%
    ungroup() %>%
    dplyr::filter(!str_detect(Position, "Q"))

  return(qualifying_times)
}


