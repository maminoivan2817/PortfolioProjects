
--SELECT *
--FROM CovidDeath
--ORDER BY 3,4 DESC


--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4 DESC

--Select the Data that we are going to be using--

--SELECT location,date,total_cases,new_cases,total_deaths,population
--FROM CovidDeaths
--ORDER BY 1,2 

--Looking at Total Cases VS. Total Deaths--

--SELECT location,date,total_cases, total_deaths, ROUND((total_deaths/total_cases) *100,2) as DeathPercentage
--FROM CovidDeaths
--ORDER BY 1,2	

--Shows likelihood of dying if contract covid in your country--

--SELECT location,date,total_cases, total_deaths, ROUND((total_deaths/total_cases) *100,2) as DeathPercentage
--FROM CovidDeaths
--WHERE location LIKE '%Philippines%'
--ORDER BY 1,2	

--Looking at Total Cases vs. Population--
--Show what percentage of population got covid--

--SELECT location, date, population, total_cases, ROUND((total_cases/population) *100,2) as PercentPopulationInfected
--FROM CovidDeaths
--WHERE location LIKE '%Philippines%'
--ORDER BY 1,2

--SELECT location, date, population, total_cases, ROUND((total_cases/population) *100,2) as PercentPopulationInfected
--FROM CovidDeaths
--WHERE location LIKE '%states%'
--ORDER BY 1,2

--Looking at the Countries with Highest Infection Rate compared to Population--

--SELECT location, population, MAX(total_cases) as HighestInfectionCount, 
--		MAX((total_cases/population)) *100 as PercentPopulationInfected
--FROM CovidDeaths
--GROUP BY location, population
--ORDER BY 4 DESC

--Showing Countries with Highest Death Count per Population--
--MAX(case(total_deaths as int)) to convert varchar in to integer--

--SELECT location, MAX(total_deaths) as TotalDeathCount
--FROM CovidDeaths
--WHERE continent IS NOT NULL 
--GROUP BY location
--ORDER BY 2 DESC

--Showing Continent with Highest Death Count per Population--

--SELECT continent, MAX(total_deaths) as TotalDeathCount
--FROM CovidDeaths
--WHERE continent IS NOT NULL 
--GROUP BY continent
--ORDER BY 2 DESC

--SELECT location, MAX(total_deaths) as TotalDeathCount
--FROM CovidDeaths
--WHERE continent IS NULL 
--GROUP BY location
--ORDER BY 2 DESC

--Global Numbers--

--SELECT 
--	date, 
--	SUM(new_cases) AS Total_Cases,	
--	SUM(new_deaths) AS Total_Deaths,
--	SUM(new_deaths)/SUM(new_cases) * 100 AS Death_Percenntage
--FROM CovidDeaths
--WHERE continent  IS NOT NULL
--GROUP BY date
--ORDER BY 1

---Total Deaths Percentage All Over Accross the world--

--SELECT 
--	SUM(new_cases) AS Total_Cases,	
--	SUM(new_deaths) AS Total_Deaths,
--	SUM(new_deaths)/SUM(new_cases) * 100 AS Death_Percentage
--FROM CovidDeaths
--WHERE continent  IS NOT NULL
--ORDER BY 1

--SELECT location ,SUM(CAST(new_vaccinations AS INT)) AS Total_Vaccinated
--FROM CovidVaccinations
--WHERE continent IS NOT NULL
--GROUP BY location
--ORDER BY 1 ASC

--SELECT SUM(CAST(new_vaccinations AS INT)) AS Total_Vaccinated
--FROM CovidVaccinations
--WHERE continent IS NOT NULL

--Looking at Total Population Vs. Vaccinations--



--SELECT 
--	dea.continent,
--	dea.location,
--	dea.date, 
--	dea.population,
--	vac.new_vaccinations,
--	SUM(vac.new_vaccinations)
--	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--FROM
--	CovidDeaths AS dea
--JOIN 
--	CovidVaccinations AS vac
--ON 
--	dea.location = vac.location
--	AND dea.date = vac.date
--WHERE 
--	dea.continent IS NOT NULL
--ORDER BY
--	2,3

--USE CTE--

WITH PopvsVac(continent, location, date, population, new_vaccinations,RollingPeopleVaccinated)
AS
(

SELECT 
	dea.continent,
	dea.location,
	dea.date, 
	dea.population,
	vac.new_vaccinations,
	SUM(vac.new_vaccinations)
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM
	CovidDeaths AS dea
JOIN 
	CovidVaccinations AS vac
ON 
	dea.location = vac.location
	AND dea.date = vac.date
WHERE 
	dea.continent IS NOT NULL
--ORDER BY
--2,3
)

SELECT *, ROUND((RollingPeopleVaccinated/population) * 100,2) 
FROM PopvsVac

--TEMP TABLES--
DROP TABLE IF EXISTS  #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent varchar(50),
location varchar(50),
Date datetime,
population int,
new_vaccinations int,
RollingPeopleVaccinated float
)

INSERT INTO #PercentPopulationVaccinated

SELECT 
	dea.continent,
	dea.location,
	dea.date, 
	dea.population,
	vac.new_vaccinations,
	SUM(vac.new_vaccinations)
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM
	CovidDeaths AS dea
JOIN 
	CovidVaccinations AS vac
ON 
	dea.location = vac.location
	AND dea.date = vac.date
WHERE 
	dea.continent IS NOT NULL
--ORDER BY
--2,3


SELECT *, ROUND((RollingPeopleVaccinated/population) * 100,2) 
FROM #PercentPopulationVaccinated

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS--

CREATE VIEW PercentPopulationVaccinated AS 
SELECT 
	dea.continent,
	dea.location,
	dea.date, 
	dea.population,
	vac.new_vaccinations,
	SUM(vac.new_vaccinations)
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM
	CovidDeaths AS dea
JOIN 
	CovidVaccinations AS vac
ON 
	dea.location = vac.location
	AND dea.date = vac.date
WHERE 
	dea.continent IS NOT NULL
--ORDER BY
--2,3

SELECT *
FROM PercentPopulationVaccinated