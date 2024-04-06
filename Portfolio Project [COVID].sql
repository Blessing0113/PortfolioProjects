SELECT * FROM CovidDeaths WHERE continent IS NOT NULL ORDER BY 3,4
--SELECT * FROM CovidVaccinations ORDER BY 3,4

--Select Data that we are going to use

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortFolioProject..CovidDeaths
ORDER BY 1, 2

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--L:ooking the Total Cases vs Total Deaths(How many cases are there in the country and how many deaths do they have for their cases )
-- Shows the chances of dying if you contract covid
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 DeathPercentage
FROM PortFolioProject..CovidDeaths
WHERE location LIKE '%states%'
--WHERE location LIKE '%South Africa%'
ORDER BY 1, 2
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------




-- Look at the Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT location, date, population, total_cases, (total_cases/population) * 100 PercentageOfPeopleGotCovid
FROM PortFolioProject..CovidDeaths
WHERE location LIKE '%states%'
--WHERE location LIKE '%south africa%'
ORDER BY 1, 2
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(CAST(total_cases AS INT)) HighestInfectionCount, MAX((total_cases/population)) * 100 HighestInfectionRate
FROM PortFolioProject..CovidDeaths
GROUP BY location, population
ORDER BY HighestInfectionRate DESC
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--LET'S BREAK THING DOWN BY CONTINENT

SELECT location, MAX(CAST(total_deaths AS INT)) HighestDeathsPerContinent
FROM PortFolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY HighestDeathsPerContinent DESC


-- Showing the continets with the Highest Death counts per population

SELECT continent, MAX(CAST(total_deaths AS INT)) NumberOfDeathsPerCont
FROM PortFolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY NumberOfDeathsPerCont DESC

--Showing Countries with Highest Death Count per population

SELECT location, population, MAX(CAST(total_deaths AS INT)) NumberOfDeaths --, MAX((total_deaths/population)) * 100 HighestDeathsPerCountry 
FROM PortFolioProject..CovidDeaths
GROUP BY location, population
ORDER BY NumberOfDeaths DESC
 
SELECT location, MAX(total_deaths) NumberOfDeaths
FROM PortFolioProject..CovidDeaths
WHERE continent IS NOT NULL -- I addded WHERE NOT NULL because some of the values in location is ASIA and is NULL in the continents
GROUP BY location
ORDER BY NumberOfDeaths DESC
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- GLOBAL NUMBERS

SELECT date, SUM(CAST(new_cases AS INT)) totalNewCases, SUM(CAST(new_deaths AS INT)) totalNewDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases ) * 100 DeathsPercentage--total_cases, (total_cases/population) * 100 PercentageOfPeopleGotCovid
FROM PortFolioProject..CovidDeaths
WHERE continent IS NOT NULL
--WHERE location LIKE '%states%'
--WHERE location LIKE '%south africa%'
GROUP BY date
ORDER BY 1, 2

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--VACCINATIONS

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingPeopleVaccinated
FROM PortFolioProject..CovidDeaths dea
JOIN PortFolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3

--USE CTE

WITH PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingPeopleVaccinated
FROM PortFolioProject..CovidDeaths dea
JOIN PortFolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 1,2,3
)

SELECT *, (RollingPeopleVaccinated/population) * 100
FROM PopvsVac

-- TEMP TABLE 
DROP TABLE IF EXISTS  #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent NVARCHAR(255),
location NVARCHAR(255),
date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingPeopleVaccinated
FROM PortFolioProject..CovidDeaths dea
JOIN PortFolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 1,2,3

SELECT *, (RollingPeopleVaccinated/population) * 100
FROM #PercentPopulationVaccinated



-- Creating view to store data for later visualisations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingPeopleVaccinated
FROM PortFolioProject..CovidDeaths dea
JOIN PortFolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 1,2,3

SELECT *
FROM PercentPopulationVaccinated