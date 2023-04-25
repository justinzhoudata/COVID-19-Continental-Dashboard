-- Select all columns from the CovidDeaths$ table
SELECT *
FROM PortfolioProject1..CovidDeaths$
ORDER BY 3, 4;

-- Select only the columns we are going to be using, order them by location and date
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..CovidDeaths$
ORDER BY 1, 2;

-- Calculate the death percentage (total deaths / total cases) for the US and order by location and date
SELECT Location, date, total_cases, total_deaths, CAST(total_deaths AS float) / CAST(total_cases AS float)*100 AS deathpercent
FROM PortfolioProject1..CovidDeaths$
WHERE location LIKE '%states%'
ORDER BY 1, 2;

-- Calculate the prevalence (total cases / population) for the US and order by location and date
SELECT Location, date, total_cases, population, (total_cases/population)*100 as Prevalence
FROM PortfolioProject1..CovidDeaths$
WHERE location LIKE '%states%'
ORDER BY 1, 2;

-- Calculate the percentage of population that has been infected (total cases / population) for each location and order by highest percentage first
SELECT Location, MAX(total_cases) as HighestInfectionCount, population, Max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject1..CovidDeaths$
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc;

-- Calculate the total death count for each location and order by highest count first
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount desc;

-- Calculate the total death count for each continent and order by highest count first
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths$
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount desc;

-- Calculate global numbers for each date (total cases, total deaths, and death percentage) and order by date and total cases
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases), 0)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;

-- Retrieving data on Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) over (Partition by dea.Location, dea.Date) as RollingVaxCount
FROM PortfolioProject1..CovidDeaths$ dea
JOIN PortfolioProject1..CovidVaccinations$ vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
ORDER by 2,3

-- Using CTE to calculate Percent Population Vaccinated
WITH PopvsVax (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) over (Partition by dea.Location, dea.Date) as RollingVaxCount
FROM PortfolioProject1..CovidDeaths$ dea
JOIN PortfolioProject1..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as VaxPercent
FROM PopvsVax

-- Using a temporary table to store Percent Population Vaccinated data
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) over (Partition by dea.Location, dea.Date) as RollingVaxCount
FROM PortfolioProject1..CovidDeaths$ dea
JOIN PortfolioProject1..CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null

SELECT*, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating a View to store data for later visualizations on Percent Population Vaccinated
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) over (Partition by dea.Location, dea.Date) as RollingVaxCount
FROM PortfolioProject1..CovidDeaths$ dea
JOIN PortfolioProject1..CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null

-- Creating a View to store data for later visualizations on US COVID Prevalence over time
Create View USCovidPrev as
SELECT Location, date, total_cases, population, (total_cases/population)*100 as Prevalence
FROM PortfolioProject1..CovidDeaths$
WHERE location LIKE '%states%'

