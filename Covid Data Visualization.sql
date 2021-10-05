/*

Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/ 

Select *
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4


-- Select Data we will start with

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by location, date


-- Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract COVID-19 in your country

Select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where location = 'United States'
and continent is not null
order by location, date


-- Total Cases vs Population
-- Shows the percentage of the population that has contracted COVID-19

Select location, date, total_cases, population, (total_cases / population) * 100 as PercentagePopulationInfected
from PortfolioProject.dbo.CovidDeaths
--where location = 'United States'
where continent is not null
order by location, date


-- Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases / population)) * 100 as PercentPopulationInfected 
from PortfolioProject.dbo.CovidDeaths
--where location = 'United States'
group by location, population
order by PercentPopulationInfected DESC


-- Countries with Highest Death Count per Population

Select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--where location = 'United States'
where continent is not null
group by location
order by TotalDeathCount DESC



-- BREAKDOWN BY CONTINENT

-- Showing continents with the highest death count per population

Select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--where location = 'United States'
where continent is not null
group by continent
order by TotalDeathCount DESC



-- GLOBAL NUMBERS

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths
, (SUM(cast(new_deaths as int)) / SUM(new_cases)) * 100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
--group by date
order by 1,2



-- Total Population vs Vaccinations
-- Show Percentage of Population that has received at least one Covid vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
from PortfolioProject.dbo.CovidDeaths as dea
join PortfolioProject.dbo.CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Using CTE to perform calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject.dbo.CovidDeaths as dea
join PortfolioProject.dbo.CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac



-- Using Temp Table to perform calculation on Partition By in previous query

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject.dbo.CovidDeaths as dea
join PortfolioProject.dbo.CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

GO



-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject.dbo.CovidDeaths as dea
join PortfolioProject.dbo.CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
