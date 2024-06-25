
SELECT * 
FROM Portafolio_Projects.DBO.CovidDeaths$
WHERE continent is not null 
ORDER BY 3, 4

--SELECT * 
--FROM Portafolio_Projects.DBO.CovidVaccinations$
--ORDER BY 3, 4

--Select the needed data

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM Portafolio_Projects.DBO.CovidDeaths$
WHERE continent is not null 
ORDER BY 1, 2

-- Total Cases vs Total Deaths Comparison

-- All Countries
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS Death_Percentage
FROM Portafolio_Projects.DBO.CovidDeaths$
WHERE continent is not null 
ORDER BY 1, 2

-- Colombia
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS Death_Percentage
FROM Portafolio_Projects.DBO.CovidDeaths$
WHERE location like '%colombia%' AND continent is not null 
ORDER BY 1, 2

-- Total Cases vs Population Comparison

-- All Countries
SELECT location, date, total_cases, population, (total_cases/population) * 100 AS Cases_Percentage
FROM Portafolio_Projects.DBO.CovidDeaths$
WHERE continent is not null 
ORDER BY 1, 2

-- Colombia
SELECT location, date, total_cases, population, (total_cases/population) * 100 AS Cases_Percentage
FROM Portafolio_Projects.DBO.CovidDeaths$
WHERE location like '%colombia%' AND continent is not null 
ORDER BY 1, 2

-- Countries with high infection rates
SELECT location, population, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population)) * 100 AS Cases_Percentage
FROM Portafolio_Projects.DBO.CovidDeaths$
WHERE continent is not null 
GROUP BY location, population
ORDER BY Cases_Percentage desc

-- Countries with high death rates
SELECT location, MAX(cast(Total_Deaths as int)) as TotalDeathCounts
FROM Portafolio_Projects.DBO.CovidDeaths$
WHERE continent is not null 
GROUP BY location
ORDER BY TotalDeathCounts desc

-- Death counts by continent
SELECT continent, MAX(cast(Total_Deaths as int)) as TotalDeathCounts
FROM Portafolio_Projects.DBO.CovidDeaths$
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCounts desc

SELECT location, MAX(cast(Total_Deaths as int)) as TotalDeathCounts
FROM Portafolio_Projects.DBO.CovidDeaths$
WHERE continent is null 
GROUP BY location
ORDER BY TotalDeathCounts desc

-- Death Rates by continent
SELECT location, MAX(cast(total_cases as int)) AS Total_Cases, MAX(cast(total_deaths as int)) AS Total_Deaths, MAX(total_deaths/total_cases) * 100 AS Death_Percentage
FROM Portafolio_Projects.DBO.CovidDeaths$
WHERE continent is null
GROUP BY location
ORDER BY 1, 2

-- Infection rate by continent
SELECT location, MAX(cast(total_cases as int)) AS Total_Cases, MAX(population) AS Population, MAX(total_cases/population) * 100 AS Cases_Percentage
FROM Portafolio_Projects.DBO.CovidDeaths$
WHERE continent is null
GROUP BY location
ORDER BY 1, 2

-- GLOBAL NUMBERS

SELECT date, SUM(New_cases) as Total_Cases, SUM(cast(New_deaths as int)) as Total_Deaths, SUM(cast(NEW_DEATHS as int))/SUM(NEW_CASES)*100 as Death_Percentage
FROM Portafolio_Projects.DBO.CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

SELECT SUM(New_cases) as Total_Cases, SUM(cast(New_deaths as int)) as Total_Deaths, SUM(cast(NEW_DEATHS as int))/SUM(NEW_CASES)*100 as Death_Percentage
FROM Portafolio_Projects.DBO.CovidDeaths$
WHERE continent is not null
ORDER BY 1, 2

-- Total People vs Vaccinations

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, SUM(Cast(Vac.New_vaccinations as int)) OVER 
(Partition by Dea.Location Order by Dea.Location, Dea.Date) AS Total_People_Vaccinated
FROM Portafolio_Projects.dbo.CovidDeaths$ Dea
Join Portafolio_Projects.DBO.CovidVaccinations$ Vac
ON Dea.location = Vac.location 
and Dea.date = Vac.date 
WHERE Dea.continent is not null
Order by 2, 3

-- CTE

WITH PopvsVac(Continent, Location, Date, Population, New_Vaccinations, Total_People_Vaccinated)
as
(SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, SUM(Cast(Vac.New_vaccinations as int)) OVER 
(Partition by Dea.Location Order by Dea.Location, Dea.Date) AS Total_People_Vaccinated
FROM Portafolio_Projects.dbo.CovidDeaths$ Dea
Join Portafolio_Projects.DBO.CovidVaccinations$ Vac
ON Dea.location = Vac.location 
and Dea.date = Vac.date 
WHERE Dea.continent is not null)

SELECT * , (Total_People_Vaccinated/Population) * 100 as Percentage_Vaccinated
FROM PopvsVac

-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Total_People_Vaccinated numeric
)

Insert Into #PercentPopulationVaccinated
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, SUM(Cast(Vac.New_vaccinations as int)) OVER 
(Partition by Dea.Location Order by Dea.Location, Dea.Date) AS Total_People_Vaccinated
FROM Portafolio_Projects.dbo.CovidDeaths$ Dea
Join Portafolio_Projects.DBO.CovidVaccinations$ Vac
ON Dea.location = Vac.location 
and Dea.date = Vac.date 
WHERE Dea.continent is not null

SELECT * , (Total_People_Vaccinated/Population) * 100 as Percentage_Vaccinated
FROM #PercentPopulationVaccinated

-- Creating View for Data Visualization

Create View Percentage_Vaccinated as 
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, SUM(Cast(Vac.New_vaccinations as int)) OVER 
(Partition by Dea.Location Order by Dea.Location, Dea.Date) AS Total_People_Vaccinated
FROM Portafolio_Projects.dbo.CovidDeaths$ Dea
Join Portafolio_Projects.DBO.CovidVaccinations$ Vac
ON Dea.location = Vac.location 
and Dea.date = Vac.date 
WHERE Dea.continent is not null

SELECT *
FROM Percentage_Vaccinated