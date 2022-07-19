with
    aggregation as (SELECT
                        begin_date_time,
                        substring(geoid, 1, 5) geoid,
                        event_type_formatted,
                        sum(property_damage)                        as swd_property_damage,
                        sum(crop_damage) 							 as swd_crop_damage,
                        sum(injuries_direct) injuries_direct,
                        sum(injuries_indirect) injuries_indirect,
                        sum(deaths_direct) deaths_direct,
                        sum(deaths_indirect) deaths_indirect
                    FROM severe_weather_new.details sw
                    WHERE year >= 1986 and year <= 2017
                      AND ((year <= 2010 and magnitude >= 0.75) OR (year >= 2010 and magnitude >= 1))
                      AND substring(geoid, 1, 5) not like '*'
                    group by 1, 2, 3
                    order by 1, 2),
    tmp_calculations as (

        select 'agg' src, event_type_formatted nri_category, geoid,
               swd_property_damage, swd_crop_damage

        from aggregation
        order by 1, 2, 3
    ),
    lrpbs as (
        SELECT tmp_calculations.*,
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
                   END crop_loss_ratio_per_basis

        FROM tmp_calculations
                 JOIN national_risk_index.nri_counties_november_2021 nri
                      ON tmp_calculations.geoid = nri.stcofips),
    national as (
        select nri_category,
               count (1),
               avg (Least(COALESCE (building_loss_ratio_per_basis, 0), 1)) b_av_n,
               avg (Least(COALESCE (crop_loss_ratio_per_basis, 0), 1)) c_av_n,

               variance(Least(COALESCE (building_loss_ratio_per_basis, 0), 1)) b_va_n,
               variance(Least(COALESCE (crop_loss_ratio_per_basis, 0), 1)) c_va_n

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
               variance(Least(COALESCE (building_loss_ratio_per_basis, 0), 1)) b_va_r,
               variance(Least(COALESCE (crop_loss_ratio_per_basis, 0), 1)) c_va_r

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
               variance(Least(COALESCE (building_loss_ratio_per_basis, 0), 1)) b_va_r,
               variance(Least(COALESCE (crop_loss_ratio_per_basis, 0), 1)) c_va_r

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
               variance(Least(COALESCE (building_loss_ratio_per_basis, 0), 1)) b_va_c,
               variance(Least(COALESCE (crop_loss_ratio_per_basis, 0), 1)) c_va_c

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
               variance(Least(COALESCE (building_loss_ratio_per_basis, 0), 1)) b_va_c,
               variance(Least(COALESCE (crop_loss_ratio_per_basis, 0), 1)) c_va_c

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
               variance(Least(COALESCE (building_loss_ratio_per_basis, 0), 1)) b_va_s,
               variance(Least(COALESCE (crop_loss_ratio_per_basis, 0), 1)) c_va_s

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
               variance(Least(COALESCE (building_loss_ratio_per_basis, 0), 1)) b_va_s,
               variance(Least(COALESCE (crop_loss_ratio_per_basis, 0), 1)) c_va_s
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
                         c_av_s), 0) AS hlr_c




        FROM county
                 JOIN national
                      ON county.nri_category = national.nri_category
                 JOIN regional
                      ON county.nri_category = regional.nri_category
                          AND county.fips = regional.geoid
                 JOIN surrounding
                      ON county.nri_category = surrounding.nri_category
                          AND county.fips = surrounding.geoid)

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
           END) swd_crop

FROM hlr
         JOIN national_risk_index.nri_counties_november_2021
              ON geoid = stcofips
GROUP BY nri_category
ORDER BY nri_category



