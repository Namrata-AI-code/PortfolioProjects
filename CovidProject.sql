--Checking the first table
SELECT * 
FROM CovidProject..CovidDeaths$
ORDER BY 3,4

--Checking the second table
SELECT * 
FROM CovidProject..CovidVaccinations$
ORDER BY 3,4

--Select the data we need
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidProject..CovidDeaths$
ORDER BY 1,2

--Looking at total cases vs total deaths
SELECT location,date,total_cases,total_deaths,(NULLIF(CONVERT(float,total_deaths),0)/CONVERT(float,total_cases))*100 as DeathPercentage
FROM CovidProject..CovidDeaths$
WHERE location like '%india%'
ORDER BY 1,2

--Total cases vs population
--Shows what percent of the population got covid
SELECT location,date,total_cases,population,(NULLIF(CONVERT(float,total_cases),0)/CONVERT(float,population))*100 as CovidInfectedPopulationPercentage
FROM CovidProject..CovidDeaths$
WHERE location like '%india%'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population
SELECT location,population,MAX(total_cases) as HighestInfectionCount,MAX(NULLIF(CONVERT(float,total_cases),0)/CONVERT(float,population))*100 as PercentagePopulationInfected
FROM CovidProject..CovidDeaths$
GROUP BY location,population
ORDER BY 4 DESC

--Showing countries with the highest death count per population
SELECT location,MAX(CONVERT(float,total_deaths)) as HighestDeathCount
FROM CovidProject..CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY HighestDeathCount DESC

--Lets Break down things by continent--->Deaths in each continent
SELECT continent,MAX(CONVERT(float,total_deaths)) as HighestDeathCount
FROM CovidProject..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY HighestDeathCount DESC

--Global Numbers
SELECT SUM(cast(new_cases as float)) as NewCases,SUM(cast(new_deaths as float)) as NewDeaths,(SUM(cast(new_deaths as float))/SUM(cast(new_cases as float)))*100 as DeathPercentage
FROM CovidProject..CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

--Looking at Population vs Vaccinations
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.date,dea.location) as RollingPeopleVaccinated
FROM CovidProject..CovidDeaths$ dea
JOIN CovidProject..CovidVaccinations$ vac
ON  dea.date = vac.date AND dea.location=vac.location
WHERE dea.continent is not null
ORDER BY 2,3

--Using CTE
With PopvsVac(Continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.date,dea.location) as RollingPeopleVaccinated--,dea.location
FROM CovidProject..CovidDeaths$ dea
JOIN CovidProject..CovidVaccinations$ vac
ON  dea.date = vac.date AND dea.location=vac.location
WHERE dea.continent is not null
)
SELECT *,(RollingPeopleVaccinated/population)*100
FROM PopvsVac

--Temp table
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date dateTime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT into #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.date,dea.location) as RollingPeopleVaccinated--,dea.location
FROM CovidProject..CovidDeaths$ dea
JOIN CovidProject..CovidVaccinations$ vac
ON  dea.date = vac.date AND dea.location=vac.location
WHERE dea.continent is not null
SELECT *,(RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--Creating VIEW to store data for later visualizations
GO 
CREATE VIEW HighestDeathCounts as
SELECT continent,MAX(CONVERT(float,total_deaths)) as HighestDeathCount
FROM CovidProject..CovidDeaths$
WHERE continent is not null
GROUP BY continent
GO

SELECT *
FROM HighestDeathCounts