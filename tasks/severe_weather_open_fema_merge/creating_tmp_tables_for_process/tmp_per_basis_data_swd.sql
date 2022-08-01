with
    swd as (SELECT
                substring(sw.geoid, 1, 5) geoid,
                sw.episode_id,
                sw.event_id,
                count(1),
                event_type_formatted,
                min(begin_date_time::date) swd_begin_date,
                max(end_date_time::date) swd_end_date,
                sum(property_damage)                        as swd_property_damage,
                sum(crop_damage) 							 as swd_crop_damage,
                sum(injuries_direct)                        as injuries_direct,
                sum(injuries_indirect)                         injuries_indirect,
                sum(deaths_direct)                             deaths_direct,
                sum(deaths_indirect)                           deaths_indirect
            FROM severe_weather_new.details sw
            WHERE year >= 1996 and year <= 2019
              AND substring(sw.geoid, 1, 5) not like '*'
              AND event_type_formatted not in ('Dense Fog', 'Dense Smoke', 'Dust Devil', 'Dust Storm', 'Astronomical Low Tide')
              AND sw.geoid is not null
            group by 1, 2, 3
            order by 1, 2)

        ,fusion_events as (
    select
        swd.geoid 																  geoid,
        event_id,
        event_type_formatted   						   							  nri_category,
        swd_begin_date			  											      swd_begin_date,
        swd_end_date		  											          swd_end_date,
        sum(swd.swd_property_damage) 											  swd_property_damage,
        sum(swd.swd_crop_damage)												  swd_crop_damage,
        sum(injuries_direct)  													  injuries_direct,
        sum(injuries_indirect) 													  injuries_indirect,
        sum(deaths_direct) 														  deaths_direct,
        sum(deaths_indirect) 													  deaths_indirect
    FROM swd
    GROUP BY 1, 2, 3, 4, 5
    ORDER BY 1, 2, 3, 4, 5
),
    details_fema_per_basis as (
        SELECT generate_series((swd_begin_date)::date,
                               LEAST(
                                       swd_end_date::date,
                                       CASE WHEN nri_category = 'drought' THEN swd_begin_date::date + INTERVAL '365 days' ELSE swd_begin_date::date + INTERVAL '31 days' END
                                   ), '1 day'::interval)::date event_day_date,
               nri_category hazard,
               geoid,
               sum(swd_property_damage::double precision/LEAST(
                               swd_end_date::date - swd_begin_date::date + 1,
                               CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END)) swd_property_damage,

               sum(swd_crop_damage::double precision/LEAST(
                               swd_end_date::date - swd_begin_date::date + 1,
                               CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END)) swd_crop_damage,

               sum(injuries_direct::double precision/LEAST(
                               swd_end_date::date - swd_begin_date::date + 1,
                               CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END)) injuries_direct,
               sum(injuries_indirect::double precision/LEAST(
                               swd_end_date::date - swd_begin_date::date + 1,
                               CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END)) injuries_indirect,
               sum(deaths_direct::double precision/LEAST(
                               swd_end_date::date - swd_begin_date::date + 1,
                               CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END)) deaths_direct,
               sum(deaths_indirect::double precision /LEAST(
                               swd_end_date::date - swd_begin_date::date + 1,
                               CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END)) deaths_inderect,
               sum(((
                                injuries_direct / LEAST(
                                            swd_end_date::date - swd_begin_date::date + 1,
                                            CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END) +
                                injuries_indirect / LEAST(
                                                swd_end_date::date - swd_begin_date::date + 1,
                                                CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END) +
                                deaths_direct / LEAST(
                                                swd_end_date::date - swd_begin_date::date + 1,
                                                CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END) +
                                deaths_indirect / LEAST(
                                                swd_end_date::date - swd_begin_date::date + 1,
                                                CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END)
                        )/10)*7600000) fatalities_dollar_value
        FROM fusion_events
        WHERE nri_category in ('coldwave', 'drought', 'heatwave', 'icestorm', 'riverine', 'winterweat')
          AND geoid is not null
        group by 1, 2, 3
        order by 1, 2, 3
    ),
    aggregation as (
        SELECT
            nri_category hazard,
            geoid,
            swd_begin_date event_day_date,
            sum (swd_property_damage) swd_property_damage,
            sum (swd_crop_damage) swd_crop_damage,
            sum(injuries_direct) injuries_direct,
            sum(injuries_indirect) injuries_indirect,
            sum(deaths_direct) deaths_direct,
            sum(deaths_indirect) deaths_indirect,
            sum((
                        NULLIF(coalesce(injuries_direct, 0) +
                               coalesce(injuries_indirect, 0) +
                               coalesce(deaths_direct, 0) +
                               coalesce(deaths_indirect, 0), 0
                            )/10 ) * 7600000) fatalities_dollar_value
        from fusion_events
        where nri_category NOT IN ('coldwave', 'drought', 'heatwave', 'icestorm', 'riverine', 'winterweat')
        group by  1, 2, 3
    ),
    final as (
        select hazard nri_category, geoid, event_day_date,
               swd_property_damage, swd_crop_damage, fatalities_dollar_value
        from aggregation

        UNION ALL

        select hazard nri_category, geoid, event_day_date,
               swd_property_damage, swd_crop_damage, fatalities_dollar_value
        from details_fema_per_basis

        order by 1, 2, 3
    )

select * from final
-- SELECT * INTO tmp_per_basis_data_zero_loss FROM final

