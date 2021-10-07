with swd as (SELECT
                 disaster_number::text,
                 substring(geoid, 1, 5) geoid,
                 sum(coalesce(property_damage, 0) + coalesce(crop_damage, 0))                         as swd_loss
             FROM severe_weather_new.details sw
                      join severe_weather_new.disaster_number_to_event_id_mapping dn_eid
                           on sw.event_id = dn_eid.event_id
             group by 1, 2
             order by 1, 2)

update severe_weather_open_fema_data_merge.fba_annual_loss_by_county_by_hazard_sba_new summary
set swd_loss = swd.swd_loss
from swd
where summary.disaster_number = swd.disaster_number
  and summary.geoid = swd.geoid