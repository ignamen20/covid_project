
# La primera querie va a ser de los números globales del covid
DROP VIEW IF EXISTS global_figures;
CREATE VIEW global_figures AS 
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases) AS death_percentage,
MAX(date) AS last_date
FROM coviddeaths
WHERE continent !=""
;


# Paises con mayor mortality_rate (definido a continuación)
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS mortality_rate,
MAX((total_deaths/total_cases)*100) AS max_death_perc
FROM coviddeaths
WHERE total_cases>1
GROUP BY location
;

# Viendo cómo fue evolucionando la tasa de mortalidad en Argentina
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS mortality_rate
FROM coviddeaths
WHERE total_cases>1 AND location like "Argentina"
;

/* paises con mayor tasa de infeccion y muerte. Elegimos con muertes mayores a 100 para que no sea una mortality_rate
artificial por retrasos de reporte etc  al cominezo del registro de datos
*/
CREATE VIEW cases_deaths_and_mortality_rates AS 
SELECT location, date, population, total_cases, total_deaths, (total_cases/population)*100 AS infection_rate,
(total_deaths/total_cases)*100 AS mortality_rate
FROM coviddeaths
WHERE total_deaths >1000
GROUP BY location
ORDER BY mortality_rate DESC
;

# Lo mismo que la querie anterior pero para países muy poblados
CREATE VIEW cases_deaths_and_mortality_rates_big_countries AS 
SELECT location, date, population, total_cases, total_deaths, (total_cases/population)*100 AS infection_rate, (total_deaths/total_cases)*100 AS mortality_rate
FROM coviddeaths
WHERE population>5000000 AND total_cases>100
ORDER BY mortality_rate DESC
;

# Paises poblados con mayor tasa de infeccion respecto a la población
CREATE VIEW infection_rate_population_big_countries AS 
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM coviddeaths
WHERE population>5000000
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC
;

# Paises con mayor tasa de infeccion respecto a la población
DROP VIEW IF EXISTS infection_rate_population;
CREATE VIEW infection_rate_population AS 
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PercentPopulationInfected,
MAX((total_deaths/population)*100) AS PercentPopulationDead
FROM coviddeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC
;

# Paises poblados con mayor cantidad de muertos, y mayor % de poblacion muerta por covid
DROP VIEW IF EXISTS death_rate_percentage_big_countries;
CREATE VIEW death_rate_percentage_big_countries AS 
SELECT location, population, MAX(total_deaths) AS HighestDeathCount, MAX((total_deaths/population)*100) AS PercentPopulationDead
FROM coviddeaths
WHERE population>5000000
GROUP BY location, population
ORDER BY PercentPopulationDead DESC
;

# Paises con mayor cantidad de muertos, y mayor % de poblacion muerta por covid
DROP VIEW IF EXISTS death_rate_percentage;
CREATE VIEW death_rate_percentage AS 
SELECT location, population, date, MAX(total_deaths) AS HighestDeathCount, MAX((total_deaths/population)*100) AS Percent_Population_Dead,
MAX((total_cases/population)*100) AS Percent_Population_Infected 
FROM coviddeaths
GROUP BY location, population, date
ORDER BY Percent_Population_Dead DESC
;

# Verificando la querie anterior usando total_deaths_per_million en vez de mi cálculo de total_deaths/population
SELECT location, population, MAX(total_deaths_per_million)
FROM coviddeaths
WHERE population>5000000 AND continent != '' 
GROUP BY location, population
ORDER BY MAX(total_deaths_per_million) DESC
;

# Muertes por continente
DROP VIEW IF EXISTS death_by_continent;
CREATE VIEW death_by_continent AS 
SELECT location , MAX(total_deaths) AS death_count, population, MAX(total_deaths)/population AS death_percentage
FROM coviddeaths
WHERE continent='' AND location IN ('Africa', 'North America', 'Asia', 'Europe', 'South America', 'Oceania')
GROUP BY location
ORDER BY total_deaths DESC
;

# Muertes y casos cada dia; a nivel mundial
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS death_perc
FROM coviddeaths
WHERE continent!=''
GROUP BY date
ORDER BY date
;

# Probando una join
SELECT dea.continent, dea.location,dea.date,  dea.population, vac.new_vaccinations
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
ORDER BY 3,2
;

/*looking at people vaccinated and population calculamos manualmente una rolling count
de personas vacunadas (en realidad vacunas aplicadas)
*/
SELECT dea.continent, dea.location, dea.date, vac.population, dea.new_vaccinations
, SUM(dea.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS 'Rolling_ppl_vaxed'
#,('Rpv'/population)*100 AS percent_vaccinated
FROM covidvaccinations dea
JOIN coviddeaths vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent != ''  
ORDER BY dea.location, dea.date;

/*el problema es que si trato de usar Rolling_ppl_vaxed para hacer una calculation, por ejemplo rpv/pop
no puedo porque estoy calculando una cosa 2 veces en una misma query. ahora vemos cómo solucionarlo
*/
#solución con Common Table Expressions
WITH Pop_vs_Vac(Continent, Location, Date, Population, Vaccinations, Rolling_people_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, vac.population, dea.new_vaccinations
, SUM(dea.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS 'Rpv'
FROM covidvaccinations dea
JOIN coviddeaths vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent != '' AND vac.continent!='' 
#ORDER BY dea.location, dea.date
)
SELECT *, (Rolling_people_vaccinated/Population)*100 AS 'rolling_percent_vaccinated'
FROM Pop_vs_Vac;

#Solución con temp_table
DROP TABLE IF EXISTS temp_table;

CREATE TABLE temp_table
(
Continent CHAR(255),
Location CHAR(255),
Date DATETIME,
Population BIGINT,
new_vaccinations INT,
Rolling_people_vaccinated BIGINT
);

INSERT INTO temp_table
SELECT dea.continent, dea.location, dea.date, vac.population, dea.new_vaccinations
, SUM(dea.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS 'Rpv'
FROM covidvaccinations dea
JOIN coviddeaths vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent != '' AND vac.continent!='' ;

SELECT * FROM temp_table;

# Ahora vamos a crear views para visualizaciones posteriores
CREATE VIEW percent_population_vaccinated AS 
SELECT dea.continent, dea.location, dea.date, vac.population, dea.new_vaccinations
, SUM(dea.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS 'Rpv'
FROM covidvaccinations dea
JOIN coviddeaths vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent != '' AND vac.continent!='';
