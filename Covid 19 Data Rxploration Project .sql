-- EXAMINING THE COVID VACCINATION TABLE
SELECT
    *
FROM
    PortfolioMain..CovidVaccine
ORDER BY
    3, 4
----------------------------------------------------------------------

-- EXAMINING THE COVID DEATH TABLE
SELECT
    *
FROM
    PortfolioMain..CovidDeath
ORDER BY
    3, 4
----------------------------------------------------------------------

-- DATA RETRIEVAL FROM COVID DEATH TABLE
SELECT
    location,
    DATE,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    PortfolioMain..CovidDeath
ORDER BY
    1, 2 
----------------------------------------------------------------------
    
-- LOOKING AT TOTAL CASES VS TOTAL DEATHS TO EXAMINE THE ODDS OF DYING DUE TO COVID CONTRACTION IN A COUNTRY
SELECT
    location,
    DATE,
    total_cases,
    new_cases,
    total_deaths,
    (
        CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)
    ) * 100 AS DeathPercent
FROM
    PortfolioMain..CovidDeath
WHERE
    location LIKE '%nigeia%'
ORDER BY
    1, 2 
----------------------------------------------------------------------

-- LOOKING AT TOTAL CASES VS POPULATION
SELECT
    location,
    DATE,
    total_cases,
    Population,
    (CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) AS InfectedRate
FROM
    PortfolioMain..CovidDeath
WHERE
    location LIKE '%nigeria%'
ORDER BY
    1, 2 
----------------------------------------------------------------------

-- LOOKING AT COUNTRIES WITH HIGHEST INFECTION ATE COMPARED TO POPULATION
SELECT
    location,
    Population,
    MAX(CAST(total_cases AS FLOAT)) AS HighestInfectionCount,
    MAX(
        (CAST(total_cases AS FLOAT) / CAST(population AS FLOAT))
    ) * 100 AS InfectedRate
FROM
    PortfolioMain..CovidDeath
GROUP BY
    location,
    population
ORDER BY
    InfectedRate desc --SHOWING CONTINENT WITH HIGHEST DEATH COUNT
----------------------------------------------------------------------


SELECT
    continent,
    MAX(CAST(total_deaths AS INT)) AS HighestDeathCount
FROM
    PortfolioMain..CovidDeath
WHERE
    continent IS NOT NULL
GROUP BY
    continent
ORDER BY
    HighestDeathCount desc 
----------------------------------------------------------------------
    
-- SHOWING COUNTRIES WITH HIGHEST DEATH COUNT
SELECT
    location,
    MAX(CAST(total_deaths AS INT)) AS HighestDeathCount
FROM
    PortfolioMain..CovidDeath
WHERE
    continent IS NOT NULL
GROUP BY
    location
ORDER BY
    HighestDeathCount desc 
----------------------------------------------------------------------
    
-- GLOBAL NUMBERS
SELECT
    SUM(CAST(new_cases AS INT)) TotalNewCases,
    SUM(CAST(new_deaths AS INT)) TotalNewDeaths,
    SUM(CAST(new_deaths AS INT)) / NULLIF(SUM(CAST(new_cases AS FLOAT)), 0) * 100 AS DeathPercent
FROM
    PortfolioMain..CovidDeath --where location like '%nigeia%'
WHERE
    continent IS NOT NULL --group by date
ORDER BY
    1, 2 
----------------------------------------------------------------------

-- LOOKING AT TOTAL POPULATION VS DEATH
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    CAST(dea.weekly_hosp_admissions AS INT) WeeklyHospAdmin,
    SUM(CAST(dea.weekly_hosp_admissions AS INT)) OVER (
        PARTITION BY dea.location
        ORDER BY
            dea.date
    ) WeeklyHospAdminSum
FROM
    PortfolioMain..CovidDeath Dea
    JOIN PortfolioMain..CovidVaccine Vac ON vac.location = dea.location
    AND vac.date = dea.date --(cast(new_cases as int)(cast(new_cases as int)
WHERE
    dea.weekly_hosp_admissions IS NOT NULL
ORDER BY
    2, 3 
----------------------------------------------------------------------

-- CALCULATING WEEKLY HOSPITAL ADMISSIONS AND CUMULATIVE SUMS BY LOCATION (EMPLOYING CTE)
WITH PopVsAdmin (
	Continent,
	Location,
	date,
	Populaton,
	WeeklyHospAdmin,
	WeeklyHospAdminSum
) AS (
	SELECT
		dea.continent,
		dea.location,
		dea.date,
		dea.population,
		CAST(dea.weekly_hosp_admissions AS INT) WeeklyHospAdmin,
		SUM(CAST(dea.weekly_hosp_admissions AS INT)) OVER (
			PARTITION BY dea.location
			ORDER BY
				dea.date
		) WeeklyHospAdminSum
	FROM
		PortfolioMain..CovidDeath Dea
		JOIN PortfolioMain..CovidVaccine Vac ON vac.location = dea.location
		AND vac.date = dea.date --(cast(new_cases as int)(cast(new_cases as int)
	WHERE
		dea.weekly_hosp_admissions IS NOT NULL --order by 2, 3
)
----------------------------------------------------------------------

-- CALCULATING WEEKLY HOSPITAL ADMISSION PERCENTAGE    
SELECT
    *,
    (WeeklyHospAdmin / Populaton) * 100 AS WeeklyAdminPercent
FROM
    PopVsAdmin 
----------------------------------------------------------------------   
   
-- CALCULATING WEEKLY HOSPITAL ADMISSION PERCENTAGE USING TEMP TABLE
    
DROP TABLE if EXISTS # PercentWeeklyAdmission 
CREATE TABLE # PercentWeeklyAdmission (
	continent nvarchar(255),
	Location nvarchar(255),
	DATE datetime,
	Population NUMERIC,
	WeeklyHospAdmin NUMERIC,
	WeeklyHospAdminSum NUMERIC
)    
-- INSERTING DATA INTO TEMPORARY TABLE
INSERT INTO
    # PercentWeeklyAdmission
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    CAST(dea.weekly_hosp_admissions AS INT) WeeklyHospAdmin,
    SUM(CAST(dea.weekly_hosp_admissions AS INT)) OVER (
        PARTITION BY dea.location
        ORDER BY
            dea.date
    ) WeeklyHospAdminSum
FROM
    PortfolioMain..CovidDeath Dea
    JOIN PortfolioMain..CovidVaccine Vac ON vac.location = dea.location
    AND vac.date = dea.date
WHERE
    dea.weekly_hosp_admissions IS NOT NULL --order by 2, 3
    
-- SELECTING DATA FROM TEMPORARY TABLE -# PercentWeeklyAdmission- AND CALCULATING PERCENTAGE 
SELECT
    *,
    (WeeklyHospAdmin / Population) * 100 AS WeeklyAdminPercent
FROM
    # PercentWeeklyAdmission 
----------------------------------------------------------------------

-- CREATING VIEW FOR LATER VISUALZATION - WEEKLY HOSPITAL ADMISSION
    use PortfolioMain go CREATE view WeeklyAdmin AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    CAST(dea.weekly_hosp_admissions AS INT) WeeklyHospAdmin,
    SUM(CAST(dea.weekly_hosp_admissions AS INT)) OVER (
        PARTITION BY dea.location
        ORDER BY
            dea.date
    ) WeeklyHospAdminSum
FROM
    PortfolioMain..CovidDeath Dea
    JOIN PortfolioMain..CovidVaccine Vac ON vac.location = dea.location
    AND vac.date = dea.date
WHERE
    dea.weekly_hosp_admissions IS NOT NULL
