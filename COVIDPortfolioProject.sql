-- Retrieves all the columns where continent field has a value and orders the entire data by loaction and date
SELECT *
FROM CovidDeaths
ORDER BY 3,4


-- Retrieves the total number of tuples in the CovidDeaths table
SELECT COUNT(*)
FROM CovidDeaths
WHERE continent IS NOT NULL

-- Retrieving the fields of our major interest
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Retrieving data for India
SELECT location, date, total_cases, total_deaths, population
FROM CovidDeaths
WHERE location LIKE 'India' AND continent IS NOT NULL
ORDER BY 1,2


-- Finding the percentage of dying if you get infected by covid in India
-- total_cases is not null has been included to exclude the tuples when there were no covid cases in the country
-- Any other country information can also be extracted by entering that country name after LIKE
SELECT location, date, total_cases, total_deaths, (CONVERT(float, total_deaths)/CONVERT(Float,total_cases))*100 AS DeathPercentage
FROM CovidDeaths
WHERE location LIKE 'India' AND total_cases IS NOT NULL AND continent IS NOT NULL
ORDER BY 1,2


-- The below query helps us extract data of what percentage of the population was infected with covid
SELECT location, date, total_cases, population, (CONVERT(float, total_cases)/CONVERT(float, population))*100 AS InfectedPercentage
FROM CovidDeaths
WHERE total_cases IS NOT NULL AND continent IS NOT NULL
ORDER BY 1,2


-- Which country has the higest infected percentage in the world, the below query will help us know!
SELECT location, population, MAX(CAST(total_cases AS int)) AS MaxInfectedCount, (MAX(CONVERT(float,total_cases))/population)*100 AS InfectedPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY InfectedPercentage DESC

-- To know what percentage of people were infected in India, then we add a HAVING statement to the above query
SELECT location, population, MAX(CAST(total_cases AS int)) AS MaxInfectedCount, (MAX(CONVERT(float, total_cases))/population)*100 AS InfectedPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
HAVING location LIKE 'India'
-- You can extract data for other countries too

-- Writing the below statement will tell us what percentage of population died across different countries
SELECT location, population, MAX(CAST(total_deaths AS int)) AS MaxDeaths, (MAX(CONVERT(float, total_deaths))/population)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY DeathPercentage DESC

-- Continent which had highest death count
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
GROUP BY continent
HAVING continent IS NOT NULL
ORDER BY TotalDeathCount DESC

-- Retrieving the continent with highest death count per population
SELECT continent, (MAX(CAST(total_deaths AS int))/SUM(population))*100 AS DeathPercentage
FROM CovidDeaths
GROUP BY continent
HAVING continent IS NOT NULL
ORDER BY DeathPercentage DESC, continent


-- This query outputs the total population of every continent
SELECT continent, SUM(population)
FROM CovidDeaths
--WHERE continent LIKE 'Africa'
GROUP BY continent
HAVING continent IS NOT NULL
ORDER BY continent

-- Gives the info of total population in each location of every continent 
SELECT continent, location, AVG(population) AS TotalPopulation
FROM CovidDeaths
WHERE continent IS NOT NULL AND continent LIKE 'Africa'
GROUP BY location, continent
ORDER BY continent, location

-- Global death percentage
SELECT SUM(new_cases) total_cases, SUM(CAST(new_deaths AS int)) total_deaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL


-- The ratio of people fully vaccinated to people vaccinated in general all over the world
SELECT dea.continent, dea.location, MAX(CAST(vac.people_vaccinated AS float)) AS people_vaccinated, MAX(CAST(vac.people_fully_vaccinated AS float)) AS people_fully_vaccinated, ROUND((MAX(CAST(vac.people_fully_vaccinated AS float))/MAX(CAST(vac.people_vaccinated AS float)))*100, 2) AS FullyVaccinatedPercentage
FROM CovidDeaths dea JOIN CovidVaccinations vac
On dea.location = vac.location
GROUP BY dea.continent, dea.location
HAVING dea.continent IS NOT NULL

--People vaccinated over population using CTE
WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea JOIN CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac

--Using temp table to find people vaccinated over population
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255), location nvarchar(255), date datetime, population numeric, new_vaccinations numeric, RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea JOIN CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.continent, dea.location

SELECT *, (RollingPeopleVaccinated/population)*100 AS VaccinatedPercentage
FROM #PercentPopulationVaccinated


--Creating views for visualisation later
CREATE VIEW PopulationVaccinatedPercentage AS
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
 FROM CovidDeaths dea JOIN CovidVaccinations vac
 ON dea.location = vac.location AND dea.date = vac.date
 WHERE dea.continent IS NOT NULL

-- Now these views can be used as tables only and are also used to perform visualisations later.
SELECT *
FROM PopulationVaccinatedPercentage

-- This is an example of how a view can be used to further extract useful information from existing extracted information and visualise better
SELECT *
FROM PopulationVaccinatedPercentage
WHERE new_vaccinations IS NOT NULL
ORDER BY continent, location

-- Creating another view for global death percentage
CREATE VIEW GlobalDeathPercentage AS
 SELECT SUM(new_cases) total_cases, SUM(CAST(new_deaths AS int)) total_deaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPercentage
 FROM CovidDeaths
 WHERE continent IS NOT NULL

SELECT * 
FROM GlobalDeathPercentage

-- Creating a view to store the death percentage across various countries
CREATE VIEW DeathPercentageAcrossCountries AS
 SELECT location, population, MAX(CAST(total_deaths AS int)) AS MaxDeaths, (MAX(CONVERT(float, total_deaths))/population)*100 AS DeathPercentage
 FROM CovidDeaths
 WHERE continent IS NOT NULL
 GROUP BY location, population

SELECT * 
FROM DeathPercentageAcrossCountries