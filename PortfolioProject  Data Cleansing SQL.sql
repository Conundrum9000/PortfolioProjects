Select *
From PortfolioProject..CovidDeaths

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
Order by 1,2


--Total cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
from PortfolioProject..CovidDeaths
Where total_deaths <> 0 AND total_cases <> 0AND location like '%Belg%'
Order by 1,2


--Total cases vs population
-- Shows what percentage of population got Covid

Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfection
from PortfolioProject..CovidDeaths
Where total_deaths <> 0 AND total_cases <> 0AND location like '%Belg%'
Order by 1,2

-- Looking at countries with highest infection rate compared to population

Select Location, population, max(total_cases) as HighestInfectionCount ,max((total_cases/population))*100 as PercentPopulationInfection
from PortfolioProject..CovidDeaths
Where total_deaths <> 0 AND total_cases <> 0
Group By location, population
Order by PercentPopulationInfection desc

--Showing countries with Highest death per population

Select Location , max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
Where total_deaths <> 0 AND total_cases <> 0 AND continent is not null
Group By location
Order by TotalDeathCount desc


-- Break things down by continent

Select continent , max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
Where total_deaths <> 0 AND total_cases <> 0 AND continent is not null
Group By continent
Order by TotalDeathCount desc


-- world numbers

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where total_deaths <> 0 AND total_cases <> 0 AND  continent is not null
Order by 1,2

--Totala population vs vaccinatioin

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE
--Number of columns(with) must be the same as number of columns in query(select)
with  PopvsVac (continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100 as Percentage
From PopvsVac


--Temp Table

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *
From #PercentPopulationVaccinated



-- creating View to store data for later Visualizations

Create View PercentPopulationvaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,

Select *
from PercentPopulationvaccinated


