with   lrpbs as (
    SELECT tmp_per_basis_data_zero_loss.*, RFLD_EXPB, RFLD_EXPA, RFLD_EXPPE,
           coalesce(CASE
                        WHEN nri_category IN ('wind')
                            THEN (CASE WHEN swd_property_damage > SWND_EXPB THEN SWND_EXPB ELSE swd_property_damage END)::float / NULLIF (SWND_EXPB, 0)
                        WHEN nri_category IN ('wildfire')
                            THEN (CASE WHEN swd_property_damage > WFIR_EXPB THEN WFIR_EXPB ELSE swd_property_damage END)::float / NULLIF (WFIR_EXPB, 0)
                        WHEN nri_category IN ('tsunami')
                            THEN swd_property_damage::float / NULLIF (TSUN_EXPB, 0)
                        WHEN nri_category IN ('tornado')
                            THEN (CASE WHEN swd_property_damage > TRND_EXPB THEN TRND_EXPB ELSE swd_property_damage END)::float / NULLIF (TRND_EXPB, 0)
                        WHEN nri_category IN ('riverine')
                            THEN (CASE WHEN swd_property_damage > RFLD_EXPB THEN RFLD_EXPB ELSE swd_property_damage END)::float / NULLIF (RFLD_EXPB, 0)
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
                            THEN (CASE WHEN swd_property_damage > AVLN_EXPB THEN AVLN_EXPB ELSE swd_property_damage END)::float / NULLIF (AVLN_EXPB, 0)
                        WHEN nri_category IN ('coldwave')
                            THEN swd_property_damage::float / NULLIF (CWAV_EXPB, 0)
                        WHEN nri_category IN ('winterweat')
                            THEN swd_property_damage::float / NULLIF (WNTW_EXPB, 0)
                        WHEN nri_category IN ('volcano')
                            THEN swd_property_damage::float / NULLIF (VLCN_EXPB, 0)
                        WHEN nri_category IN ('coastal')
                            THEN (CASE WHEN swd_property_damage > CFLD_EXPB THEN CFLD_EXPB ELSE swd_property_damage END)::float / NULLIF (CFLD_EXPB, 0)
                        END, 0) building_loss_ratio_per_basis,


           coalesce(CASE
                        WHEN nri_category IN ('wind')
                            THEN (CASE WHEN swd_crop_damage > SWND_EXPA THEN SWND_EXPA ELSE swd_crop_damage END)::float / NULLIF (SWND_EXPA, 0)
                        WHEN nri_category IN ('wildfire')
                            THEN (CASE WHEN swd_crop_damage > WFIR_EXPA THEN WFIR_EXPA ELSE swd_crop_damage END)::float / NULLIF (WFIR_EXPA, 0)
                        WHEN nri_category IN ('tornado')
                            THEN (CASE WHEN swd_crop_damage > TRND_EXPA THEN TRND_EXPA ELSE swd_crop_damage END)::float / NULLIF (TRND_EXPA, 0)
                        WHEN nri_category IN ('riverine')
                            THEN (CASE WHEN swd_crop_damage > RFLD_EXPA THEN RFLD_EXPA ELSE swd_crop_damage END)::float / NULLIF (RFLD_EXPA, 0)
                        WHEN nri_category IN ('hurricane')
                            THEN (CASE WHEN swd_crop_damage > HRCN_EXPA THEN HRCN_EXPA ELSE swd_crop_damage END)::float / NULLIF (HRCN_EXPA, 0)
                        WHEN nri_category IN ('heatwave')
                            THEN (CASE WHEN swd_crop_damage > HWAV_EXPA THEN HWAV_EXPA ELSE swd_crop_damage END)::float / NULLIF (HWAV_EXPA, 0)
                        WHEN nri_category IN ('hail')
                            THEN swd_crop_damage::float / NULLIF (HAIL_EXPA, 0)
                        WHEN nri_category IN ('drought')
                            THEN (CASE WHEN swd_crop_damage > DRGT_EXPA THEN DRGT_EXPA ELSE swd_crop_damage END)::float / NULLIF (DRGT_EXPA, 0)
                        WHEN nri_category IN ('coldwave')
                            THEN (CASE WHEN swd_crop_damage > CWAV_EXPA THEN CWAV_EXPA ELSE swd_crop_damage END)::float / NULLIF (CWAV_EXPA, 0)
                        WHEN nri_category IN ('winterweat')
                            THEN swd_crop_damage::float / NULLIF (WNTW_EXPA, 0)
                        END, 0) crop_loss_ratio_per_basis,

           coalesce(CASE
                        WHEN nri_category IN ('wind')
                            THEN fatalities_dollar_value::float / NULLIF (SWND_EXPPE, 0)
                        WHEN nri_category IN ('wildfire')
                            THEN fatalities_dollar_value::float / NULLIF (WFIR_EXPPE, 0)
                        WHEN nri_category IN ('tsunami')
                            THEN fatalities_dollar_value::float / NULLIF (TSUN_EXPPE, 0)
                        WHEN nri_category IN ('tornado')
                            THEN fatalities_dollar_value::float / NULLIF (TRND_EXPPE, 0)
                        WHEN nri_category IN ('riverine')
                            THEN (CASE WHEN fatalities_dollar_value > RFLD_EXPPE THEN RFLD_EXPPE ELSE fatalities_dollar_value END)::float / NULLIF (RFLD_EXPPE, 0)
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
                        END, 0) population_loss_ratio_per_basis

    FROM tmp_per_basis_data_swd  tmp_per_basis_data_zero_loss
             JOIN national_risk_index.nri_counties_november_2021 nri
                  ON tmp_per_basis_data_zero_loss.geoid = nri.stcofips),
       national as (
           select nri_category,
                  count (1),
                  avg (building_loss_ratio_per_basis) b_av_n,
                  avg (crop_loss_ratio_per_basis) c_av_n,
                  avg (population_loss_ratio_per_basis) p_av_n,

                  variance(building_loss_ratio_per_basis) b_va_n,
                  variance(crop_loss_ratio_per_basis) c_va_n,
                  variance(population_loss_ratio_per_basis) p_va_n

           from lrpbs as a
           WHERE nri_category is not null
           group by 1
           order by 1
       ),
       regional as (
           select region,
                  nri_category,
                  count (1),
                  avg (building_loss_ratio_per_basis) b_av_r,
                  avg (crop_loss_ratio_per_basis) c_av_r,
                  avg (population_loss_ratio_per_basis) p_av_r,

                  variance(building_loss_ratio_per_basis) b_va_r,
                  variance(crop_loss_ratio_per_basis) c_va_r,
                  variance(population_loss_ratio_per_basis) p_va_r

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

                  variance(building_loss_ratio_per_basis) b_va_r,
                  variance(crop_loss_ratio_per_basis) c_va_r,
                  variance(population_loss_ratio_per_basis) p_va_r

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
                  nri_category,
                  count (1),
                  avg (building_loss_ratio_per_basis) b_av_c,
                  avg (crop_loss_ratio_per_basis) c_av_c,
                  avg (population_loss_ratio_per_basis) p_av_c,

                  variance(building_loss_ratio_per_basis) b_va_c,
                  variance(crop_loss_ratio_per_basis) c_va_c,
                  variance(population_loss_ratio_per_basis) p_va_c

           from lrpbs as a

                    join severe_weather_new.fips_to_regions_and_surrounding_counties as b
                         on b.fips = a.geoid
                             and nri_category != 'hurricane'
           WHERE nri_category is not null
           group by 1, 2, 3

           UNION ALL

           select LEFT (b.fips, 5) fips,
                  b.region,
                  nri_category,
                  count (1),
                  avg (building_loss_ratio_per_basis) b_av_c,
                  avg (crop_loss_ratio_per_basis) c_av_c,
                  avg (population_loss_ratio_per_basis) p_av_c,

                  variance(building_loss_ratio_per_basis) b_va_c,
                  variance(crop_loss_ratio_per_basis) c_va_c,
                  variance(population_loss_ratio_per_basis) p_va_c

           from lrpbs as a
                    join severe_weather_new.fips_to_regions_and_surrounding_counties_hurricane as b
                         on b.fips = a.geoid
                             and nri_category = 'hurricane'
           WHERE nri_category is not null
           group by 1, 2, 3
           order by 1, 2, 3),
       grid_variance as (
           select id, nri_category, variance(building_loss_ratio_per_basis) b_va
           from tmp_fips_to_grid_mapping_196_new grid
                    JOIN lrpbs
                         ON grid.fips = lrpbs.geoid
           group by 1, 2
           order by 1, 2, 3),
       fips_to_id_ranking as (
           select grid.fips, grid.id, nri_category, b_va,
                  (covered_area * 100) / total_area percent_area_covered,
                  rank() over (partition by grid.fips, nri_category order by b_va, ((covered_area * 100) / total_area) desc ),
                  first_value(grid.id) over (partition by grid.fips, nri_category order by b_va, ((covered_area * 100) / total_area) desc ) lowest_var_highest_area_id
           from tmp_fips_to_grid_mapping_196_new grid
                    JOIN (select fips, sum(covered_area) total_area from tmp_fips_to_grid_mapping_196_new group by 1) total_area
                         ON total_area.fips = grid.fips
                    JOIN grid_variance
                         ON grid_variance.id = grid.id
                -- 	group by id
           order by 1, 4, 5 desc),
       fips_to_id_mapping as (
           select distinct fips, nri_category, lowest_var_highest_area_id
           from fips_to_id_ranking
           order by 1
       ),
       grid_values as (
           select lowest_var_highest_area_id, lrpbs.nri_category,
                  avg (building_loss_ratio_per_basis) b_av_s,
                  avg (crop_loss_ratio_per_basis) c_av_s,
                  avg (population_loss_ratio_per_basis) p_av_s,

                  variance(building_loss_ratio_per_basis) b_va_s,
                  variance(crop_loss_ratio_per_basis) c_va_s,
                  variance(population_loss_ratio_per_basis) p_va_s
           from fips_to_id_mapping
                    JOIN lrpbs
                         ON fips = lrpbs.geoid
                             AND fips_to_id_mapping.nri_category = lrpbs.nri_category
           group by 1, 2),
       surrounding as (
           SELECT fim.fips surrounding, gv.*
           FROM fips_to_id_mapping fim
                    JOIN grid_values gv
                         ON fim.lowest_var_highest_area_id = gv.lowest_var_highest_area_id
                             AND fim.nri_category = gv.nri_category
       ),
       hlr as (
           SELECT county.fips as geoid,
                  regional.region,
                  surrounding.surrounding surrounding,
                  county.nri_category,


                  CASE
                      WHEN county.nri_category not in ('coastal', 'drought', 'hurricane', 'landslide', 'riverine', 'winterweat')
                          THEN COALESCE(((
                                                 (1.0 / NULLIF(b_va_n, 0)) /
                                                 (
                                                         CASE WHEN county.nri_category not in ('coastal', 'drought', 'hurricane', 'landslide', 'riverine', 'winterweat') THEN COALESCE(1.0 / NULLIF(b_va_n, 0), 0) ELSE 0 END +
                                                         CASE  WHEN county.nri_category not in ('avalanche', 'earthquake', 'landslide', 'lightning', 'volcano', 'wildfire') THEN COALESCE(1.0 / NULLIF(b_va_r, 0), 0) ELSE 0 END +
                                                         CASE WHEN county.nri_category not in ('landslide') THEN COALESCE(1.0 / NULLIF(b_va_c, 0), 0) ELSE 0 END +
                                                         CASE WHEN county.nri_category not in ('avalanche', 'landslide', 'riverine') THEN COALESCE(1.0 / NULLIF(b_va_s, 0), 0) ELSE 0 END
                                                     )
                                             ) * b_av_n

                                            ), 0)
                      ELSE 0
                      END
                      +
                  CASE
                      WHEN county.nri_category not in ('avalanche', 'earthquake', 'landslide', 'lightning', 'volcano', 'wildfire')
                          THEN
                          COALESCE(((
                                            (1.0 / NULLIF(b_va_r, 0)) /
                                            (
                                                    CASE WHEN county.nri_category not in ('coastal', 'drought', 'hurricane', 'landslide', 'riverine', 'winterweat') THEN COALESCE(1.0 / NULLIF(b_va_n, 0), 0) ELSE 0 END +
                                                    CASE  WHEN county.nri_category not in ('avalanche', 'earthquake', 'landslide', 'lightning', 'volcano', 'wildfire') THEN COALESCE(1.0 / NULLIF(b_va_r, 0), 0) ELSE 0 END +
                                                    CASE WHEN county.nri_category not in ('landslide') THEN COALESCE(1.0 / NULLIF(b_va_c, 0), 0) ELSE 0 END +
                                                    CASE WHEN county.nri_category not in ('avalanche', 'landslide', 'riverine') THEN COALESCE(1.0 / NULLIF(b_va_s, 0), 0) ELSE 0 END
                                                )
                                        ) *
                                    b_av_r), 0)
                      ELSE 0
                      END
                      +
                  CASE
                      WHEN county.nri_category not in ('landslide')
                          THEN
                          COALESCE(((
                                            (1.0 / NULLIF(b_va_c, 0)) /
                                            (
                                                    CASE WHEN county.nri_category not in ('coastal', 'drought', 'hurricane', 'landslide', 'riverine', 'winterweat') THEN COALESCE(1.0 / NULLIF(b_va_n, 0), 0) ELSE 0 END +
                                                    CASE  WHEN county.nri_category not in ('avalanche', 'earthquake', 'landslide', 'lightning', 'volcano', 'wildfire') THEN COALESCE(1.0 / NULLIF(b_va_r, 0), 0) ELSE 0 END +
                                                    CASE WHEN county.nri_category not in ('landslide') THEN COALESCE(1.0 / NULLIF(b_va_c, 0), 0) ELSE 0 END +
                                                    CASE WHEN county.nri_category not in ('avalanche', 'landslide', 'riverine') THEN COALESCE(1.0 / NULLIF(b_va_s, 0), 0) ELSE 0 END
                                                )
                                        ) *
                                    b_av_c), 0)
                      ELSE 0
                      END
                      +
                  CASE
                      WHEN county.nri_category not in ('avalanche', 'landslide', 'riverine')
                          THEN
                          COALESCE(((
                                            (1.0 / NULLIF(b_va_s, 0)) /
                                            (
                                                    CASE WHEN county.nri_category not in ('coastal', 'drought', 'hurricane', 'landslide', 'riverine', 'winterweat') THEN COALESCE(1.0 / NULLIF(b_va_n, 0), 0) ELSE 0 END +
                                                    CASE  WHEN county.nri_category not in ('avalanche', 'earthquake', 'landslide', 'lightning', 'volcano', 'wildfire') THEN COALESCE(1.0 / NULLIF(b_va_r, 0), 0) ELSE 0 END +
                                                    CASE WHEN county.nri_category not in ('landslide') THEN COALESCE(1.0 / NULLIF(b_va_c, 0), 0) ELSE 0 END +
                                                    CASE WHEN county.nri_category not in ('avalanche', 'landslide', 'riverine') THEN COALESCE(1.0 / NULLIF(b_va_s, 0), 0) ELSE 0 END
                                                )
                                        ) *
                                    b_av_s), 0)
                      ELSE 0
                      END 	AS hlr_b,

                  CASE
                      WHEN county.nri_category not in ('coastal', 'drought', 'hurricane', 'landslide', 'riverine', 'winterweat')
                          THEN
                          COALESCE(((
                                            (1.0 / NULLIF(c_va_n, 0)) /
                                            (
                                                    CASE WHEN county.nri_category not in ('coastal', 'drought', 'hurricane', 'landslide', 'riverine', 'winterweat') THEN COALESCE(1.0 / NULLIF(c_va_n, 0), 0) ELSE 0 END +
                                                    CASE  WHEN county.nri_category not in ('avalanche', 'earthquake', 'landslide', 'lightning', 'volcano', 'wildfire') THEN COALESCE(1.0 / NULLIF(c_va_r, 0), 0) ELSE 0 END +
                                                    CASE WHEN county.nri_category not in ('landslide') THEN COALESCE(1.0 / NULLIF(c_va_c, 0), 0) ELSE 0 END +
                                                    CASE WHEN county.nri_category not in ('avalanche', 'landslide', 'riverine') THEN COALESCE(1.0 / NULLIF(c_va_s, 0), 0) ELSE 0 END
                                                )
                                        ) *
                                    c_av_n), 0)
                      ELSE 0
                      END
                      +
                  CASE
                      WHEN county.nri_category not in ('avalanche', 'earthquake', 'landslide', 'lightning', 'volcano', 'wildfire')
                          THEN
                          COALESCE(((
                                            (1.0 / NULLIF(c_va_r, 0)) /
                                            (
                                                    CASE WHEN county.nri_category not in ('coastal', 'drought', 'hurricane', 'landslide', 'riverine', 'winterweat') THEN COALESCE(1.0 / NULLIF(c_va_n, 0), 0) ELSE 0 END +
                                                    CASE  WHEN county.nri_category not in ('avalanche', 'earthquake', 'landslide', 'lightning', 'volcano', 'wildfire') THEN COALESCE(1.0 / NULLIF(c_va_r, 0), 0) ELSE 0 END +
                                                    CASE WHEN county.nri_category not in ('landslide') THEN COALESCE(1.0 / NULLIF(c_va_c, 0), 0) ELSE 0 END +
                                                    CASE WHEN county.nri_category not in ('avalanche', 'landslide', 'riverine') THEN COALESCE(1.0 / NULLIF(c_va_s, 0), 0) ELSE 0 END
                                                )
                                        ) *
                                    c_av_r), 0)
                      ELSE 0
                      END +
                  CASE
                      WHEN county.nri_category not in ('landslide')
                          THEN
                          COALESCE(((
                                            (1.0 / NULLIF(c_va_c, 0)) /
                                            (
                                                    CASE WHEN county.nri_category not in ('coastal', 'drought', 'hurricane', 'landslide', 'riverine', 'winterweat') THEN COALESCE(1.0 / NULLIF(c_va_n, 0), 0) ELSE 0 END +
                                                    CASE  WHEN county.nri_category not in ('avalanche', 'earthquake', 'landslide', 'lightning', 'volcano', 'wildfire') THEN COALESCE(1.0 / NULLIF(c_va_r, 0), 0) ELSE 0 END +
                                                    CASE WHEN county.nri_category not in ('landslide') THEN COALESCE(1.0 / NULLIF(c_va_c, 0), 0) ELSE 0 END +
                                                    CASE WHEN county.nri_category not in ('avalanche', 'landslide', 'riverine') THEN COALESCE(1.0 / NULLIF(c_va_s, 0), 0) ELSE 0 END
                                                )
                                        ) *
                                    c_av_c), 0)
                      ELSE 0
                      END +
                  CASE
                      WHEN county.nri_category not in ('avalanche', 'landslide', 'riverine')
                          THEN
                          COALESCE(((
                                            (1.0 / NULLIF(c_va_s, 0)) /
                                            (
                                                    CASE WHEN county.nri_category not in ('coastal', 'drought', 'hurricane', 'landslide', 'riverine', 'winterweat') THEN COALESCE(1.0 / NULLIF(c_va_n, 0), 0) ELSE 0 END +
                                                    CASE  WHEN county.nri_category not in ('avalanche', 'earthquake', 'landslide', 'lightning', 'volcano', 'wildfire') THEN COALESCE(1.0 / NULLIF(c_va_r, 0), 0) ELSE 0 END +
                                                    CASE WHEN county.nri_category not in ('landslide') THEN COALESCE(1.0 / NULLIF(c_va_c, 0), 0) ELSE 0 END +
                                                    CASE WHEN county.nri_category not in ('avalanche', 'landslide', 'riverine') THEN COALESCE(1.0 / NULLIF(c_va_s, 0), 0) ELSE 0 END
                                                )
                                        ) *
                                    c_av_s), 0)
                      ELSE 0
                      END AS hlr_c,

                  CASE
                      WHEN county.nri_category not in ('coastal', 'drought', 'hurricane', 'landslide', 'riverine', 'winterweat')
                          THEN
                          COALESCE(((
                                            (1.0 / NULLIF(p_va_n, 0)) /
                                            (
                                                    CASE WHEN county.nri_category not in ('coastal', 'drought', 'hurricane', 'landslide', 'riverine', 'winterweat') THEN COALESCE(1.0 / NULLIF(p_va_n, 0), 0) ELSE 0 END +
                                                    CASE  WHEN county.nri_category not in ('avalanche', 'earthquake', 'landslide', 'lightning', 'volcano', 'wildfire') THEN COALESCE(1.0 / NULLIF(p_va_r, 0), 0) ELSE 0 END +
                                                    CASE WHEN county.nri_category not in ('landslide') THEN COALESCE(1.0 / NULLIF(p_va_c, 0), 0) ELSE 0 END +
                                                    CASE WHEN county.nri_category not in ('avalanche', 'landslide', 'riverine') THEN COALESCE(1.0 / NULLIF(p_va_s, 0), 0) ELSE 0 END
                                                )
                                        ) *
                                    p_av_n), 0)
                      ELSE 0
                      END
                      +
                  CASE
                      WHEN county.nri_category not in ('avalanche', 'earthquake', 'landslide', 'lightning', 'volcano', 'wildfire')
                          THEN
                          COALESCE(((
                                            (1.0 / NULLIF(p_va_r, 0)) /
                                            (
                                                    CASE WHEN county.nri_category not in ('coastal', 'drought', 'hurricane', 'landslide', 'riverine', 'winterweat') THEN COALESCE(1.0 / NULLIF(p_va_n, 0), 0) ELSE 0 END +
                                                    CASE  WHEN county.nri_category not in ('avalanche', 'earthquake', 'landslide', 'lightning', 'volcano', 'wildfire') THEN COALESCE(1.0 / NULLIF(p_va_r, 0), 0) ELSE 0 END +
                                                    CASE WHEN county.nri_category not in ('landslide') THEN COALESCE(1.0 / NULLIF(p_va_c, 0), 0) ELSE 0 END +
                                                    CASE WHEN county.nri_category not in ('avalanche', 'landslide', 'riverine') THEN COALESCE(1.0 / NULLIF(p_va_s, 0), 0) ELSE 0 END
                                                )
                                        ) *
                                    p_av_r), 0)
                      ELSE 0
                      END +
                  CASE
                      WHEN county.nri_category not in ('landslide')
                          THEN
                          COALESCE(((
                                            (1.0 / NULLIF(p_va_c, 0)) /
                                            (
                                                    CASE WHEN county.nri_category not in ('coastal', 'drought', 'hurricane', 'landslide', 'riverine', 'winterweat') THEN COALESCE(1.0 / NULLIF(p_va_n, 0), 0) ELSE 0 END +
                                                    CASE  WHEN county.nri_category not in ('avalanche', 'earthquake', 'landslide', 'lightning', 'volcano', 'wildfire') THEN COALESCE(1.0 / NULLIF(p_va_r, 0), 0) ELSE 0 END +
                                                    CASE WHEN county.nri_category not in ('landslide') THEN COALESCE(1.0 / NULLIF(p_va_c, 0), 0) ELSE 0 END +
                                                    CASE WHEN county.nri_category not in ('avalanche', 'landslide', 'riverine') THEN COALESCE(1.0 / NULLIF(p_va_s, 0), 0) ELSE 0 END
                                                )
                                        ) *
                                    p_av_c), 0)
                      ELSE 0
                      END +
                  CASE
                      WHEN county.nri_category not in ('avalanche', 'landslide', 'riverine')
                          THEN
                          COALESCE(((
                                            (1.0 / NULLIF(p_va_s, 0)) /
                                            (
                                                    CASE WHEN county.nri_category not in ('coastal', 'drought', 'hurricane', 'landslide', 'riverine', 'winterweat') THEN COALESCE(1.0 / NULLIF(p_va_n, 0), 0) ELSE 0 END +
                                                    CASE  WHEN county.nri_category not in ('avalanche', 'earthquake', 'landslide', 'lightning', 'volcano', 'wildfire') THEN COALESCE(1.0 / NULLIF(p_va_r, 0), 0) ELSE 0 END +
                                                    CASE WHEN county.nri_category not in ('landslide') THEN COALESCE(1.0 / NULLIF(p_va_c, 0), 0) ELSE 0 END +
                                                    CASE WHEN county.nri_category not in ('avalanche', 'landslide', 'riverine') THEN COALESCE(1.0 / NULLIF(p_va_s, 0), 0) ELSE 0 END
                                                )
                                        ) *
                                    p_av_s), 0)
                      ELSE 0
                      END 	AS hlr_p




           FROM county
                    JOIN national
                         ON county.nri_category = national.nri_category
                    JOIN regional
                         ON county.nri_category = regional.nri_category
                             AND county.region = regional.region
                    JOIN surrounding
                         ON county.nri_category = surrounding.nri_category
                             AND county.fips = surrounding.surrounding
       )



select *
into tmp_hlr_swd_wt
from hlr



