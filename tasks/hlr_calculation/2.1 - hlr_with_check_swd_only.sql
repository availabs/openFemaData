with 
per_basis as (
    select * from public.tmp_per_basis_data_swd
),
lrpbs as (
    SELECT per_basis.*, RFLD_EXPB, RFLD_EXPA, RFLD_EXPPE,
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

--            coalesce(CASE
--                         WHEN nri_category IN ('wind')
--                             THEN fema_property_damage::float / NULLIF (SWND_EXPB, 0)
--                         WHEN nri_category IN ('wildfire')
--                             THEN (CASE WHEN fema_property_damage > WFIR_EXPB THEN WFIR_EXPB ELSE fema_property_damage END)::float / NULLIF (WFIR_EXPB, 0)
--                         WHEN nri_category IN ('tsunami')
--                             THEN fema_property_damage::float / NULLIF (TSUN_EXPB, 0)
--                         WHEN nri_category IN ('tornado')
--                             THEN fema_property_damage::float / NULLIF (TRND_EXPB, 0)
--                         WHEN nri_category IN ('riverine')
--                             THEN (CASE WHEN fema_property_damage > RFLD_EXPB THEN RFLD_EXPB ELSE fema_property_damage END)::float / NULLIF (RFLD_EXPB, 0)
--                         WHEN nri_category IN ('lightning')
--                             THEN fema_property_damage::float / NULLIF (LTNG_EXPB, 0)
--                         WHEN nri_category IN ('landslide')
--                             THEN fema_property_damage::float / NULLIF (LNDS_EXPB, 0)
--                         WHEN nri_category IN ('icestorm')
--                             THEN fema_property_damage::float / NULLIF (ISTM_EXPB, 0)
--                         WHEN nri_category IN ('hurricane')
--                             THEN fema_property_damage::float / NULLIF (HRCN_EXPB, 0)
--                         WHEN nri_category IN ('heatwave')
--                             THEN fema_property_damage::float / NULLIF (HWAV_EXPB, 0)
--                         WHEN nri_category IN ('hail')
--                             THEN fema_property_damage::float / NULLIF (HAIL_EXPB, 0)
--                         WHEN nri_category IN ('avalanche')
--                             THEN fema_property_damage::float / NULLIF (AVLN_EXPB, 0)
--                         WHEN nri_category IN ('coldwave')
--                             THEN fema_property_damage::float / NULLIF (CWAV_EXPB, 0)
--                         WHEN nri_category IN ('winterweat')
--                             THEN fema_property_damage::float / NULLIF (WNTW_EXPB, 0)
--                         WHEN nri_category IN ('volcano')
--                             THEN fema_property_damage::float / NULLIF (VLCN_EXPB, 0)
--                         WHEN nri_category IN ('coastal')
--                             THEN fema_property_damage::float / NULLIF (CFLD_EXPB, 0)
--                         END, 0) fema_building_loss_ratio_per_basis,

--            coalesce(CASE
--                         WHEN nri_category IN ('wind')
--                             THEN fema_crop_damage::float / NULLIF (SWND_expa, 0)
--                         WHEN nri_category IN ('wildfire')
--                             THEN fema_crop_damage::float / NULLIF (WFIR_expa, 0)
--                         WHEN nri_category IN ('tornado')
--                             THEN fema_crop_damage::float / NULLIF (TRND_expa, 0)
--                         WHEN nri_category IN ('riverine')
--                             THEN (CASE WHEN fema_crop_damage > RFLD_expa THEN RFLD_expa ELSE fema_crop_damage END)::float / NULLIF (RFLD_expa, 0)
--                         WHEN nri_category IN ('hurricane')
--                             THEN fema_crop_damage::float / NULLIF (HRCN_expa, 0)
--                         WHEN nri_category IN ('heatwave')
--                             THEN fema_crop_damage::float / NULLIF (HWAV_expa, 0)
--                         WHEN nri_category IN ('hail')
--                             THEN fema_crop_damage::float / NULLIF (HAIL_expa, 0)
--                         WHEN nri_category IN ('drought')
--                             THEN fema_crop_damage::float /NULLIF(DRGT_expa, 0)
--                         WHEN nri_category IN ('coldwave')
--                             THEN fema_crop_damage::float / NULLIF (CWAV_expa, 0)
--                         WHEN nri_category IN ('winterweat')
--                             THEN fema_crop_damage::float / NULLIF (WNTW_expa, 0)
--                         END, 0) fema_crop_loss_ratio_per_basis,

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

    FROM per_basis
             JOIN national_risk_index.nri_counties_november_2021 nri
                  ON per_basis.geoid = nri.stcofips),
       national as (
           select nri_category,
                  count (1),
                  avg (building_loss_ratio_per_basis) b_av_n,
                  avg (crop_loss_ratio_per_basis) c_av_n,
                  avg (population_loss_ratio_per_basis) p_av_n,
--                   avg (fema_building_loss_ratio_per_basis) f_av_n,
--                   avg (fema_crop_loss_ratio_per_basis) fc_av_n,
                  variance(building_loss_ratio_per_basis) b_va_n,
                  variance(crop_loss_ratio_per_basis) c_va_n,
                  variance(population_loss_ratio_per_basis) p_va_n
--                   variance(fema_building_loss_ratio_per_basis) f_va_n,
--                   variance(fema_crop_loss_ratio_per_basis) fc_va_n

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
--                   avg (fema_building_loss_ratio_per_basis) f_av_r,
--                   avg (fema_crop_loss_ratio_per_basis) fc_av_r,
                  variance(building_loss_ratio_per_basis) b_va_r,
                  variance(crop_loss_ratio_per_basis) c_va_r,
                  variance(population_loss_ratio_per_basis) p_va_r
--                   variance(fema_building_loss_ratio_per_basis) f_va_r,
--                   variance(fema_crop_loss_ratio_per_basis) fc_va_r

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
--                   avg (fema_building_loss_ratio_per_basis) f_av_r,
--                   avg (fema_crop_loss_ratio_per_basis) fc_av_r,
                  variance(building_loss_ratio_per_basis) b_va_r,
                  variance(crop_loss_ratio_per_basis) c_va_r,
                  variance(population_loss_ratio_per_basis) p_va_r
--                   variance(fema_building_loss_ratio_per_basis) f_va_r,
--                   variance(fema_crop_loss_ratio_per_basis) fc_va_r

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
                  count (1) as num_events,
                  avg (building_loss_ratio_per_basis) b_av_c,
                  avg (crop_loss_ratio_per_basis) c_av_c,
                  avg (population_loss_ratio_per_basis) p_av_c,
--                   avg (fema_building_loss_ratio_per_basis) f_av_c,
--                   avg (fema_crop_loss_ratio_per_basis) fc_av_c,
                  variance(building_loss_ratio_per_basis) b_va_c,
                  variance(crop_loss_ratio_per_basis) c_va_c,
                  variance(population_loss_ratio_per_basis) p_va_c
--                   variance(fema_building_loss_ratio_per_basis) f_va_c,
--                   variance(fema_crop_loss_ratio_per_basis) fc_va_c

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
                  count (1) as num_events,
                  avg (building_loss_ratio_per_basis) b_av_c,
                  avg (crop_loss_ratio_per_basis) c_av_c,
                  avg (population_loss_ratio_per_basis) p_av_c,
--                   avg (fema_building_loss_ratio_per_basis) f_av_c,
--                   avg (fema_crop_loss_ratio_per_basis) fc_av_c,
                  variance(building_loss_ratio_per_basis) b_va_c,
                  variance(crop_loss_ratio_per_basis) c_va_c,
                  variance(population_loss_ratio_per_basis) p_va_c
--                   variance(fema_building_loss_ratio_per_basis) f_va_c,
--                   variance(fema_crop_loss_ratio_per_basis) fc_va_c

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
                --  group by id
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
--                   avg (fema_building_loss_ratio_per_basis) f_av_s,
--                   avg (fema_crop_loss_ratio_per_basis) fc_av_s,
                  variance(building_loss_ratio_per_basis) b_va_s,
                  variance(crop_loss_ratio_per_basis) c_va_s,
                  variance(population_loss_ratio_per_basis) p_va_s
--                   variance(fema_building_loss_ratio_per_basis) f_va_s,
--                   variance(fema_crop_loss_ratio_per_basis) fc_va_s
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
                                                         COALESCE(1.0 / NULLIF(b_va_n, 0), 0) +
                                                         COALESCE(1.0 / NULLIF(b_va_r, 0), 0) +
                                                         COALESCE(1.0 / NULLIF(b_va_c, 0), 0) +
                                                         COALESCE(1.0 / NULLIF(b_va_s, 0), 0)
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
                                                    COALESCE(1.0 / NULLIF(b_va_n, 0), 0) +
                                                    COALESCE(1.0 / NULLIF(b_va_r, 0), 0) +
                                                    COALESCE(1.0 / NULLIF(b_va_c, 0), 0) +
                                                    COALESCE(1.0 / NULLIF(b_va_s, 0), 0)
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
                                                    COALESCE(1.0 / NULLIF(b_va_n, 0), 0) +
                                                    COALESCE(1.0 / NULLIF(b_va_r, 0), 0) +
                                                    COALESCE(1.0 / NULLIF(b_va_c, 0), 0) +
                                                    COALESCE(1.0 / NULLIF(b_va_s, 0), 0)
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
                                                    COALESCE(1.0 / NULLIF(b_va_n, 0), 0) +
                                                    COALESCE(1.0 / NULLIF(b_va_r, 0), 0) +
                                                    COALESCE(1.0 / NULLIF(b_va_c, 0), 0) +
                                                    COALESCE(1.0 / NULLIF(b_va_s, 0), 0)
                                                )
                                        ) *
                                    b_av_s), 0)
                      ELSE 0
                      END   AS hlr_b,

                  CASE
                      WHEN county.nri_category not in ('coastal', 'drought', 'hurricane', 'landslide', 'riverine', 'winterweat')
                          THEN
                          COALESCE(((
                                            (1.0 / NULLIF(c_va_n, 0)) /
                                            (
                                                    COALESCE(1.0 / NULLIF(c_va_n, 0), 0) +
                                                    COALESCE(1.0 / NULLIF(c_va_r, 0), 0) +
                                                    COALESCE(1.0 / NULLIF(c_va_c, 0), 0) +
                                                    COALESCE(1.0 / NULLIF(c_va_s, 0), 0)
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
                                                    COALESCE(1.0 / NULLIF(c_va_n, 0), 0) +
                                                    COALESCE(1.0 / NULLIF(c_va_r, 0), 0) +
                                                    COALESCE(1.0 / NULLIF(c_va_c, 0), 0) +
                                                    COALESCE(1.0 / NULLIF(c_va_s, 0), 0)
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
                                                    COALESCE(1.0 / NULLIF(c_va_n, 0), 0) +
                                                    COALESCE(1.0 / NULLIF(c_va_r, 0), 0) +
                                                    COALESCE(1.0 / NULLIF(c_va_c, 0), 0) +
                                                    COALESCE(1.0 / NULLIF(c_va_s, 0), 0)
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
                                                    COALESCE(1.0 / NULLIF(c_va_n, 0), 0) +
                                                    COALESCE(1.0 / NULLIF(c_va_r, 0), 0) +
                                                    COALESCE(1.0 / NULLIF(c_va_c, 0), 0) +
                                                    COALESCE(1.0 / NULLIF(c_va_s, 0), 0)
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
                                                    COALESCE(1.0 / NULLIF(p_va_n, 0), 0) +
                                                    COALESCE(1.0 / NULLIF(p_va_r, 0), 0) +
                                                    COALESCE(1.0 / NULLIF(p_va_c, 0), 0) +
                                                    COALESCE(1.0 / NULLIF(p_va_s, 0), 0)
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
                                                    COALESCE(1.0 / NULLIF(p_va_n, 0), 0) +
                                                    COALESCE(1.0 / NULLIF(p_va_r, 0), 0) +
                                                    COALESCE(1.0 / NULLIF(p_va_c, 0), 0) +
                                                    COALESCE(1.0 / NULLIF(p_va_s, 0), 0)
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
                                                    COALESCE(1.0 / NULLIF(p_va_n, 0), 0) +
                                                    COALESCE(1.0 / NULLIF(p_va_r, 0), 0) +
                                                    COALESCE(1.0 / NULLIF(p_va_c, 0), 0) +
                                                    COALESCE(1.0 / NULLIF(p_va_s, 0), 0)
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
                                                    COALESCE(1.0 / NULLIF(p_va_n, 0), 0) +
                                                    COALESCE(1.0 / NULLIF(p_va_r, 0), 0) +
                                                    COALESCE(1.0 / NULLIF(p_va_c, 0), 0) +
                                                    COALESCE(1.0 / NULLIF(p_va_s, 0), 0)
                                                )
                                        ) *
                                    p_av_s), 0)
                      ELSE 0
                      END   AS hlr_p

