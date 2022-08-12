with
    disaster_declarations_summary as (
        SELECT * from open_fema_data.tmp_disaster_loss_summary
		where disaster_number = ANY('{4085, 3351}') 
    ),
    disaster_declarations_summary_grouped_for_merge as (
        SELECT disaster_number,
               incident_type,
               ARRAY_AGG(geoid) counties,
               min(fema_incident_begin_date::date)                     fema_incident_begin_date,
               max(fema_incident_end_date::date)                       fema_incident_end_date
        FROM disaster_declarations_summary
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
                                     (incident_type = 'hurricane' AND event_type_formatted = 'riverine') OR
							  		 (incident_type = 'hurricane' AND event_type_formatted = 'coastal') OR
							  		 (incident_type = 'hurricane' AND event_type_formatted = 'wind') OR
                                     (incident_type = 'icestorm' AND event_type_formatted = 'coldwave') OR
--                                      (incident_type = 'icestorm' AND event_type_formatted = 'hail') OR
                                     (incident_type = 'winterweat' AND event_type_formatted = 'coldwave') OR
                                     (incident_type = 'winterweat' AND event_type_formatted = 'icestorm') OR
                                     (incident_type = 'earthquake' AND event_type_formatted = 'landslide') OR
                                 --                 (incident_type = 'tornado' AND event_type_formatted = 'coastal') OR
--                 (incident_type = 'tornado' AND event_type_formatted = 'Heavy Rain') OR
                                     (incident_type = 'tornado' AND event_type_formatted = 'wind') OR
--                 (incident_type = 'tornado' AND event_type_formatted = 'hail') OR
                                     (incident_type = 'icestorm' AND event_type_formatted = 'winterweat')
                             )
        WHERE year >= 1996 and year <= 2019
