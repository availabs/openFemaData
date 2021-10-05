const reformat_open_fema_sba = (table) => `with t as (
    SELECT fema_disaster_number, substring(geoid, 1, 5) geoid, SUM(total_verified_loss) total_loss
    FROM public.sba_disaster_loan_data_new
    GROUP BY 1, 2
    ORDER BY 1, 2, 3
)


update severe_weather_open_fema_data_merge.${table} dst
set sba_loss = t.total_loss
from t
where t.fema_disaster_number = any(dst.disaster_ids)
  and t.geoid = dst.geoid`

module.exports = reformat_open_fema_sba

const sql = `
    with  
	county_to_state as (
			SELECT stusps, county.geoid, county.name, county.namelsad
			FROM geo.tl_2017_us_county county
					 JOIN geo.tl_2017_us_state state
						  on county.statefp = state.geoid
			order by county.statefp, countyfp
	),
	pa_data as (
    select disaster_number disaster_number_pa, 
		state_number_code::text || lpad(county_code::text, 3, '0') geoid_pa, 
		extract(YEAR from declaration_date) disaster_year_pa,
		CASE
                    when incident_type = 'Fire' then 'wildfire'
                    when incident_type = 'Tsunami' then 'tsunami'
                    when incident_type = 'Tornado' then 'tornado'
                    when incident_type = 'Flood' then 'riverine'
                    when incident_type = 'Severe Storm(s)' then 'riverine'
                    when incident_type = 'Mud/Landslide' then 'landslide'
                    when incident_type = 'Severe Ice Storm' then 'icestorm'
                    when incident_type = 'Hurricane' then 'hurricane'
                    when incident_type = 'Typhoon' then 'hurricane'
                    when incident_type = 'Earthquake' then 'earthquake'
                    when incident_type = 'Drought' then 'drought'
                    when incident_type = 'Freezing' then 'coldwave'
                    when incident_type = 'Snow' then 'winterweat'
                    when incident_type = 'Volcano' then 'volcano'
                    when incident_type = 'Coastal Storm' then 'coastal'
                    else incident_type
                    END 															   as hazard_pa, 
		sum(coalesce(project_amount, 0)) project_amount
    from open_fema_data.public_assistance_funded_projects_details_v1
    where dcc not in ('A', 'B', 'Z')
-- 	and disaster_number = '4085' 
    group by 1, 2, 3, 4
),
     ihp_data as (
         SELECT disaster_number,
		 		county_to_state.geoid,
                extract(YEAR from declaration_date) disaster_year,
                CASE
                    when ihp.incident_type = 'Fire' then 'wildfire'
                    when ihp.incident_type = 'Tsunami' then 'tsunami'
                    when ihp.incident_type = 'Tornado' then 'tornado'
                    when ihp.incident_type = 'Flood' then 'riverine'
                    when ihp.incident_type = 'Severe Storm(s)' then 'riverine'
                    when ihp.incident_type = 'Mud/Landslide' then 'landslide'
                    when ihp.incident_type = 'Severe Ice Storm' then 'icestorm'
                    when ihp.incident_type = 'Hurricane' then 'hurricane'
                    when ihp.incident_type = 'Typhoon' then 'hurricane'
                    when ihp.incident_type = 'Earthquake' then 'earthquake'
                    when ihp.incident_type = 'Drought' then 'drought'
                    when ihp.incident_type = 'Freezing' then 'coldwave'
                    when ihp.incident_type = 'Snow' then 'winterweat'
                    when ihp.incident_type = 'Volcano' then 'volcano'
                    when ihp.incident_type = 'Coastal Storm' then 'coastal'
                    else ihp.incident_type
                    END 															   as hazard,
                sum(coalesce(rpfvl, 0) + coalesce(ppfvl, 0))                    as ihp_verified_loss,
                sum(coalesce(ha_amount, 0)) 												   as ha_loss,
                sum(coalesce(rpfvl, 0) + coalesce(ppfvl, 0)) as total_loss
         FROM open_fema_data.individuals_and_households_program_valid_registrations_v1 ihp
		 join county_to_state
		 on damaged_state_abbreviation = stusps
		 and (
				REPLACE(REPLACE(REPLACE(lower(county), '(', ''), ')', ''), ' ', '') like '%' || REPLACE(lower(namelsad), ' ', '') || '%'
			   OR
				REPLACE(REPLACE(REPLACE(lower(county), '(', ''), ')', ''), ' ', '') = REPLACE(lower(name), ' ', '')
			)
-- 		 and disaster_number = '4085' 
         group by 1,2,3,4
     )
-- 	 ,sba_data as (
--     SELECT fema_disaster_number disaster_number, year, substring(geoid, 1, 5) geoid, SUM(total_verified_loss) sba_loss
--     FROM public.sba_disaster_loan_data_new
--     GROUP BY 1, 2, 3
--     ORDER BY 1, 2, 3, 4
-- )

insert into severe_weather_open_fema_data_merge.fba_annual_loss_by_county_by_hazard_sba_new
select 
	CASE 
		when t.disaster_year_pa is not null
			then t.disaster_year_pa
		else t.disaster_year 
	END 												as year, 
	CASE 
		when t.hazard_pa is not null
			then t.hazard_pa
		else t.hazard 
	END 												as hazard, 
	CASE 
		when t.geoid_pa is not null
			then t.geoid_pa
		else t.geoid
	END 												as geoid,
	CASE  
			when t.disaster_number_pa is not null
				then t.disaster_number_pa::text
			else t.disaster_number::text
	END					   								as disaster_number,
	
	ihp_verified_loss, ha_loss, project_amount, 0 as sba_loss, 0 as total_loss
from (ihp_data full outer join pa_data 
    on ihp_data.disaster_number = pa_data.disaster_number_pa::text
	and ihp_data.geoid = pa_data.geoid_pa) t
	where ihp_verified_loss > 0 
	or ha_loss > 0
	or project_amount > 0
-- group by 1,2,3,4



`

