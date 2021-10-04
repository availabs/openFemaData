const reformat_open_fema_ihp = (table, sba) => `
BEGIN;
delete from severe_weather_open_fema_data_merge.${table};

with  
	county_to_state as (
			SELECT stusps, county.geoid, county.name, county.namelsad
			FROM geo.tl_2017_us_county county
					 JOIN geo.tl_2017_us_state state
						  on county.statefp = state.geoid
			order by county.statefp, countyfp
	),
	pa_data as (
    select disaster_number, 
		state_number_code::text || lpad(county_code::text, 3, '0') geoid, 
		extract(YEAR from declaration_date) disaster_year,
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
                    END 															   as hazard, 
		sum(coalesce(project_amount, 0)) project_amount
    from open_fema_data.public_assistance_funded_projects_details_v1
    where dcc not in ('A', 'B', 'Z')
	and disaster_number = '4085' 
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
		 and disaster_number = '4085' 
         group by 1,2,3,4
     )


INSERT INTO severe_weather_open_fema_data_merge.${table}
select 
	CASE 
		when pa_data.disaster_year is not null
			then pa_data.disaster_year
		else ihp_data.disaster_year 
	END disaster_year, 
	CASE 
		when pa_data.hazard is not null
			then pa_data.hazard
		else ihp_data.hazard 
	END hazard, 
	CASE 
		when pa_data.geoid is not null
			then pa_data.geoid
		else ihp_data.geoid 
	END geoid,
		ihp_verified_loss, ha_loss, project_amount,
    	array_agg(
			CASE 
				when pa_data.disaster_number is not null
					then pa_data.disaster_number::text
				else ihp_data.disaster_number 
			END
		)						   as disaster_ids
from ihp_data  
    full outer join pa_data 
    on ihp_data.disaster_number = pa_data.disaster_number::text
	and pa_data.geoid = ihp_data.geoid  
	where ihp_verified_loss > 0 
	or ha_loss > 0
	or project_amount > 0
group by 1,2,3,4,5,6

commit;
end;
`

module.exports = reformat_open_fema_ihp