SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS mortality_rate
FROM coviddeaths
WHERE location like '%gentina';
#paises con mayor tasa de infeccion y muerte. mejor usar max(total_cases) porque la fecha se puede ir actualizando
SELECT location, date, population, total_cases, total_deaths, (total_cases/population)*100 AS infection_rate, (total_deaths/total_cases)*100 AS mortality_rate
FROM coviddeaths
WHERE population>5000000 AND total_cases>100
ORDER BY mortality_rate DESC;

#paises con mayor tasa de infeccion respecto a la población
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM coviddeaths
WHERE population>5000000
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

SELECT location, population, MAX(total_deaths) AS HighestDeathCount, MAX((total_deaths/population)*100) AS PercentPopulationDead
FROM coviddeaths
WHERE population>5000000
GROUP BY location, population
ORDER BY PercentPopulationDead DESC;
#the same thing as the last query but using dataset column total_deaths_per_million
SELECT location, population, MAX(total_deaths_per_million)
FROM coviddeaths
WHERE population>5000000 AND continent != '' 
GROUP BY location, population
ORDER BY MAX(total_deaths_per_million) DESC;

#muertes por continente
SELECT continent, MAX(total_deaths) AS death_count
FROM coviddeaths
WHERE continent!=''
GROUP BY continent
ORDER BY total_deaths DESC;

#muertes y casos cada dia 
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS death_perc
FROM coviddeaths
WHERE continent!=''
GROUP BY date
ORDER BY date;

#casos y muertes totales a nivel mundial
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS death_perc
FROM coviddeaths
WHERE continent!=''
ORDER BY date;

SELECT dea.continent, dea.location,dea.date,  dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations)
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
ORDER BY 3,2;

#looking at people vaccinated and population
SELECT dea.continent, dea.location, dea.date, vac.population, dea.new_vaccinations
, SUM(dea.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS 'Rolling_ppl_vaxed'
#,('Rpv'/population)*100 AS percent_vaccinated
FROM covidvaccinations dea
JOIN coviddeaths vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent != '' AND vac.continent!='' 
ORDER BY dea.location, dea.date;
#el problema es que si trato de usar Rolling_ppl_vaxed para hacer una calculation, por ejemplo rpv/pop
#no puedo porque estoy calculando una cosa 2 veces en una misma query. ahora vemos cómo solucionarlo

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

#Ahora vamos a crear views para visualizaciones posteriores

CREATE VIEW percent_population_vaccinated AS 
SELECT dea.continent, dea.location, dea.date, vac.population, dea.new_vaccinations
, SUM(dea.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS 'Rpv'
FROM covidvaccinations dea
JOIN coviddeaths vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent != '' AND vac.continent!='' ;
