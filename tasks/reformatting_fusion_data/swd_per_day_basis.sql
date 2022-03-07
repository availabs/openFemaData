INSERT INTO severe_weather_new.details_per_day_basis(
    event_day_date, total_days, episode_id, event_id, event_type, year, geoid, property_damage, crop_damage, injuries_direct, injuries_indirect, deaths_direct, deaths_indirect)
SELECT generate_series(begin_date_time::date, end_date_time::date, '1 day'::interval)::date event_day_date,
       (select array_length(array_agg(i), 1) from generate_series(begin_date_time::date, end_date_time::date, '1 day'::interval) i) total_days,
       episode_id, event_id, event_type, year, geoid,

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
                           end_date_time::date, '1 day'::interval) i) deaths_inderect
FROM severe_weather_new.details
-- where
--     (begin_day != end_day
--         or
--      begin_yearmonth != end_yearmonth)
--   and
--       coalesce(property_damage, 0) + coalesce(crop_damage, 0) > 0
order by event_id, episode_id


--
-- SELECT
--     begin_date_time, end_date_time,
--
--     generate_series(begin_date_time::date,
--                     end_date_time::date, '1 day'::interval)::date event_day_date,
--
--     (select array_length(array_agg(i), 1) from
--         generate_series(begin_date_time::date,
--                         end_date_time::date, '1 day'::interval) i) days,
--
--
--     episode_id, event_id, event_type,
--     geoid, year,
--
--     property_damage original_pd,
--
--     property_damage::double precision/(select array_length(array_agg(i), 1) from
--         generate_series(begin_date_time::date,
--                         end_date_time::date, '1 day'::interval) i) property_damage_per_day,
--
--     crop_damage original_cd,
--
--     crop_damage::double precision/(select array_length(array_agg(i), 1) from
--         generate_series(begin_date_time::date,
--                         end_date_time::date, '1 day'::interval) i) crop_damage_per_day,
--
--     injuries_direct, injuries_indirect, deaths_direct, deaths_indirect
-- FROM severe_weather_new.details
-- where
--     (begin_day != end_day
--         or
--      begin_yearmonth != end_yearmonth)
--   and coalesce(property_damage, 0) + coalesce(crop_damage, 0) > 0
-- order by episode_id
-- limit 100

