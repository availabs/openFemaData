with   lrpbs as (
    SELECT tmp_per_basis_data_zero_loss.*,
           CASE
               WHEN nri_category IN ('wind')
                   THEN swd_property_damage/ NULLIF (SWND_EXPB, 0)
               WHEN nri_category IN ('wildfire')
                   THEN swd_property_damage/ NULLIF (WFIR_EXPB, 0)
               WHEN nri_category IN ('tsunami')
                   THEN swd_property_damage/ NULLIF (TSUN_EXPB, 0)
               WHEN nri_category IN ('tornado')
                   THEN swd_property_damage/ NULLIF (TRND_EXPB, 0)
               WHEN nri_category IN ('riverine')
                   THEN swd_property_damage/ NULLIF (RFLD_EXPB, 0)
               WHEN nri_category IN ('lightning')
                   THEN swd_property_damage/ NULLIF (LTNG_EXPB, 0)
               WHEN nri_category IN ('landslide')
                   THEN swd_property_damage/ NULLIF (LNDS_EXPB, 0)
               WHEN nri_category IN ('icestorm')
                   THEN swd_property_damage/ NULLIF (ISTM_EXPB, 0)
               WHEN nri_category IN ('hurricane')
                   THEN swd_property_damage/ NULLIF (HRCN_EXPB, 0)
               WHEN nri_category IN ('heatwave')
                   THEN swd_property_damage/ NULLIF (HWAV_EXPB, 0)
               WHEN nri_category IN ('hail')
                   THEN swd_property_damage/ NULLIF (HAIL_EXPB, 0)
               WHEN nri_category IN ('avalanche')
                   THEN swd_property_damage/ NULLIF (AVLN_EXPB, 0)
               WHEN nri_category IN ('coldwave')
                   THEN swd_property_damage/ NULLIF (CWAV_EXPB, 0)
               WHEN nri_category IN ('winterweat')
                   THEN swd_property_damage/ NULLIF (WNTW_EXPB, 0)
               WHEN nri_category IN ('volcano')
                   THEN swd_property_damage/ NULLIF (VLCN_EXPB, 0)
               WHEN nri_category IN ('coastal')
                   THEN swd_property_damage/ NULLIF (CFLD_EXPB, 0)
               END building_loss_ratio_per_basis,
           CASE
               WHEN nri_category IN ('wind')
                   THEN fema_property_damage/ NULLIF (SWND_EXPB, 0)
               WHEN nri_category IN ('wildfire')
                   THEN fema_property_damage/ NULLIF (WFIR_EXPB, 0)
               WHEN nri_category IN ('tsunami')
                   THEN fema_property_damage/ NULLIF (TSUN_EXPB, 0)
               WHEN nri_category IN ('tornado')
                   THEN fema_property_damage/ NULLIF (TRND_EXPB, 0)
               WHEN nri_category IN ('riverine')
                   THEN fema_property_damage/ NULLIF (RFLD_EXPB, 0)
               WHEN nri_category IN ('lightning')
                   THEN fema_property_damage/ NULLIF (LTNG_EXPB, 0)
               WHEN nri_category IN ('landslide')
                   THEN fema_property_damage/ NULLIF (LNDS_EXPB, 0)
               WHEN nri_category IN ('icestorm')
                   THEN fema_property_damage/ NULLIF (ISTM_EXPB, 0)
               WHEN nri_category IN ('hurricane')
                   THEN fema_property_damage/ NULLIF (HRCN_EXPB, 0)
               WHEN nri_category IN ('heatwave')
                   THEN fema_property_damage/ NULLIF (HWAV_EXPB, 0)
               WHEN nri_category IN ('hail')
                   THEN fema_property_damage/ NULLIF (HAIL_EXPB, 0)
               WHEN nri_category IN ('avalanche')
                   THEN fema_property_damage/ NULLIF (AVLN_EXPB, 0)
               WHEN nri_category IN ('coldwave')
                   THEN fema_property_damage/ NULLIF (CWAV_EXPB, 0)
               WHEN nri_category IN ('winterweat')
                   THEN fema_property_damage/ NULLIF (WNTW_EXPB, 0)
               WHEN nri_category IN ('volcano')
                   THEN fema_property_damage/ NULLIF (VLCN_EXPB, 0)
               WHEN nri_category IN ('coastal')
                   THEN fema_property_damage/ NULLIF (CFLD_EXPB, 0)
               END fema_building_loss_ratio_per_basis,


--                CASE
--                    WHEN nri_category IN ('wind')
--                        THEN merged_property_damage/ NULLIF (SWND_EXPB, 0)
--                    WHEN nri_category IN ('wildfire')
--                        THEN merged_property_damage/ NULLIF (WFIR_EXPB, 0)
--                    WHEN nri_category IN ('tsunami')
--                        THEN merged_property_damage/ NULLIF (TSUN_EXPB, 0)
--                    WHEN nri_category IN ('tornado')
--                        THEN merged_property_damage/ NULLIF (TRND_EXPB, 0)
--                    WHEN nri_category IN ('riverine')
--                        THEN merged_property_damage/ NULLIF (RFLD_EXPB, 0)
--                    WHEN nri_category IN ('lightning')
--                        THEN merged_property_damage/ NULLIF (LTNG_EXPB, 0)
--                    WHEN nri_category IN ('landslide')
--                        THEN merged_property_damage/ NULLIF (LNDS_EXPB, 0)
--                    WHEN nri_category IN ('icestorm')
--                        THEN merged_property_damage/ NULLIF (ISTM_EXPB, 0)
--                    WHEN nri_category IN ('hurricane')
--                        THEN merged_property_damage/ NULLIF (HRCN_EXPB, 0)
--                    WHEN nri_category IN ('heatwave')
--                        THEN merged_property_damage/ NULLIF (HWAV_EXPB, 0)
--                    WHEN nri_category IN ('hail')
--                        THEN merged_property_damage/ NULLIF (HAIL_EXPB, 0)
--                    WHEN nri_category IN ('avalanche')
--                        THEN merged_property_damage/ NULLIF (AVLN_EXPB, 0)
--                    WHEN nri_category IN ('coldwave')
--                        THEN merged_property_damage/ NULLIF (CWAV_EXPB, 0)
--                    WHEN nri_category IN ('winterweat')
--                        THEN merged_property_damage/ NULLIF (WNTW_EXPB, 0)
--                    WHEN nri_category IN ('volcano')
--                        THEN merged_property_damage/ NULLIF (VLCN_EXPB, 0)
--                    WHEN nri_category IN ('coastal')
--                        THEN merged_property_damage/ NULLIF (CFLD_EXPB, 0)
--                    END merged_building_loss_ratio_per_basis,

           CASE
               WHEN nri_category IN ('wind')
                   THEN fema_crop_damage/ NULLIF (SWND_expa, 0)
               WHEN nri_category IN ('wildfire')
                   THEN fema_crop_damage/ NULLIF (WFIR_expa, 0)
               WHEN nri_category IN ('tornado')
                   THEN fema_crop_damage/ NULLIF (TRND_expa, 0)
               WHEN nri_category IN ('riverine')
                   THEN fema_crop_damage/ NULLIF (RFLD_expa, 0)
               WHEN nri_category IN ('hurricane')
                   THEN fema_crop_damage/ NULLIF (HRCN_expa, 0)
               WHEN nri_category IN ('heatwave')
                   THEN fema_crop_damage/ NULLIF (HWAV_expa, 0)
               WHEN nri_category IN ('hail')
                   THEN fema_crop_damage/ NULLIF (HAIL_expa, 0)
               WHEN nri_category IN ('drought')
                   THEN fema_crop_damage/NULLIF(DRGT_expa, 0)
               WHEN nri_category IN ('coldwave')
                   THEN fema_crop_damage/ NULLIF (CWAV_expa, 0)
               WHEN nri_category IN ('winterweat')
                   THEN fema_crop_damage/ NULLIF (WNTW_expa, 0)
               END fema_crop_loss_ratio_per_basis,

           CASE
               WHEN nri_category IN ('wind')
                   THEN swd_crop_damage/ NULLIF (SWND_EXPA, 0)
               WHEN nri_category IN ('wildfire')
                   THEN swd_crop_damage/ NULLIF (WFIR_EXPA, 0)
               WHEN nri_category IN ('tornado')
                   THEN swd_crop_damage/ NULLIF (TRND_EXPA, 0)
               WHEN nri_category IN ('riverine')
                   THEN swd_crop_damage/ NULLIF (RFLD_EXPA, 0)
               WHEN nri_category IN ('hurricane')
                   THEN swd_crop_damage/ NULLIF (HRCN_EXPA, 0)
               WHEN nri_category IN ('heatwave')
                   THEN swd_crop_damage/ NULLIF (HWAV_EXPA, 0)
               WHEN nri_category IN ('hail')
                   THEN swd_crop_damage/ NULLIF (HAIL_EXPA, 0)
               WHEN nri_category IN ('drought')
                   THEN swd_crop_damage/ NULLIF (DRGT_EXPA, 0)
               WHEN nri_category IN ('coldwave')
                   THEN swd_crop_damage/ NULLIF (CWAV_EXPA, 0)
               WHEN nri_category IN ('winterweat')
                   THEN swd_crop_damage/ NULLIF (WNTW_EXPA, 0)
               END crop_loss_ratio_per_basis,


--                CASE
--                    WHEN nri_category IN ('wind')
--                        THEN merged_crop_damage/ NULLIF (SWND_EXPA, 0)
--                    WHEN nri_category IN ('wildfire')
--                        THEN merged_crop_damage/ NULLIF (WFIR_EXPA, 0)
--                    WHEN nri_category IN ('tornado')
--                        THEN merged_crop_damage/ NULLIF (TRND_EXPA, 0)
--                    WHEN nri_category IN ('riverine')
--                        THEN merged_crop_damage/ NULLIF (RFLD_EXPA, 0)
--                    WHEN nri_category IN ('hurricane')
--                        THEN merged_crop_damage/ NULLIF (HRCN_EXPA, 0)
--                    WHEN nri_category IN ('heatwave')
--                        THEN merged_crop_damage/ NULLIF (HWAV_EXPA, 0)
--                    WHEN nri_category IN ('hail')
--                        THEN merged_crop_damage/ NULLIF (HAIL_EXPA, 0)
--                    WHEN nri_category IN ('drought')
--                        THEN merged_crop_damage/ NULLIF (DRGT_EXPA, 0)
--                    WHEN nri_category IN ('coldwave')
--                        THEN merged_crop_damage/ NULLIF (CWAV_EXPA, 0)
--                    WHEN nri_category IN ('winterweat')
--                        THEN merged_crop_damage/ NULLIF (WNTW_EXPA, 0)
--                    END merged_crop_loss_ratio_per_basis,

           CASE
               WHEN nri_category IN ('wind')
                   THEN fatalities_dollar_value/ NULLIF (SWND_EXPPE, 0)
               WHEN nri_category IN ('wildfire')
                   THEN fatalities_dollar_value/ NULLIF (WFIR_EXPPE, 0)
               WHEN nri_category IN ('tsunami')
                   THEN fatalities_dollar_value/ NULLIF (TSUN_EXPPE, 0)
               WHEN nri_category IN ('tornado')
                   THEN fatalities_dollar_value/ NULLIF (TRND_EXPPE, 0)
               WHEN nri_category IN ('riverine')
                   THEN fatalities_dollar_value/ NULLIF (RFLD_EXPPE, 0)
               WHEN nri_category IN ('lightning')
                   THEN fatalities_dollar_value/ NULLIF (LTNG_EXPPE, 0)
               WHEN nri_category IN ('landslide')
                   THEN fatalities_dollar_value/ NULLIF (LNDS_EXPPE, 0)
               WHEN nri_category IN ('icestorm')
                   THEN fatalities_dollar_value/ NULLIF (ISTM_EXPPE, 0)
               WHEN nri_category IN ('hurricane')
                   THEN fatalities_dollar_value/ NULLIF (HRCN_EXPPE, 0)
               WHEN nri_category IN ('heatwave')
                   THEN fatalities_dollar_value/ NULLIF (HWAV_EXPPE, 0)
               WHEN nri_category IN ('hail')
                   THEN fatalities_dollar_value/ NULLIF (HAIL_EXPPE, 0)
               WHEN nri_category IN ('avalanche')
                   THEN fatalities_dollar_value/ NULLIF (AVLN_EXPPE, 0)
               WHEN nri_category IN ('coldwave')
                   THEN fatalities_dollar_value/ NULLIF (CWAV_EXPPE, 0)
               WHEN nri_category IN ('winterweat')
                   THEN fatalities_dollar_value/ NULLIF (WNTW_EXPPE, 0)
               WHEN nri_category IN ('volcano')
                   THEN fatalities_dollar_value/ NULLIF (VLCN_EXPPE, 0)
               WHEN nri_category IN ('coastal')
                   THEN fatalities_dollar_value/ NULLIF (CFLD_EXPPE, 0)
               END population_loss_ratio_per_basis
    FROM tmp_per_basis_data_zero_loss
             JOIN national_risk_index.nri_counties_november_2021 nri
                  ON tmp_per_basis_data_zero_loss.geoid = nri.stcofips),
       national as (
           select nri_category,
                  count (1),
                  avg (Least(COALESCE (building_loss_ratio_per_basis, 0), 1)) b_av_n,
                  avg (Least(COALESCE (crop_loss_ratio_per_basis, 0), 1)) c_av_n,
--                avg (Least(COALESCE (merged_building_loss_ratio_per_basis, 0), 1)) mb_av_n,
--                avg (Least(COALESCE (merged_crop_loss_ratio_per_basis, 0), 1)) mc_av_n,
                  avg (Least(COALESCE (population_loss_ratio_per_basis, 0), 1)) p_av_n,
                  avg (Least(COALESCE (fema_building_loss_ratio_per_basis, 0), 1)) f_av_n,
                  avg (Least(COALESCE (fema_crop_loss_ratio_per_basis, 0), 1)) fc_av_n,
                  variance(Least(COALESCE (building_loss_ratio_per_basis, 0), 1)) b_va_n,
                  variance(Least(COALESCE (crop_loss_ratio_per_basis, 0), 1)) c_va_n,
--                variance(Least(COALESCE (merged_building_loss_ratio_per_basis, 0), 1)) mb_va_n,
--                variance(Least(COALESCE (merged_crop_loss_ratio_per_basis, 0), 1)) mc_va_n,
                  variance(Least(COALESCE (population_loss_ratio_per_basis, 0), 1)) p_va_n,
                  variance(Least(COALESCE (fema_building_loss_ratio_per_basis, 0), 1)) f_va_n,
                  variance(Least(COALESCE (fema_crop_loss_ratio_per_basis, 0), 1)) fc_va_n

           from lrpbs as a
           WHERE nri_category is not null
           group by 1
           order by 1),
       regional as (
           select a.geoid, region,
                  nri_category,
                  count (1),
                  avg (Least(COALESCE (building_loss_ratio_per_basis, 0), 1)) b_av_r,
                  avg (Least(COALESCE (crop_loss_ratio_per_basis, 0), 1)) c_av_r,
                  avg (Least(COALESCE (population_loss_ratio_per_basis, 0), 1)) p_av_r,
                  avg (Least(COALESCE (fema_building_loss_ratio_per_basis, 0), 1)) f_av_r,
                  avg (Least(COALESCE (fema_crop_loss_ratio_per_basis, 0), 1)) fc_av_r,
--                avg (Least(COALESCE (merged_building_loss_ratio_per_basis, 0), 1)) mb_av_r,
--                avg (Least(COALESCE (merged_crop_loss_ratio_per_basis, 0), 1)) mc_av_r,
                  variance(Least(COALESCE (building_loss_ratio_per_basis, 0), 1)) b_va_r,
                  variance(Least(COALESCE (crop_loss_ratio_per_basis, 0), 1)) c_va_r,
                  variance(Least(COALESCE (population_loss_ratio_per_basis, 0), 1)) p_va_r,
                  variance(Least(COALESCE (fema_building_loss_ratio_per_basis, 0), 1)) f_va_r,
                  variance(Least(COALESCE (fema_crop_loss_ratio_per_basis, 0), 1)) fc_va_r
--                variance(Least(COALESCE (merged_building_loss_ratio_per_basis, 0), 1)) mb_va_r,
--                variance(Least(COALESCE (merged_crop_loss_ratio_per_basis, 0), 1)) mc_va_r

           from lrpbs as a
                    join severe_weather_new.fips_to_regions_and_surrounding_counties as b
                         on b.fips = a.geoid
                             and nri_category != 'hurricane'
           WHERE nri_category is not null
           group by 1, 2, 3

           UNION

           select a.geoid, region,
                  nri_category,
                  count (1),
                  avg (Least(COALESCE (building_loss_ratio_per_basis, 0), 1)) b_av_r,
                  avg (Least(COALESCE (crop_loss_ratio_per_basis, 0), 1)) c_av_r,
                  avg (Least(COALESCE (population_loss_ratio_per_basis, 0), 1)) p_av_r,
                  avg (Least(COALESCE (fema_building_loss_ratio_per_basis, 0), 1)) f_av_r,
                  avg (Least(COALESCE (fema_crop_loss_ratio_per_basis, 0), 1)) fc_av_r,
--                avg (Least(COALESCE (merged_building_loss_ratio_per_basis, 0), 1)) mb_av_r,
--                avg (Least(COALESCE (merged_crop_loss_ratio_per_basis, 0), 1)) mc_av_r,
                  variance(Least(COALESCE (building_loss_ratio_per_basis, 0), 1)) b_va_r,
                  variance(Least(COALESCE (crop_loss_ratio_per_basis, 0), 1)) c_va_r,
                  variance(Least(COALESCE (population_loss_ratio_per_basis, 0), 1)) p_va_r,
                  variance(Least(COALESCE (fema_building_loss_ratio_per_basis, 0), 1)) f_va_r,
                  variance(Least(COALESCE (fema_crop_loss_ratio_per_basis, 0), 1)) fc_va_r
--                variance(Least(COALESCE (merged_building_loss_ratio_per_basis, 0), 1)) mb_va_r,
--                variance(Least(COALESCE (merged_crop_loss_ratio_per_basis, 0), 1)) mc_va_r

           from lrpbs as a
                    join severe_weather_new.fips_to_regions_and_surrounding_counties_hurricane as b
                         on b.fips = a.geoid
                             and nri_category = 'hurricane'
           WHERE nri_category is not null
           group by 1, 2, 3
           order by 1, 2, 3

       ),
       county as (
           select LEFT (b.fips, 5) fips,
                  nri_category,
                  count (1),
                  avg (Least(COALESCE (building_loss_ratio_per_basis, 0), 1)) b_av_c,
                  avg (Least(COALESCE (crop_loss_ratio_per_basis, 0), 1)) c_av_c,
                  avg (Least(COALESCE (population_loss_ratio_per_basis, 0), 1)) p_av_c,
                  avg (Least(COALESCE (fema_building_loss_ratio_per_basis, 0), 1)) f_av_c,
                  avg (Least(COALESCE (fema_crop_loss_ratio_per_basis, 0), 1)) fc_av_c,
--                avg (Least(COALESCE (merged_building_loss_ratio_per_basis, 0), 1)) mb_av_c,
--                avg (Least(COALESCE (merged_crop_loss_ratio_per_basis, 0), 1)) mc_av_c,
                  variance(Least(COALESCE (building_loss_ratio_per_basis, 0), 1)) b_va_c,
                  variance(Least(COALESCE (crop_loss_ratio_per_basis, 0), 1)) c_va_c,
                  variance(Least(COALESCE (population_loss_ratio_per_basis, 0), 1)) p_va_c,
                  variance(Least(COALESCE (fema_building_loss_ratio_per_basis, 0), 1)) f_va_c,
                  variance(Least(COALESCE (fema_crop_loss_ratio_per_basis, 0), 1)) fc_va_c
--                variance(Least(COALESCE (merged_building_loss_ratio_per_basis, 0), 1)) mb_va_c,
--                variance(Least(COALESCE (merged_crop_loss_ratio_per_basis, 0), 1)) mc_va_c

           from lrpbs as a
                    join severe_weather_new.fips_to_regions_and_surrounding_counties as b
                         on b.fips = a.geoid
                             and nri_category != 'hurricane'
           WHERE nri_category is not null
           group by 1, 2

           UNION

           select LEFT (b.fips, 5) fips,
                  nri_category,
                  count (1),
                  avg (Least(COALESCE (building_loss_ratio_per_basis, 0), 1)) b_av_c,
                  avg (Least(COALESCE (crop_loss_ratio_per_basis, 0), 1)) c_av_c,
                  avg (Least(COALESCE (population_loss_ratio_per_basis, 0), 1)) p_av_c,
                  avg (Least(COALESCE (fema_building_loss_ratio_per_basis, 0), 1)) f_av_c,
                  avg (Least(COALESCE (fema_crop_loss_ratio_per_basis, 0), 1)) fc_av_c,
--                avg (Least(COALESCE (merged_building_loss_ratio_per_basis, 0), 1)) mb_av_c,
--                avg (Least(COALESCE (merged_crop_loss_ratio_per_basis, 0), 1)) mc_av_c,
                  variance(Least(COALESCE (building_loss_ratio_per_basis, 0), 1)) b_va_c,
                  variance(Least(COALESCE (crop_loss_ratio_per_basis, 0), 1)) c_va_c,
                  variance(Least(COALESCE (population_loss_ratio_per_basis, 0), 1)) p_va_c,
                  variance(Least(COALESCE (fema_building_loss_ratio_per_basis, 0), 1)) f_va_c,
                  variance(Least(COALESCE (fema_crop_loss_ratio_per_basis, 0), 1)) fc_va_c
--                variance(Least(COALESCE (merged_building_loss_ratio_per_basis, 0), 1)) mb_va_c,
--                variance(Least(COALESCE (merged_crop_loss_ratio_per_basis, 0), 1)) mc_va_c

           from lrpbs as a
                    join severe_weather_new.fips_to_regions_and_surrounding_counties_hurricane as b
                         on b.fips = a.geoid
                             and nri_category = 'hurricane'
           WHERE nri_category is not null
           group by 1, 2
           order by 1, 2),
       surrounding as (
           select a.geoid, surrounding_counties fips,
                  nri_category,
                  count (1),
                  avg (Least(COALESCE (building_loss_ratio_per_basis, 0), 1)) b_av_s,
                  avg (Least(COALESCE (crop_loss_ratio_per_basis, 0), 1)) c_av_s,
                  avg (Least(COALESCE (population_loss_ratio_per_basis, 0), 1)) p_av_s,
                  avg (Least(COALESCE (fema_building_loss_ratio_per_basis, 0), 1)) f_av_s,
                  avg (Least(COALESCE (fema_crop_loss_ratio_per_basis, 0), 1)) fc_av_s,
--                avg (Least(COALESCE (merged_building_loss_ratio_per_basis, 0), 1)) mb_av_s,
--                avg (Least(COALESCE (merged_crop_loss_ratio_per_basis, 0), 1)) mc_av_s,
                  variance(Least(COALESCE (building_loss_ratio_per_basis, 0), 1)) b_va_s,
                  variance(Least(COALESCE (crop_loss_ratio_per_basis, 0), 1)) c_va_s,
                  variance(Least(COALESCE (population_loss_ratio_per_basis, 0), 1)) p_va_s,
                  variance(Least(COALESCE (fema_building_loss_ratio_per_basis, 0), 1)) f_va_s,
                  variance(Least(COALESCE (fema_crop_loss_ratio_per_basis, 0), 1)) fc_va_s
--                variance(Least(COALESCE (merged_building_loss_ratio_per_basis, 0), 1)) mb_va_s,
--                variance(Least(COALESCE (merged_crop_loss_ratio_per_basis, 0), 1)) mc_va_s

           from lrpbs as a
                    join severe_weather_new.fips_to_regions_and_surrounding_counties as b
                         on b.fips = a.geoid
                             and nri_category != 'hurricane'
           WHERE nri_category is not null
           group by 1, 2, 3


           UNION

           select a.geoid, surrounding_counties fips,
                  nri_category,
                  count (1),
                  avg (Least(COALESCE (building_loss_ratio_per_basis, 0), 1)) b_av_s,
                  avg (Least(COALESCE (crop_loss_ratio_per_basis, 0), 1)) c_av_s,
                  avg (Least(COALESCE (population_loss_ratio_per_basis, 0), 1)) p_av_s,
                  avg (Least(COALESCE (fema_building_loss_ratio_per_basis, 0), 1)) f_av_s,
                  avg (Least(COALESCE (fema_crop_loss_ratio_per_basis, 0), 1)) fc_av_s,
--                avg (Least(COALESCE (merged_building_loss_ratio_per_basis, 0), 1)) mb_av_s,
--                avg (Least(COALESCE (merged_crop_loss_ratio_per_basis, 0), 1)) mc_av_s,
                  variance(Least(COALESCE (building_loss_ratio_per_basis, 0), 1)) b_va_s,
                  variance(Least(COALESCE (crop_loss_ratio_per_basis, 0), 1)) c_va_s,
                  variance(Least(COALESCE (population_loss_ratio_per_basis, 0), 1)) p_va_s,
                  variance(Least(COALESCE (fema_building_loss_ratio_per_basis, 0), 1)) f_va_s,
                  variance(Least(COALESCE (fema_crop_loss_ratio_per_basis, 0), 1)) fc_va_s
--                variance(Least(COALESCE (merged_building_loss_ratio_per_basis, 0), 1)) mb_va_s,
--                variance(Least(COALESCE (merged_crop_loss_ratio_per_basis, 0), 1)) mc_va_s
           from lrpbs as a
                    join severe_weather_new.fips_to_regions_and_surrounding_counties_hurricane as b
                         on b.fips = a.geoid
                             and nri_category = 'hurricane'
           WHERE nri_category is not null
           group by 1, 2, 3
           order by 1, 2, 3
       ),

       hlr as (
           SELECT county.fips geoid,
                  regional.region,
                  surrounding.fips surrounding,
                  county.nri_category,

                  COALESCE(((
                                    (1.0 / NULLIF(b_va_n, 0)) /
                                    (
                                            COALESCE(1.0 / NULLIF(b_va_n, 0), 0) +
                                            COALESCE(1.0 / NULLIF(b_va_r, 0), 0) +
                                            COALESCE(1.0 / NULLIF(b_va_c, 0), 0) +
                                            COALESCE(1.0 / NULLIF(b_va_s, 0), 0)
                                        )
                                ) *
                            b_av_n), 0) +
                  COALESCE(((
                                    (1.0 / NULLIF(b_va_r, 0)) /
                                    (
                                            COALESCE(1.0 / NULLIF(b_va_n, 0), 0) +
                                            COALESCE(1.0 / NULLIF(b_va_r, 0), 0) +
                                            COALESCE(1.0 / NULLIF(b_va_c, 0), 0) +
                                            COALESCE(1.0 / NULLIF(b_va_s, 0), 0)
                                        )
                                ) *
                            b_av_r), 0) +
                  COALESCE(((
                                    (1.0 / NULLIF(b_va_c, 0)) /
                                    (
                                            COALESCE(1.0 / NULLIF(b_va_n, 0), 0) +
                                            COALESCE(1.0 / NULLIF(b_va_r, 0), 0) +
                                            COALESCE(1.0 / NULLIF(b_va_c, 0), 0) +
                                            COALESCE(1.0 / NULLIF(b_va_s, 0), 0)
                                        )
                                ) *
                            b_av_c), 0) +
                  COALESCE(((
                                    (1.0 / NULLIF(b_va_s, 0)) /
                                    (
                                            COALESCE(1.0 / NULLIF(b_va_n, 0), 0) +
                                            COALESCE(1.0 / NULLIF(b_va_r, 0), 0) +
                                            COALESCE(1.0 / NULLIF(b_va_c, 0), 0) +
                                            COALESCE(1.0 / NULLIF(b_va_s, 0), 0)
                                        )
                                ) *
                            b_av_s), 0) AS hlr_b,

                  COALESCE(((
                                    (1.0 / NULLIF(c_va_n, 0)) /
                                    (
                                            COALESCE(1.0 / NULLIF(c_va_n, 0), 0) +
                                            COALESCE(1.0 / NULLIF(c_va_r, 0), 0) +
                                            COALESCE(1.0 / NULLIF(c_va_c, 0), 0) +
                                            COALESCE(1.0 / NULLIF(c_va_s, 0), 0)
                                        )
                                ) *
                            c_av_n), 0) +
                  COALESCE(((
                                    (1.0 / NULLIF(c_va_r, 0)) /
                                    (
                                            COALESCE(1.0 / NULLIF(c_va_n, 0), 0) +
                                            COALESCE(1.0 / NULLIF(c_va_r, 0), 0) +
                                            COALESCE(1.0 / NULLIF(c_va_c, 0), 0) +
                                            COALESCE(1.0 / NULLIF(c_va_s, 0), 0)
                                        )
                                ) *
                            c_av_r), 0) +
                  COALESCE(((
                                    (1.0 / NULLIF(c_va_c, 0)) /
                                    (
                                            COALESCE(1.0 / NULLIF(c_va_n, 0), 0) +
                                            COALESCE(1.0 / NULLIF(c_va_r, 0), 0) +
                                            COALESCE(1.0 / NULLIF(c_va_c, 0), 0) +
                                            COALESCE(1.0 / NULLIF(c_va_s, 0), 0)
                                        )
                                ) *
                            c_av_c), 0) +
                  COALESCE(((
                                    (1.0 / NULLIF(c_va_s, 0)) /
                                    (
                                            COALESCE(1.0 / NULLIF(c_va_n, 0), 0) +
                                            COALESCE(1.0 / NULLIF(c_va_r, 0), 0) +
                                            COALESCE(1.0 / NULLIF(c_va_c, 0), 0) +
                                            COALESCE(1.0 / NULLIF(c_va_s, 0), 0)
                                        )
                                ) *
                            c_av_s), 0) AS hlr_c,

                  COALESCE(((
                                    (1.0 / NULLIF(p_va_n, 0)) /
                                    (
                                            COALESCE(1.0 / NULLIF(p_va_n, 0), 0) +
                                            COALESCE(1.0 / NULLIF(p_va_r, 0), 0) +
                                            COALESCE(1.0 / NULLIF(p_va_c, 0), 0) +
                                            COALESCE(1.0 / NULLIF(p_va_s, 0), 0)
                                        )
                                ) *
                            p_av_n), 0) +
                  COALESCE(((
                                    (1.0 / NULLIF(p_va_r, 0)) /
                                    (
                                            COALESCE(1.0 / NULLIF(p_va_n, 0), 0) +
                                            COALESCE(1.0 / NULLIF(p_va_r, 0), 0) +
                                            COALESCE(1.0 / NULLIF(p_va_c, 0), 0) +
                                            COALESCE(1.0 / NULLIF(p_va_s, 0), 0)
                                        )
                                ) *
                            p_av_r), 0) +
                  COALESCE(((
                                    (1.0 / NULLIF(p_va_c, 0)) /
                                    (
                                            COALESCE(1.0 / NULLIF(p_va_n, 0), 0) +
                                            COALESCE(1.0 / NULLIF(p_va_r, 0), 0) +
                                            COALESCE(1.0 / NULLIF(p_va_c, 0), 0) +
                                            COALESCE(1.0 / NULLIF(p_va_s, 0), 0)
                                        )
                                ) *
                            p_av_c), 0) +
                  COALESCE(((
                                    (1.0 / NULLIF(p_va_s, 0)) /
                                    (
                                            COALESCE(1.0 / NULLIF(p_va_n, 0), 0) +
                                            COALESCE(1.0 / NULLIF(p_va_r, 0), 0) +
                                            COALESCE(1.0 / NULLIF(p_va_c, 0), 0) +
                                            COALESCE(1.0 / NULLIF(p_va_s, 0), 0)
                                        )
                                ) *
                            p_av_s), 0) AS hlr_p,

                  COALESCE(((
                                    (1.0 / NULLIF(f_va_n, 0)) /
                                    (
                                            COALESCE(1.0 / NULLIF(f_va_n, 0), 0) +
                                            COALESCE(1.0 / NULLIF(f_va_r, 0), 0) +
                                            COALESCE(1.0 / NULLIF(f_va_c, 0), 0) +
                                            COALESCE(1.0 / NULLIF(f_va_s, 0), 0)
                                        )
                                ) *
                            f_av_n), 0) +
                  COALESCE(((
                                    (1.0 / NULLIF(f_va_r, 0)) /
                                    (
                                            COALESCE(1.0 / NULLIF(f_va_n, 0), 0) +
                                            COALESCE(1.0 / NULLIF(f_va_r, 0), 0) +
                                            COALESCE(1.0 / NULLIF(f_va_c, 0), 0) +
                                            COALESCE(1.0 / NULLIF(f_va_s, 0), 0)
                                        )
                                ) *
                            f_av_r), 0) +
                  COALESCE(((
                                    (1.0 / NULLIF(f_va_c, 0)) /
                                    (
                                            COALESCE(1.0 / NULLIF(f_va_n, 0), 0) +
                                            COALESCE(1.0 / NULLIF(f_va_r, 0), 0) +
                                            COALESCE(1.0 / NULLIF(f_va_c, 0), 0) +
                                            COALESCE(1.0 / NULLIF(f_va_s, 0), 0)
                                        )
                                ) *
                            f_av_c), 0) +
                  COALESCE(((
                                    (1.0 / NULLIF(f_va_s, 0)) /
                                    (
                                            COALESCE(1.0 / NULLIF(f_va_n, 0), 0) +
                                            COALESCE(1.0 / NULLIF(f_va_r, 0), 0) +
                                            COALESCE(1.0 / NULLIF(f_va_c, 0), 0) +
                                            COALESCE(1.0 / NULLIF(f_va_s, 0), 0)
                                        )
                                ) *
                            f_av_s), 0) AS hlr_f,

--                COALESCE(((
--                                  (1.0 / NULLIF(mb_va_n, 0)) /
--                                  (
--                                          COALESCE(1.0 / NULLIF(mb_va_n, 0), 0) +
--                                          COALESCE(1.0 / NULLIF(mb_va_r, 0), 0) +
--                                          COALESCE(1.0 / NULLIF(mb_va_c, 0), 0) +
--                                          COALESCE(1.0 / NULLIF(mb_va_s, 0), 0)
--                                      )
--                              ) *
--                          mb_av_n), 0) +
--                COALESCE(((
--                                  (1.0 / NULLIF(mb_va_r, 0)) /
--                                  (
--                                          COALESCE(1.0 / NULLIF(mb_va_n, 0), 0) +
--                                          COALESCE(1.0 / NULLIF(mb_va_r, 0), 0) +
--                                          COALESCE(1.0 / NULLIF(mb_va_c, 0), 0) +
--                                          COALESCE(1.0 / NULLIF(mb_va_s, 0), 0)
--                                      )
--                              ) *
--                          mb_av_r), 0) +
--                COALESCE(((
--                                  (1.0 / NULLIF(mb_va_c, 0)) /
--                                  (
--                                          COALESCE(1.0 / NULLIF(mb_va_n, 0), 0) +
--                                          COALESCE(1.0 / NULLIF(mb_va_r, 0), 0) +
--                                          COALESCE(1.0 / NULLIF(mb_va_c, 0), 0) +
--                                          COALESCE(1.0 / NULLIF(mb_va_s, 0), 0)
--                                      )
--                              ) *
--                          mb_av_c), 0) +
--                COALESCE(((
--                                  (1.0 / NULLIF(mb_va_s, 0)) /
--                                  (
--                                          COALESCE(1.0 / NULLIF(mb_va_n, 0), 0) +
--                                          COALESCE(1.0 / NULLIF(mb_va_r, 0), 0) +
--                                          COALESCE(1.0 / NULLIF(mb_va_c, 0), 0) +
--                                          COALESCE(1.0 / NULLIF(mb_va_s, 0), 0)
--                                      )
--                              ) *
--                          mb_av_s), 0) AS hlr_mb,

                  COALESCE(((
                                    (1.0 / NULLIF(fc_va_n, 0)) /
                                    (
                                            COALESCE(1.0 / NULLIF(fc_va_n, 0), 0) +
                                            COALESCE(1.0 / NULLIF(fc_va_r, 0), 0) +
                                            COALESCE(1.0 / NULLIF(fc_va_c, 0), 0) +
                                            COALESCE(1.0 / NULLIF(fc_va_s, 0), 0)
                                        )
                                ) *
                            fc_av_n), 0) +
                  COALESCE(((
                                    (1.0 / NULLIF(fc_va_r, 0)) /
                                    (
                                            COALESCE(1.0 / NULLIF(fc_va_n, 0), 0) +
                                            COALESCE(1.0 / NULLIF(fc_va_r, 0), 0) +
                                            COALESCE(1.0 / NULLIF(fc_va_c, 0), 0) +
                                            COALESCE(1.0 / NULLIF(fc_va_s, 0), 0)
                                        )
                                ) *
                            fc_av_r), 0) +
                  COALESCE(((
                                    (1.0 / NULLIF(fc_va_c, 0)) /
                                    (
                                            COALESCE(1.0 / NULLIF(fc_va_n, 0), 0) +
                                            COALESCE(1.0 / NULLIF(fc_va_r, 0), 0) +
                                            COALESCE(1.0 / NULLIF(fc_va_c, 0), 0) +
                                            COALESCE(1.0 / NULLIF(fc_va_s, 0), 0)
                                        )
                                ) *
                            fc_av_c), 0) +
                  COALESCE(((
                                    (1.0 / NULLIF(fc_va_s, 0)) /
                                    (
                                            COALESCE(1.0 / NULLIF(fc_va_n, 0), 0) +
                                            COALESCE(1.0 / NULLIF(fc_va_r, 0), 0) +
                                            COALESCE(1.0 / NULLIF(fc_va_c, 0), 0) +
                                            COALESCE(1.0 / NULLIF(fc_va_s, 0), 0)
                                        )
                                ) *
                            fc_av_s), 0) AS hlr_fc

--                COALESCE(((
--                                  (1.0 / NULLIF(mc_va_n, 0)) /
--                                  (
--                                          COALESCE(1.0 / NULLIF(mc_va_n, 0), 0) +
--                                          COALESCE(1.0 / NULLIF(mc_va_r, 0), 0) +
--                                          COALESCE(1.0 / NULLIF(mc_va_c, 0), 0) +
--                                          COALESCE(1.0 / NULLIF(mc_va_s, 0), 0)
--                                      )
--                              ) *
--                          mc_av_n), 0) +
--                COALESCE(((
--                                  (1.0 / NULLIF(mc_va_r, 0)) /
--                                  (
--                                          COALESCE(1.0 / NULLIF(mc_va_n, 0), 0) +
--                                          COALESCE(1.0 / NULLIF(mc_va_r, 0), 0) +
--                                          COALESCE(1.0 / NULLIF(mc_va_c, 0), 0) +
--                                          COALESCE(1.0 / NULLIF(mc_va_s, 0), 0)
--                                      )
--                              ) *
--                          mc_av_r), 0) +
--                COALESCE(((
--                                  (1.0 / NULLIF(mc_va_c, 0)) /
--                                  (
--                                          COALESCE(1.0 / NULLIF(mc_va_n, 0), 0) +
--                                          COALESCE(1.0 / NULLIF(mc_va_r, 0), 0) +
--                                          COALESCE(1.0 / NULLIF(mc_va_c, 0), 0) +
--                                          COALESCE(1.0 / NULLIF(mc_va_s, 0), 0)
--                                      )
--                              ) *
--                          mc_av_c), 0) +
--                COALESCE(((
--                                  (1.0 / NULLIF(mc_va_s, 0)) /
--                                  (
--                                          COALESCE(1.0 / NULLIF(mc_va_n, 0), 0) +
--                                          COALESCE(1.0 / NULLIF(mc_va_r, 0), 0) +
--                                          COALESCE(1.0 / NULLIF(mc_va_c, 0), 0) +
--                                          COALESCE(1.0 / NULLIF(mc_va_s, 0), 0)
--                                      )
--                              ) *
--                          mc_av_s), 0) AS hlr_mc


           FROM severe_weather_new.fips_to_regions_and_surrounding_counties mapping
                    JOIN county
                         ON mapping.fips = county.fips
                    JOIN national
                         ON county.nri_category = national.nri_category
                    JOIN regional
                         ON county.nri_category = regional.nri_category
                             AND mapping.region = regional.region
                    JOIN surrounding
                         ON county.nri_category = surrounding.nri_category
                             AND mapping.surrounding_counties = surrounding.fips
           WHERE county.nri_category != 'hurricane')




