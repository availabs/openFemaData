with zero_loss_count as (
    SELECT b.geoid, b.nri_category,
           (max(CASE
                    WHEN nri_category IN ('coldwave')
                        THEN CWAV_AFREQ
--                     WHEN nri_category IN ('drought') -- not for buildings
--                         THEN DRGT_AFREQ
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
               --                WHEN nri_category IN ('tornado')
--                    THEN TRND_AFREQ
                    ELSE null
               END) * 24) - count(1) records_to_insert
    FROM national_risk_index.nri_counties_november_2021 a
             JOIN tmp_per_basis_data_swd b
                  ON a.stcofips = b.geoid
    WHERE nri_category IN ('coldwave', 'drought', 'hail', 'heatwave', 'hurricane', 'icestorm', 'lightning', 'riverine', 'wind', 'tsunami', 'winterweat')
    group by 1 , 2
),
     records_to_insert as (
         select generate_series(1, records_to_insert::integer), nri_category, geoid,
                null event_day_date, null event_ids, null num_events, 0 swd_property_damage, 0 swd_crop_damage, 0 fatalities_dollar_value
         from zero_loss_count
         where records_to_insert >= 0
     )

select * from records_to_insert
order by records_to_insert
-- INSERT INTO tmp_per_basis_data_swd
-- SELECT nri_category, geoid, event_day_date::timestamp, event_ids::integer[], num_events::bigint, swd_property_damage, swd_crop_damage, fatalities_dollar_value
-- FROM records_to_insert

-- DELETE FROM public.tmp_per_basis_data_swd
-- WHERE event_day_date is null