--                   CASE
--                       WHEN county.nri_category not in ('coastal', 'drought', 'hurricane', 'landslide', 'riverine', 'winterweat')
--                           THEN
--                           COALESCE(((
--                                             (1.0 / NULLIF(f_va_n, 0)) /
--                                             (
--                                                     COALESCE(1.0 / NULLIF(f_va_n, 0), 0) +
--                                                     COALESCE(1.0 / NULLIF(f_va_r, 0), 0) +
--                                                     COALESCE(1.0 / NULLIF(f_va_c, 0), 0) +
--                                                     COALESCE(1.0 / NULLIF(f_va_s, 0), 0)
--                                                 )
--                                         ) *
--                                     f_av_n), 0)
--                       ELSE 0
--                       END +
--                   CASE
--                       WHEN county.nri_category not in ('avalanche', 'earthquake', 'landslide', 'lightning', 'volcano', 'wildfire')
--                           THEN
--                           COALESCE(((
--                                             (1.0 / NULLIF(f_va_r, 0)) /
--                                             (
--                                                     COALESCE(1.0 / NULLIF(f_va_n, 0), 0) +
--                                                     COALESCE(1.0 / NULLIF(f_va_r, 0), 0) +
--                                                     COALESCE(1.0 / NULLIF(f_va_c, 0), 0) +
--                                                     COALESCE(1.0 / NULLIF(f_va_s, 0), 0)
--                                                 )
--                                         ) *
--                                     f_av_r), 0)
--                       ELSE 0
--                       END +
--                   CASE
--                       WHEN county.nri_category not in ('landslide')
--                           THEN
--                           COALESCE(((
--                                             (1.0 / NULLIF(f_va_c, 0)) /
--                                             (
--                                                     COALESCE(1.0 / NULLIF(f_va_n, 0), 0) +
--                                                     COALESCE(1.0 / NULLIF(f_va_r, 0), 0) +
--                                                     COALESCE(1.0 / NULLIF(f_va_c, 0), 0) +
--                                                     COALESCE(1.0 / NULLIF(f_va_s, 0), 0)
--                                                 )
--                                         ) *
--                                     f_av_c), 0)
--                       ELSE 0
--                       END +
--                   CASE
--                       WHEN county.nri_category not in ('avalanche', 'landslide', 'riverine')
--                           THEN
--                           COALESCE(((
--                                             (1.0 / NULLIF(f_va_s, 0)) /
--                                             (
--                                                     COALESCE(1.0 / NULLIF(f_va_n, 0), 0) +
--                                                     COALESCE(1.0 / NULLIF(f_va_r, 0), 0) +
--                                                     COALESCE(1.0 / NULLIF(f_va_c, 0), 0) +
--                                                     COALESCE(1.0 / NULLIF(f_va_s, 0), 0)
--                                                 )
--                                         ) *
--                                     f_av_s), 0)
--                       ELSE 0
--                       END AS hlr_f,

