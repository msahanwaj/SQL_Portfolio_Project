select *
from Covaid ..covid_death
where continent is not null
order by 3,4

--select *
--from Covaid ..covid_vaccination
--order by 3,4


select  location,date,total_cases,new_cases,total_deaths,population
from Covaid ..covid_death
order by 1,2


--Total Casec vs Total Deaths

select  location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Covaid ..covid_death
where location like '%india%'
order by 1,2

-- Total Cases vs population
--What percentage of population got Covid

select  location,date,total_cases,population, (total_deaths/population)*100 as PercentageOfPopulationInfected
from Covaid ..covid_death
--where location like '%india%'
order by 1,2

--Looking at Countries with higest infection rate
select  location,population,max(total_cases) as HigestInfectionCount, max((total_deaths/population))*100 as PercentageOfPopulationInfected
from Covaid ..covid_death
--where location like '%india%'
Group by location,population
order by PercentageOfPopulationInfected desc

--Countries with Higest Death count per Population
select  location,MAX(cast(total_deaths as int)) as TotalDeathCount
from Covaid ..covid_death
where continent is not null
Group by location
order by TotalDeathCount desc

--BREAK THINGS DOWN BY CONTINENT
-- Shoeing the Continents with the higest death count per population
select  continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from Covaid ..covid_death
where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAN NUMBERS total_cases,total_deaths and DeathPercentages
select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from Covaid ..covid_death
where continent is not null
--Group by date
order by 1,2

--Total Population VS Vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as PeopleVaccinated
--(PeopleVaccinated/population)*100
from Covaid ..covid_death dea
join Covaid ..covid_vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 1,2,3

	--USE CTE
	with  popvsVac (continent,location,Date,Population,new_vaccinations, PeopleVaccinated)
	as
	(
	select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as PeopleVaccinated
--(PeopleVaccinated/population)*100
from Covaid ..covid_death dea
join Covaid ..covid_vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3
	)

	--TEMP TABLE

	DROP TABLE IF exists #PercentagePopulationVaccinated
	Create Table #PercentagePopulationVaccinated
	(
	continent nvarchar(255),
	Location nvarchar(255),
	Data datetime,
	Population numeric,
	New_vaccinations numeric,
	PeopleVaccinated numeric,
	)

	insert into #PercentagePopulationVaccinated
	select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as PeopleVaccinated
--(PeopleVaccinated/population)*100
from Covaid ..covid_death dea
join Covaid ..covid_vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 1,2,3
	select *,(PeopleVaccinated/population)*100
	from #PercentagePopulationVaccinated

	--Creating data to store data for later visualization
	create View PercentagePopulationVaccinated as
		select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as PeopleVaccinated
--(PeopleVaccinated/population)*100
from Covaid ..covid_death dea
join Covaid ..covid_vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 1,2,3

