with   buildings as (
    select
        'buildings' ctype,
        event_id,
        substring(geoid, 1, 5) geoid,
        nri_category nri_category,
        min(coalesce(swd_begin_date, fema_incident_begin_date))::date     swd_begin_date,
        max(coalesce(swd_end_date, fema_incident_end_date))  ::date      swd_end_date,
        coalesce(sum(fusion_property_damage), 0)     damage
    FROM severe_weather_new.tmp_merged_data_v3
    WHERE extract(YEAR from coalesce(swd_begin_date, fema_incident_begin_date)) >= 1996 and extract(YEAR from coalesce(swd_end_date, fema_incident_end_date)) <= 2019
      AND nri_category not in ('Dense Fog', 'Marine Dense Fog', 'Dense Smoke', 'Dust Devil', 'Dust Storm', 'Astronomical Low Tide', 'Northern Lights', 'OTHER')
      AND geoid is not null
      AND fusion_property_damage > 0
    GROUP BY 1, 2, 3, 4
),
       crop as (
           select
               'crop' ctype,
               event_id,
               substring(geoid, 1, 5) geoid,
               nri_category nri_category,
               min(coalesce(swd_begin_date, fema_incident_begin_date))::date     swd_begin_date,
               max(coalesce(swd_end_date, fema_incident_end_date))  ::date      swd_end_date,
               coalesce(sum(fusion_crop_damage), 0)         damage
           FROM severe_weather_new.tmp_merged_data_v3
           WHERE extract(YEAR from coalesce(swd_begin_date, fema_incident_begin_date)) >= 1996 and extract(YEAR from coalesce(swd_end_date, fema_incident_end_date)) <= 2019
             AND nri_category not in ('Dense Fog', 'Marine Dense Fog', 'Dense Smoke', 'Dust Devil', 'Dust Storm', 'Astronomical Low Tide', 'Northern Lights', 'OTHER')
             AND geoid is not null
             AND fusion_crop_damage > 0
           GROUP BY 1, 2, 3, 4
       ),
       population as (
           select
               'population' ctype,
               event_id,
               substring(geoid, 1, 5) geoid,
               nri_category nri_category,
               min(coalesce(swd_begin_date, fema_incident_begin_date))::date     swd_begin_date,
               max(coalesce(swd_end_date, fema_incident_end_date))  ::date      swd_end_date,
               coalesce(sum(swd_population_damage), 0) * 7600000   damage
           FROM severe_weather_new.tmp_merged_data_v3
           WHERE extract(YEAR from coalesce(swd_begin_date, fema_incident_begin_date)) >= 1996 and extract(YEAR from coalesce(swd_end_date, fema_incident_end_date)) <= 2019
             AND nri_category not in ('Dense Fog', 'Marine Dense Fog', 'Dense Smoke', 'Dust Devil', 'Dust Storm', 'Astronomical Low Tide', 'Northern Lights', 'OTHER')
             AND geoid is not null
             AND swd_population_damage > 0
           GROUP BY 1, 2, 3, 4
       ), alldata as (
    select * from buildings

    union all

    select * from crop

    union all

    select * from population
),
       consec_aggregation_prep as (
           SELECT
               ctype,
               nri_category,
               geoid,
               swd_begin_date event_day_date,
               CASE
                   WHEN lead(swd_begin_date, 1) OVER(partition by geoid, nri_category, ctype order by swd_begin_date) - swd_begin_date = 1
                       then 1
                   WHEN lag(swd_begin_date, 1) OVER(partition by geoid, nri_category, ctype order by swd_begin_date) - swd_begin_date = -1
                       then 1
                   else 0
                   END consec_days,
               event_id,
               damage

           from alldata
           where nri_category IN ('coastal', 'hurricane', 'tsunami')
       ),
       consec_aggregation as (
           SELECT ctype, nri_category, geoid, min(event_day_date) event_day_date, ARRAY_AGG(event_id) event_ids , count(1) num_events, sum(damage) damage
           FROM consec_aggregation_prep
           GROUP BY 1, 2, 3, consec_days
       ),
       day_expansion as (
           SELECT ctype,
                  geoid,
                  nri_category,
                  generate_series(swd_begin_date::date,
                                  LEAST(
                                          swd_end_date::date,
                                          CASE WHEN nri_category = 'drought' THEN swd_begin_date::date + INTERVAL '365 days' ELSE swd_begin_date::date + INTERVAL '31 days' END
                                      ), '1 day'::interval)::date event_day_date,
                  swd_end_date::date,
                  sum(damage::double precision/LEAST(
                                  swd_end_date::date - swd_begin_date::date + 1,
                                  CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END)) damage
           FROM alldata
           WHERE nri_category in ('coldwave', 'drought', 'heatwave', 'icestorm', 'riverine', 'winterweat')
             AND geoid is not null
           group by 1, 2, 3, 4, 5
           order by 1, 2, 3, 4, 5
       ),
       timeframe_agg_prep as (
           SELECT ctype, geoid, nri_category, swd_begin_date, swd_end_date,
                  CASE
                      WHEN lead(swd_begin_date, 1) OVER(partition by geoid, nri_category, ctype order by swd_begin_date, swd_end_date)
                               BETWEEN swd_begin_date AND swd_end_date AND
                           lead(swd_end_date, 1) OVER(partition by geoid, nri_category, ctype order by swd_begin_date, swd_end_date)
                               BETWEEN swd_begin_date AND swd_end_date
                          then 1
                      WHEN swd_begin_date BETWEEN lag(swd_begin_date, 1) OVER(partition by geoid, nri_category, ctype order by swd_begin_date, swd_end_date) AND
                                       lag(swd_end_date, 1)   OVER(partition by geoid, nri_category, ctype order by swd_begin_date, swd_end_date)
                          AND
                           swd_end_date BETWEEN lag(swd_begin_date, 1) OVER(partition by geoid, nri_category, ctype order by swd_begin_date, swd_end_date) AND
                                       lag(swd_end_date, 1)   OVER(partition by geoid, nri_category, ctype order by swd_begin_date, swd_end_date)
                          then 1
                      else 0
                      END consec_days,
                  damage
           FROM (
                    SELECT ctype, geoid, nri_category, swd_begin_date, swd_end_date, damage FROM alldata where nri_category IN (
                                                                                                                                'avalanche', 'earthquack', 'hail',
                                                                                                                                'lightning', 'wind', 'volcano', 'wildfire')
                    UNION ALL
                    SELECT * FROM day_expansion
                ) a
       ),
       timeframe_agg as (
           SELECT ctype, geoid, nri_category, min(swd_begin_date) event_day_date, sum(damage) damage
           FROM timeframe_agg_prep
           GROUP BY 1, 2, 3, consec_days
       ),
       final as (
           select ctype, nri_category, geoid, event_day_date,
                  event_ids, num_events,
                  damage, null::double precision damage_adjusted
           from consec_aggregation

           UNION ALL

           select ctype, nri_category, geoid, event_day_date,
                  null as event_ids, null as num_events,
                  damage, null::double precision damage_adjusted
           from timeframe_agg

           UNION ALL

           SELECT ctype, nri_category, geoid, swd_begin_date event_day_date,
                  null as event_ids, null as num_events,
                  damage, null::double precision damage_adjusted
           FROM alldata
           WHERE nri_category IN ('tornado', 'landslide')
           order by 1, 2, 3, 4
       )

SELECT row_number() over () id, * INTO tmp_pb_fusion_v3 FROM final




