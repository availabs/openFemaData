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
               -- 				    WHEN nri_category IN ('tornado')
--                    		THEN TRND_AFREQ
                    ELSE null
               END) * 24) - count(1) records_to_insert
    FROM national_risk_index.nri_counties_november_2021 a
             JOIN tmp_pb_normalised b
                  ON a.stcofips = b.geoid
    WHERE nri_category IN
          ('coldwave', 'drought', 'hail', 'heatwave', 'hurricane', 'icestorm', 'lightning', 'riverine', 'wind', 'tsunami', 'winterweat')
    group by 1, 2, 3
),
     records_to_insert as (
         select generate_series(1, records_to_insert::integer),
                ctype, nri_category, geoid,
                null event_day_date, null event_ids, null num_events, 0 damage
         from zero_loss_count
         where records_to_insert >= 0
           and nri_category not in ('drought')
           and ctype = 'buildings'

         union all

         select generate_series(1, records_to_insert::integer),
                ctype, nri_category, geoid,
                null event_day_date, null event_ids, null num_events, 0 damage
         from zero_loss_count
         where records_to_insert >= 0
           and nri_category in ('coldwave', 'drought', 'hail', 'heatwave', 'hurricane', 'riverine', 'wind', 'wildfire', 'winterweat' --,'tornado',
             )
           and ctype = 'crop'

         union all

         select generate_series(1, records_to_insert::integer),
                ctype, nri_category, geoid,
                null event_day_date, null event_ids, null num_events, 0 damage
         from zero_loss_count
         where records_to_insert >= 0
           and nri_category not in ('drought')
           and ctype = 'population'
     )

-- select ctype, count(1) from records_to_insert group by 1

INSERT INTO tmp_pb_normalised
SELECT ctype, nri_category, geoid, event_day_date::timestamp, event_ids::integer[], num_events::bigint, damage
FROM records_to_insert

-- DELETE FROM tmp_pb_normalised
-- WHERE event_day_date is null



