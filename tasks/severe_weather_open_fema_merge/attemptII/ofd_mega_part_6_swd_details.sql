with swd as (SELECT
                 disaster_number::text,
                 substring(geoid, 1, 5) geoid,
                 sum(property_damage)                        as swd_property_damage,
                 sum(crop_damage) 							 as swd_crop_damage
             FROM severe_weather_new.details sw
                      join severe_weather_new.disaster_number_to_event_id_mapping_without_hazard_type dn_eid
                           on sw.event_id = dn_eid.event_id
             group by 1, 2
             order by 1, 2)

update severe_weather_open_fema_data_merge.disaster_summaries_merge_without_hazard_type summary
set swd_property_damage = swd.swd_property_damage,
    swd_crop_damage = swd.swd_crop_damage
from swd
where summary.disaster_number = swd.disaster_number
  and summary.geoid = swd.geoid