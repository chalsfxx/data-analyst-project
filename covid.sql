Select *

From [PortfolioProject-1]..CovidDeaths
Where continent is not null
order by 3,4 

--Select *

--From [PortfolioProject-1]..CovidVaccinations
--order by 3,4 

--select data that we are going to be using

Select Location, date, total_cases, new_cases,total_deaths,population

From [PortfolioProject-1]..CovidDeaths
Where continent is not null
order by 1,2


--looking at total cases vs total deaths 
--shows likelihood of dying if you contract covid in USA

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentatge
From [PortfolioProject-1]..CovidDeaths
Where Location like '%states%'
and continent is not null
order by 1,2


-- looking at total cases vs population 
--shows what % of population got covid 

Select Location, date, Population, total_cases, (total_cases/population) *100 as PopulationGotCovid
From [PortfolioProject-1]..CovidDeaths
Where Location like '%states%'
and continent is not null
order by 1,2

--Looking at countries with highest infection rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) *100 as HighestInfectedxPopulation
From [PortfolioProject-1]..CovidDeaths
--Where Location like '%states%'
group by Location, Population
order by HighestInfectedxPopulation desc

--showing countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as Totaldeathcount
From [PortfolioProject-1]..CovidDeaths
--Where Location like '%states%'
Where continent is not null
group by Location
order by Totaldeathcount desc

--Lets break things down by continent

--showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as Totaldeathcount
From [PortfolioProject-1]..CovidDeaths
--Where Location like '%states%'
Where continent is null
group by continent
order by Totaldeathcount desc


--GLOBAL NUMBERS 

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(new_cases)*100 as DeathPercentatge
From [PortfolioProject-1]..CovidDeaths
--Where location like '%states%'
where continent is not null
group by date
order by 1,2


--Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From [PortfolioProject-1]..CovidDeaths dea 
Join [PortfolioProject-1]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From [PortfolioProject-1]..CovidDeaths dea 
Join [PortfolioProject-1]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
--order by 2,3

)
select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE

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

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From [PortfolioProject-1]..CovidDeaths dea 
Join [PortfolioProject-1]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
--order by 2,3


select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations


Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From [PortfolioProject-1]..CovidDeaths dea 
Join [PortfolioProject-1]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
--order by 2,3