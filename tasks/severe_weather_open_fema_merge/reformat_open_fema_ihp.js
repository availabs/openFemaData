const reformat_open_fema_ihp = (table, sba) => `
BEGIN;
delete from severe_weather_open_fema_data_merge.${table};

with pa_data as (
    select disaster_number, sum(coalesce(project_amount, 0)) project_amount
    from open_fema_data.public_assistance_funded_projects_details_v1
    where dcc not in ('A', 'B', 'Z')
    group by 1
),
     ihp_data as (
         SELECT disaster_number,
                county,
                damaged_state_abbreviation 			state,
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
                sum(ha_amount) 												   as ha_loss,
                sum(coalesce(rpfvl, 0) + coalesce(ppfvl, 0)) as total_loss
         FROM open_fema_data.individuals_and_households_program_valid_registrations_v1 ihp
         group by 1,2,3,4,5
     )


INSERT INTO severe_weather_open_fema_data_merge.${table}
select county, state, disaster_year, hazard, ihp_verified_loss, ha_loss, 0 as project_amount, ${sba ? `0 as sba_loss,` : ``} total_loss,
       array_agg(distinct ihp_data.disaster_number) 						   as disaster_ids
from ihp_data
--     join pa_data
--                    on ihp_data.disaster_number = pa_data.disaster_number::text
group by county, state, disaster_year, hazard, ihp_verified_loss, ha_loss, project_amount, total_loss;

commit;
end;
`

module.exports = reformat_open_fema_ihp