SELECT nri_category,
       sum(CASE
               WHEN nri_category IN ('coastal')
                   THEN hlr_b * CFLD_EXPB  * CFLD_AFREQ
               WHEN nri_category IN ('coldwave')
                   THEN hlr_b * CWAV_EXPB  * CWAV_AFREQ
               WHEN nri_category IN ('drought')
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
           END) swd_building,

       sum(CASE
               WHEN nri_category IN ('coastal')
                   THEN hlr_f * CFLD_EXPB  * CFLD_AFREQ
               WHEN nri_category IN ('coldwave')
                   THEN hlr_f * CWAV_EXPB  * CWAV_AFREQ
               WHEN nri_category IN ('drought')
                   THEN hlr_f * CWAV_EXPB  * CWAV_AFREQ
               WHEN nri_category IN ('hurricane')
                   THEN hlr_f * HRCN_EXPB  * HRCN_AFREQ
               WHEN nri_category IN ('heatwave')
                   THEN hlr_f * HWAV_EXPB  * HWAV_AFREQ
               WHEN nri_category IN ('hail')
                   THEN hlr_f * HAIL_EXPB  * HAIL_AFREQ
               WHEN nri_category IN ('tornado')
                   THEN hlr_f * TRND_EXPB  * TRND_AFREQ
               WHEN nri_category IN ('riverine')
                   THEN hlr_f * RFLD_EXPB  * RFLD_AFREQ
               WHEN nri_category IN ('lightning')
                   THEN hlr_f * LTNG_EXPB  * LTNG_AFREQ
               WHEN nri_category IN ('landslide')
                   THEN hlr_f * LNDS_EXPB  * LNDS_AFREQ
               WHEN nri_category IN ('icestorm')
                   THEN hlr_f * ISTM_EXPB  * ISTM_AFREQ
               WHEN nri_category IN ('wind')
                   THEN hlr_f * SWND_EXPB  * SWND_AFREQ
               WHEN nri_category IN ('wildfire')
                   THEN hlr_f * WFIR_EXPB  * WFIR_AFREQ
               WHEN nri_category IN ('winterweat')
                   THEN hlr_f * WNTW_EXPB  * WNTW_AFREQ
               WHEN nri_category IN ('tsunami')
                   THEN hlr_f * TSUN_EXPB  * TSUN_AFREQ
               WHEN nri_category IN ('avalanche')
                   THEN hlr_f * AVLN_EXPB  * AVLN_AFREQ
               WHEN nri_category IN ('volcano')
                   THEN hlr_f * VLCN_EXPB  * VLCN_AFREQ
           END) fema_building,

