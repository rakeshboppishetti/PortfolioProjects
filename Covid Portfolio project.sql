select *
from PortfolioProject..CovidDeaths
--where continent is not null
order by 3,4

select *
from PortfolioProject..CovidVaccinations
order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2

--total case vs total deaths
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

select location,date,population,total_cases,(total_cases/population)*100 as TotalcasePercentage
from PortfolioProject..CovidDeaths
Where location like '%austral%'
order by 1,2

--Country with high infection rates
select location,population, Max(total_cases) as High_infection_count, Max(total_cases/population)*100 as Population_with_Highrate
from PortfolioProject..CovidDeaths
Group by location,population
order by 3,4 desc

--Countries with highest deathcount per population
select location,max(total_deaths) as Total_death_count
from PortfolioProject..CovidDeaths
Group by location
order by Total_death_count desc


select location,max(cast(total_deaths as int)) as Total_death_count
from PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by Total_death_count desc


select continent,max(cast(total_deaths as int)) as Total_death_count
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by Total_death_count desc

--looking at total population vs vaccinations

select CD.continent,CD.location,CD.date,cd.population, CV.new_vaccinations
from PortfolioProject..CovidVaccinations as CV
join PortfolioProject..CovidDeaths as CD
on CV.location=CD.location
and CV.date=CD.date
where CD.continent is not null
order by 2,3

select CD.continent,CD.location,CD.date,cd.population, CV.new_vaccinations,
SUM(convert(float,CV.new_vaccinations)) over (partition by CD.location order by CD.location, cd.date) as Rolling_Peoplevaccinated,
--(Rolling_Peoplevaccinated/population)*100
from PortfolioProject..CovidVaccinations as CV
join PortfolioProject..CovidDeaths as CD
on CV.location=CD.location
and CV.date=CD.date
where CD.continent is not null
order by 2,3


--USE CTE
WITH PopvsVac (continent, location,date,population,new_vaccinations, Rolling_Peoplevaccinated) 
as 
(
select CD.continent,CD.location,CD.date,cd.population, CV.new_vaccinations,
SUM(convert(float,CV.new_vaccinations)) over (partition by CD.location order by CD.location, cd.date) as Rolling_Peoplevaccinated
--(Rolling_Peoplevaccinated/population)*100
from PortfolioProject..CovidVaccinations as CV
join PortfolioProject..CovidDeaths as CD
on CV.location=CD.location
and CV.date=CD.date
where CD.continent is not null
--order by 2,3
)
select *, (Rolling_Peoplevaccinated/population)*100 
from PopvsVac

--use temp table
drop table if exists #Percent_People_Vaccinated
create table #Percent_People_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
Rolling_Peoplevaccinated numeric
)
insert into #Percent_People_Vaccinated
select CD.continent,CD.location,CD.date,cd.population, CV.new_vaccinations,
SUM(convert(float,CV.new_vaccinations)) over (partition by CD.location order by CD.location, cd.date) as Rolling_Peoplevaccinated
--(Rolling_Peoplevaccinated/population)*100
from PortfolioProject..CovidVaccinations as CV
join PortfolioProject..CovidDeaths as CD
on CV.location=CD.location
and CV.date=CD.date
where CD.continent is not null
--order by 2,3
select *, (Rolling_Peoplevaccinated/population)*100 
from #Percent_People_Vaccinated

--create view to store data for later visualisations

create view ppvc as
select CD.continent,CD.location,CD.date,cd.population, CV.new_vaccinations,
SUM(convert(float,CV.new_vaccinations)) over (partition by CD.location order by CD.location, cd.date) as Rolling_Peoplevaccinated
--(Rolling_Peoplevaccinated/population)*100
from PortfolioProject..CovidVaccinations as CV
join PortfolioProject..CovidDeaths as CD
on CV.location=CD.location
and CV.date=CD.date
where CD.continent is not null
--order by 2,3


select * from ppvc