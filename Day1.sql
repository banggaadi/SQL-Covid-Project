--SELECT *
--FROM Portfolio..CovidDeaths
--order by 3,4

-- Select the data that we're going to use
-- Location, date, total case, new case, total death, population
-- order by location and date 
--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM Portfolio..CovidDeaths
--order by 1,2

-- Total case vs Total Death
-- add column for case/death percentage as death percentage in indonesia
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as 'Death Percentage'
FROM Portfolio..CovidDeaths
WHERE location like 'indonesia'
order by 2

-- Total case vs population	
SELECT location, date, total_cases, population, (total_cases/population)*100 as 'Covid Percentage'
FROM Portfolio..CovidDeaths
WHERE location like 'indonesia'
order by 2

-- Countries with highest infected
SELECT continent, location, population, MAX(total_cases) as 'TotalCase', MAX((total_cases/population))*100 as 'CovidPercentage'
FROM Portfolio..CovidDeaths
WHERE continent is not NULL
GROUP BY continent, location, population
ORDER BY CovidPercentage DESC

-- Countries with highest infected without Continent
SELECT location, population, MAX(total_cases) as 'TotalCase', MAX((total_cases/population))*100 as 'CovidPercentage'
FROM Portfolio..CovidDeaths
WHERE continent is not NULL
GROUP BY location, population
ORDER BY CovidPercentage DESC

-- Top 5 Countries Population with highest infected without Continent
SELECT TOP 5 location, population, MAX(total_cases) as 'TotalCase', MAX((total_cases/population))*100 as 'CovidPercentage'
FROM Portfolio..CovidDeaths
WHERE continent is not NULL
GROUP BY location, population
ORDER BY population DESC

-- Countries with highest death per population
SELECT location, MAX(cast(total_deaths as int)) as 'TotalDeath'
FROM Portfolio..CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeath DESC

-- Continent with highest death per population
SELECT continent, MAX(cast(total_deaths as int)) as 'TotalDeath'
FROM Portfolio..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeath DESC

-- Continent with highest death per population
SELECT location, MAX(cast(total_deaths as int)) as 'TotalDeath'
FROM Portfolio..CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeath DESC

-- Global Number 
SELECT date, SUM(new_cases) as 'TotalInfected', SUM(cast(new_deaths as int)) as 'TotalDeaths', (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as 'DeathPercentage'
FROM Portfolio..CovidDeaths
WHERE continent is not NULL
GROUP BY date
ORDER BY DeathPercentage DESC

-- TOTAL All
SELECT SUM(new_cases) as 'TotalInfected', SUM(cast(new_deaths as int)) as 'TotalDeaths', (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as 'DeathPercentage'
FROM Portfolio..CovidDeaths
WHERE continent is not NULL
ORDER BY DeathPercentage DESC

-- Total Population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3

-- Total Population vs Vaccination Rolled up
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as 'Total Vac'
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3

--With date
Select location, date, population, MAX(total_cases) as HighestCase, MAX(total_deaths) as HighestDeath
From Portfolio..CovidDeaths
--Where location like '%states%'
where continent is not null 
GROUP BY location, population, date
order by 1,2


--CTE
WITH PopvsVac (Continent, Location, Date, Population, NewVaccinations, TotalVac)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as 'Total Vac'
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
)

SELECT *, (TotalVac/Population)*100 as VaccinationPercentage
FROM PopvsVac

--Population Density vs Infected
SELECT location,  MAX(total_cases) as 'Total Infected', MAX(population) as 'Population', MAX(population_density) as 'Population Density', MAX((total_cases/population))*100 as 'CovidPercentage'
FROM Portfolio..CovidDeaths
WHERE continent is not NULL AND total_cases is not NULL
GROUP BY location
ORDER BY [Population] DESC


-- Create new table
DROP Table if exists #PopulationVaccinated
CREATE Table #PopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
NewVaccinations numeric,
TotalVac numeric
)

INSERT INTO #PopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as 'Total Vac'
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL

SELECT *, (TotalVac/Population)*100 as VaccinationPercentage
FROM #PopulationVaccinated

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as 'Total Vac'
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL

