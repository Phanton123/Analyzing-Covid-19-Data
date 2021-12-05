SELECT * FROM PortfolioProject..Covid_deaths$
ORDER BY location ,date

-- Select Data that we are going to be starting with

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..Covid_deaths$
Where continent is not null 
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..Covid_deaths$
WHERE total_deaths is not null
ORDER BY location, date

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid in the country of india
SELECT location, date, total_cases,population, (total_cases/population)*100 AS PopulationPercerntInfected
FROM PortfolioProject..Covid_deaths$
WHERE location = 'India'
ORDER BY location, date

-- Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..Covid_deaths$
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population, using cast as total deats in varchar initally
SELECT location, population,MAX(CAST (total_deaths AS int)) AS MaximumDeaths
FROM PortfolioProject..Covid_deaths$
GROUP BY location
ORDER BY MaximumDeaths DESC


 -- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT continent,MAX(CAST (total_deaths AS int)) AS MaximumDeathsInContinent
FROM PortfolioProject..Covid_deaths$
WHERE continent is not null
GROUP BY continent
ORDER BY MaximumDeathsInContinent DESC


-- GLOBAL NUMBERS
SELECT date, SUM(new_cases)  AS GlobalCasesEverday, SUM(CAST(new_deaths AS int)) AS GlobalDeathsEveryday, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS deathpercentage
FROM PortfolioProject..Covid_deaths$
WHERE new_deaths <> 0
GROUP BY date
ORDER BY date

-- GLOBAL NUMBERS	OVERALL
SELECT  SUM(new_cases)  AS totalcases, SUM(CAST(new_deaths AS int)) AS totaldeaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS deathpercentage
FROM PortfolioProject..Covid_deaths$
WHERE new_deaths <> 0
--GROUP BY date
--ORDER BY date


--VACCINATIONS
--joining the two tables bases on location and date
--total population vs total vaccinations
--look at albiania we get the rolling vaccinations
SELECT dea.date, dea.continent,  dea.location,  dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint))  OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..Covid_deaths$ dea --dea is alias name
JOIN PortfolioProject..Covid_vaccinations$ vac --vac is alias name
ON dea.location = vac.location
AND dea.date = vac.date
ORDER BY dea.location, dea.date


--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated --destination Table
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Covid_deaths$ dea
Join PortfolioProject..Covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Covid_deaths$ dea
Join PortfolioProject..Covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


select * From PercentPopulationVaccinated