--        sum(CASE
--                WHEN nri_category IN ('coastal')
--                    THEN hlr_mb * CFLD_EXPB  * CFLD_AFREQ
--                WHEN nri_category IN ('coldwave')
--                    THEN hlr_mb * CWAV_EXPB  * CWAV_AFREQ
--                WHEN nri_category IN ('drought')
--                    THEN hlr_mb * CWAV_EXPB  * CWAV_AFREQ
--                WHEN nri_category IN ('hurricane')
--                    THEN hlr_mb * HRCN_EXPB  * HRCN_AFREQ
--                WHEN nri_category IN ('heatwave')
--                    THEN hlr_mb * HWAV_EXPB  * HWAV_AFREQ
--                WHEN nri_category IN ('hail')
--                    THEN hlr_mb * HAIL_EXPB  * HAIL_AFREQ
--                WHEN nri_category IN ('tornado')
--                    THEN hlr_mb * TRND_EXPB  * TRND_AFREQ
--                WHEN nri_category IN ('riverine')
--                    THEN hlr_mb * RFLD_EXPB  * RFLD_AFREQ
--                WHEN nri_category IN ('lightning')
--                    THEN hlr_mb * LTNG_EXPB  * LTNG_AFREQ
--                WHEN nri_category IN ('landslide')
--                    THEN hlr_mb * LNDS_EXPB  * LNDS_AFREQ
--                WHEN nri_category IN ('icestorm')
--                    THEN hlr_mb * ISTM_EXPB  * ISTM_AFREQ
--                WHEN nri_category IN ('wind')
--                    THEN hlr_mb * SWND_EXPB  * SWND_AFREQ
--                WHEN nri_category IN ('wildfire')
--                    THEN hlr_mb * WFIR_EXPB  * WFIR_AFREQ
--                WHEN nri_category IN ('winterweat')
--                    THEN hlr_mb * WNTW_EXPB  * WNTW_AFREQ
--                WHEN nri_category IN ('tsunami')
--                    THEN hlr_mb * TSUN_EXPB  * TSUN_AFREQ
--                WHEN nri_category IN ('avalanche')
--                    THEN hlr_mb * AVLN_EXPB  * AVLN_AFREQ
--                WHEN nri_category IN ('volcano')
--                    THEN hlr_mb * VLCN_EXPB  * VLCN_AFREQ
--            END) merged_building,

       sum(CASE
               WHEN nri_category IN ('coldwave')
                   THEN hlr_c * CWAV_EXPA  * CWAV_AFREQ
               WHEN nri_category IN ('drought')
                   THEN hlr_c * CWAV_EXPA  * CWAV_AFREQ
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
           END) swd_crop,

       sum(CASE
               WHEN nri_category IN ('coldwave')
                   THEN hlr_fc * CWAV_EXPA  * CWAV_AFREQ
               WHEN nri_category IN ('drought')
                   THEN hlr_fc * CWAV_EXPA  * CWAV_AFREQ
               WHEN nri_category IN ('hurricane')
                   THEN hlr_fc * HRCN_EXPA  * HRCN_AFREQ
               WHEN nri_category IN ('heatwave')
                   THEN hlr_fc * HWAV_EXPA  * HWAV_AFREQ
               WHEN nri_category IN ('hail')
                   THEN hlr_fc * HAIL_EXPA  * HAIL_AFREQ
               WHEN nri_category IN ('tornado')
                   THEN hlr_fc * TRND_EXPA  * TRND_AFREQ
               WHEN nri_category IN ('riverine')
                   THEN hlr_fc * RFLD_EXPA  * RFLD_AFREQ
               WHEN nri_category IN ('wind')
                   THEN hlr_fc * SWND_EXPA  * SWND_AFREQ
               WHEN nri_category IN ('wildfire')
                   THEN hlr_fc * WFIR_EXPA  * WFIR_AFREQ
               WHEN nri_category IN ('winterweat')
                   THEN hlr_fc * WNTW_EXPA  * WNTW_AFREQ
           END) fema_crop

