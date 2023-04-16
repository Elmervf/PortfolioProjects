

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location = 'El Salvador'
	and continent is not null;

-- Looking at the Total Cases vs Population
--Shows what percentage of population got Covid

select location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
from CovidDeaths
where location = 'El Salvador';

-- Looking at Countries with Highest Infection Rate compared to Population

select location, max(total_cases) as HighestInfectionCount, population, max((total_cases/population))*100 as PopulationInfectedPercentage
from CovidDeaths
--where location = 'El Salvador'
group by location, population
order by PopulationInfectedPercentage desc;

-- Showing Countries with highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc;

-- Breaking thinkgs down by continent


-- Showing continents with highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc;


-- GLOBAL NUMBERS

select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by date desc;

select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null;


-- Looking at Total Population vs Vaccinations

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
from CovidDeaths cd
join CovidVaccinations cv on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null;

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from CovidDeaths cd
join CovidVaccinations cv on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null;

--,(RollingPeopleVaccinated/population)*100

-- USING CTE

with PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from CovidDeaths cd
join CovidVaccinations cv on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac;



-- TEMP TABLE

DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from CovidDeaths cd
join CovidVaccinations cv on cd.location = cv.location
	and cd.date = cv.date
--where cd.continent is not null

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated;


--CREATING VIEW FOR VISUALIZATION

create view PercentPopulationVaccinated as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from CovidDeaths cd
join CovidVaccinations cv on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null;

select *
from PercentPopulationVaccinated;