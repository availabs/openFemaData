with zero_loss_count as (
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
             JOIN tmp_pb_normalised_date b
                  ON a.stcofips = b.geoid
             LEFT join (
        select distinct substring(geoid, 1, 5) geoid, begin_date_time::date, (array_agg(tor_f_scale))[1] tor_f_scale
        from severe_weather_new.details
        where nri_category = 'tornado'
        group by 1, 2
    ) c
                       on b.geoid = substring(c.geoid, 1, 5)
                           and begin_date_time = event_day_date
                           and b.nri_category = 'tornado'

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
         select generate_series(1, records_to_insert::integer),
                ctype, nri_category, geoid,
                null event_day_date, null event_ids, null num_events, 0 damage, 0 damage_adjusted
         from zero_loss_count
         where records_to_insert >= 0
           and nri_category not in ('drought')
           and ctype = 'buildings'

         union all

         select generate_series(1, records_to_insert::integer),
                ctype, nri_category, geoid,
                null event_day_date, null event_ids, null num_events, 0 damage, 0 damage_adjusted
         from zero_loss_count
         where records_to_insert >= 0
           and nri_category in (
                                'coldwave', 'drought', 'hail',
                                'heatwave', 'hurricane', 'riverine',
                                'wind', 'tornado', 'winterweat'
             )
           and ctype = 'crop'

         union all

         select generate_series(1, records_to_insert::integer),
                ctype, nri_category, geoid,
                null event_day_date, null event_ids, null num_events, 0 damage, 0 damage_adjusted
         from zero_loss_count
         where records_to_insert >= 0
           and nri_category not in ('drought')
           and ctype = 'population'
     )

INSERT INTO tmp_pb_normalised_date
SELECT ctype, nri_category, geoid, event_day_date::timestamp, event_ids::integer[], num_events::bigint, damage, damage_adjusted
FROM records_to_insert

-- DELETE FROM tmp_pb_normalised_date
-- WHERE event_day_date is null