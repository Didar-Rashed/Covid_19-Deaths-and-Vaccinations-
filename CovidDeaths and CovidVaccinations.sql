Create table covidDeaths (iso_code text,	continent varchar,	location varchar,	date date,
						  population numeric,	total_cases int,	new_cases int,	new_cases_smoothed decimal,
						  total_deaths int, new_deaths int,	new_deaths_smoothed decimal,	total_cases_per_million decimal,
						  new_cases_per_million	decimal, new_cases_smoothed_per_million decimal,	total_deaths_per_million decimal,
						  new_deaths_per_million decimal,	new_deaths_smoothed_per_million decimal,
						  reproduction_rate decimal, 	icu_patients int,	icu_patients_per_million decimal,	hosp_patients int,	hosp_patients_per_million decimal,
						  weekly_icu_admissions int,	weekly_icu_admissions_per_million decimal,	weekly_hosp_admissions int,
						  weekly_hosp_admissions_per_million decimal
)
alter table covidDeaths
alter column weekly_hosp_admissions set data type decimal


Select * from covidDeaths
order by 3,4
limit 20

-- Selecting data that we are going to use:

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covidDeaths
ORDER BY 1,2

-- Looking at total cases vs total deaths:

SELECT location, date, total_cases, total_deaths, cast((total_cases/total_deaths)*100.0 as float) AS DeathRate
FROM covidDeaths
WHERE location like 'Bangladesh'
ORDER BY 1,2

-- Looking at total cases vs population:

SELECT location, date, population, total_cases, cast((total_cases/population)*100.0 as float) AS InfectionRate
FROM covidDeaths
WHERE location like 'Bangladesh'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS Highest_infection_count, cast((total_cases/population)*100.0 as float) AS InfectionRate
FROM covidDeaths
WHERE location like 'Bangladesh'
GROUP BY location, population, total_cases
ORDER BY total_cases DESC

--Looking at countries with highest death per population

SELECT location, MAX(total_deaths) AS HighestDeathCount
FROM covidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY HighestDeathCount DESC

--Breaking it out by continent

SELECT continent, MAX(total_deaths) AS HighestDeathCount
FROM covidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY HighestDeathCount DESC

--Looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location,dea.date) as RollingPeopleVaccinated
FROM covidDeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not NULL
order by 2,3

--USE CTE

with PopulationVsVaccinations (continent,location,date,population,New_vaccinations,rollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location,dea.date) as RollingPeopleVaccinated
FROM covidDeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not NULL
--order by 2,3
)
select* , (rollingPeopleVaccinated/population)*100
from PopulationVsVaccinations


-- Creating View

CREATE VIEW PopulationVsVaccinations AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location,dea.date) as RollingPeopleVaccinated
FROM covidDeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not NULL
order by 2,3