const proper = 
    `
    BEGIN;


CREATE TEMPORARY TABLE county_to_state ON COMMIT DROP AS 
	SELECT stusps, county.geoid, county.name, county.namelsad
			FROM geo.tl_2017_us_county county
					 JOIN geo.tl_2017_us_state state
						  on county.statefp = state.geoid
			order by county.statefp, countyfp;

CREATE INDEX tmp_cts_name_idx
  ON county_to_state
  USING BTREE
  (name, namelsad);
  
CREATE TEMPORARY TABLE pa_data ON COMMIT DROP AS 
	    select disaster_number disaster_number_pa, 
		state_number_code::text || lpad(county_code::text, 3, '0') geoid_pa, 
		extract(YEAR from declaration_date) disaster_year_pa,
		CASE
                    when incident_type = 'Fire' then 'wildfire'
                    when incident_type = 'Tsunami' then 'tsunami'
                    when incident_type = 'Tornado' then 'tornado'
                    when incident_type = 'Flood' then 'riverine'
                    when incident_type = 'Severe Storm(s)' then 'riverine'
                    when incident_type = 'Mud/Landslide' then 'landslide'
                    when incident_type = 'Severe Ice Storm' then 'icestorm'
                    when incident_type = 'Hurricane' then 'hurricane'
                    when incident_type = 'Typhoon' then 'hurricane'
                    when incident_type = 'Earthquake' then 'earthquake'
                    when incident_type = 'Drought' then 'drought'
                    when incident_type = 'Freezing' then 'coldwave'
                    when incident_type = 'Snow' then 'winterweat'
                    when incident_type = 'Volcano' then 'volcano'
                    when incident_type = 'Coastal Storm' then 'coastal'
                    else incident_type
                    END 															   as hazard_pa, 
		sum(coalesce(project_amount, 0)) project_amount
    from open_fema_data.public_assistance_funded_projects_details_v1
    where dcc not in ('A', 'B', 'Z')
-- 	and disaster_number = '4085' 
    group by 1, 2, 3, 4;


CREATE TEMPORARY TABLE ihp_data ON COMMIT DROP AS 
	         SELECT disaster_number,
		 		county_to_state.geoid,
                extract(YEAR from declaration_date) disaster_year,
                CASE
                    when ihp.incident_type = 'Fire' then 'wildfire'
                    when ihp.incident_type = 'Tsunami' then 'tsunami'
                    when ihp.incident_type = 'Tornado' then 'tornado'
                    when ihp.incident_type = 'Flood' then 'riverine'
                    when ihp.incident_type = 'Severe Storm(s)' then 'riverine'
                    when ihp.incident_type = 'Mud/Landslide' then 'landslide'
                    when ihp.incident_type = 'Severe Ice Storm' then 'icestorm'
                    when ihp.incident_type = 'Hurricane' then 'hurricane'
                    when ihp.incident_type = 'Typhoon' then 'hurricane'
                    when ihp.incident_type = 'Earthquake' then 'earthquake'
                    when ihp.incident_type = 'Drought' then 'drought'
                    when ihp.incident_type = 'Freezing' then 'coldwave'
                    when ihp.incident_type = 'Snow' then 'winterweat'
                    when ihp.incident_type = 'Volcano' then 'volcano'
                    when ihp.incident_type = 'Coastal Storm' then 'coastal'
                    else ihp.incident_type
                    END 															   as hazard,
                sum(coalesce(rpfvl, 0) + coalesce(ppfvl, 0))                    as ihp_verified_loss,
                sum(coalesce(ha_amount, 0)) 												   as ha_loss,
                sum(coalesce(rpfvl, 0) + coalesce(ppfvl, 0)) as total_loss
         FROM open_fema_data.individuals_and_households_program_valid_registrations_v1 ihp
		 join county_to_state
		 on coalesce(rpfvl, 0) + coalesce(ppfvl, 0) + coalesce(ha_amount, 0) > 0 
		 and damaged_state_abbreviation = stusps
		 and (
				REPLACE(REPLACE(REPLACE(lower(county), '(', ''), ')', ''), ' ', '') like '%' || REPLACE(lower(namelsad), ' ', '') || '%'
			   OR
				REPLACE(REPLACE(REPLACE(lower(county), '(', ''), ')', ''), ' ', '') = REPLACE(lower(name), ' ', '')
			)
-- 		 and disaster_number = '4085' 
         group by 1,2,3,4;
		 
insert into severe_weather_open_fema_data_merge.fba_annual_loss_by_county_by_hazard_sba_new
select 
	CASE 
		when t.disaster_year_pa is not null
			then t.disaster_year_pa
		else t.disaster_year 
	END 												as year, 
	CASE 
		when t.hazard_pa is not null
			then t.hazard_pa
		else t.hazard 
	END 												as hazard, 
	CASE 
		when t.geoid_pa is not null
			then t.geoid_pa
		else t.geoid
	END 												as geoid,
	CASE  
			when t.disaster_number_pa is not null
				then t.disaster_number_pa::text
			else t.disaster_number::text
	END					   								as disaster_number,
	
	ihp_verified_loss, ha_loss, project_amount, 0 as sba_loss, 0 as total_loss
from (ihp_data full outer join pa_data 
    on ihp_data.disaster_number = pa_data.disaster_number_pa::text
	and ihp_data.geoid = pa_data.geoid_pa) t
	where ihp_verified_loss > 0 
	or ha_loss > 0
	or project_amount > 0;
-- group by 1,2,3,4
	
COMMIT;
END;
    `