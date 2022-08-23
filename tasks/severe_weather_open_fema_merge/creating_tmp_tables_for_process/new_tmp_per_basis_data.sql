with   merged_data_for_per_basis as (
    select
        event_id,
        geoid,
        nri_category,
        array_agg(disaster_number) disaster_number,
        min(swd_begin_date)     swd_begin_date,
        max(swd_end_date)       swd_end_date,
        min(fema_incident_begin_date)   fema_incident_begin_date,
        max(fema_incident_end_date)     fema_incident_end_date,
        sum(swd_property_damage)        swd_property_damage,
        sum(swd_crop_damage)        swd_crop_damage,
        sum(injuries_direct)        injuries_direct,
        sum(injuries_indirect)        injuries_indirect,
        sum(deaths_direct)        deaths_direct,
        sum(deaths_indirect)        deaths_indirect,
        sum(fema_property_damage)        fema_property_damage,
        sum(fema_crop_damage)        fema_crop_damage

    FROM severe_weather_new.tmp_merged_data_updated_fema_data
    GROUP BY 1, 2, 3
),
       details_fema_per_basis as (
           SELECT generate_series(coalesce(swd_begin_date, fema_incident_begin_date)::date,
                                  LEAST(
                                          coalesce(swd_end_date, fema_incident_end_date)::date,
                                          CASE WHEN nri_category = 'drought' THEN coalesce(swd_begin_date, fema_incident_begin_date)::date + INTERVAL '365 days' ELSE coalesce(swd_begin_date, fema_incident_begin_date)::date + INTERVAL '31 days' END
                                      ), '1 day'::interval)::date event_day_date,
                  nri_category,
                  geoid,
                  sum(swd_property_damage::double precision/LEAST(
                                  coalesce(swd_end_date, fema_incident_end_date)::date - coalesce(swd_begin_date, fema_incident_begin_date)::date + 1,
                                  CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END)) swd_property_damage,

                  sum(swd_crop_damage::double precision/LEAST(
                                  coalesce(swd_end_date, fema_incident_end_date)::date - coalesce(swd_begin_date, fema_incident_begin_date)::date + 1,
                                  CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END)) swd_crop_damage,

                  sum(injuries_direct::double precision/LEAST(
                                  coalesce(swd_end_date, fema_incident_end_date)::date - coalesce(swd_begin_date, fema_incident_begin_date)::date + 1,
                                  CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END)) injuries_direct,
                  sum(injuries_indirect::double precision/LEAST(
                                  coalesce(swd_end_date, fema_incident_end_date)::date - coalesce(swd_begin_date, fema_incident_begin_date)::date + 1,
                                  CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END)) injuries_indirect,
                  sum(deaths_direct::double precision/LEAST(
                                  coalesce(swd_end_date, fema_incident_end_date)::date - coalesce(swd_begin_date, fema_incident_begin_date)::date + 1,
                                  CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END)) deaths_direct,
                  sum(deaths_indirect::double precision /LEAST(
                                  coalesce(swd_end_date, fema_incident_end_date)::date - coalesce(swd_begin_date, fema_incident_begin_date)::date + 1,
                                  CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END)) deaths_inderect,
                  sum(fema_property_damage/LEAST(
                                  coalesce(swd_end_date, fema_incident_end_date)::date - coalesce(swd_begin_date, fema_incident_begin_date)::date + 1,
                                  CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END)) fema_property_damage,
                  sum(fema_crop_damage/LEAST(
                                  coalesce(swd_end_date, fema_incident_end_date)::date - coalesce(swd_begin_date, fema_incident_begin_date)::date + 1,
                                  CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END)) fema_crop_damage,
                  sum(((
                                   injuries_direct / LEAST(
                                               coalesce(swd_end_date, fema_incident_end_date)::date - coalesce(swd_begin_date, fema_incident_begin_date)::date + 1,
                                               CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END) +
                                   injuries_indirect / LEAST(
                                                   coalesce(swd_end_date, fema_incident_end_date)::date - coalesce(swd_begin_date, fema_incident_begin_date)::date + 1,
                                                   CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END) +
                                   deaths_direct / LEAST(
                                                   coalesce(swd_end_date, fema_incident_end_date)::date - coalesce(swd_begin_date, fema_incident_begin_date)::date + 1,
                                                   CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END) +
                                   deaths_indirect / LEAST(
                                                   coalesce(swd_end_date, fema_incident_end_date)::date - coalesce(swd_begin_date, fema_incident_begin_date)::date + 1,
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
               coalesce(swd_begin_date, fema_incident_begin_date) event_day_date,
               ARRAY_AGG(event_id)	  event_ids,
               ARRAY_AGG(distinct disaster_number) disaster_number,
               count(1) 					num_events,
               sum (swd_property_damage) swd_property_damage,
               sum (swd_crop_damage) swd_crop_damage,
               sum(injuries_direct) injuries_direct,
               sum(injuries_indirect) injuries_indirect,
               sum(deaths_direct) deaths_direct,
               sum(deaths_indirect) deaths_indirect,
               sum (fema_property_damage) fema_property_damage,
               sum (fema_crop_damage) fema_crop_damage,
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
                  event_ids, disaster_number, num_events,
                  swd_property_damage, swd_crop_damage, fema_property_damage, fema_crop_damage, fatalities_dollar_value
           from aggregation

           UNION ALL

           select nri_category, geoid, event_day_date,
                  null as event_ids, null as disaster_number, null as num_events,
                  swd_property_damage, swd_crop_damage, fema_property_damage, fema_crop_damage, fatalities_dollar_value
           from details_fema_per_basis

           order by 1, 2, 3
       )

SELECT * INTO tmp_per_basis_data_zero_loss_detailed_new_data_v2 FROM final;
