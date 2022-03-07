INSERT INTO severe_weather_new.details_fema_per_day_basis(
    event_day_date, total_days, episode_id, event_id, event_type, year, geoid, property_damage, crop_damage, injuries_direct, injuries_indirect, deaths_direct, deaths_indirect,
    fema_property_damage)
SELECT generate_series(begin_date_time::date, end_date_time::date, '1 day'::interval)::date event_day_date,
       (select array_length(array_agg(i), 1) from generate_series(begin_date_time::date, end_date_time::date, '1 day'::interval) i) total_days,
       episode_id, details.event_id, event_type, details.year, details.geoid,

       property_damage::double precision/(select array_length(array_agg(i), 1) from
           generate_series(begin_date_time::date,
                           end_date_time::date, '1 day'::interval) i) property_damage,

       crop_damage::double precision/(select array_length(array_agg(i), 1) from
           generate_series(begin_date_time::date,
                           end_date_time::date, '1 day'::interval) i) crop_damage,

       injuries_direct::double precision/(select array_length(array_agg(i), 1) from
           generate_series(begin_date_time::date,
                           end_date_time::date, '1 day'::interval) i) injuries_direct,
       injuries_indirect::double precision/(select array_length(array_agg(i), 1) from
           generate_series(begin_date_time::date,
                           end_date_time::date, '1 day'::interval) i) injuries_indirect,
       deaths_direct::double precision/(select array_length(array_agg(i), 1) from
           generate_series(begin_date_time::date,
                           end_date_time::date, '1 day'::interval) i) deaths_direct,
       deaths_indirect::double precision /(select array_length(array_agg(i), 1) from
           generate_series(begin_date_time::date,
                           end_date_time::date, '1 day'::interval) i) deaths_inderect,
       total_loss/(select array_length(array_agg(i), 1) from
           generate_series(begin_date_time::date,
                           end_date_time::date, '1 day'::interval) i) fema_property_damage
FROM severe_weather_new.details
         LEFT JOIN (
    SELECT m.event_id, sum(s.total_loss) total_loss
    FROM severe_weather_new.disaster_number_to_event_id_mapping_without_hazard_type m
             JOIN severe_weather_open_fema_data_merge.disaster_summaries_merge_without_hazard_type_2 s
                  ON s.disaster_number = m.disaster_number::text
    group by m.event_id
) mapping
                   ON mapping.event_id = details.event_id 