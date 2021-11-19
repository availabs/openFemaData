with ofd as (
    SELECT year, geoid, hazard, disaster_number,
           SUM(coalesce(ihp_verified_loss, 0) + coalesce(project_amount, 0) + coalesce(sba_loss, 0) + coalesce(nfip, 0) + coalesce(usda_crop_damage, 0)) ofd_loss
    FROM severe_weather_open_fema_data_merge.disaster_summaries_merge_without_hazard_type
    WHERE disaster_number is not null
    GROUP BY 1, 2, 3, 4
    ORDER BY 1, 2, 3, 4, 5
),
     swd as (SELECT extract(YEAR From begin_date_time) as year, substring(geoid, 1, 5) geoid, event_type_formatted hazard,
                    sum(coalesce(property_damage, 0) + coalesce(crop_damage, 0))                         as swd_loss
             FROM severe_weather_new.details sw
             WHERE event_id not in (SELECT event_id from severe_weather_new.disaster_number_to_event_id_mapping_without_hazard_type)
             GROUP BY 1, 2, 3
             ORDER BY 1, 2, 3, 4)

INSERT INTO severe_weather_open_fema_data_merge.fusion
SELECT coalesce(ofd.year, swd.year) as year, coalesce(ofd.geoid, swd.geoid) geoid, coalesce(ofd.hazard, swd.hazard) hazard,
       disaster_number, coalesce(ofd_loss, swd_loss) fusion_loss
FROM ofd FULL OUTER JOIN swd
                         ON ofd.year = swd.year
                             AND ofd.geoid = swd.geoid
                             AND ofd.hazard = swd.hazard
GROUP BY 1,2,3,4,5
ORDER BY 1,2,3,4 DESC