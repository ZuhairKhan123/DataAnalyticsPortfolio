SELECT *
FROM ['owid-covid-deaths$']
WHERE continent is not null
ORDER BY 3, 4

--SELECT *
--FROM ['owid-covid-vaccines$']
--ORDER BY 3, 4

-- Select Data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM ['owid-covid-deaths$']
ORDER BY 1,2

-- Total cases vs deaths
-- Shows likelihood of death in States
SELECT Location, date, total_cases, total_deaths, (total_deaths/NULLIF(total_cases,0))*100 as death_percentage
FROM ['owid-covid-deaths$']
Where location like '%States%'
ORDER BY 1,2

-- looking at total cases vs population
SELECT Location, date, total_cases, population, (total_cases/population)*100 as PopulationWithCovid
FROM ['owid-covid-deaths$']
Where location like '%States%'
ORDER BY 1,2

--  Looking at countries with highest infection rate vs population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, 
       MAX((total_cases/population)*100) as PopulationWithCovid
FROM ['owid-covid-deaths$']
GROUP BY Location, population
ORDER BY HighestInfectionCount DESC

-- Let's break things down by continent
SELECT location, MAX(total_deaths) as HighestDeathCount, 
       MAX((total_cases/population)*100) as PopulationWithCovid
FROM ['owid-covid-deaths$']
WHERE continent is null
GROUP BY location
ORDER BY HighestDeathCount DESC


-- Countries with highest death count per population
SELECT Location, population, MAX(total_deaths) as HighestDeathCount, 
       MAX((total_cases/population)*100) as PopulationWithCovid
FROM ['owid-covid-deaths$']
WHERE continent is not null
GROUP BY Location, population
ORDER BY HighestDeathCount DESC


-- Showing continents with highest death count per population
SELECT continent, MAX(total_deaths) as HighestDeathCount, 
       MAX((total_cases/population)*100) as PopulationWithCovid
FROM ['owid-covid-deaths$']
WHERE continent is not null
GROUP BY continent
ORDER BY HighestDeathCount DESC


-- Global numbers
SELECT date, total_cases, total_deaths, (total_deaths/NULLIF(total_cases,0))*100 as DeathPercentage
FROM ['owid-covid-deaths$']
WHERE continent is not null
ORDER BY 1,2

SELECT SUM(cast(new_cases as int)) as new_cases, SUM(cast(new_deaths as int)) as new_deaths, SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 as DeathPercentage
/*total_cases, total_deaths, (total_deaths/NULLIF(total_cases,0))*100 as DeathPercentage*/
FROM ['owid-covid-deaths$']
WHERE continent is not null
--Group by date
ORDER BY 1,2


-- Total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
From ['owid-covid-deaths$'] dea
Join ['owid-covid-vaccines$'] vac
    On dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not Null
ORDER BY 1,2, 3
