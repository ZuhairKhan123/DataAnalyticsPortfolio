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

Select dea.continent, dea.location, dea.[date], dea.population, vac.new_vaccinations, 
       SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.[date]) as RollingPeopleVaccinated
From PortfolioProject.dbo.['owid-covid-deaths$'] dea
Join PortfolioProject.dbo.['owid-covid-vaccines$'] vac
    On dea.location = vac.location
    and dea.[date] = vac.[date]
WHERE dea.continent is not Null
ORDER BY 1, 2, 3


-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as(
Select dea.continent, dea.location, dea.[date], dea.population, vac.new_vaccinations, 
       SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.[date]) as RollingPeopleVaccinated
From PortfolioProject.dbo.['owid-covid-deaths$'] dea
Join PortfolioProject.dbo.['owid-covid-vaccines$'] vac
    On dea.location = vac.location
    and dea.[date] = vac.[date]
WHERE dea.continent is not Null
)
Select *, (RollingPeopleVaccinated/Population)*100 as PeopleVacPercent
From PopvsVac

-- Temp Table
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
Select dea.continent, dea.location, dea.[date], dea.population, vac.new_vaccinations, 
       SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.[date]) as RollingPeopleVaccinated
From PortfolioProject.dbo.['owid-covid-deaths$'] dea
Join PortfolioProject.dbo.['owid-covid-vaccines$'] vac
    On dea.location = vac.location
    and dea.[date] = vac.[date]
WHERE dea.continent is not Null

Select *, (RollingPeopleVaccinated/Population)*100 as PeopleVacPercent
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations
DROP View if exists PercentPopulationVaccinated;
GO

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.[date], dea.population, vac.new_vaccinations, 
       SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.[date]) as RollingPeopleVaccinated
From PortfolioProject.dbo.['owid-covid-deaths$'] dea
Join PortfolioProject.dbo.['owid-covid-vaccines$'] vac
    On dea.location = vac.location
    and dea.[date] = vac.[date]
WHERE dea.continent is not Null
--Order by 2,3


USE PortfolioProject;
GO

SELECT name, type_desc 
FROM sys.objects 
WHERE type = 'V' AND name = 'PercentPopulationVaccinated'


USE PortfolioProject;
GO

CREATE VIEW PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.[date], dea.population, vac.new_vaccinations,
    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.[date]) as RollingPeopleVaccinated
From ['owid-covid-deaths$'] dea
Join ['owid-covid-vaccines$'] vac
    On dea.location = vac.location
    and dea.[date] = vac.[date]
WHERE dea.continent is not Null;
GO


-- Data Cleaning in SQL
Select *
From dbo.NashvilleHousing

-- Standardize Date Format
Select SaleDateConverted, CONVERT(Date, SaleDate)
From dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- Populate Property Address Data
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From dbo.NashvilleHousing a
-- Where PropertyAddress is Null
-- order by ParcelID
JOIN dbo.NashvilleHousing b
    on a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID] 
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
    on a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID] 
Where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, States)
Select PropertyAddress
From dbo.NashvilleHousing 
-- Where PropertyAddress is Null
-- order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
From dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select *
From dbo.NashvilleHousing


-- Changing owner address using parsename
Select OwnerAddress
From dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress,',', '.'), 3) as Address
,PARSENAME(REPLACE(OwnerAddress,',', '.'), 2) as City
,PARSENAME(REPLACE(OwnerAddress,',', '.'), 1) as State
From dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)

Select *
From dbo.NashvilleHousing


-- Change Y or N for SoldAsVacant
Select Distinct(SoldAsVacant), Count(SoldAsVacant) as Total
From dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END
From dbo.NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END


-- Remove Duplicates
With RowNumCTE AS (
Select *,
    ROW_NUMBER() OVER (
    PARTITION BY ParcelID, 
                 PropertyAddress, 
                 SalePrice, 
                 SaleDate, 
                 LegalReference 
                 ORDER BY 
                    UniqueID) row_num
From dbo.NashvilleHousing
)
Delete
From RowNumCTE
Where row_num > 1
Order by PropertyAddress




-- Delete Unused Columns

SELECT *
From dbo.NashvilleHousing

Alter Table dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
