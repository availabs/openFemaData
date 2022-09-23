with pb as (
    select pb.geoid geoid, pb.nri_category, ctype, event_day_date, tor_f_scale
    from tmp_pb_fusion_v4 pb
             LEFT JOIN (
        SELECT DISTINCT substring(geoid, 1, 5) geoid,
                        nri_category cat,
                        begin_date_time::date,
                        (array_agg(tor_f_scale))[1] tor_f_scale
        FROM severe_weather_new.details
        WHERE nri_category = 'tornado'
        GROUP BY 1, 2, 3
    ) details
                       on pb.geoid = details.geoid
                           and event_day_date = begin_date_time
                           and pb.nri_category = details.cat
),
     zero_loss_count as (
         SELECT ctype, b.geoid, b.nri_category,
                (max(CASE
                         WHEN nri_category IN ('coldwave')
                             THEN CWAV_AFREQ
                         WHEN nri_category IN ('drought')
                             THEN DRGT_AFREQ
                         WHEN nri_category IN ('hail')
                             THEN HAIL_AFREQ
                         WHEN nri_category IN ('heatwave')
                             THEN HWAV_AFREQ
                         WHEN nri_category IN ('hurricane')
                             THEN HRCN_AFREQ
                         WHEN nri_category IN ('icestorm')
                             THEN ISTM_AFREQ
                         WHEN nri_category IN ('lightning')
                             THEN LTNG_AFREQ
                         WHEN nri_category IN ('riverine')
                             THEN RFLD_AFREQ
                         WHEN nri_category IN ('wind')
                             THEN SWND_AFREQ
                         WHEN nri_category IN ('tsunami')
                             THEN TSUN_AFREQ
                         WHEN nri_category IN ('winterweat')
                             THEN WNTW_AFREQ
                         WHEN nri_category IN ('tornado')
                             THEN TRND_AFREQ
                         ELSE null
                    END) * 24) - count(1) records_to_insert
         FROM national_risk_index.nri_counties_november_2021 a
                  JOIN pb b
                       ON a.stcofips = b.geoid
         WHERE  nri_category IN
                (
                 'coldwave', 'drought', 'hail', 'heatwave',
                 'hurricane', 'icestorm', 'lightning', 'riverine',
                 'wind', 'tsunami', 'winterweat'
                    )
            OR (nri_category = 'tornado' and tor_f_scale not like '%4' and tor_f_scale not like '%5' )
         group by 1, 2, 3
     ),
     records_to_insert as (
         select generate_series(1, floor(records_to_insert)::integer),
                ctype, nri_category, geoid,
                null event_day_date, null event_ids, null num_events, 0 damage, 0 damage_adjusted
         from zero_loss_count
         where records_to_insert >= 1
           and nri_category not in ('drought')
           and ctype = 'buildings'

         union all

         select generate_series(1, floor(records_to_insert)::integer),
                ctype, nri_category, geoid,
                null event_day_date, null event_ids, null num_events, 0 damage, 0 damage_adjusted
         from zero_loss_count
         where records_to_insert >= 1
           and nri_category in (
                                'coldwave', 'drought', 'hail',
                                'heatwave', 'hurricane', 'riverine',
                                'wind', 'tornado', 'winterweat'
             )
           and ctype = 'crop'

         union all

         select generate_series(1, floor(records_to_insert)::integer),
                ctype, nri_category, geoid,
                null event_day_date, null event_ids, null num_events, 0 damage, 0 damage_adjusted
         from zero_loss_count
         where records_to_insert >= 1
           and nri_category not in ('drought')
           and ctype = 'population'
     )

INSERT INTO tmp_pb_fusion_v4
SELECT null id, ctype, nri_category, geoid, event_day_date::timestamp, event_ids::integer[], num_events::bigint, damage, damage_adjusted
FROM records_to_insert

-- DELETE FROM tmp_pb_fusion_v4
-- WHERE event_day_date is null