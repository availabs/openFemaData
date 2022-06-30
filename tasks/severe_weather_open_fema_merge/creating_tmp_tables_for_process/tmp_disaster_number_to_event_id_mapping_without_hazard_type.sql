with disaster_declarations_summary as (
    SELECT a.disaster_number,
           CASE
               WHEN lower(incident_type) = 'coastal storm'
                   THEN 'coastal'
               WHEN lower(incident_type) IN ('dam/levee break', 'flood', 'severe storm', 'severe storm(s)')
                   THEN 'riverine'
               WHEN lower(incident_type) = 'drought'
                   THEN 'drought'
               WHEN lower(incident_type) = 'fire'
                   THEN 'wildfire'
               WHEN lower(incident_type) = 'freezing'
                   THEN 'coldwave'
               WHEN lower(incident_type) IN ('hurricane', 'typhoon')
                   THEN 'hurricane'
               WHEN lower(incident_type) = 'mud/landslide'
                   THEN 'landslide'
               WHEN lower(incident_type) = 'severe ice storm'
                   THEN 'icestorm'
               WHEN lower(incident_type) = 'snow'
                   THEN 'winterweat'
               WHEN lower(incident_type) = 'earthquake'
                   THEN 'earthquake'
               WHEN lower(incident_type) = 'severe storm(s)'
                   THEN 'riverine'
               WHEN lower(incident_type) = 'tornado'
                   THEN 'tornado'
               WHEN lower(incident_type) = 'tsunami'
                   THEN 'tsunami'
               WHEN lower(incident_type) = 'volcano'
                   THEN 'volcano'
               ELSE incident_type
               END incident_type,
           ARRAY_AGG(fips_state_code || fips_county_code)    counties,
           MIN(incident_begin_date)                          incident_begin_date,
           MAX(incident_end_date)                            incident_end_date
    FROM open_fema_data.disaster_declarations_summaries_v2 a
    GROUP BY 1, 2
)
insert into tmp_disaster_number_to_event_id_mapping_without_hazard_type
SELECT distinct disaster_number, event_id
FROM severe_weather_new.details sw
         JOIN disaster_declarations_summary d
              ON substring(geoid, 1, 5) = any (d.counties)
                  AND (begin_date_time, end_date_time) OVERLAPS (incident_begin_date, incident_end_date)
                  AND (
                             incident_type = event_type_formatted OR
                             (incident_type = 'hurricane' AND event_type_formatted = 'riverine') OR
                             (incident_type = 'riverine' AND event_type_formatted = 'tornado') OR
                             (incident_type = 'riverine' AND event_type_formatted = 'coastal') OR
--                                       (incident_type = 'riverine' AND event_type_formatted = 'Heavy Rain') OR
                             (incident_type = 'icestorm' AND event_type_formatted = 'coldwave') OR
                             (incident_type = 'icestorm' AND event_type_formatted = 'hail') OR
                             (incident_type = 'winterweat' AND event_type_formatted = 'coldwave') OR
                             (incident_type = 'winterweat' AND event_type_formatted = 'icestorm')
                     )
ORDER BY disaster_number
