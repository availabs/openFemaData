with raw_swd as (
    select event_type_formatted raw_swd_nri_category,
           sum(CASE
                   WHEN coalesce(property_damage, 0) + coalesce(crop_damage, 0) +
                        coalesce(injuries_direct, 0) + coalesce(injuries_indirect, 0) +
                        coalesce(deaths_direct, 0) + coalesce(deaths_indirect, 0) > 0
                       THEN 1
                   ELSE 0
               END) avail_num_non_zero,
           sum(CASE
                   WHEN not coalesce(property_damage, 0) + coalesce(crop_damage, 0) +
                            coalesce(injuries_direct, 0) + coalesce(injuries_indirect, 0) +
                            coalesce(deaths_direct, 0) + coalesce(deaths_indirect, 0) > 0
                       THEN 1
                   ELSE 0
               END) avail_num_zero,
           extract (YEAR from max(end_date_time)) - extract ( YEAR from min(begin_date_time)) avail_num_years,
           sum(property_damage) avail_property_damage,
           sum(crop_damage) avail_crop_damage,
           sum(coalesce(injuries_direct, 0) + coalesce(injuries_indirect, 0) +
               coalesce(deaths_direct, 0) + coalesce(deaths_indirect, 0)) avail_population_raw
    from severe_weather_new.details
    WHERE year >= 1996 and year <= 2019
      AND geoid is not null
    group by 1
),
     per_basis as (
         select nri_category per_basis_nri_category,
                sum(CASE
                        WHEN coalesce(swd_property_damage, 0) + coalesce(swd_crop_damage, 0) + coalesce(fatalities_dollar_value, 0) > 0
                            THEN 1
                        ELSE 0
                    END) avail_pb_num_non_zero,
                sum(CASE
                        WHEN not coalesce(swd_property_damage, 0) + coalesce(swd_crop_damage, 0) + coalesce(fatalities_dollar_value, 0) > 0
                            THEN 1
                        ELSE 0
                    END) avail_pb_num_zero,
                extract (YEAR from max(event_day_date)) - extract ( YEAR from min(event_day_date)) avail_pb_num_years,
                sum(swd_property_damage) avail_pb_property_damage,
                sum(swd_crop_damage) avail_pb_crop_damage,
                sum(fatalities_dollar_value) avail_pb_fatalities_dollar_value
         from tmp_per_basis_data_swd
         group by 1
     ),
     avail_eals as (
         SELECT nri_category avail_eals_nri_category,
                sum(CASE
                        WHEN nri_category IN ('coastal')
                            THEN hlr_b * CFLD_EXPB  * CFLD_AFREQ
                        WHEN nri_category IN ('coldwave')
                            THEN hlr_b * CWAV_EXPB  * CWAV_AFREQ
                        WHEN nri_category IN ('hurricane')
                            THEN hlr_b * HRCN_EXPB  * HRCN_AFREQ
                        WHEN nri_category IN ('heatwave')
                            THEN hlr_b * HWAV_EXPB  * HWAV_AFREQ
                        WHEN nri_category IN ('hail')
                            THEN hlr_b * HAIL_EXPB  * HAIL_AFREQ
                        WHEN nri_category IN ('tornado')
                            THEN hlr_b * TRND_EXPB  * TRND_AFREQ
                        WHEN nri_category IN ('riverine')
                            THEN hlr_b * RFLD_EXPB  * RFLD_AFREQ
                        WHEN nri_category IN ('lightning')
                            THEN hlr_b * LTNG_EXPB  * LTNG_AFREQ
                        WHEN nri_category IN ('landslide')
                            THEN hlr_b * LNDS_EXPB  * LNDS_AFREQ
                        WHEN nri_category IN ('icestorm')
                            THEN hlr_b * ISTM_EXPB  * ISTM_AFREQ
                        WHEN nri_category IN ('wind')
                            THEN hlr_b * SWND_EXPB  * SWND_AFREQ
                        WHEN nri_category IN ('wildfire')
                            THEN hlr_b * WFIR_EXPB  * WFIR_AFREQ
                        WHEN nri_category IN ('winterweat')
                            THEN hlr_b * WNTW_EXPB  * WNTW_AFREQ
                        WHEN nri_category IN ('tsunami')
                            THEN hlr_b * TSUN_EXPB  * TSUN_AFREQ
                        WHEN nri_category IN ('avalanche')
                            THEN hlr_b * AVLN_EXPB  * AVLN_AFREQ
                        WHEN nri_category IN ('volcano')
                            THEN hlr_b * VLCN_EXPB  * VLCN_AFREQ
                    END) avail_eal_buildings,
                sum(CASE
                        WHEN nri_category IN ('coldwave')
                            THEN hlr_c * CWAV_EXPA  * CWAV_AFREQ
                        WHEN nri_category IN ('drought')
                            THEN hlr_c * DRGT_EXPA  * DRGT_AFREQ
                        WHEN nri_category IN ('hurricane')
                            THEN hlr_c * HRCN_EXPA  * HRCN_AFREQ
                        WHEN nri_category IN ('heatwave')
                            THEN hlr_c * HWAV_EXPA  * HWAV_AFREQ
                        WHEN nri_category IN ('hail')
                            THEN hlr_c * HAIL_EXPA  * HAIL_AFREQ
                        WHEN nri_category IN ('tornado')
                            THEN hlr_c * TRND_EXPA  * TRND_AFREQ
                        WHEN nri_category IN ('riverine')
                            THEN hlr_c * RFLD_EXPA  * RFLD_AFREQ
                        WHEN nri_category IN ('wind')
                            THEN hlr_c * SWND_EXPA  * SWND_AFREQ
                        WHEN nri_category IN ('wildfire')
                            THEN hlr_c * WFIR_EXPA  * WFIR_AFREQ
                        WHEN nri_category IN ('winterweat')
                            THEN hlr_c * WNTW_EXPA  * WNTW_AFREQ
                    END) avail_eal_crop

-- 	sum(CASE
--                WHEN nri_category IN ('coastal')
--                    THEN CFLD_HLRB * CFLD_EXPB  * CFLD_AFREQ
--                WHEN nri_category IN ('coldwave')
--                    THEN CWAV_HLRB * CWAV_EXPB  * CWAV_AFREQ
--                WHEN nri_category IN ('hurricane')
--                    THEN HRCN_HLRB * HRCN_EXPB  * HRCN_AFREQ
--                WHEN nri_category IN ('heatwave')
--                    THEN HWAV_HLRB * HWAV_EXPB  * HWAV_AFREQ
--                WHEN nri_category IN ('hail')
--                    THEN HAIL_HLRB * HAIL_EXPB  * HAIL_AFREQ
--                WHEN nri_category IN ('tornado')
--                    THEN TRND_HLRB * TRND_EXPB  * TRND_AFREQ
--                WHEN nri_category IN ('riverine')
--                    THEN RFLD_HLRB * RFLD_EXPB  * RFLD_AFREQ
--                WHEN nri_category IN ('lightning')
--                    THEN LTNG_HLRB * LTNG_EXPB  * LTNG_AFREQ
--                WHEN nri_category IN ('landslide')
--                    THEN LNDS_HLRB * LNDS_EXPB  * LNDS_AFREQ
--                WHEN nri_category IN ('icestorm')
--                    THEN ISTM_HLRB * ISTM_EXPB  * ISTM_AFREQ
--                WHEN nri_category IN ('wind')
--                    THEN SWND_HLRB * SWND_EXPB  * SWND_AFREQ
--                WHEN nri_category IN ('wildfire')
--                    THEN WFIR_HLRB * WFIR_EXPB  * WFIR_AFREQ
--                WHEN nri_category IN ('winterweat')
--                    THEN WNTW_HLRB * WNTW_EXPB  * WNTW_AFREQ
--                WHEN nri_category IN ('tsunami')
--                    THEN TSUN_HLRB * TSUN_EXPB  * TSUN_AFREQ
--                WHEN nri_category IN ('avalanche')
--                    THEN AVLN_HLRB * AVLN_EXPB  * AVLN_AFREQ
--                WHEN nri_category IN ('volcano')
--                    THEN VLCN_HLRB * VLCN_EXPB  * VLCN_AFREQ
--            END) nri_eal_buildings,
-- 	 sum(CASE
--                WHEN nri_category IN ('coldwave')
--                    THEN CWAV_HLRA * CWAV_EXPA  * CWAV_AFREQ
--                WHEN nri_category IN ('drought')
--                    THEN DRGT_HLRA * DRGT_EXPA  * DRGT_AFREQ
--                WHEN nri_category IN ('hurricane')
--                    THEN HRCN_HLRA * HRCN_EXPA  * HRCN_AFREQ
--                WHEN nri_category IN ('heatwave')
--                    THEN HWAV_HLRA * HWAV_EXPA  * HWAV_AFREQ
--                WHEN nri_category IN ('hail')
--                    THEN HAIL_HLRA * HAIL_EXPA  * HAIL_AFREQ
--                WHEN nri_category IN ('tornado')
--                    THEN TRND_HLRA * TRND_EXPA  * TRND_AFREQ
--                WHEN nri_category IN ('riverine')
--                    THEN RFLD_HLRA * RFLD_EXPA  * RFLD_AFREQ
--                WHEN nri_category IN ('wind')
--                    THEN SWND_HLRA * SWND_EXPA  * SWND_AFREQ
--                WHEN nri_category IN ('wildfire')
--                    THEN WFIR_HLRA * WFIR_EXPA  * WFIR_AFREQ
--                WHEN nri_category IN ('winterweat')
--                    THEN WNTW_HLRA * WNTW_EXPA  * WNTW_AFREQ
--            END) nri_eal_crop
         FROM tmp_hlr_swd_wt hlr
                  JOIN national_risk_index.nri_counties_november_2021 nri
                       ON hlr.geoid = nri.stcofips
         GROUP BY 1
     ),
     nri_eals as (
         select
             unnest(array['coastal', 'coldwave', 'hurricane',  'heatwave', 'hail','tornado', 'riverine', 'lightning','landslide',  'icestorm',
                 'wind', 'wildfire',  'winterweat', 'tsunami','avalanche',  'volcano'
                 ]) as nri_eals_nri_category,
             unnest(array[
                 sum(CFLD_hlrb * CFLD_EXPB  * CFLD_AFREQ),
                 sum(CWAV_hlrb * CWAV_EXPB  * CWAV_AFREQ),
                 sum(HRCN_hlrb * HRCN_EXPB  * HRCN_AFREQ),
                 sum(HWAV_hlrb * HWAV_EXPB  * HWAV_AFREQ),
                 sum(HAIL_hlrb * HAIL_EXPB  * HAIL_AFREQ),
                 sum(TRND_hlrb * TRND_EXPB  * TRND_AFREQ),
                 sum(RFLD_hlrb * RFLD_EXPB  * RFLD_AFREQ),
                 sum(LTNG_hlrb * LTNG_EXPB  * LTNG_AFREQ),
                 sum(LNDS_hlrb * LNDS_EXPB  * LNDS_AFREQ),
                 sum(ISTM_hlrb * ISTM_EXPB  * ISTM_AFREQ),
                 sum(SWND_hlrb * SWND_EXPB  * SWND_AFREQ),
                 sum(WFIR_hlrb * WFIR_EXPB  * WFIR_AFREQ),
                 sum(WNTW_hlrb * WNTW_EXPB  * WNTW_AFREQ),
                 sum(TSUN_hlrb * TSUN_EXPB  * TSUN_AFREQ),
                 sum(AVLN_hlrb * AVLN_EXPB  * AVLN_AFREQ),
                 sum(VLCN_hlrb * VLCN_EXPB  * VLCN_AFREQ)
                 ]) as nri_eal_buildings,
             unnest(array[
                 sum(CWAV_hlra * CWAV_EXPB  * CWAV_AFREQ),
                 sum(HRCN_hlra * HRCN_EXPB  * HRCN_AFREQ),
                 sum(HWAV_hlra * HWAV_EXPB  * HWAV_AFREQ),
                 sum(HAIL_hlra * HAIL_EXPB  * HAIL_AFREQ),
                 sum(TRND_hlra * TRND_EXPB  * TRND_AFREQ),
                 sum(RFLD_hlra * RFLD_EXPB  * RFLD_AFREQ),
                 sum(SWND_hlra * SWND_EXPB  * SWND_AFREQ),
                 sum(WFIR_hlra * WFIR_EXPB  * WFIR_AFREQ),
                 sum(WNTW_hlra * WNTW_EXPB  * WNTW_AFREQ)
                 ]) as nri_eal_crop

         FROM national_risk_index.nri_counties_november_2021 nri
     )


select raw_swd.*,
       avail_property_damage / avail_num_years avail_property_damage_annualized,
       avail_crop_damage / avail_num_years avail_property_crop_annualized,
       per_basis.*,
       avail_eals.*, nri_eals.*
from raw_swd
         left join per_basis
                   on raw_swd_nri_category = per_basis_nri_category

         left join nri_eals
                   on raw_swd_nri_category = nri_eals_nri_category

         left join avail_eals
                   on raw_swd_nri_category = avail_eals_nri_category

order by avail_eals_nri_category