--        sum(CASE
--                WHEN nri_category IN ('coldwave')
--                    THEN hlr_mc * CWAV_EXPA  * CWAV_AFREQ
--                WHEN nri_category IN ('drought')
--                    THEN hlr_mc * CWAV_EXPA  * CWAV_AFREQ
--                WHEN nri_category IN ('hurricane')
--                    THEN hlr_mc * HRCN_EXPA  * HRCN_AFREQ
--                WHEN nri_category IN ('heatwave')
--                    THEN hlr_mc * HWAV_EXPA  * HWAV_AFREQ
--                WHEN nri_category IN ('hail')
--                    THEN hlr_mc * HAIL_EXPA  * HAIL_AFREQ
--                WHEN nri_category IN ('tornado')
--                    THEN hlr_mc * TRND_EXPA  * TRND_AFREQ
--                WHEN nri_category IN ('riverine')
--                    THEN hlr_mc * RFLD_EXPA  * RFLD_AFREQ
--                WHEN nri_category IN ('wind')
--                    THEN hlr_mc * SWND_EXPA  * SWND_AFREQ
--                WHEN nri_category IN ('wildfire')
--                    THEN hlr_mc * WFIR_EXPA  * WFIR_AFREQ
--                WHEN nri_category IN ('winterweat')
--                    THEN hlr_mc * WNTW_EXPA  * WNTW_AFREQ
--            END) merged_crop
FROM hlr
         JOIN national_risk_index.nri_counties_november_2021
              ON geoid = stcofips
GROUP BY nri_category
ORDER BY nri_category

