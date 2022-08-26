with   merged_data_for_per_basis as (
    select
        event_id,
        substring(geoid, 1, 5) geoid,
        nri_category nri_category,
        min(begin_date_time)     swd_begin_date,
        max(end_date_time)       swd_end_date,
        sum(property_damage)        swd_property_damage,
        sum(crop_damage)        swd_crop_damage,
        sum(injuries_direct)        injuries_direct,
        sum(injuries_indirect)        injuries_indirect,
        sum(deaths_direct)        deaths_direct,
        sum(deaths_indirect)        deaths_indirect
    FROM severe_weather_new.details
    WHERE year >= 1996 and year <= 2019
      AND nri_category not in ('Dense Fog', 'Marine Dense Fog', 'Dense Smoke', 'Dust Devil', 'Dust Storm', 'Astronomical Low Tide', 'Northern Lights', 'OTHER')
      AND geoid is not null
      AND property_damage > 0
    GROUP BY 1, 2, 3
),
       details_fema_per_basis as (
           SELECT generate_series(swd_begin_date::date,
                                  LEAST(
                                          swd_end_date::date,
                                          CASE WHEN nri_category = 'drought' THEN swd_begin_date::date + INTERVAL '365 days' ELSE swd_begin_date::date + INTERVAL '31 days' END
                                      ), '1 day'::interval)::date event_day_date,
                  nri_category,
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
           FROM merged_data_for_per_basis
           WHERE nri_category in ('coldwave', 'drought', 'heatwave', 'icestorm', 'riverine', 'winterweat')
             AND geoid is not null
           group by 1, 2, 3
           order by 1, 2, 3),
       aggregation as (
           SELECT
               nri_category,
               geoid,
               swd_begin_date event_day_date,
               ARRAY_AGG(event_id)	  event_ids,
               count(1) 					num_events,
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
           from merged_data_for_per_basis
           where nri_category NOT IN ('coldwave', 'drought', 'heatwave', 'icestorm', 'riverine', 'winterweat')
           group by  1, 2, 3
       ),
       final as (
           select nri_category, geoid, event_day_date,
                  event_ids, num_events,
                  swd_property_damage, swd_crop_damage, fatalities_dollar_value
           from aggregation

           UNION ALL

           select nri_category, geoid, event_day_date,
                  null as event_ids, null as num_events,
                  swd_property_damage, swd_crop_damage, fatalities_dollar_value
           from details_fema_per_basis

           order by 1, 2, 3
       )

SELECT * INTO tmp_per_basis_data_swd FROM final;
