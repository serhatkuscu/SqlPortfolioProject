Select * 
from PortfolioProject..CovidDeaths  
order by 3,4 

--SELECT *
--From PortfolioProject..CovidVaccinations 
--order by 3,4 

Select location,date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths 
order by 1,2 

---- Rate of deaths in the USA ---  

Select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths  
Where location like '%states%'
order by 1,2	 
--- 
-- What percentage of Population got covid --  

Select location,date, population , total_cases, (total_cases/population)*100 as CasePercentage
from PortfolioProject..CovidDeaths  
Where location like '%states%'
order by 1,2 

-------- 

Select location, population , MAX(total_cases) as HightestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths  
--Where location like '%states%' 
Group By location, population
order by PercentPopulationInfected Desc		


-- Showing countries with highest death count per population --- 

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount  
from PortfolioProject..CovidDeaths  
--Where location like '%states%' 
Group By location
order by TotalDeathCount Desc


-- By continent --  

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount  
from PortfolioProject..CovidDeaths  
--Where location like '%states%'  
Where continent is not null 
Group By continent
order by TotalDeathCount Desc

-- Global Numbers -- 

	Select date,SUM(new_cases) as TotalNewCases, SUM(CAST(new_deaths as int)) as totalDeaths, SUM(cast 
	(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
	from PortfolioProject..CovidDeaths  
	--Where location like '%states%'  
	Where continent is not null 
	Group By date
	order by 1,2  

--------- Totalcase Global ----- 

	Select SUM(new_cases) as TotalNewCases, SUM(CAST(new_deaths as int)) as totalDeaths, SUM(cast 
	(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
	from PortfolioProject..CovidDeaths  
	--Where location like '%states%'  
	Where continent is not null 
	--Group By date
	order by 1,2   

--------- Total population vs Vaccanitions

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, Sum(convert(int, vac.new_vaccinations )) over (Partition By dea.location order By dea.location, 
  dea.date) as RollingPeopleVaccinated
 From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac   
     on  dea.location = vac.location 
	 and dea.date = vac.date
where dea.continent is not null 
order by 2,3	 

---------------  Using Cte  

With PopvsVac (Continent ,Location, Date, Population, new_vaccinations, RollingPeopleVaccinated) 
as(

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, Sum(convert(int, vac.new_vaccinations )) over (Partition By dea.location order By dea.location, 
  dea.date) as RollingPeopleVaccinated
 From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac   
     on  dea.location = vac.location  
	 and dea.date = vac.date
where dea.continent is not null 
--order by 2,3	  
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


-- Temp Table 
Drop Table if exists  #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated 
( 
Continent	nvarchar(255), 
Location nvarchar(255),
Date Datetime,
Population numeric, 
New_vaccinations numeric, 
RollingPeoplevaccinated numeric 
)

Insert Into   #PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, Sum(convert(int, vac.new_vaccinations )) over (Partition By dea.location order By dea.location, 
  dea.date) as RollingPeopleVaccinated
 From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac   
     on  dea.location = vac.location  
	 and dea.date = vac.date
where dea.continent is not null 
--order by 2,3	  


Select *, (RollingPeopleVaccinated/Population)*100
from  #PercentPopulationVaccinated 


-- creating View to store data for later visulations -- 

create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, Sum(convert(int, vac.new_vaccinations )) over (Partition By dea.location order By dea.location, 
  dea.date) as RollingPeopleVaccinated
 From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac   
     on  dea.location = vac.location  
	 and dea.date = vac.date
where dea.continent is not null 
--order by 2,3