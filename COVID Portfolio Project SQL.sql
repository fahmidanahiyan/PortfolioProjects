SELECT *
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

--Total Cases vs Total Deaths
--Likelihood of dying from Covid in Bangladesh
SELECT location, date, total_cases, total_deaths, (total_deaths/NULLIF(total_cases,0))*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%desh%'
ORDER BY 1,2

--Total Cases vs Population
--Percentage of population that got Covid
SELECT location, date, population, total_cases, (total_cases/NULLIF(population,0))*100 as InfectedPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%desh%'
ORDER BY 1,2

--Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/NULLIF(population,0)))*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Countries with Highest Death Count per Population
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY location
ORDER BY TotalDeathCount DESC

--Continents with Highest Death Count per Population
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/NULLIF(SUM(new_cases),0))*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths

SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/NULLIF(SUM(new_cases),0))*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY date
ORDER BY 1

SELECT *
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject.dbo.CovidVaccinations
ORDER BY 3,4

--Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths as dea
JOIN PortfolioProject.dbo.CovidVaccinations as vac
	ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3

--CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths as dea
JOIN PortfolioProject.dbo.CovidVaccinations as vac
	ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent is not NULL
)
SELECT *,(RollingPeopleVaccinated/NULLIF(population,0))*100
FROM PopvsVac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths as dea
JOIN PortfolioProject.dbo.CovidVaccinations as vac
	ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent is not NULL

SELECT *,(RollingPeopleVaccinated/NULLIF(population,0))*100
FROM #PercentPopulationVaccinated

--Create view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths as dea
JOIN PortfolioProject.dbo.CovidVaccinations as vac
	ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent is not NULL

SELECT *
FROM PercentPopulationVaccinated