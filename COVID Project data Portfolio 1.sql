--SELECT location, date, total_cases, new_cases, total_deaths, population 
--FROM ['covid-covid-data (project)$']
--ORDER BY 1,2 

-- we will be looking at total cases VS new deaths

SELECT location, population,total_cases, (total_cases/population)*100 AS Highest_infec
FROM ['covid-covid-data (project)$']
WHERE location = '%EUROPE%'
ORDER BY 1,2 


SELECT Location, population, MAX(total_cases) Highest_infec, MAX(total_cases/population)*100 AS Population_infec
FROM ['covid-covid-data (project)$']
--WHERE location = '%Asia%'
GROUP BY location, population
ORDER BY 1,2 

--Break down by continent
SELECT continent, MAX(total_deaths) AS tot_deaths
FROM ['covid-covid-data (project)$']
WHERE continent is NOT null
GROUP BY continent
ORDER BY 1,2 desc

--showing the continents with the highest death counts per population

SELECT location, MAX(cast(total_deaths as float)) AS tot_deaths
FROM ['covid-covid-data (project)$']
WHERE continent is NOT null
GROUP BY location
ORDER BY tot_deaths desc


--LETS BREAK THINGS DOWN BY CONTINENT
SELECT continent, MAX(cast(total_deaths as float)) AS tot_deaths
FROM ['covid-covid-data (project)$']
WHERE continent is not null
GROUP BY continent
ORDER BY tot_deaths desc


--Global numbers
SELECT SUM(CAST(new_deaths as int)), SUM(CAST(new_cases as float)), SUM(CAST(new_cases as int))/SUM(CAST(new_cases as float))*100 as DEATHPERCENTAGE
FROM ['covid-covid-data (project)$']
--WHERE location = '%EUROPE%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2 

--joining tables vacines and deaths
SELECT *
FROM ['covid vacinations data (project$'] VA
JOIN ['covid-covid-data (project)$'] DEA 
ON DEA.location = VA.location AND DEA.date = VA.date



--total population VS vaccinations (I abbreviated the table  name so its easier to type it out when using joins) 
--Partition by was used to break down the values as well the SUM fucntion add,
--when tyring to convert big numbers into proprer intergers use CONVERT(bigint)

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VA.new_vaccinations, SUM(CONVERT(bigint,VA.new_vaccinations)) 
OVER (Partition by DEA.location order by DEA.location, DEA.date) as Rollingpeople_vaccinated
FROM Vaccinations VA 
JOIN ['covid-covid-data (project)$'] DEA
ON DEA.location = VA.location AND DEA.date = VA.date 
WHERE DEA.continent is not null
ORDER BY 2,3


--CTE being used for the query below in order to creat a aggregate function (Rollingpeople_vaccinated/population)*100
--because it runs an error when you add it

with PopvsVac(Continent, location, date, population, new_vaccinations, Rollingpeople_vaccinated)
as
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VA.new_vaccinations, SUM(CONVERT(bigint decim,VA.new_vaccinations)) 
OVER (Partition by DEA.location order by DEA.location, DEA.date) as Rollingpeople_vaccinated
FROM Vaccinations VA 
JOIN ['covid-covid-data (project)$'] DEA
ON DEA.location = VA.location AND DEA.date = VA.date 
WHERE DEA.continent is not null
--ORDER BY 2,3
)
SELECT *,(Rollingpeople_vaccinated/population)*100
FROM PopvsVac


--creating temp table
-- USE THE "Drop Table if exists" FUNCTION IF THE QUERY RETURNS AN ERROR SAYING TABLE ALREADY EXISTS

Drop table if exists #PercentpopulationVaccinated 
Create Table #PercentpopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
Population numeric,
New_Vaccinations numeric,
Rollingpeople_Vaccinated numeric
)

Insert Into #PercentpopulationVaccinated
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VA.new_vaccinations, SUM(CONVERT(bigint,VA.new_vaccinations)) 
OVER (Partition by DEA.location order by DEA.location, DEA.date) as Rollingpeople_vaccinated
FROM Vaccinations VA 
JOIN ['covid-covid-data (project)$'] DEA
ON DEA.location = VA.location AND DEA.date = VA.date 
WHERE DEA.continent is not null
--ORDER BY 2,3

SELECT *,(Rollingpeople_vaccinated/population)*100
FROM #PercentpopulationVaccinated


--creating a view for later visualization
create View PercentpopulationVaccinated as 
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VA.new_vaccinations, SUM(CONVERT(bigint,VA.new_vaccinations)) 
OVER (Partition by DEA.location order by DEA.location, DEA.date) as Rollingpeople_vaccinated
FROM Vaccinations VA 
JOIN ['covid-covid-data (project)$'] DEA
ON DEA.location = VA.location AND DEA.date = VA.date 
WHERE DEA.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentpopulationVaccinated