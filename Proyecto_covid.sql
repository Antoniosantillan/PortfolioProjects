--Complete Data
SELECT location, 
	   dates,
	   total_cases, 
	   new_cases, 
	   total_deaths,
	   population
FROM Muertes_covid
ORDER BY location
-- Global numbers
SELECT sum(new_cases) AS Total_cases,
	   sum(CAST(new_deaths as REAL)) AS Total_deaths,
	   (sum(CAST(new_deaths as REAL))/sum(new_cases))*100 AS DeathPercentage
FROM Muertes_covid
WHERE NOT continent="NULL"
ORDER BY 1,2
--DeathPercentage_of_infected
SELECT location,  
	   max (total_cases) as HighestInfected,
	   max(CAST(total_deaths as INTEGER)) asTotaldeath_count,
	   max((cast(total_deaths as real)/total_cases)*100) as DeathsPercentage_of_infected
FROM Muertes_covid
GROUP BY location
ORDER BY location
--Percentage_of_infected_population
SELECT location,
	   population,
	   max(CAST(total_cases as INTEGER)) as HighestInfected,
	   max((cast(total_cases as real)/population)*100) as InfectedPercentage_of_population
FROM Muertes_covid
GROUP By location
ORDER BY location
--DeathPercentage_of_population
SELECT location,  
	   population,
	   max(CAST(total_deaths as INTEGER)) as Totaldeath_count,
	   max((cast(total_deaths as real)/population)*100) as DeathsPercentage_of_Population
FROM Muertes_covid
GROUP BY location
ORDER BY DeathsPercentage_of_Population DESC
--Deaths_per_country
SELECT location,
	   max(CAST(total_deaths as INTEGER)) as Totaldeath_count
FROM Muertes_covid
WHERE NOT continent="NULL"
GROUP BY location
ORDER BY Totaldeath_count DESC
--Deaths_per_Continent
SELECT continent,
	   max(CAST(total_deaths as INTEGER)) as Totaldeath_count
FROM Muertes_covid
WHERE NOT continent="NULL"
GROUP BY continent
ORDER BY Totaldeath_count DESC
--Deaths_per_Territory
SELECT location,
	   max(CAST(total_deaths as INTEGER)) as Totaldeath_count
FROM Muertes_covid
WHERE continent is NULL
GROUP BY location
ORDER BY Totaldeath_count DESC
--Percent_Population_Vaccinated
WITH PopvsVac (Continent, Location, Dates,Population, New_vaccinations, Total_New_Vaccinations)
AS
(
SELECT MC.continent,
	   MC.location,
	   strftime(substr(MC.dates,7,4)||"-"||substr(MC.dates,4,2)|| "-"|| substr(MC.dates,1,2)) as Dates,
	   MC.population,
	   VC.new_vaccinations,
	   sum(VC.new_vaccinations) OVER (
								  PARTITION BY MC.location 
								  ORDER BY MC. location, strftime(substr(MC.dates,7,4)||"-"||substr(MC.dates,4,2)|| "-"|| substr(MC.dates,1,2))
								  ) AS Total_new_Vaccinations
FROM Muertes_covid AS MC
JOIN Vacunas_covid AS VC
	 ON MC.location=VC.location
	 AND MC.dates = VC.dates
WHERE MC.continent is NOT NULL
)
SELECT *, (CAST(Total_new_Vaccinations AS REAL)/Population)*100 AS Percent_Vaccination_People
FROM PopvsVac
--Creation_Table_Percent_Population_Vaccinated
DROP TABLE IF EXISTS PercentPopulationVaccinated --(Optional_comand)
CREATE TABLE IF NOT EXISTS PercentPopulationVaccinated
(
Continent TEXT,
Location TEXT,
Dates datetime,
Population NUMERIC,
New_vaccinations NUMERIC,
Total_new_Vaccinations NUMERIC
)
INSERT INTO PercentPopulationVaccinated
SELECT MC.continent,
	   MC.location,
	   strftime(substr(MC.dates,7,4)||"-"||substr(MC.dates,4,2)|| "-"|| substr(MC.dates,1,2)) as Dates,
	   MC.population,
	   VC.new_vaccinations,
	   sum(VC.new_vaccinations) OVER (
								  PARTITION BY MC.location 
								  ORDER BY MC. location, strftime(substr(MC.dates,7,4)||"-"||substr(MC.dates,4,2)|| "-"|| substr(MC.dates,1,2))
								  ) AS Total_new_Vaccinations
FROM Muertes_covid AS MC
JOIN Vacunas_covid AS VC
	 ON MC.location=VC.location
	 AND MC.dates = VC.dates
WHERE MC.continent is NOT NULL
--Table_query:
SELECT *, (CAST(Total_new_Vaccinations AS REAL)/Population)*100 AS Percent_Vaccination_People
FROM PercentPopulationVaccinated
---Creation of VIEW
DROP VIEW IF EXISTS PercentPopulationVaccinated--(Optional_comand)
CREATE VIEW PercentPopulationVaccinated 
AS
SELECT MC.continent,
	   MC.location,
	   strftime(substr(MC.dates,7,4)||"-"||substr(MC.dates,4,2)|| "-"|| substr(MC.dates,1,2)) as Dates,
	   MC.population,
	   VC.new_vaccinations,
	   sum(VC.new_vaccinations) OVER (
								  PARTITION BY MC.location 
								  ORDER BY MC. location, strftime(substr(MC.dates,7,4)||"-"||substr(MC.dates,4,2)|| "-"|| substr(MC.dates,1,2))
								  ) AS Total_new_Vaccinations
FROM Muertes_covid AS MC
JOIN Vacunas_covid AS VC
	 ON MC.location=VC.location
	 AND MC.dates = VC.dates
WHERE MC.continent is NOT NULL
--View_query:
SELECT *
FROM PercentPopulationVaccinated