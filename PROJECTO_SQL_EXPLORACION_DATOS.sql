
SELECT * 
FROM Portafolio_Projects.DBO.CovidDeaths$
WHERE continent is not null 
ORDER BY 3, 4

--SELECT * 
--FROM Portafolio_Projects.DBO.CovidVaccinations$
--ORDER BY 3, 4

--Selecciona los datos

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM Portafolio_Projects.DBO.CovidDeaths$
WHERE continent is not null 
ORDER BY 1, 2

-- Total de Casos vs Total Decesos

-- Todos los países
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS Porcentaje_Decesos
FROM Portafolio_Projects.DBO.CovidDeaths$
WHERE continent is not null 
ORDER BY 1, 2

-- Colombia
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS Porcentaje_Decesos
FROM Portafolio_Projects.DBO.CovidDeaths$
WHERE location like '%colombia%' AND continent is not null 
ORDER BY 1, 2

-- Total Casos vs Población

-- Todos los países
SELECT location, date, total_cases, population, (total_cases/population) * 100 AS Porcentaje_Casos
FROM Portafolio_Projects.DBO.CovidDeaths$
WHERE continent is not null 
ORDER BY 1, 2

-- Colombia
SELECT location, date, total_cases, population, (total_cases/population) * 100 AS Porcentaje_Casos
FROM Portafolio_Projects.DBO.CovidDeaths$
WHERE location like '%colombia%' AND continent is not null 
ORDER BY 1, 2

-- Países con Mayores Tasas de Contagios
SELECT location, population, MAX(total_cases) as Pico_Contagios, population, MAX((total_cases/population)) * 100 AS Porcentaje_Casos
FROM Portafolio_Projects.DBO.CovidDeaths$
WHERE continent is not null 
GROUP BY location, population
ORDER BY Porcentaje_Casos desc

-- Países con Mayores Tasas de Mortalidad
SELECT location, MAX(cast(Total_Deaths as int)) as Total_Decesos
FROM Portafolio_Projects.DBO.CovidDeaths$
WHERE continent is not null 
GROUP BY location
ORDER BY Total_Decesos desc

-- Conteo de Muertes por Continente
SELECT continent, MAX(cast(Total_Deaths as int)) as Total_Decesos
FROM Portafolio_Projects.DBO.CovidDeaths$
WHERE continent is not null 
GROUP BY continent
ORDER BY Total_Decesos desc

SELECT location, MAX(cast(Total_Deaths as int)) as Total_Decesos
FROM Portafolio_Projects.DBO.CovidDeaths$
WHERE continent is null 
GROUP BY location
ORDER BY Total_Decesos desc

-- Tasa de Decesos por Continente
SELECT location, MAX(cast(total_cases as int)) AS Total_Casos, MAX(cast(total_deaths as int)) AS Total_Decesos, MAX(total_deaths/total_cases) * 100 AS Porcentaje_Decesos
FROM Portafolio_Projects.DBO.CovidDeaths$
WHERE continent is null
GROUP BY location
ORDER BY 1, 2

-- Tasa de Contagios por Continente
SELECT location, MAX(cast(total_cases as int)) AS Total_Casos, MAX(population) AS Poblacion, MAX(total_cases/population) * 100 AS Porcentaje_Casos
FROM Portafolio_Projects.DBO.CovidDeaths$
WHERE continent is null
GROUP BY location
ORDER BY 1, 2

-- Tasas Globales

SELECT date, SUM(New_cases) as Total_Casos, SUM(cast(New_deaths as int)) as Total_Decesos, SUM(cast(NEW_DEATHS as int))/SUM(NEW_CASES)*100 as Porcentaje_Decesos
FROM Portafolio_Projects.DBO.CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

SELECT SUM(New_cases) as Total_Casos, SUM(cast(New_deaths as int)) as Total_Decesos, SUM(cast(NEW_DEATHS as int))/SUM(NEW_CASES)*100 as Porcentaje_Decesos
FROM Portafolio_Projects.DBO.CovidDeaths$
WHERE continent is not null
ORDER BY 1, 2

-- Tasa de Población Vacunada

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, SUM(Cast(Vac.New_vaccinations as int)) OVER 
(Partition by Dea.Location Order by Dea.Location, Dea.Date) AS Total_Vacunados
FROM Portafolio_Projects.dbo.CovidDeaths$ Dea
Join Portafolio_Projects.DBO.CovidVaccinations$ Vac
ON Dea.location = Vac.location 
and Dea.date = Vac.date 
WHERE Dea.continent is not null
Order by 2, 3

-- CTE

WITH PopvsVac(Continent, Location, Date, Population, New_Vaccinations, Total_Vacunados)
as
(SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, SUM(Cast(Vac.New_vaccinations as int)) OVER 
(Partition by Dea.Location Order by Dea.Location, Dea.Date) AS Total_Vacunados
FROM Portafolio_Projects.dbo.CovidDeaths$ Dea
Join Portafolio_Projects.DBO.CovidVaccinations$ Vac
ON Dea.location = Vac.location 
and Dea.date = Vac.date 
WHERE Dea.continent is not null)

SELECT * , (Total_Vacunados/Population) * 100 as Porcentaje_Vacunado
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
Total_Vacunados numeric
)

Insert Into #PercentPopulationVaccinated
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, SUM(Cast(Vac.New_vaccinations as int)) OVER 
(Partition by Dea.Location Order by Dea.Location, Dea.Date) AS Total_Vacunados
FROM Portafolio_Projects.dbo.CovidDeaths$ Dea
Join Portafolio_Projects.DBO.CovidVaccinations$ Vac
ON Dea.location = Vac.location 
and Dea.date = Vac.date 
WHERE Dea.continent is not null

SELECT * , (Total_Vacunados/Population) * 100 as Porcentaje_Vacunado
FROM #PercentPopulationVaccinated

-- Creando Vista

Create View Porcentaje_Vacunado as 
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, SUM(Cast(Vac.New_vaccinations as int)) OVER 
(Partition by Dea.Location Order by Dea.Location, Dea.Date) AS Total_Vacunado
FROM Portafolio_Projects.dbo.CovidDeaths$ Dea
Join Portafolio_Projects.DBO.CovidVaccinations$ Vac
ON Dea.location = Vac.location 
and Dea.date = Vac.date 
WHERE Dea.continent is not null

SELECT *
FROM Porcentaje_Vacunado