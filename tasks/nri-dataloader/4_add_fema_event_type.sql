with t as (SELECT mapping.event_id, hazard, count(1)
           FROM severe_weather_new.details
                    LEFT JOIN (
               SELECT m.event_id, hazard, sum(s.total_loss) total_loss
               FROM severe_weather_new.disaster_number_to_event_id_mapping_without_hazard_type m
                        JOIN severe_weather_open_fema_data_merge.disaster_summaries_merge_without_hazard_type_2 s
                             ON s.disaster_number = m.disaster_number::text
               group by m.event_id, hazard
           ) mapping
                              ON mapping.event_id = details.event_id
           group by 1, 2
           order by 3 desc, 1,2)

UPDATE severe_weather_new.details_fema_per_day_basis dst
SET fema_event_type = t.hazard
FROM t
WHERE dst.event_id = t.event_id
