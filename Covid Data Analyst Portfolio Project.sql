/*
Covid 19 Data exploration

Skills used: Joins, CTEs, Temp tables, Aggregate Dunction, Converting Data Types

*/

-- Select Data that we are going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent != ''
ORDER BY 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Hungary

SELECT location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'Hungary'
ORDER BY 1,2


-- Total Cases vs Population
-- Shows what percentage of population is infected with Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
--Where location = 'Hungary'
ORDER BY 1,2


-- Countries with highest infection rate compared to population

SELECT location, population, 
	MAX(total_cases) AS HighestInfectionCount,  
	Max((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--  Showing countries with highest death count

SELECT location,  MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent != ''
GROUP BY location
ORDER BY TotalDeathCount DESC

-- DATA BY CONTINENT
-- Showing continents with highest death

SELECT location,  MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent = ''
AND location IN ('World','Europe','North America','South America','European Union', 'Asia', 'Africa','Oceania')
GROUP BY location
ORDER BY TotalDeathCount DESC

-- GLOBAL DATA
-- Shows likelihood of dying if you contract covid globally

SELECT 
	SUM(new_cases) AS total_cases, 
	SUM(new_deaths) AS total_deaths, 
	SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent != ''

-- Looking at number of people fully vaccinated per country
 
SELECT dea.location, 
	MAX(vac.people_fully_vaccinated) AS PeopleFullyVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent != ''
GROUP BY dea.location
ORDER BY 1,2

-- Using CTE to determine the percentage of people fully vaccianted per population

-- There are countries where according to the data more than 100% of the population is fully vaccinated. This is caused by incorrect or outdated population data in the dataset.
-- There are countries which have no data about the number of people who are fully vaccinated, these countries have been excluded from the query

WITH FullyVaccPercent (Location, PeopleFullyVaccinated, Population)
AS
(
SELECT dea.location, MAX(vac.people_fully_vaccinated) AS PeopleFullyVaccinated, dea.population
FROM PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent != ''
GROUP BY dea.location, dea.population
)
Select *, (PeopleFullyVaccinated/population) * 100 AS PercentFullyVaccinated
FROM FullyVaccPercent
WHERE PeopleFullyVaccinated != 0
ORDER BY 4 DESC

-- Using Temp table to replicate the previous query

DROP TABLE IF EXISTS #temp_PeopleFullyVaccinated
CREATE TABLE #temp_PeopleFullyVaccinated (
	Location nvarchar(255),
	PeopleFullyVaccinated float,
	Population bigint
	)
INSERT INTO #temp_PeopleFullyVaccinated
SELECT dea.location, MAX(vac.people_fully_vaccinated) AS PeopleFullyVaccinated, dea.population
FROM PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent != ''
GROUP BY dea.location, dea.population

SELECT *, (PeopleFullyVaccinated/population) * 100
FROM #temp_PeopleFullyVaccinated
WHERE PeopleFullyVaccinated != 0
ORDER BY 4 DESC



