--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
ORDER BY location, date


/*SELECT *
FROM covidvaccinations
ORDER BY location, date*/

-- Looking at total_cases vs total_deaths
	-- Shows likelihood of dying if you contract covid in SG
SELECT location, date, total_cases::FLOAT, total_deaths::FLOAT, (total_deaths::FLOAT/total_cases::FLOAT)*100 AS DeathPercentage
FROM coviddeaths
	WHERE location like 'Singapore'
ORDER BY location, date

-- Looking at total_cases vs total_deaths
	-- Shows what % of population got covid
SELECT location, date, total_cases::FLOAT, population::FLOAT, (total_cases::FLOAT/population::FLOAT)*100 AS DeathPercentage
FROM coviddeaths
	WHERE location like '%States%'
ORDER BY location, date

-- Looking at Countries with highest infection rate
SELECT location, MAX(total_cases)::FLOAT, population::FLOAT, MAX((total_cases::FLOAT/population::FLOAT))*100 AS InfectionRate
FROM coviddeaths
GROUP BY location, population
HAVING MAX((total_cases::FLOAT/population::FLOAT))*100 IS NOT NULL
ORDER BY InfectionRate DESC
LIMIT 1

-- Showing countried with highest death count
SELECT location, MAX(total_deaths)::FLOAT AS MaxDeath, population::FLOAT
FROM coviddeaths
GROUP BY location, population, continent
HAVING MAX(total_deaths) IS NOT NULL AND continent  IS NOT NULL
ORDER BY MaxDeath DESC

-- Showing continent with World with highest death count
SELECT location, MAX(total_deaths)::FLOAT AS MaxDeath
FROM coviddeaths
	WHERE continent is NULL
GROUP BY location
ORDER BY MaxDeath DESC

-- Showing continent with highest death count
SELECT continent, MAX(total_deaths)::FLOAT AS MaxDeath
FROM coviddeaths
	WHERE continent is not NULL
GROUP BY continent
ORDER BY MaxDeath DESC

-- Global Numbers
SELECT date, SUM(new_cases) as total_cases, SUM(new_death) as total_deaths, (SUM(new_death)::FLOAT/SUM(new_cases)::FLOAT)*100 AS DeathPercentage
FROM coviddeaths
	WHERE continent is not null
	GROUP BY date
ORDER BY date

-- Looking at total population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(vac.new_vaccinations) OVER (partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated--, (RollingPeopleVaccinated
FROM coviddeaths as dea
JOIN covidvaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY  dea.location, dea.date

-- USE CTE 
WITH PopvsVac (Continent, Location, Date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(vac.new_vaccinations) OVER (partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated--, (RollingPeopleVaccinated
FROM coviddeaths as dea
JOIN covidvaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY  dea.location, dea.date
	
)
SELECT *, (RollingPeopleVaccinated::FLOAT/population::FLOAT)*100 as Percentage
	FROM PopvsVac


-- TEMP TABLE
DROP Table if exists PercentPopulationVaccinated;
CREATE TEMP Table PercentPopulationVaccinated
	(
	continent varchar(20),
	location varchar(50),
	date date,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
	);
	
INSERT into PercentPopulationVaccinated (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(vac.new_vaccinations) OVER (partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated--, (RollingPeopleVaccinated
FROM coviddeaths as dea
JOIN covidvaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null;

	
SELECT *, (RollingPeopleVaccinated::FLOAT/population::FLOAT)*100 as Percentage
	FROM PercentPopulationVaccinated


-- Creating View to store data for later visualisation
CREATE View PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(vac.new_vaccinations) OVER (partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated--, (RollingPeopleVaccinated
FROM coviddeaths as dea
JOIN covidvaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null;

SELECT * FROM PercentPopulationVaccinated