--           AND (property_damage > 0 OR crop_damage > 0 OR injuries_direct > 0 OR injuries_indirect > 0 OR deaths_direct > 0 OR deaths_indirect > 0)
          AND event_type_formatted not in ('Dense Fog', 'Dense Smoke', 'Dust Devil', 'Dust Storm', 'Astronomical Low Tide')
          AND geoid is not null
        ORDER BY disaster_number
    ),
    disaster_division_factor as (
        select disaster_number, count(1) division_factor
        from disaster_number_to_event_id_mapping_without_hazard_type
        group by disaster_number
        order by 1 desc
    ),
    event_division_factor as (
        select event_id, count(1) division_factor
        from disaster_number_to_event_id_mapping_without_hazard_type
        group by event_id
        order by 1 desc
    ),
    swd as (SELECT
                dd.disaster_number::text,
                substring(sw.geoid, 1, 5) geoid,
                sw.episode_id,
                sw.event_id,
                count(1),
                event_type_formatted,
                min(fema_incident_begin_date)                                               as fema_incident_begin_date,
                max(fema_incident_end_date)                                                 as fema_incident_end_date,
                min(begin_date_time::date) swd_begin_date,
                max(end_date_time::date) swd_end_date,
                sum(property_damage/coalesce(edf.division_factor, 1))                        as swd_property_damage,
                sum(crop_damage/coalesce(edf.division_factor, 1)) 							 as swd_crop_damage,
                sum(injuries_direct/coalesce(edf.division_factor, 1))                        as injuries_direct,
                sum(injuries_indirect/coalesce(edf.division_factor, 1))                         injuries_indirect,
                sum(deaths_direct/coalesce(edf.division_factor, 1))                             deaths_direct,
                sum(deaths_indirect/coalesce(edf.division_factor, 1))                           deaths_indirect
            FROM severe_weather_new.details sw
                     LEFT JOIN disaster_number_to_event_id_mapping_without_hazard_type dn_eid
                               on sw.event_id = dn_eid.event_id
                     LEFT JOIN disaster_declarations_summary dd
                               on dd.disaster_number::text = dn_eid.disaster_number
                                   AND substring(sw.geoid, 1, 5) = dd.geoid
                     LEFT JOIN event_division_factor edf
                               ON edf.event_id = sw.event_id

            WHERE year >= 1996 and year <= 2019
              AND substring(sw.geoid, 1, 5) not like '*'
--               AND (property_damage > 0 OR crop_damage > 0 OR injuries_direct > 0 OR injuries_indirect > 0 OR deaths_direct > 0 OR deaths_indirect > 0)
              AND event_type_formatted not in ('Dense Fog', 'Dense Smoke', 'Dust Devil', 'Dust Storm', 'Astronomical Low Tide')
--             	AND sw.event_id = 5696210
              AND sw.geoid is not null
			and dd.disaster_number::text = ANY('{4085, 3351}') 
            group by 1, 2, 3, 4
            order by 1, 2)

        ,fusion_events as (
    select
        coalesce(ofd.geoid, swd.geoid) geoid,
        event_id,
        coalesce(event_type_formatted , incident_type)   						  nri_category,
        swd_begin_date			  											      swd_begin_date,
        swd_end_date		  											          swd_end_date,
        ofd.disaster_number						  					  			  disaster_number,
        min(coalesce(ofd.fema_incident_begin_date, swd.fema_incident_begin_date))  fema_incident_begin_date,
        max(coalesce(ofd.fema_incident_end_date, swd.fema_incident_end_date))     fema_incident_end_date,
        sum(fema_property_damage) 				  fema_property_damage,
        sum(fema_crop_damage)     				  fema_crop_damage,
        sum(swd.swd_property_damage) 											  swd_property_damage,
        sum(swd.swd_crop_damage)												  swd_crop_damage,
        sum(injuries_direct)  													  injuries_direct,
        sum(injuries_indirect) 													  injuries_indirect,
        sum(deaths_direct) 														  deaths_direct,
        sum(deaths_indirect) 													  deaths_indirect

    FROM disaster_declarations_summary ofd
             FULL OUTER JOIN swd
                             ON ofd.disaster_number = swd.disaster_number
                                 AND ofd.geoid = swd.geoid
             LEFT JOIN disaster_division_factor ddf
                       ON ofd.disaster_number = ddf.disaster_number
	
    GROUP BY 1, 2, 3, 4, 5,6
    ORDER BY 1, 2, 3, 4, 5,6
)
--     details_fema_per_basis as (
--         SELECT generate_series(coalesce(swd_begin_date, fema_incident_begin_date)::date,
--                                LEAST(
--                                        coalesce(swd_end_date, fema_incident_end_date)::date,
--                                        CASE WHEN nri_category = 'drought' THEN coalesce(swd_begin_date, fema_incident_begin_date)::date + INTERVAL '365 days' ELSE coalesce(swd_begin_date, fema_incident_begin_date)::date + INTERVAL '31 days' END
--                                    ), '1 day'::interval)::date event_day_date,
--                nri_category hazard,
--                geoid,
--                sum(swd_property_damage::double precision/LEAST(
--                                coalesce(swd_end_date, fema_incident_end_date)::date - coalesce(swd_begin_date, fema_incident_begin_date)::date + 1,
--                                CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END)) swd_property_damage,

--                sum(swd_crop_damage::double precision/LEAST(
--                                coalesce(swd_end_date, fema_incident_end_date)::date - coalesce(swd_begin_date, fema_incident_begin_date)::date + 1,
--                                CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END)) swd_crop_damage,

--                sum(injuries_direct::double precision/LEAST(
--                                coalesce(swd_end_date, fema_incident_end_date)::date - coalesce(swd_begin_date, fema_incident_begin_date)::date + 1,
--                                CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END)) injuries_direct,
--                sum(injuries_indirect::double precision/LEAST(
--                                coalesce(swd_end_date, fema_incident_end_date)::date - coalesce(swd_begin_date, fema_incident_begin_date)::date + 1,
--                                CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END)) injuries_indirect,
--                sum(deaths_direct::double precision/LEAST(
--                                coalesce(swd_end_date, fema_incident_end_date)::date - coalesce(swd_begin_date, fema_incident_begin_date)::date + 1,
--                                CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END)) deaths_direct,
--                sum(deaths_indirect::double precision /LEAST(
--                                coalesce(swd_end_date, fema_incident_end_date)::date - coalesce(swd_begin_date, fema_incident_begin_date)::date + 1,
--                                CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END)) deaths_inderect,
--                sum(fema_property_damage/LEAST(
--                                coalesce(swd_end_date, fema_incident_end_date)::date - coalesce(swd_begin_date, fema_incident_begin_date)::date + 1,
--                                CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END)) fema_property_damage,
--                sum(fema_crop_damage/LEAST(
--                                coalesce(swd_end_date, fema_incident_end_date)::date - coalesce(swd_begin_date, fema_incident_begin_date)::date + 1,
--                                CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END)) fema_crop_damage,
--                sum(((
--                                 injuries_direct / LEAST(
--                                             coalesce(swd_end_date, fema_incident_end_date)::date - coalesce(swd_begin_date, fema_incident_begin_date)::date + 1,
--                                             CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END) +
--                                 injuries_indirect / LEAST(
--                                                 coalesce(swd_end_date, fema_incident_end_date)::date - coalesce(swd_begin_date, fema_incident_begin_date)::date + 1,
--                                                 CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END) +
--                                 deaths_direct / LEAST(
--                                                 coalesce(swd_end_date, fema_incident_end_date)::date - coalesce(swd_begin_date, fema_incident_begin_date)::date + 1,
--                                                 CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END) +
--                                 deaths_indirect / LEAST(
--                                                 coalesce(swd_end_date, fema_incident_end_date)::date - coalesce(swd_begin_date, fema_incident_begin_date)::date + 1,
--                                                 CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END)
--                         )/10)*7600000) fatalities_dollar_value
--         FROM fusion_events
--         WHERE nri_category in ('coldwave', 'drought', 'heatwave', 'icestorm', 'riverine', 'winterweat')
--           AND geoid is not null
--         group by 1, 2, 3
--         order by 1, 2, 3),
--     aggregation as (
--         SELECT
--             nri_category hazard,
--             geoid,
--             coalesce(swd_begin_date, fema_incident_begin_date) event_day_date,
--             ARRAY_AGG(event_id)	  event_ids,
--             ARRAY_AGG(distinct disaster_numbers) disaster_number,
--             count(1) 					num_events,
--             sum (swd_property_damage) swd_property_damage,
--             sum (swd_crop_damage) swd_crop_damage,
--             sum(injuries_direct) injuries_direct,
--             sum(injuries_indirect) injuries_indirect,
--             sum(deaths_direct) deaths_direct,
--             sum(deaths_indirect) deaths_indirect,
--             sum (fema_property_damage) fema_property_damage,
--             sum (fema_crop_damage) fema_crop_damage,
--             sum((
--                         NULLIF(coalesce(injuries_direct, 0) +
--                                coalesce(injuries_indirect, 0) +
--                                coalesce(deaths_direct, 0) +
--                                coalesce(deaths_indirect, 0), 0
--                             )/10 ) * 7600000) fatalities_dollar_value
--         from fusion_events
--         where nri_category NOT IN ('coldwave', 'drought', 'heatwave', 'icestorm', 'riverine', 'winterweat')
--         group by  1, 2, 3
--     ),
--     final as (
--         select hazard nri_category, geoid, event_day_date,
--                event_ids, disaster_number, num_events,
--                swd_property_damage, swd_crop_damage, fema_property_damage, fema_crop_damage, fatalities_dollar_value
--         from aggregation

--         UNION ALL

--         select hazard nri_category, geoid, event_day_date,
--                null as event_ids, null as disaster_number, null as num_events,
--                swd_property_damage, swd_crop_damage, fema_property_damage, fema_crop_damage, fatalities_dollar_value
--         from details_fema_per_basis

--         order by 1, 2, 3
--     )

SELECT
	disaster_number,
	count(1),
	to_char(sum(fema_property_damage), 'FM999,999,999,999') as fema,
	to_char(sum(swd_property_damage), 'FM999,999,999,999') as swd
	FROM fusion_events where  disaster_number = '4085'
	group by 1
	order by 1;

-- select disaster_number, sum(fema_property_damage) from disaster_declarations_summary where disaster_number = '4085'
-- group by 1

