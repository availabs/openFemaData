with county_to_state as (
    SELECT stusps, county.geoid, county.name, county.namelsad
    FROM geo.tl_2017_us_county county
             JOIN geo.tl_2017_us_state state
                  on county.statefp = state.geoid
    order by county.statefp, countyfp
)

insert into severe_weather_open_fema_data_merge.test_merge(stusps, geoid, name, namelsad, disaster_number, year, hazard, ihp_verified_loss, ha_loss)
SELECT
    stusps,
    county_to_state.geoid,
    name,
    namelsad,
    ihp.disaster_number,
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
    sum(coalesce(ha_amount, 0)) 												   as ha_loss
FROM open_fema_data.individuals_and_households_program_valid_registrations_v1 ihp
         full outer join county_to_state
                         on coalesce(rpfvl, 0) + coalesce(ppfvl, 0) + coalesce(ha_amount, 0) > 0
                             and damaged_state_abbreviation = stusps
                             and (
                                        REPLACE(REPLACE(REPLACE(lower(county), '(', ''), ')', ''), ' ', '') like '%' || REPLACE(lower(namelsad), ' ', '') || '%'
                                    OR
                                        REPLACE(REPLACE(REPLACE(lower(county), '(', ''), ')', ''), ' ', '') = REPLACE(lower(name), ' ', '')
                                )
group by 1,2,3,4,5,6,7