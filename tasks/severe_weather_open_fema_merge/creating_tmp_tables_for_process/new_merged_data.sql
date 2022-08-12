with disaster_declarations_summary_grouped_for_merge as (
    SELECT disaster_number,
           incident_type,
           ARRAY_AGG(geoid) counties,
           min(fema_incident_begin_date::date)                     fema_incident_begin_date,
           max(fema_incident_end_date::date)                       fema_incident_end_date
    FROM open_fema_data.tmp_disaster_loss_summary
    GROUP BY 1, 2
),
     disaster_number_to_event_id_mapping_without_hazard_type as (
         SELECT distinct disaster_number, event_id
         FROM severe_weather_new.details sw
                  JOIN disaster_declarations_summary_grouped_for_merge d
                       ON substring(geoid, 1, 5) = any (d.counties)
                           AND (begin_date_time::date, end_date_time::date) OVERLAPS (fema_incident_begin_date, fema_incident_end_date)
                           AND (
                                      incident_type = event_type_formatted OR
                                      (incident_type = 'hurricane' AND event_type_formatted = 'coastal') OR
                                      (incident_type = 'hurricane' AND event_type_formatted = 'wind') OR
                                      (incident_type = 'hurricane' AND event_type_formatted = 'riverine') OR
                                      (incident_type = 'icestorm' AND event_type_formatted = 'coldwave') OR
                                      (incident_type = 'winterweat' AND event_type_formatted = 'coldwave') OR
                                      (incident_type = 'winterweat' AND event_type_formatted = 'icestorm') OR
                                      (incident_type = 'earthquake' AND event_type_formatted = 'landslide') OR
                                      (incident_type = 'tornado' AND event_type_formatted = 'wind') OR
                                      (incident_type = 'icestorm' AND event_type_formatted = 'winterweat')
                              )
         WHERE year >= 1996 and year <= 2019
           AND event_type_formatted not in ('Dense Fog', 'Dense Smoke', 'Dust Devil', 'Dust Storm', 'Astronomical Low Tide')
           AND geoid is not null
         ORDER BY disaster_number
     ),
     event_division_factor as (
         select event_id, count(1) division_factor
         from disaster_number_to_event_id_mapping_without_hazard_type
         group by event_id
         order by 1 desc
     ),
     swd as (
         SELECT
             substring(sw.geoid, 1, 5) geoid,
             sw.event_id,
             dn_eid.disaster_number,
             sw.event_type_formatted nri_category,
             min(begin_date_time::date) swd_begin_date,
             max(end_date_time::date) swd_end_date,
             sum(property_damage)/coalesce(edf.division_factor, 1)                        as swd_property_damage,
             sum(crop_damage)/coalesce(edf.division_factor, 1) 							 as swd_crop_damage,
             sum(injuries_direct)/coalesce(edf.division_factor, 1)                        as injuries_direct,
             sum(injuries_indirect)/coalesce(edf.division_factor, 1)                         injuries_indirect,
             sum(deaths_direct)/coalesce(edf.division_factor, 1)                             deaths_direct,
             sum(deaths_indirect)/coalesce(edf.division_factor, 1)                           deaths_indirect
         FROM severe_weather_new.details sw
                  LEFT JOIN disaster_number_to_event_id_mapping_without_hazard_type dn_eid
                            on sw.event_id = dn_eid.event_id
                  LEFT JOIN event_division_factor edf
                            ON edf.event_id = sw.event_id
         WHERE year >= 1996 and year <= 2019
           AND event_type_formatted not in ('Dense Fog', 'Dense Smoke', 'Dust Devil', 'Dust Storm', 'Astronomical Low Tide')
           AND (sw.geoid is not null)
         group by 1, 2, 3, 4, division_factor
         order by 1, 2, 3, 4
     ),
     full_data as (
         SELECT coalesce(swd.geoid, ofd.geoid)   geoid,
                event_id,
                ofd.disaster_number,
                coalesce(nri_category, incident_type) nri_category,

                swd_begin_date,
                swd_end_date,

                fema_incident_begin_date,
                fema_incident_end_date,

                fema_property_damage,
                fema_crop_damage,

                swd_property_damage,
                swd_crop_damage,
                injuries_direct,
                injuries_indirect,
                deaths_direct,
                deaths_indirect
         FROM swd
                  FULL OUTER JOIN open_fema_data.tmp_disaster_loss_summary ofd
                                  ON swd.disaster_number = ofd.disaster_number
                                      AND swd.geoid = ofd.geoid
     ),
     disaster_division_factor as (
         select disaster_number, geoid, count(1) ddf
         from full_data
         group by 1, 2
         order by 1, 2
     ),
     full_adjusted as (
         SELECT fd.geoid,
                event_id,
                fd.disaster_number,
                nri_category,
                swd_begin_date,
                swd_end_date,
                fema_incident_begin_date,
                fema_incident_end_date,
                fema_property_damage/ddf fema_property_damage,
                fema_crop_damage/ddf fema_crop_damage,
                swd_property_damage,
                swd_crop_damage,
                injuries_direct,
                injuries_indirect,
                deaths_direct,
                deaths_indirect
         FROM full_data fd
                  LEFT JOIN disaster_division_factor ddf
                            ON ddf.disaster_number = fd.disaster_number
                                AND ddf.geoid = fd.geoid
     )
select *
into severe_weather_new.tmp_merged_data
from full_adjusted
