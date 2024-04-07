
select *
from PortfolioProject..COVIDmortality
where continent is not null
order by 3,4

--select *
--from PortfolioProject..COVIDvaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..COVIDmortality
where continent is not null
order by 1,2

--Looking at fatality rate in Nigeria

select location, date, total_cases, new_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as Percentagefatality
from PortfolioProject..COVIDmortality
where location like '%nigeria%'
and continent is not null
order by 1,2

--Looking at Incidence rate in percentage in Nigeria

select location, date, population, total_cases, (cast(total_cases as float)/cast(population as float))*100 as Percentageincidence
from PortfolioProject..COVIDmortality
where location like '%Nigeria%'
order by 1,2

--Country with the highest incidence 

select location, population, max(total_cases) as highestincidence, max((cast(total_cases as float)/cast(population as float)))*100 as Percentageincidence
from PortfolioProject..COVIDmortality
--where location like '%nigeria%'
Group by location, population
order by Percentageincidence desc

--Showing countries with the highest fatality

select location, max((cast(total_deaths as int))) as totalmortality
from PortfolioProject..COVIDmortality
--where location like '%nigeria%'
where continent is not null
Group by location, population
order by totalmortality desc


--Mortality per continent

select continent, max((cast(total_deaths as int))) as totalmortality
from PortfolioProject..COVIDmortality
--where location like '%nigeria%'
where continent is not null
Group by continent
order by totalmortality desc

--Global numbers

select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, isnull(sum(new_deaths)/nullif(sum(new_cases),0),0) * 100 as percentage
from PortfolioProject..COVIDmortality
--where location like '%nigeria%'
where continent is not null
group by date
order by 1,2

select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, isnull(sum(new_deaths)/nullif(sum(new_cases),0),0) * 100 as deathpercentage
from PortfolioProject..COVIDmortality
--where location like '%nigeria%'
where continent is not null
group by date
order by 1,2

--Mortality rate worldwide as at 25th March 2024
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, isnull(sum(new_deaths)/nullif(sum(new_cases),0),0) * 100 as deathpercentage
from PortfolioProject..COVIDmortality
--where location like '%nigeria%'
where continent is not null
order by 1,2

--Looking at total population vs vaccinations
select mor.continent, mor.location, mor.date, mor.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by mor.location order by mor.location, mor.date) as Rollingpeoplevaccinated
from PortfolioProject..COVIDmortality mor
join PortfolioProject..COVIDvaccinations vac
	on mor.location = vac.location
	and mor.date = vac.date
where mor.continent is not null
order by 2, 3


--Use CTE

with popvsvac (continent, location, date, population,new_vaccinations, Rollingpeoplevaccinated)
as
(
select mor.continent, mor.location, mor.date, mor.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by mor.location order by mor.location, mor.date) as Rollingpeoplevaccinated
from PortfolioProject..COVIDmortality mor
join PortfolioProject..COVIDvaccinations vac
	on mor.location = vac.location
	and mor.date = vac.date
where mor.continent is not null
--order by 2, 3
)
select *, (Rollingpeoplevaccinated/population)* 100 as percentagevaccinated
from popvsvac



--Temp table

drop table if exists #percentpopulationvaccinated

create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select mor.continent, mor.location, mor.date, mor.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by mor.location order by mor.location, mor.date) as Rollingpeoplevaccinated
from PortfolioProject..COVIDmortality mor
join PortfolioProject..COVIDvaccinations vac
	on mor.location = vac.location
	and mor.date = vac.date
where mor.continent is not null
--order by 2, 3

select *, (Rollingpeoplevaccinated/population)* 100 as percentagevaccinated
from #percentpopulationvaccinated


--Creating view to store data for later visualization

CREATE View percentpopulationvaccinated as
select mor.continent, mor.location, mor.date, mor.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by mor.location order by mor.location, mor.date) as Rollingpeoplevaccinated
from PortfolioProject..COVIDmortality mor
join PortfolioProject..COVIDvaccinations vac
	on mor.location = vac.location
	and mor.date = vac.date
where mor.continent is not null
--order by 2, 3


select * 
from percentpopulationvaccinated