--                   CASE
--                       WHEN county.nri_category not in ('coastal', 'drought', 'hurricane', 'landslide', 'riverine', 'winterweat')
--                           THEN
--                           COALESCE(((
--                                             (1.0 / NULLIF(fc_va_n, 0)) /
--                                             (
--                                                     COALESCE(1.0 / NULLIF(fc_va_n, 0), 0) +
--                                                     COALESCE(1.0 / NULLIF(fc_va_r, 0), 0) +
--                                                     COALESCE(1.0 / NULLIF(fc_va_c, 0), 0) +
--                                                     COALESCE(1.0 / NULLIF(fc_va_s, 0), 0)
--                                                 )
--                                         ) *
--                                     fc_av_n), 0)
--                       ELSE 0
--                       END +
--                   CASE
--                       WHEN county.nri_category not in ('avalanche', 'earthquake', 'landslide', 'lightning', 'volcano', 'wildfire')
--                           THEN
--                           COALESCE(((
--                                             (1.0 / NULLIF(fc_va_r, 0)) /
--                                             (
--                                                     COALESCE(1.0 / NULLIF(fc_va_n, 0), 0) +
--                                                     COALESCE(1.0 / NULLIF(fc_va_r, 0), 0) +
--                                                     COALESCE(1.0 / NULLIF(fc_va_c, 0), 0) +
--                                                     COALESCE(1.0 / NULLIF(fc_va_s, 0), 0)
--                                                 )
--                                         ) *
--                                     fc_av_r), 0)
--                       ELSE 0
--                       END +
--                   CASE
--                       WHEN county.nri_category not in ('landslide')
--                           THEN
--                           COALESCE(((
--                                             (1.0 / NULLIF(fc_va_c, 0)) /
--                                             (
--                                                     COALESCE(1.0 / NULLIF(fc_va_n, 0), 0) +
--                                                     COALESCE(1.0 / NULLIF(fc_va_r, 0), 0) +
--                                                     COALESCE(1.0 / NULLIF(fc_va_c, 0), 0) +
--                                                     COALESCE(1.0 / NULLIF(fc_va_s, 0), 0)
--                                                 )
--                                         ) *
--                                     fc_av_c), 0)
--                       ELSE 0
--                       END +
--                   CASE
--                       WHEN county.nri_category not in ('avalanche', 'landslide', 'riverine')
--                           THEN
--                           COALESCE(((
--                                             (1.0 / NULLIF(fc_va_s, 0)) /
--                                             (
--                                                     COALESCE(1.0 / NULLIF(fc_va_n, 0), 0) +
--                                                     COALESCE(1.0 / NULLIF(fc_va_r, 0), 0) +
--                                                     COALESCE(1.0 / NULLIF(fc_va_c, 0), 0) +
--                                                     COALESCE(1.0 / NULLIF(fc_va_s, 0), 0)
--                                                 )
--                                         ) *
--                                     fc_av_s), 0)
--                       ELSE 0
--                       END  AS hlr_fc

           FROM county
                    JOIN national
                         ON county.nri_category = national.nri_category
                    JOIN regional
                         ON county.nri_category = regional.nri_category
                             AND county.region = regional.region
                    JOIN surrounding
                         ON county.nri_category = surrounding.nri_category
                             AND county.fips = surrounding.surrounding
       ),
       nri_summary as (
    select 
           stcofips,
unnest(array['coastal', 'coldwave', 'hurricane',  'heatwave', 'hail','tornado', 'riverine', 'lightning','landslide',  'icestorm', 
 'wind', 'wildfire',  'winterweat', 'tsunami','avalanche',  'volcano'
                ]) as nri_category,
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
]) as nri_property,
           unnest(array[
    sum(CFLD_hlrb), 
    sum(CWAV_hlrb), 
    sum(HRCN_hlrb),
    sum(HWAV_hlrb),
    sum(HAIL_hlrb), 
    sum(TRND_hlrb ), 
    sum(RFLD_hlrb),
    sum(LTNG_hlrb ), 
    sum(LNDS_hlrb), 
    sum(ISTM_hlrb ),
    sum(SWND_hlrb),
    sum(WFIR_hlrb ), 
    sum(WNTW_hlrb ), 
    sum(TSUN_hlrb ), 
    sum(AVLN_hlrb), 
    sum(VLCN_hlrb)
]) as nri_hlr_b,
    unnest(array[
    sum( CFLD_EXPB ), 
    sum( CWAV_EXPB ), 
    sum( HRCN_EXPB ),
    sum(HWAV_EXPB),
    sum(HAIL_EXPB  ), 
    sum( TRND_EXPB ), 
    sum( RFLD_EXPB ),
    sum(LTNG_EXPB  ), 
    sum(LNDS_EXPB ), 
    sum( ISTM_EXPB ),
    sum( SWND_EXPB  ),
    sum( WFIR_EXPB  ), 
    sum( WNTW_EXPB ), 
    sum( TSUN_EXPB), 
    sum( AVLN_EXPB ), 
    sum(VLCN_EXPB  )
]) as nri_exp_b,
           unnest(array[
    sum( CFLD_AFREQ),
    sum( CWAV_AFREQ), 
    sum( HRCN_AFREQ),
    sum( HWAV_AFREQ),
    sum( HAIL_AFREQ), 
    sum( TRND_AFREQ), 
    sum( RFLD_AFREQ),
    sum( LTNG_AFREQ), 
    sum( LNDS_AFREQ), 
    sum(ISTM_AFREQ),
    sum( SWND_AFREQ),
    sum( WFIR_AFREQ), 
    sum( WNTW_AFREQ), 
    sum(TSUN_AFREQ), 
    sum(AVLN_AFREQ), 
    sum( VLCN_AFREQ)
]) as nri_freq
FROM national_risk_index.nri_counties_november_2021 nri
group by stcofips
),
hlr_parts as 
(
 select
    county.fips as geoid,
    county.num_events,
    regional.region,
    surrounding.surrounding surrounding,
    county.nri_category,
    (
                
                COALESCE(1.0 / NULLIF(b_va_r, 0), 0) +
                COALESCE(1.0 / NULLIF(b_va_c, 0), 0) +
                COALESCE(1.0 / NULLIF(b_va_s, 0), 0)
    ) as wt_denom,
    b_va_n,
    b_av_n,
    b_va_r,
    b_av_r,
    b_va_s,
    b_av_s,
    b_va_c,
    b_av_c
    
 FROM county
                    JOIN national
                         ON county.nri_category = national.nri_category
                    JOIN regional
                         ON county.nri_category = regional.nri_category
                             AND county.region = regional.region
                    JOIN surrounding
                         ON county.nri_category = surrounding.nri_category
                             AND county.fips = surrounding.surrounding

),
swd_summary as (
    select  
        substring(geoid,1,5) as geoid, event_type_formatted, sum(property_damage) as property_damage, 
        round(sum(property_damage)/23) as property_damage_annual
    from severe_weather_new.details 
    where year >=1996 and year <=2019
    group by 1,2
),
hlr_details as (
select a.geoid,  
    a.nri_category,
    a.num_events,
    (1.0 / NULLIF(b_va_n, 0)) / nullif(wt_denom,0) as b_wt_n,
    COALESCE(((1.0 / NULLIF(b_va_n, 0)) / nullif(wt_denom,0) ) * b_av_n, 0) as b_hlr_n,
    
    (1.0 / NULLIF(b_va_r, 0)) / nullif(wt_denom,0) as b_wt_r,
    COALESCE(((1.0 / NULLIF(b_va_r, 0)) / nullif(wt_denom,0) ) * b_av_r, 0) as b_hlr_r,
    
    (1.0 / NULLIF(b_va_s, 0)) / nullif(wt_denom,0) as b_wt_s,
    COALESCE(((1.0 / NULLIF(b_va_s, 0)) / nullif(wt_denom,0) ) * b_av_s, 0) as b_hlr_s,
    
    (1.0 / NULLIF(b_va_c, 0)) / nullif(wt_denom,0) as b_wt_c,
    COALESCE(((1.0 / NULLIF(b_va_c, 0)) / nullif(wt_denom,0) ) * b_av_c, 0) as b_hlt_c,
    
    (  
   
        COALESCE(((1.0 / NULLIF(b_va_r, 0)) / nullif(wt_denom,0) ) * b_av_r, 0) +
        COALESCE(((1.0 / NULLIF(b_va_s, 0)) / nullif(wt_denom,0) ) * b_av_s, 0) +
        COALESCE(((1.0 / NULLIF(b_va_c, 0)) / nullif(wt_denom,0) ) * b_av_c, 0) 
    
    ) as hlr,
    b.nri_hlr_b,
    round(b.nri_hlr_b * b.nri_exp_b * nri_freq) as nri_cost,
    b.nri_exp_b,
    b.nri_freq,
    c.property_damage_annual
   

    
from hlr_parts as a
right outer join nri_summary  as b on  a.geoid = b.stcofips and a.nri_category = b.nri_category
join swd_summary as c on 
c.geoid = a.geoid and c.event_type_formatted = a.nri_category

WHERE a.nri_category = 'coastal'
order by nri_cost desc
)
select geoid, 
	num_events,
	nri_hlr_b, hlr, 
	nri_cost, hlr*nri_freq*nri_exp_b as avail_cost, 
	nri_cost - hlr*nri_freq*nri_exp_b as diff   
from hlr_details
order by 7 desc

