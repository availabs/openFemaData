with county_to_state as (
    SELECT stusps, county.geoid, county.name, county.namelsad
    FROM geo.tl_2017_us_county county
             JOIN geo.tl_2017_us_state state
                  on county.statefp = state.geoid
-- 	where county.statefp = '36'
    order by county.statefp, countyfp
)

-- select county, state
-- from severe_weather_open_fema_data_merge.fema_presidential_disasters_annual_loss_by_county_by_hazard a
-- where geoid is null


UPDATE severe_weather_open_fema_data_merge.fema_presidential_disasters_annual_loss_by_county_by_hazard a
set geoid = b.geoid
    from county_to_state b
where a.state = b.stusps
  and (
    REPLACE(REPLACE(REPLACE(lower(county), '(', ''), ')', ''), ' ', '') like '%' || REPLACE(lower(namelsad), ' ', '') || '%'
   OR
    REPLACE(REPLACE(REPLACE(lower(county), '(', ''), ')', ''), ' ', '') = REPLACE(lower(name), ' ', '')
    )


-- SELECT stusps, county.geoid, county.name, county.namelsad
-- FROM geo.tl_2017_us_county county
-- JOIN geo.tl_2017_us_state state
-- on county.statefp = state.geoid
-- where lower(county.namelsad) like '%fort%'
-- order by county.statefp, countyfp
