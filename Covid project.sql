Select *
From PortfolioProject..[covid vaccination]
where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..[Covid Deaths]
--Order by 3,4

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..[Covid Deaths]
order by 1,2

-- Looking at Total cases vs Total deaths
-- Shows the likelihood of dying in your country

Select location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..[Covid Deaths]
where location like '%states%'
order by 1,2

--Looking at total cases vs population
-- shows what % of population got covid

Select continent, date, total_cases, population, (Total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..[Covid Deaths]
--where location like '%states%'
where continent is not null
order by 1,2

--looking looking at countries with highest infection rate compared to population

Select continent, population, MAX(total_cases) as HighestInfectionCount, MAX((Total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..[Covid Deaths]
--where location like '%states%'
where continent is not null
Group by continent, population
order by PercentPopulationInfected desc

--showing countries with highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..[Covid Deaths]
--where location like '%states%'
where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Lets break things down by continent

-- showing continets with the highest death count per population 

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..[Covid Deaths]
--where location like '%states%'
where continent is not null
Group by continent
Order by TotalDeathCount desc


-- global numbers 

Select date, Sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..[Covid Deaths]
--where location like '%states%'
where continent is not null
group by date
order by 1,2

--Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
--, (rollingPeopleVaccinated/population)*100
from PortfolioProject..[Covid Deaths] dea
join PortfolioProject..[covid vaccination] vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
--, (rollingPeopleVaccinated/population)*100
from PortfolioProject..[Covid Deaths] dea
join PortfolioProject..[covid vaccination] vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac



-- Temp Count



Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
--, (rollingPeopleVaccinated/population)*100
from PortfolioProject..[Covid Deaths] dea
join PortfolioProject..[covid vaccination] vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--creating view to store data for later visual
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
--, (rollingPeopleVaccinated/population)*100
from PortfolioProject..[Covid Deaths] dea
join PortfolioProject..[covid vaccination] vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select*
from PercentPopulationVaccinated