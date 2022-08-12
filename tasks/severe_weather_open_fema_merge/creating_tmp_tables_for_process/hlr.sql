with   lrpbs as (
    SELECT tmp_per_basis_data_zero_loss.*,
           CASE
               WHEN nri_category IN ('wind')
                   THEN swd_property_damage::float / NULLIF (SWND_EXPB, 0)
               WHEN nri_category IN ('wildfire')
                   THEN swd_property_damage::float / NULLIF (WFIR_EXPB, 0)
               WHEN nri_category IN ('tsunami')
                   THEN swd_property_damage::float / NULLIF (TSUN_EXPB, 0)
               WHEN nri_category IN ('tornado')
                   THEN swd_property_damage::float / NULLIF (TRND_EXPB, 0)
               WHEN nri_category IN ('riverine')
                   THEN swd_property_damage::float / NULLIF (RFLD_EXPB, 0)
               WHEN nri_category IN ('lightning')
                   THEN swd_property_damage::float / NULLIF (LTNG_EXPB, 0)
               WHEN nri_category IN ('landslide')
                   THEN swd_property_damage::float / NULLIF (LNDS_EXPB, 0)
               WHEN nri_category IN ('icestorm')
                   THEN swd_property_damage::float / NULLIF (ISTM_EXPB, 0)
               WHEN nri_category IN ('hurricane')
                   THEN swd_property_damage::float / NULLIF (HRCN_EXPB, 0)
               WHEN nri_category IN ('heatwave')
                   THEN swd_property_damage::float / NULLIF (HWAV_EXPB, 0)
               WHEN nri_category IN ('hail')
                   THEN swd_property_damage::float / NULLIF (HAIL_EXPB, 0)
               WHEN nri_category IN ('avalanche')
                   THEN swd_property_damage::float / NULLIF (AVLN_EXPB, 0)
               WHEN nri_category IN ('coldwave')
                   THEN swd_property_damage::float / NULLIF (CWAV_EXPB, 0)
               WHEN nri_category IN ('winterweat')
                   THEN swd_property_damage::float / NULLIF (WNTW_EXPB, 0)
               WHEN nri_category IN ('volcano')
                   THEN swd_property_damage::float / NULLIF (VLCN_EXPB, 0)
               WHEN nri_category IN ('coastal')
                   THEN swd_property_damage::float / NULLIF (CFLD_EXPB, 0)
               END building_loss_ratio_per_basis,
           CASE
               WHEN nri_category IN ('wind')
                   THEN fema_property_damage::float / NULLIF (SWND_EXPB, 0)
               WHEN nri_category IN ('wildfire')
                   THEN fema_property_damage::float / NULLIF (WFIR_EXPB, 0)
               WHEN nri_category IN ('tsunami')
                   THEN fema_property_damage::float / NULLIF (TSUN_EXPB, 0)
               WHEN nri_category IN ('tornado')
                   THEN fema_property_damage::float / NULLIF (TRND_EXPB, 0)
               WHEN nri_category IN ('riverine')
                   THEN fema_property_damage::float / NULLIF (RFLD_EXPB, 0)
               WHEN nri_category IN ('lightning')
                   THEN fema_property_damage::float / NULLIF (LTNG_EXPB, 0)
               WHEN nri_category IN ('landslide')
                   THEN fema_property_damage::float / NULLIF (LNDS_EXPB, 0)
               WHEN nri_category IN ('icestorm')
                   THEN fema_property_damage::float / NULLIF (ISTM_EXPB, 0)
               WHEN nri_category IN ('hurricane')
                   THEN fema_property_damage::float / NULLIF (HRCN_EXPB, 0)
               WHEN nri_category IN ('heatwave')
                   THEN fema_property_damage::float / NULLIF (HWAV_EXPB, 0)
               WHEN nri_category IN ('hail')
                   THEN fema_property_damage::float / NULLIF (HAIL_EXPB, 0)
               WHEN nri_category IN ('avalanche')
                   THEN fema_property_damage::float / NULLIF (AVLN_EXPB, 0)
               WHEN nri_category IN ('coldwave')
                   THEN fema_property_damage::float / NULLIF (CWAV_EXPB, 0)
               WHEN nri_category IN ('winterweat')
                   THEN fema_property_damage::float / NULLIF (WNTW_EXPB, 0)
               WHEN nri_category IN ('volcano')
                   THEN fema_property_damage::float / NULLIF (VLCN_EXPB, 0)
               WHEN nri_category IN ('coastal')
                   THEN fema_property_damage::float / NULLIF (CFLD_EXPB, 0)
               END fema_building_loss_ratio_per_basis,

           CASE
               WHEN nri_category IN ('wind')
                   THEN fema_crop_damage::float / NULLIF (SWND_expa, 0)
               WHEN nri_category IN ('wildfire')
                   THEN fema_crop_damage::float / NULLIF (WFIR_expa, 0)
               WHEN nri_category IN ('tornado')
                   THEN fema_crop_damage::float / NULLIF (TRND_expa, 0)
               WHEN nri_category IN ('riverine')
                   THEN fema_crop_damage::float / NULLIF (RFLD_expa, 0)
               WHEN nri_category IN ('hurricane')
                   THEN fema_crop_damage::float / NULLIF (HRCN_expa, 0)
               WHEN nri_category IN ('heatwave')
                   THEN fema_crop_damage::float / NULLIF (HWAV_expa, 0)
               WHEN nri_category IN ('hail')
                   THEN fema_crop_damage::float / NULLIF (HAIL_expa, 0)
               WHEN nri_category IN ('drought')
                   THEN fema_crop_damage::float /NULLIF(DRGT_expa, 0)
               WHEN nri_category IN ('coldwave')
                   THEN fema_crop_damage::float / NULLIF (CWAV_expa, 0)
               WHEN nri_category IN ('winterweat')
                   THEN fema_crop_damage::float / NULLIF (WNTW_expa, 0)
               END fema_crop_loss_ratio_per_basis,

           CASE
               WHEN nri_category IN ('wind')
                   THEN swd_crop_damage::float / NULLIF (SWND_EXPA, 0)
               WHEN nri_category IN ('wildfire')
                   THEN swd_crop_damage::float / NULLIF (WFIR_EXPA, 0)
               WHEN nri_category IN ('tornado')
                   THEN swd_crop_damage::float / NULLIF (TRND_EXPA, 0)
               WHEN nri_category IN ('riverine')
                   THEN swd_crop_damage::float / NULLIF (RFLD_EXPA, 0)
               WHEN nri_category IN ('hurricane')
                   THEN swd_crop_damage::float / NULLIF (HRCN_EXPA, 0)
               WHEN nri_category IN ('heatwave')
                   THEN swd_crop_damage::float / NULLIF (HWAV_EXPA, 0)
               WHEN nri_category IN ('hail')
                   THEN swd_crop_damage::float / NULLIF (HAIL_EXPA, 0)
               WHEN nri_category IN ('drought')
                   THEN swd_crop_damage::float / NULLIF (DRGT_EXPA, 0)
               WHEN nri_category IN ('coldwave')
                   THEN swd_crop_damage::float / NULLIF (CWAV_EXPA, 0)
               WHEN nri_category IN ('winterweat')
                   THEN swd_crop_damage::float / NULLIF (WNTW_EXPA, 0)
               END crop_loss_ratio_per_basis,

           CASE
               WHEN nri_category IN ('wind')
                   THEN fatalities_dollar_value::float / NULLIF (SWND_EXPPE, 0)
               WHEN nri_category IN ('wildfire')
                   THEN fatalities_dollar_value::float / NULLIF (WFIR_EXPPE, 0)
               WHEN nri_category IN ('tsunami')
                   THEN fatalities_dollar_value::float / NULLIF (TSUN_EXPPE, 0)
               WHEN nri_category IN ('tornado')
                   THEN fatalities_dollar_value::float / NULLIF (TRND_EXPPE, 0)
               WHEN nri_category IN ('riverine')
                   THEN fatalities_dollar_value::float / NULLIF (RFLD_EXPPE, 0)
               WHEN nri_category IN ('lightning')
                   THEN fatalities_dollar_value::float / NULLIF (LTNG_EXPPE, 0)
               WHEN nri_category IN ('landslide')
                   THEN fatalities_dollar_value::float / NULLIF (LNDS_EXPPE, 0)
               WHEN nri_category IN ('icestorm')
                   THEN fatalities_dollar_value::float / NULLIF (ISTM_EXPPE, 0)
               WHEN nri_category IN ('hurricane')
                   THEN fatalities_dollar_value::float / NULLIF (HRCN_EXPPE, 0)
               WHEN nri_category IN ('heatwave')
                   THEN fatalities_dollar_value::float / NULLIF (HWAV_EXPPE, 0)
               WHEN nri_category IN ('hail')
                   THEN fatalities_dollar_value::float / NULLIF (HAIL_EXPPE, 0)
               WHEN nri_category IN ('avalanche')
                   THEN fatalities_dollar_value::float / NULLIF (AVLN_EXPPE, 0)
               WHEN nri_category IN ('coldwave')
                   THEN fatalities_dollar_value::float / NULLIF (CWAV_EXPPE, 0)
               WHEN nri_category IN ('winterweat')
                   THEN fatalities_dollar_value::float / NULLIF (WNTW_EXPPE, 0)
               WHEN nri_category IN ('volcano')
                   THEN fatalities_dollar_value::float / NULLIF (VLCN_EXPPE, 0)
               WHEN nri_category IN ('coastal')
                   THEN fatalities_dollar_value::float / NULLIF (CFLD_EXPPE, 0)
               END population_loss_ratio_per_basis
    FROM tmp_per_basis_data_zero_loss
             JOIN national_risk_index.nri_counties_november_2021 nri
                  ON tmp_per_basis_data_zero_loss.geoid = nri.stcofips),
       national as (
           select nri_category,
                  count (1),
                  avg (building_loss_ratio_per_basis) b_av_n,
                  avg (crop_loss_ratio_per_basis) c_av_n,
                  avg (population_loss_ratio_per_basis) p_av_n,
                  avg (fema_building_loss_ratio_per_basis) f_av_n,
                  avg (fema_crop_loss_ratio_per_basis) fc_av_n,
                  variance(building_loss_ratio_per_basis) b_va_n,
                  variance(crop_loss_ratio_per_basis) c_va_n,
                  variance(population_loss_ratio_per_basis) p_va_n,
                  variance(fema_building_loss_ratio_per_basis) f_va_n,
                  variance(fema_crop_loss_ratio_per_basis) fc_va_n

           from lrpbs as a
           WHERE nri_category is not null
           group by 1
           order by 1),
       regional as (
           select region,
                  nri_category,
                  count (1),
                  avg (building_loss_ratio_per_basis) b_av_r,
                  avg (crop_loss_ratio_per_basis) c_av_r,
                  avg (population_loss_ratio_per_basis) p_av_r,
                  avg (fema_building_loss_ratio_per_basis) f_av_r,
                  avg (fema_crop_loss_ratio_per_basis) fc_av_r,
                  variance(building_loss_ratio_per_basis) b_va_r,
                  variance(crop_loss_ratio_per_basis) c_va_r,
                  variance(population_loss_ratio_per_basis) p_va_r,
                  variance(fema_building_loss_ratio_per_basis) f_va_r,
                  variance(fema_crop_loss_ratio_per_basis) fc_va_r

           from lrpbs as a
                    join severe_weather_new.fips_to_regions_and_surrounding_counties as b
                         on b.fips = a.geoid
                             and nri_category != 'hurricane'
           WHERE nri_category is not null
           group by 1, 2

           UNION ALL

           select region,
                  nri_category,
                  count (1),
                  avg (building_loss_ratio_per_basis) b_av_r,
                  avg (crop_loss_ratio_per_basis) c_av_r,
                  avg (population_loss_ratio_per_basis) p_av_r,
                  avg (fema_building_loss_ratio_per_basis) f_av_r,
                  avg (fema_crop_loss_ratio_per_basis) fc_av_r,
                  variance(building_loss_ratio_per_basis) b_va_r,
                  variance(crop_loss_ratio_per_basis) c_va_r,
                  variance(population_loss_ratio_per_basis) p_va_r,
                  variance(fema_building_loss_ratio_per_basis) f_va_r,
                  variance(fema_crop_loss_ratio_per_basis) fc_va_r

           from lrpbs as a
                    join severe_weather_new.fips_to_regions_and_surrounding_counties_hurricane as b
                         on b.fips = a.geoid
                             and nri_category = 'hurricane'
           WHERE nri_category is not null
           group by 1, 2
           order by 1, 2

       ),
       county as (
           select LEFT (b.fips, 5) fips,
                  b.region,
                  b.surrounding_counties as surrounding,
                  nri_category,
                  count (1),
                  avg (building_loss_ratio_per_basis) b_av_c,
                  avg (crop_loss_ratio_per_basis) c_av_c,
                  avg (population_loss_ratio_per_basis) p_av_c,
                  avg (fema_building_loss_ratio_per_basis) f_av_c,
                  avg (fema_crop_loss_ratio_per_basis) fc_av_c,
                  variance(building_loss_ratio_per_basis) b_va_c,
                  variance(crop_loss_ratio_per_basis) c_va_c,
                  variance(population_loss_ratio_per_basis) p_va_c,
                  variance(fema_building_loss_ratio_per_basis) f_va_c,
                  variance(fema_crop_loss_ratio_per_basis) fc_va_c

           from lrpbs as a

                    join severe_weather_new.fips_to_regions_and_surrounding_counties as b
                         on b.fips = a.geoid
                             and nri_category != 'hurricane'
           WHERE nri_category is not null
           group by 1, 2, 3, 4

           UNION ALL

           select LEFT (b.fips, 5) fips,
                  b.region,
                  b.surrounding_counties as surrounding,
                  nri_category,
                  count (1),
                  avg (building_loss_ratio_per_basis) b_av_c,
                  avg (crop_loss_ratio_per_basis) c_av_c,
                  avg (population_loss_ratio_per_basis) p_av_c,
                  avg (fema_building_loss_ratio_per_basis) f_av_c,
                  avg (fema_crop_loss_ratio_per_basis) fc_av_c,
                  variance(building_loss_ratio_per_basis) b_va_c,
                  variance(crop_loss_ratio_per_basis) c_va_c,
                  variance(population_loss_ratio_per_basis) p_va_c,
                  variance(fema_building_loss_ratio_per_basis) f_va_c,
                  variance(fema_crop_loss_ratio_per_basis) fc_va_c

           from lrpbs as a
                    join severe_weather_new.fips_to_regions_and_surrounding_counties_hurricane as b
                         on b.fips = a.geoid
                             and nri_category = 'hurricane'
           WHERE nri_category is not null
           group by 1, 2, 3, 4
           order by 1, 2, 3, 4),
       surrounding as (
           select surrounding_counties surrounding,
                  nri_category,
                  count (1),
                  avg (building_loss_ratio_per_basis) b_av_s,
                  avg (crop_loss_ratio_per_basis) c_av_s,
                  avg (population_loss_ratio_per_basis) p_av_s,
                  avg (fema_building_loss_ratio_per_basis) f_av_s,
                  avg (fema_crop_loss_ratio_per_basis) fc_av_s,
                  variance(building_loss_ratio_per_basis) b_va_s,
                  variance(crop_loss_ratio_per_basis) c_va_s,
                  variance(population_loss_ratio_per_basis) p_va_s,
                  variance(fema_building_loss_ratio_per_basis) f_va_s,
                  variance(fema_crop_loss_ratio_per_basis) fc_va_s

           from lrpbs as a
                    join severe_weather_new.fips_to_regions_and_surrounding_counties as b
                         on b.fips = a.geoid
                             and nri_category != 'hurricane'
           WHERE nri_category is not null
           group by 1, 2


           UNION

           select surrounding_counties surrounding,
                  nri_category,
                  count (1),
                  avg (building_loss_ratio_per_basis) b_av_s,
                  avg (crop_loss_ratio_per_basis) c_av_s,
                  avg (population_loss_ratio_per_basis) p_av_s,
                  avg (fema_building_loss_ratio_per_basis) f_av_s,
                  avg (fema_crop_loss_ratio_per_basis) fc_av_s,
                  variance(building_loss_ratio_per_basis) b_va_s,
                  variance(crop_loss_ratio_per_basis) c_va_s,
                  variance(population_loss_ratio_per_basis) p_va_s,
                  variance(fema_building_loss_ratio_per_basis) f_va_s,
                  variance(fema_crop_loss_ratio_per_basis) fc_va_s
           from lrpbs as a
                    join severe_weather_new.fips_to_regions_and_surrounding_counties_hurricane as b
                         on b.fips = a.geoid
                             and nri_category = 'hurricane'
           WHERE nri_category is not null
           group by 1, 2
           order by 1, 2
       ),

       hlr as (
           SELECT county.fips as geoid,
                  regional.region,
                  surrounding.surrounding surrounding,
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

           FROM county
                    JOIN national
                         ON county.nri_category = national.nri_category
                    JOIN regional
                         ON county.nri_category = regional.nri_category
                             AND county.region = regional.region
                    JOIN surrounding
                         ON county.nri_category = surrounding.nri_category
                             AND county.surrounding = surrounding.surrounding
       )




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
FROM hlr
         JOIN national_risk_index.nri_counties_november_2021
              ON geoid = stcofips
GROUP BY nri_category
ORDER BY nri_category
