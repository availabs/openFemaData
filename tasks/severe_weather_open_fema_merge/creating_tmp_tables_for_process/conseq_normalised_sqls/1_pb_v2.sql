with   buildings as (
    select
        'buildings' ctype,
        event_id,
        substring(geoid, 1, 5) geoid,
        nri_category nri_category,
        min(begin_date_time)::date     swd_begin_date,
        max(end_date_time)  ::date      swd_end_date,
        coalesce(sum(property_damage), 0)     damage
    FROM severe_weather_new.details
    WHERE year >= 1996 and year <= 2019
      AND nri_category not in ('Dense Fog', 'Marine Dense Fog', 'Dense Smoke', 'Dust Devil', 'Dust Storm', 'Astronomical Low Tide', 'Northern Lights', 'OTHER')
      AND geoid is not null
    GROUP BY 1, 2, 3
),
       crop as (
           select
               'crop' ctype,
               event_id,
               substring(geoid, 1, 5) geoid,
               nri_category nri_category,
               min(begin_date_time)::date      swd_begin_date,
               max(end_date_time)::date        swd_end_date,
               coalesce(sum(crop_damage), 0)         damage
           FROM severe_weather_new.details
           WHERE year >= 1996 and year <= 2019
             AND nri_category not in ('Dense Fog', 'Marine Dense Fog', 'Dense Smoke', 'Dust Devil', 'Dust Storm', 'Astronomical Low Tide', 'Northern Lights', 'OTHER')
             AND geoid is not null
           GROUP BY 1, 2, 3
       ),
       population as (
           select
               'population' ctype,
               event_id,
               substring(geoid, 1, 5) geoid,
               nri_category nri_category,
               min(begin_date_time)::date      swd_begin_date,
               max(end_date_time)::date        swd_end_date,
               coalesce(sum(
                                    coalesce(deaths_direct::float,0) +
                                    coalesce(deaths_indirect::float,0) +
                                    (
                                            (
                                                    coalesce(injuries_direct::float,0) +
                                                    coalesce(injuries_indirect::float,0)
                                                ) / 10
                                        )
                            ), 0) * 7600000   damage
           FROM severe_weather_new.details
           WHERE year >= 1996 and year <= 2019
             AND nri_category not in ('Dense Fog', 'Marine Dense Fog', 'Dense Smoke', 'Dust Devil', 'Dust Storm', 'Astronomical Low Tide', 'Northern Lights', 'OTHER')
             AND geoid is not null
           GROUP BY 1, 2, 3
       ), alldata as (
    select * from buildings

    union all

    select * from crop

    union all

    select * from population
),

       details_fema_per_basis as (
           SELECT ctype,
                  generate_series(swd_begin_date::date,
                                  LEAST(
                                          swd_end_date::date,
                                          CASE WHEN nri_category = 'drought' THEN swd_begin_date::date + INTERVAL '365 days' ELSE swd_begin_date::date + INTERVAL '31 days' END
                                      ), '1 day'::interval)::date event_day_date,
                  nri_category,
                  geoid,
                  sum(damage::double precision/LEAST(
                                  swd_end_date::date - swd_begin_date::date + 1,
                                  CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END)) damage
           FROM alldata
           WHERE nri_category in ('coldwave', 'drought', 'heatwave', 'icestorm', 'riverine', 'winterweat')
             AND geoid is not null
           group by 1, 2, 3, 4
           order by 1, 2, 3, 4),
       aggregation as (
           SELECT
               ctype,
               nri_category,
               geoid,
               swd_begin_date event_day_date,
               ARRAY_AGG(event_id)	  event_ids,
               count(1) 					num_events,
               sum (damage) damage

           from alldata
           where nri_category NOT IN ('coldwave', 'drought', 'heatwave', 'icestorm', 'riverine', 'winterweat')
           group by  1, 2, 3, 4
       ),
       final as (
           select ctype, nri_category, geoid, event_day_date,
                  event_ids, num_events,
                  damage, null::double precision damage_adjusted
           from aggregation

           UNION ALL

           select ctype, nri_category, geoid, event_day_date,
                  null as event_ids, null as num_events,
                  damage, null::double precision damage_adjusted
           from details_fema_per_basis

           order by 1, 2, 3, 4
       )

SELECT row_number() over () id, * INTO tmp_pb_for_doc_v2 FROM final


