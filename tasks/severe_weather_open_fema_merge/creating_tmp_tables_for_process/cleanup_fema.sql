-- select *
-- from severe_weather_new.details
-- where event_id = 5475131

select distinct a.geoid, a.disaster_number, b.disaster_number, a.fema_property_damage, b.fema_property_damage,
                daterange(a.fema_incident_begin_date::date, a.fema_incident_end_date::date),
                daterange(b.fema_incident_begin_date::date, b.fema_incident_end_date::date)
from open_fema_data.tmp_disaster_loss_summary a
         JOIN open_fema_data.tmp_disaster_loss_summary b
              ON (a.fema_incident_begin_date, a.fema_incident_end_date) overlaps (b.fema_incident_begin_date, b.fema_incident_end_date)
                  and a.geoid = b.geoid
                  and a.disaster_number != b.disaster_number
                  -- and not (a.disaster_number::numeric >= 3000 and a.disaster_number::numeric  <= 3999)
-- and not (b.disaster_number::numeric >= 3000 and b.disaster_number::numeric <= 3999)
                  and not (a.disaster_number::numeric >= 2000 and a.disaster_number::numeric  <= 2999)
                  and not (b.disaster_number::numeric >= 2000 and b.disaster_number::numeric <= 2999)
                  and a.disaster_number > b.disaster_number -- to eliminate duplicate matches i.e. 1 -> 2, 2 -> 1
order by 1, 2
limit 100