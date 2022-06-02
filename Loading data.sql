DROP TABLE IF exists coviddeaths;
CREATE TABLE coviddeaths (
iso_code char(255),
continent char(255),
location char(255),
date datetime,
population BIGINT ,
total_cases	BIGINT,
new_cases INT,
new_cases_smoothed DOUBLE,
total_deaths BIGINT,
new_deaths INT,
new_deaths_smoothed DOUBLE,
total_cases_per_million DOUBLE,
new_cases_per_million DOUBLE,
new_cases_smoothed_per_million DOUBLE,
total_deaths_per_million DOUBLE,
new_deaths_per_million DOUBLE,
new_deaths_smoothed_per_million DOUBLE,
reproduction_rate DOUBLE  ,
icu_patients BIGINT,
icu_patients_per_million DOUBLE  ,
hosp_patients INT,
hosp_patients_per_million DOUBLE ,
weekly_icu_admissions INT,
weekly_icu_admissions_per_million DOUBLE ,
weekly_hosp_admissions INT,
weekly_hosp_admissions_per_million DOUBLE ,
total_tests BIGINT
);


SELECT *
FROM coviddeaths;

#cargado de datos a coviddeaths

LOAD DATA LOCAL INFILE 'C:\\Users\\ignam\\OneDrive\\Documents\\SQL\\Covid project v2\\coviddeaths.csv' INTO TABLE coviddeaths
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

SELECT COUNT(*)
FROM coviddeaths
;

#Tiene que coincidir con la cantidad de rows del CSV

DROP TABLE IF EXISTS covidvaccinations;

CREATE TABLE covidvaccinations(
iso_code char(255),	
continent char(255),	
location char(255),
date	 datetime,
new_tests	 BIGINT,
total_tests_per_thousand	DOUBLE,
new_tests_per_thousand	DOUBLE,
new_tests_smoothed	DOUBLE,
new_tests_smoothed_per_thousand	DOUBLE,
positive_rate	DOUBLE,
tests_per_case	DOUBLE,
tests_units	DOUBLE,
total_vaccinations	 BIGINT,
people_vaccinated	 BIGINT,
people_fully_vaccinated	 BIGINT,
total_boosters	 BIGINT,
new_vaccinations	 BIGINT,
new_vaccinations_smoothed	DOUBLE,
total_vaccinations_per_hundred	DOUBLE,
people_vaccinated_per_hundred	DOUBLE,
people_fully_vaccinated_per_hundred	DOUBLE,
total_boosters_per_hundred	DOUBLE,
new_vaccinations_smoothed_per_million	DOUBLE,
new_people_vaccinated_smoothed	DOUBLE,
new_people_vaccinated_smoothed_per_hundred	DOUBLE,
stringency_index	DOUBLE,
population_density	DOUBLE,
median_age	DOUBLE,
aged_65_older	DOUBLE,
aged_70_older	DOUBLE,
gdp_per_capita	DOUBLE,
extreme_poverty	DOUBLE,
cardiovasc_death_rate	DOUBLE,
diabetes_prevalence	DOUBLE,
female_smokers	DOUBLE,
male_smokers	DOUBLE,
handwashing_facilities	DOUBLE,
hospital_beds_per_thousand	DOUBLE,
life_expectancy	DOUBLE,
human_development_index	DOUBLE,
excess_mortality_cumulative_absolute	DOUBLE,
excess_mortality_cumulative	DOUBLE,
excess_mortality	DOUBLE,
excess_mortality_cumulative_per_million DOUBLE
);

#cargado de datos a covidvaccinatios
LOAD DATA LOCAL INFILE 'C:\\Users\\ignam\\OneDrive\\Documents\\SQL\\Covid project v2\\covidvaccinations.csv' INTO TABLE covidvaccinations
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

SELECT COUNT(*)
FROM covidvaccinations
;
#Coincide con el número de rows del CSV


#está terminado el cargado de datos.