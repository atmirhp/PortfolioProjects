/*
Queries used for Tableau Project
*/


-- 1

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject.coviddeaths
-- WHERE location like '%states%' 
WHERE continent IS NOT NULL -- where location = 'World'
-- GROUP BY date
ORDER BY 1,2;


-- 2

SELECT location, SUM(new_deaths) AS TotalDeathCount
FROM PortfolioProject.coviddeaths
-- WHERE location LIKE '%states%'
WHERE continent IS NULL AND location NOT IN ('World', 'European Union', 'International') AND location NOT LIKE '%income%'
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- 3

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject.coviddeaths
-- WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;


-- 4
SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject.coviddeaths
-- WHERE location LIKE '%states%'
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC;




/*
Original Queries
*/


SELECT continent, Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if one contacts covid in his/her country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.coviddeaths
Where location like '%states%' AND continent IS NOT NULL
ORDER BY 1,2;


-- Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT Location, date, Population, total_cases, (total_cases/Population)*100 AS PercentPopulationInfected
FROM PortfolioProject.coviddeaths
Where location like '%states%'
ORDER BY 1,2;


-- Countries with Highest Infection Rate compared to Population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/Population))*100 AS PercentPopulationInfected
FROM PortfolioProject.coviddeaths
-- Where location like '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC;


-- Showing Countries with Highest Death Count per Population
SELECT Location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.coviddeaths
-- Where location like '%states%'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;


-- By Continent

-- Continents with the highest deaths count per population
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.coviddeaths
-- Where location like '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;



-- Global Numbers
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject.coviddeaths
-- WHERE location like '%states%' 
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;


-- Global Death Percentage
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject.coviddeaths
-- WHERE location like '%states%' 
WHERE continent IS NOT NULL
ORDER BY 1,2;


-- Total Population vc Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- , MAX(RollingPeopleVaccinated)/Population*100
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;


-- Use CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- , MAX(RollingPeopleVaccinated)/Population*100
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS VaccinationsRate
FROM PopvsVac;


-- Use Temp Table
DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated
( 
Continent VARCHAR(255),
Location VARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
RollingPeopleVaccinated DOUBLE
);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- , MAX(RollingPeopleVaccinated)/Population*100
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac
ON dea.location = vac.location AND dea.date = vac.date;
-- WHERE dea.continent IS NOT NULL;
-- ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100 AS VaccinationsRate
FROM PercentPopulationVaccinated;



-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated_view AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- , MAX(RollingPeopleVaccinated)/Population*100
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
-- ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinated_view
