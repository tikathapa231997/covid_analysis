--select * from dbo.covid_vaccination
select * from corona_virus.dbo.covid_deaths

--selecting data that we are using 

select location,date,total_cases,new_cases,total_deaths,population
from corona_virus.dbo.covid_deaths
order by 1,2

---% chance that of surviving if you get infected in a perticular country 

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as "%_of_survival"
from corona_virus.dbo.covid_deaths
order by 1,2


-- most recent chance of survival in perticual country 

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as "%_of_survival"
from corona_virus.dbo.covid_deaths 
where date=(select max(date) from corona_virus.dbo.covid_deaths)
order by 1


-- population infected by covid 

select location,date,total_cases,population,(total_cases/population)*100 as "%_infected"
from corona_virus.dbo.covid_deaths
--where location='Nepal'
order by 1,2


--country having highest infection rate in recent time 

select location,date,total_cases,population,(total_cases/population)*100 as "%_infected"
from corona_virus.dbo.covid_deaths 
where (total_cases/population)=(select max(total_cases/population) from corona_virus.dbo.covid_deaths)

--country with lowest infection rate in recent time

select distinct location,(total_cases/population)*100 as "%_infected"
from corona_virus.dbo.covid_deaths 
where (total_cases/population)=(select min(total_cases/population) 
from corona_virus.dbo.covid_deaths 
where date=(select max(date) from corona_virus.dbo.covid_deaths))



--number of deaths in each country 

select location,max(cast(total_deaths as int)) as 'total_deaths'
from corona_virus.dbo.covid_deaths
where continent is null 
group by location
order by 2 desc

--number of deaths as per continent 

select location,max(cast(total_deaths as int)) as 'total_deaths'
from corona_virus.dbo.covid_deaths
where continent is not null 
group by location
order by 2 desc

-- global numbers (total case on a perticular day all over the world)

select date,sum(new_cases) as 'cases',sum(cast(new_deaths as int)) as 'deaths'
from corona_virus.dbo.covid_deaths
where continent is not null 
group by date
order by date desc


-- joining covid_deaths and covid_vaccination 

select * from  corona_virus.dbo.covid_deaths d
join corona_virus.dbo.covid_vaccination v
on d.location=v.location and d.date=v.date

--population versus vacination using cte 

with people_vacinated(continent,location,date,population,new_vaccinations,rolling_people_vaccinated)
as
(
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(cast(v.new_vaccinations as int )) over (partition by d.location order by d.location,d.date) as rolling_people_vaccinated
from  corona_virus.dbo.covid_deaths d
join corona_virus.dbo.covid_vaccination v
on d.location=v.location and d.date=v.date
where d.continent is not null
)
select *,rolling_people_vaccinated/population from people_vacinated


-- creating temprory table 

 drop table if exists percentage_of_people_vaccinated
 create table percentage_of_people_vaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 rolling_people_vaccinated numeric
 )

 insert into percentage_of_people_vaccinated
 select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(cast(v.new_vaccinations as int )) over (partition by d.location order by d.location,d.date) as rolling_people_vaccinated
from  corona_virus.dbo.covid_deaths d
join corona_virus.dbo.covid_vaccination v
on d.location=v.location and d.date=v.date
where d.continent is not null
 

 select * from percentage_of_people_vaccinated

 -- creating view for visualization 

 create view number_of_people_vaccinated_view as 
 select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(cast(v.new_vaccinations as int )) over (partition by d.location order by d.location,d.date) as rolling_people_vaccinated
from  corona_virus.dbo.covid_deaths d
join corona_virus.dbo.covid_vaccination v
on d.location=v.location and d.date=v.date
where d.continent is not null

select * from percentage_of_people_vaccinated_view