lrpbs as (SELECT swd.*,
                      CASE
                          WHEN nri_category IN ('wind')
                              THEN swd_property_damage/NULLIF(SWND_EXPB, 0)
                          WHEN nri_category IN ('wildfire')
                              THEN swd_property_damage/NULLIF(WFIR_EXPB, 0)
                          WHEN nri_category IN ('tsunami')
                              THEN swd_property_damage/NULLIF(TSUN_EXPB, 0)
                          WHEN nri_category IN ('tornado')
                              THEN swd_property_damage/NULLIF(TRND_EXPB, 0)
                          WHEN nri_category IN ('riverine')
                              THEN swd_property_damage/NULLIF(RFLD_EXPB, 0)
                          WHEN nri_category IN ('lightning')
                              THEN swd_property_damage/NULLIF(LTNG_EXPB, 0)
                          WHEN nri_category IN ('landslide')
                              THEN swd_property_damage/NULLIF(LNDS_EXPB, 0)
                          WHEN nri_category IN ('icestorm')
                              THEN swd_property_damage/NULLIF(ISTM_EXPB, 0)
                          WHEN nri_category IN ('hurricane')
                              THEN swd_property_damage/NULLIF(HRCN_EXPB, 0)
                          WHEN nri_category IN ('heatwave')
                              THEN swd_property_damage/NULLIF(HWAV_EXPB, 0)
                          WHEN nri_category IN ('hail')
                              THEN swd_property_damage/NULLIF(HAIL_EXPB, 0)
                          --            WHEN nri_category IN ('drought')
--                THEN swd_property_damage/NULLIF(DRGT_EXPB, 0)
                          WHEN nri_category IN ('avalanche')
                              THEN swd_property_damage/NULLIF(AVLN_EXPB, 0)
                          WHEN nri_category IN ('coldwave')
                              THEN swd_property_damage/NULLIF(CWAV_EXPB, 0)
                          WHEN nri_category IN ('winterweat')
                              THEN swd_property_damage/NULLIF(WNTW_EXPB, 0)
                          WHEN nri_category IN ('volcano')
                              THEN swd_property_damage/NULLIF(VLCN_EXPB, 0)
                          WHEN nri_category IN ('coastal')
                              THEN swd_property_damage/NULLIF(CFLD_EXPB, 0)
                          END building_loss_ratio_per_basis,







                      CASE
                          WHEN nri_category IN ('wind')
                              THEN fema_property_damage/NULLIF(SWND_EXPB, 0)
                          WHEN nri_category IN ('wildfire')
                              THEN fema_property_damage/NULLIF(WFIR_EXPB, 0)
                          WHEN nri_category IN ('tsunami')
                              THEN fema_property_damage/NULLIF(TSUN_EXPB, 0)
                          WHEN nri_category IN ('tornado')
                              THEN fema_property_damage/NULLIF(TRND_EXPB, 0)
                          WHEN nri_category IN ('riverine')
                              THEN fema_property_damage/NULLIF(RFLD_EXPB, 0)
                          WHEN nri_category IN ('lightning')
                              THEN fema_property_damage/NULLIF(LTNG_EXPB, 0)
                          WHEN nri_category IN ('landslide')
                              THEN fema_property_damage/NULLIF(LNDS_EXPB, 0)
                          WHEN nri_category IN ('icestorm')
                              THEN fema_property_damage/NULLIF(ISTM_EXPB, 0)
                          WHEN nri_category IN ('hurricane')
                              THEN fema_property_damage/NULLIF(HRCN_EXPB, 0)
                          WHEN nri_category IN ('heatwave')
                              THEN fema_property_damage/NULLIF(HWAV_EXPB, 0)
                          WHEN nri_category IN ('hail')
                              THEN fema_property_damage/NULLIF(HAIL_EXPB, 0)
                          --            WHEN nri_category IN ('drought')
--                THEN fema_property_damage/NULLIF(DRGT_EXPB, 0)
                          WHEN nri_category IN ('avalanche')
                              THEN fema_property_damage/NULLIF(AVLN_EXPB, 0)
                          WHEN nri_category IN ('coldwave')
                              THEN fema_property_damage/NULLIF(CWAV_EXPB, 0)
                          WHEN nri_category IN ('winterweat')
                              THEN fema_property_damage/NULLIF(WNTW_EXPB, 0)
                          WHEN nri_category IN ('volcano')
                              THEN fema_property_damage/NULLIF(VLCN_EXPB, 0)
                          WHEN nri_category IN ('coastal')
                              THEN fema_property_damage/NULLIF(CFLD_EXPB, 0)
                          END fema_building_loss_ratio_per_basis,





                      CASE
                          WHEN nri_category IN ('wind')
                              THEN swd_crop_damage/NULLIF(SWND_EXPA, 0)
                          WHEN nri_category IN ('wildfire')
                              THEN swd_crop_damage/NULLIF(WFIR_EXPA, 0)
                          --            WHEN nri_category IN ('tsunami')
--                THEN swd_crop_damage/NULLIF(TSUN_EXPA, 0)
                          WHEN nri_category IN ('tornado')
                              THEN swd_crop_damage/NULLIF(TRND_EXPA, 0)
                          WHEN nri_category IN ('riverine')
                              THEN swd_crop_damage/NULLIF(RFLD_EXPA, 0)
                          --            WHEN nri_category IN ('lightning')
--                THEN swd_crop_damage/NULLIF(LTNG_EXPA, 0)
--            WHEN nri_category IN ('landslide')
--                THEN swd_crop_damage/NULLIF(LNDS_EXPA, 0)
--            WHEN nri_category IN ('icestorm')
--                THEN swd_crop_damage/NULLIF(ISTM_EXPA, 0)
                          WHEN nri_category IN ('hurricane')
                              THEN swd_crop_damage/NULLIF(HRCN_EXPA, 0)
                          WHEN nri_category IN ('heatwave')
                              THEN swd_crop_damage/NULLIF(HWAV_EXPA, 0)
                          WHEN nri_category IN ('hail')
                              THEN swd_crop_damage/NULLIF(HAIL_EXPA, 0)
                          WHEN nri_category IN ('drought')
                              THEN swd_crop_damage/NULLIF(DRGT_EXPA, 0)
                          --            WHEN nri_category IN ('avalanche')
--                THEN swd_crop_damage/NULLIF(AVLN_EXPA, 0)
                          WHEN nri_category IN ('coldwave')
                              THEN swd_crop_damage/NULLIF(CWAV_EXPA, 0)
                          WHEN nri_category IN ('winterweat')
                              THEN swd_crop_damage/NULLIF(WNTW_EXPA, 0)
                          --            WHEN nri_category IN ('volcano')
--                THEN swd_crop_damage/NULLIF(VLCN_EXPA, 0)
--            WHEN nri_category IN ('coastal')
--                THEN swd_crop_damage/NULLIF(CFLD_EXPA, 0)
                          END crop_loss_ratio_per_basis,





                      CASE
                          WHEN nri_category IN ('wind')
                              THEN fatalities_dollar_value/NULLIF(SWND_EXPPE, 0)
                          WHEN nri_category IN ('wildfire')
                              THEN fatalities_dollar_value/NULLIF(WFIR_EXPPE, 0)
                          WHEN nri_category IN ('tsunami')
                              THEN fatalities_dollar_value/NULLIF(TSUN_EXPPE, 0)
                          WHEN nri_category IN ('tornado')
                              THEN fatalities_dollar_value/NULLIF(TRND_EXPPE, 0)
                          WHEN nri_category IN ('riverine')
                              THEN fatalities_dollar_value/NULLIF(RFLD_EXPPE, 0)
                          WHEN nri_category IN ('lightning')
                              THEN fatalities_dollar_value/NULLIF(LTNG_EXPPE, 0)
                          WHEN nri_category IN ('landslide')
                              THEN fatalities_dollar_value/NULLIF(LNDS_EXPPE, 0)
                          WHEN nri_category IN ('icestorm')
                              THEN fatalities_dollar_value/NULLIF(ISTM_EXPPE, 0)
                          WHEN nri_category IN ('hurricane')
                              THEN fatalities_dollar_value/NULLIF(HRCN_EXPPE, 0)
                          WHEN nri_category IN ('heatwave')
                              THEN fatalities_dollar_value/NULLIF(HWAV_EXPPE, 0)
                          WHEN nri_category IN ('hail')
                              THEN fatalities_dollar_value/NULLIF(HAIL_EXPPE, 0)
                          --            WHEN nri_category IN ('drought')
--                THEN fatalities_dollar_value/NULLIF(DRGT_EXPPE, 0)
                          WHEN nri_category IN ('avalanche')
                              THEN fatalities_dollar_value/NULLIF(AVLN_EXPPE, 0)
                          WHEN nri_category IN ('coldwave')
                              THEN fatalities_dollar_value/NULLIF(CWAV_EXPPE, 0)
                          WHEN nri_category IN ('winterweat')
                              THEN fatalities_dollar_value/NULLIF(WNTW_EXPPE, 0)
                          WHEN nri_category IN ('volcano')
                              THEN fatalities_dollar_value/NULLIF(VLCN_EXPPE, 0)
                          WHEN nri_category IN ('coastal')
                              THEN fatalities_dollar_value/NULLIF(CFLD_EXPPE, 0)
                          END population_loss_ratio_per_basis
               FROM tmp_calculations swd
                        JOIN national_risk_index.nri_counties_november_2021 nri
                             ON substring(swd.geoid, 1, 5) = nri.stcofips),

     national as (select nri_category,
                         count(1),
                         avg(Least(COALESCE(building_loss_ratio_per_basis, 0), 1))           b_av_n,
                         avg(Least(COALESCE(crop_loss_ratio_per_basis, 0), 1))               c_av_n,
                         avg(Least(COALESCE(population_loss_ratio_per_basis, 0), 1))         p_av_n,
                         avg(Least(COALESCE(fema_building_loss_ratio_per_basis, 0), 1))      f_av_n,

                         variance(Least(COALESCE(building_loss_ratio_per_basis, 0), 1))      b_va_n,
                         variance(Least(COALESCE(crop_loss_ratio_per_basis, 0), 1))          c_va_n,
                         variance(Least(COALESCE(population_loss_ratio_per_basis, 0), 1))    p_va_n,
                         variance(Least(COALESCE(fema_building_loss_ratio_per_basis, 0), 1)) f_va_n

                  from lrpbs as a
                           join severe_weather_new.fips_to_regions_and_surrounding_counties_hurricane as b
                                on b.fips = a.geoid
                  WHERE nri_category is not null
                  group by 1
                  order by 1),
     regional as (select region,
                         nri_category,
                         count(1),
                         avg(Least(COALESCE(building_loss_ratio_per_basis, 0), 1))           b_av_r,
                         avg(Least(COALESCE(crop_loss_ratio_per_basis, 0), 1))               c_av_r,
                         avg(Least(COALESCE(population_loss_ratio_per_basis, 0), 1))         p_av_r,
                         avg(Least(COALESCE(fema_building_loss_ratio_per_basis, 0), 1))      f_av_r,

                         variance(Least(COALESCE(building_loss_ratio_per_basis, 0), 1))      b_va_r,
                         variance(Least(COALESCE(crop_loss_ratio_per_basis, 0), 1))          c_va_r,
                         variance(Least(COALESCE(population_loss_ratio_per_basis, 0), 1))    p_va_r,
                         variance(Least(COALESCE(fema_building_loss_ratio_per_basis, 0), 1)) f_va_r

                  from lrpbs as a
                           join severe_weather_new.fips_to_regions_and_surrounding_counties_hurricane as b
                                on b.fips = a.geoid
                  WHERE nri_category is not null
                  group by 1, 2
                  order by 1, 2),
     county as (select LEFT(b.fips, 5)                                                     fips,
                       nri_category,
                       count(1),
                       avg(Least(COALESCE(building_loss_ratio_per_basis, 0), 1))           b_av_c,
                       avg(Least(COALESCE(crop_loss_ratio_per_basis, 0), 1))               c_av_c,
                       avg(Least(COALESCE(population_loss_ratio_per_basis, 0), 1))         p_av_c,
                       avg(Least(COALESCE(fema_building_loss_ratio_per_basis, 0), 1))      f_av_c,

                       variance(Least(COALESCE(building_loss_ratio_per_basis, 0), 1))      b_va_c,
                       variance(Least(COALESCE(crop_loss_ratio_per_basis, 0), 1))          c_va_c,
                       variance(Least(COALESCE(population_loss_ratio_per_basis, 0), 1))    p_va_c,
                       variance(Least(COALESCE(fema_building_loss_ratio_per_basis, 0), 1)) f_va_c

                from lrpbs as a
                         join severe_weather_new.fips_to_regions_and_surrounding_counties_hurricane as b
                              on b.fips = a.geoid
                WHERE nri_category is not null
                group by 1, 2
                order by 1, 2),

     surrounding as (select surrounding_counties                                                fips,
                            nri_category,
                            count(1),
                            avg(Least(COALESCE(building_loss_ratio_per_basis, 0), 1))           b_av_s,
                            avg(Least(COALESCE(crop_loss_ratio_per_basis, 0), 1))               c_av_s,
                            avg(Least(COALESCE(population_loss_ratio_per_basis, 0), 1))         p_av_s,
                            avg(Least(COALESCE(fema_building_loss_ratio_per_basis, 0), 1))      f_av_s,

                            variance(Least(COALESCE(building_loss_ratio_per_basis, 0), 1))      b_va_s,
                            variance(Least(COALESCE(crop_loss_ratio_per_basis, 0), 1))          c_va_s,
                            variance(Least(COALESCE(population_loss_ratio_per_basis, 0), 1))    p_va_s,
                            variance(Least(COALESCE(fema_building_loss_ratio_per_basis, 0), 1)) f_va_s

                     from lrpbs as a
                              join severe_weather_new.fips_to_regions_and_surrounding_counties_hurricane as b
                                   on b.fips = a.geoid
                     WHERE nri_category is not null
                     group by 1, 2
                     order by 1, 2)

SELECT mapping.fips,
       mapping.region,
       mapping.surrounding_counties,
       county.*,
       national.*,
       regional.*,
       surrounding.*,

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
                 f_av_s), 0) AS hlr_f


FROM severe_weather_new.fips_to_regions_and_surrounding_counties_hurricane mapping
         JOIN county
              on county.fips = mapping.fips
         LEFT JOIN national
                   ON county.nri_category = national.nri_category
         LEFT JOIN regional
                   ON mapping.region = regional.region AND county.nri_category = regional.nri_category
         LEFT JOIN surrounding
                   ON mapping.surrounding_counties = surrounding.fips and county.nri_category = surrounding.nri_category


