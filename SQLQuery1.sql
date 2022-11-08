-- 
SELECT *
FROM portfolioproject..CovidDeaths c2



-- adding total deaths
-- SQL: running total via sum -over -partition by -order by statement
SELECT location, date, new_cases, population, total_deaths,
	SUM(new_cases) OVER (PARTITION BY location ORDER BY date) AS total_cases
FROM portfolioproject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- death rate if contracted
-- SQL: NULLIF statement to avoid divid by zero error
SELECT location, date, new_cases, population, total_deaths,
	SUM(new_cases) OVER (PARTITION BY location ORDER BY date) AS total_cases, 
	(total_deaths/NULLIF((SUM(new_cases) OVER (PARTITION BY location ORDER BY date)), 0))*100 AS death_rate
FROM portfolioproject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- infection rate
SELECT location, date, new_cases, population, total_deaths,
	SUM(new_cases) OVER (PARTITION BY location ORDER BY date) AS total_cases, 
	(SUM(new_cases) OVER (PARTITION BY location ORDER BY date)/population)*100 AS infection_rate
FROM portfolioproject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- countries with highest infection rate
-- SQL: CTE
WITH totalcasesCTE (location, population, date, total_cases)
AS 
(SELECT location, population, date,
		SUM(new_cases) OVER (PARTITION BY location ORDER BY date)
		FROM portfolioproject..CovidDeaths
		WHERE continent IS NOT NULL
)
SELECT location, population,
	MAX(total_cases) as latest_total_cases,
	(MAX(total_cases) / population)*100 as infection_rate
	FROM totalcasesCTE
	GROUP BY location, population
	ORDER BY 4 desc


-- death rate if infected
SELECT location, population, MAX(CAST(total_deaths AS BIGINT))
FROM portfolioproject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population 
ORDER BY 3 desc


-- global cases and deaths
-- SQL: cast to change date type for aggregate functions 
SELECT date, SUM(new_cases) AS cases, SUM(CAST(new_deaths AS BIGINT)) AS deaths,  
(SUM(CAST(new_deaths AS BIGINT))/SUM(new_cases))*100 AS death_rate
FROM portfolioproject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1


-- vaxx rate over time
SELECT d.location, d.date, d.population, v.people_fully_vaccinated, (v.people_fully_vaccinated/d.population)*100 AS vaxx_rate
		
FROM portfolioproject..CovidDeaths d
JOIN portfolioproject..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL


