SELECT
    id, event_day_date, total_days, episode_id, swd_per_day.event_id, event_type,
    swd_per_day.year,
    swd_per_day.geoid,disaster_number,
    mapping.hazard, mapping.total_loss/total_days
FROM severe_weather_new.details_per_day_basis swd_per_day
         join (
    SELECT m.event_id, s.* FROM
        severe_weather_new.disaster_number_to_event_id_mapping_without_hazard_type m
            JOIN severe_weather_open_fema_data_merge.disaster_summaries_merge_without_hazard_type_2 s
                 ON s.disaster_number = m.disaster_number::text
) mapping
              on mapping.event_id = swd_per_day.event_id
                  and mapping.geoid = substring(swd_per_day.geoid, 1, 5)

-- need to do aggregation before mapping to fema, to prevent duplicate mappings from swd to fema. in swd, for each geoid and hazard type, all events that map to same disaster_number should be summed up.


CREATE TEMP TABLE t as (
    select count(1), id, episode_id, sum(total_days) days, substring(swd_per_day.geoid, 1, 5) geoid, event_type, swd_per_day.year, disaster_number, hazard fema_event_type, total_loss,
           0 as grouped_total_days
    FROM severe_weather_new.details_per_day_basis swd_per_day
             JOIN (
        SELECT m.event_id, s.* FROM
            severe_weather_new.disaster_number_to_event_id_mapping_without_hazard_type m
                JOIN severe_weather_open_fema_data_merge.disaster_summaries_merge_without_hazard_type_2 s
                     ON s.disaster_number = m.disaster_number::text
    ) mapping
                  on mapping.event_id = swd_per_day.event_id
                      and mapping.geoid = substring(swd_per_day.geoid, 1, 5)
    where swd_per_day.geoid is not null
    group by id, swd_per_day.geoid, event_type, swd_per_day.year, episode_id, disaster_number, hazard, total_loss
    order by disaster_number, geoid, 1 desc
);

CREATE TEMP TABLE s as ( select sum(days) days, geoid, disaster_number from t group by geoid, disaster_number );

update t
set grouped_total_days = s.days
from s
where t.geoid = s.geoid
  and t.disaster_number = s.disaster_number;

UPDATE severe_weather_new.details_per_day_basis src
SET fema_property_damage = (t.total_loss/t.grouped_total_days)*t.days,
    fema_event_type = t.fema_event_type
FROM t
WHERE src.id = t.id
-- select *, (total_loss/grouped_total_days)*days fema_property_damage from t order by geoid, disaster_number

-- equally divide disaster_loss, and then multiply with days of perticular event

