---------------------- insert table ----------------------------
INSERT INTO population_density.county ("FIPS",
									   county_name,
									   landarea,
									   ttl_population,
									   pvty_number,
									   pvty_rate,
									   median_income,
									   median_income_pct,
									   unemployment_number,
									   unemployment_rate,
									  state_id
									  )
SELECT  
       fips_txt2, 
	   area_name2,
	   landarea,
	   "2019",
	   povall_2019,
	   pctpovall_2019,
	   median_household_income_2019,
	   med_hh_income_percent_of_state_total_2019,
	   unemployed_2019,
	   unemployment_rate_2019,
	   (select state_id from population_density.county_state where state_name = stage.stabr)state_id
FROM (
	select distinct fips_txt2, 
	   area_name2,
	   landarea,
	   "2019",
	   povall_2019,
	   pctpovall_2019,
	   median_household_income_2019,
	   med_hh_income_percent_of_state_total_2019,
	   unemployed_2019,
	   unemployment_rate_2019,
	   stabr 
	  from
	  population_density.stage)stage


------------------------- data manipulation -----------------
--------- for landarea ---------
select landarea :: double precision :: integer
from population_density.county
--------- for ttl_population -------
select to_number(ttl_population :: text, '999999')
from population_density.county
--------- for pvty num ----------
select to_number(pvty_number :: text, '9999999')
from population_density.county
---------- for pvty_rate --------
select pvty_rate :: double precision 
from population_density.county
---------- for median income -------
select to_number(median_income :: text, '999999')
from population_density.county
---------- for median_income_pct ---------
select median_income_pct :: double precision 
from population_density.county
---------- for unemployment_number -------
select to_number(unemployment_number :: text, '99999')
from population_density.county
---------- for unemployment_rate ----------
select unemployment_rate :: double precision 
from population_density.county

------------- UPDATE Table county ----------
UPDATE population_density.county c
	SET landarea= (
		select landarea :: double precision :: integer 
		from population_density.county 
	), 
	ttl_population= (
		select to_number(ttl_population :: text, '999999') 
		from population_density.county
    ), 
	pvty_number= (
		select to_number(pvty_number :: text, '9999999')
		from population_density.county
	), 
	pvty_rate= (
		select pvty_rate :: double precision 
		from population_density.county
	), 
	median_income= (
		select to_number(median_income :: text, '999999')
		from population_density.county
	), 
	median_income_pct= (
		select median_income_pct :: double precision 
		from population_density.county
	), 
	unemployment_number= (
		select to_number(unemployment_number :: text, '99999')
		from population_density.county
	), 
	unemployment_rate=(
		select unemployment_rate :: double precision 
		from population_density.county
	);
	
-------------try alter instead ----------
ALTER TABLE population_density.county
   ALTER COLUMN landarea type integer
   USING landarea::double precision :: integer
   
ALTER TABLE population_density.county
   ALTER COLUMN ttl_population type integer
   USING to_number(ttl_population :: text, '999999')
   
select ttl_population/nullif(landarea,0) as population_density
from population_density.county
order by population_density asc

ALTER TABLE population_density.county
   ALTER COLUMN pvty_number type integer
   USING to_number(pvty_number :: text, '999999')
   
ALTER TABLE population_density.county
   ALTER COLUMN pvty_rate type double precision 
   USING pvty_rate :: double precision 
   
ALTER TABLE population_density.county
   ALTER COLUMN median_income type integer
   USING to_number(median_income :: text, '999999')
   
ALTER TABLE population_density.county
   ALTER COLUMN median_income_pct type double precision
   USING median_income_pct :: double precision

ALTER TABLE population_density.county
   ALTER COLUMN unemployment_number type integer
   USING median_income_pct :: double precision 

ALTER TABLE population_density.county
   ALTER COLUMN unemployment_rate type double precision 
   USING unemployment_rate :: double precision
   
select * from population_density.county

----------- create density table --------
ALTER TABLE population_density.county
ADD COLUMN population_density2 INTEGER; -- Exclude the NOT NULL constraint here

UPDATE population_density.county SET population_density2=ttl_population/nullif(landarea,0); -- Insert data with a regular UPDATE

select population_density2 from 
population_density.county
-------*-------------------------
ALTER TABLE population_density.county
ALTER COLUMN population_density2 SET NOT NULL;

ALTER TABLE population_density.county
DROP COLUMN population_density

