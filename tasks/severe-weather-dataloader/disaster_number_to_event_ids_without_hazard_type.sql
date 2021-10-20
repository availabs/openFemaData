with t as (
    SELECT a.disaster_number,
           ARRAY_AGG(fips_state_code || fips_county_code)    counties,
           MIN(incident_begin_date)                          incident_begin_date,
           MAX(incident_end_date)                            incident_end_date
    FROM open_fema_data.disaster_declarations_summaries_v2 a
    GROUP BY 1)

INSERT INTO severe_weather_new.disaster_number_to_event_id_mapping_without_hazard_type
SELECT distinct disaster_number, event_id
FROM severe_weather_new.details sw
         JOIN t
              ON substring(geoid, 1, 5) = any (t.counties)
                  AND begin_date_time >= incident_begin_date
                  AND end_date_time <= incident_end_date
order BY disaster_number