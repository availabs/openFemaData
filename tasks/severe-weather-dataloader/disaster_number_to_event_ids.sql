with t as (
    SELECT a.disaster_number,
           a.incident_type                                   disaster_type,
           ARRAY_AGG(fips_state_code || fips_county_code)    counties,
           MIN(incident_begin_date)                          incident_begin_date,
           MAX(incident_end_date)                            incident_end_date
    FROM open_fema_data.disaster_declarations_summaries_v2 a
    GROUP BY 1, 2)

INSERT INTO severe_weather_new.disaster_number_to_event_id_mapping
SELECT distinct disaster_number, event_id
FROM severe_weather_new.details sw
         JOIN t
              ON t.counties @> string_to_array(substring(geoid, 1, 5), ',')
                  AND begin_date_time >= incident_begin_date
                  AND end_date_time <= incident_end_date
                  AND lower(event_type_formatted) = lower(disaster_type)
order BY disaster_number