with   lrpbs as (
    SELECT pb.*,
           CASE
               WHEN ctype = 'buildings'
                   THEN
                   coalesce(CASE
                                WHEN nri_category IN ('wind')
                                    THEN (CASE WHEN damage_adjusted > SWND_EXPB THEN SWND_EXPB ELSE damage_adjusted END)::float / NULLIF (SWND_EXPB, 0)
                                WHEN nri_category IN ('wildfire')
                                    THEN (CASE WHEN damage_adjusted > WFIR_EXPB THEN WFIR_EXPB ELSE damage_adjusted END)::float / NULLIF (WFIR_EXPB, 0)
                                WHEN nri_category IN ('tsunami')
                                    THEN damage_adjusted::float / NULLIF (TSUN_EXPB, 0)
                                WHEN nri_category IN ('tornado')
                                    THEN (CASE WHEN damage_adjusted > TRND_EXPB THEN TRND_EXPB ELSE damage_adjusted END)::float / NULLIF (TRND_EXPB, 0)
                                WHEN nri_category IN ('riverine')
                                    THEN (CASE WHEN damage_adjusted > RFLD_EXPB THEN RFLD_EXPB ELSE damage_adjusted END)::float / NULLIF (RFLD_EXPB, 0)
                                WHEN nri_category IN ('lightning')
                                    THEN damage_adjusted::float / NULLIF (LTNG_EXPB, 0)
                                WHEN nri_category IN ('landslide')
                                    THEN damage_adjusted::float / NULLIF (LNDS_EXPB, 0)
                                WHEN nri_category IN ('icestorm')
                                    THEN damage_adjusted::float / NULLIF (ISTM_EXPB, 0)
                                WHEN nri_category IN ('hurricane')
                                    THEN damage_adjusted::float / NULLIF (HRCN_EXPB, 0)
                                WHEN nri_category IN ('heatwave')
                                    THEN damage_adjusted::float / NULLIF (HWAV_EXPB, 0)
                                WHEN nri_category IN ('hail')
                                    THEN damage_adjusted::float / NULLIF (HAIL_EXPB, 0)
                                WHEN nri_category IN ('avalanche')
                                    THEN (CASE WHEN damage_adjusted > AVLN_EXPB THEN AVLN_EXPB ELSE damage_adjusted END)::float / NULLIF (AVLN_EXPB, 0)
                                WHEN nri_category IN ('coldwave')
                                    THEN damage_adjusted::float / NULLIF (CWAV_EXPB, 0)
                                WHEN nri_category IN ('winterweat')
                                    THEN damage_adjusted::float / NULLIF (WNTW_EXPB, 0)
                                WHEN nri_category IN ('volcano')
                                    THEN damage_adjusted::float / NULLIF (VLCN_EXPB, 0)
                                WHEN nri_category IN ('coastal')
                                    THEN (CASE WHEN damage_adjusted > CFLD_EXPB THEN CFLD_EXPB ELSE damage_adjusted END)::float / NULLIF (CFLD_EXPB, 0)
                                END, 0)
               WHEN ctype = 'crop'
                   THEN
                   coalesce(CASE
                                WHEN nri_category IN ('wind')
                                    THEN (CASE WHEN damage_adjusted > SWND_EXPA THEN SWND_EXPA ELSE damage_adjusted END)::float / NULLIF (SWND_EXPA, 0)
                                WHEN nri_category IN ('wildfire')
                                    THEN (CASE WHEN damage_adjusted > WFIR_EXPA THEN WFIR_EXPA ELSE damage_adjusted END)::float / NULLIF (WFIR_EXPA, 0)
                                WHEN nri_category IN ('tornado')
                                    THEN (CASE WHEN damage_adjusted > TRND_EXPA THEN TRND_EXPA ELSE damage_adjusted END)::float / NULLIF (TRND_EXPA, 0)
                                WHEN nri_category IN ('riverine')
                                    THEN (CASE WHEN damage_adjusted > RFLD_EXPA THEN RFLD_EXPA ELSE damage_adjusted END)::float / NULLIF (RFLD_EXPA, 0)
                                WHEN nri_category IN ('hurricane')
                                    THEN (CASE WHEN damage_adjusted > HRCN_EXPA THEN HRCN_EXPA ELSE damage_adjusted END)::float / NULLIF (HRCN_EXPA, 0)
                                WHEN nri_category IN ('heatwave')
                                    THEN (CASE WHEN damage_adjusted > HWAV_EXPA THEN HWAV_EXPA ELSE damage_adjusted END)::float / NULLIF (HWAV_EXPA, 0)
                                WHEN nri_category IN ('hail')
                                    THEN damage_adjusted::float / NULLIF (HAIL_EXPA, 0)
                                WHEN nri_category IN ('drought')
                                    THEN (CASE WHEN damage_adjusted > DRGT_EXPA THEN DRGT_EXPA ELSE damage_adjusted END)::float / NULLIF (DRGT_EXPA, 0)
                                WHEN nri_category IN ('coldwave')
                                    THEN (CASE WHEN damage_adjusted > CWAV_EXPA THEN CWAV_EXPA ELSE damage_adjusted END)::float / NULLIF (CWAV_EXPA, 0)
                                WHEN nri_category IN ('winterweat')
                                    THEN damage_adjusted::float / NULLIF (WNTW_EXPA, 0)
                                END, 0)
               WHEN ctype = 'population'
                   THEN
                   coalesce(CASE
                                WHEN nri_category IN ('wind')
                                    THEN damage_adjusted::float / NULLIF (SWND_EXPPE, 0)
                                WHEN nri_category IN ('wildfire')
                                    THEN damage_adjusted::float / NULLIF (WFIR_EXPPE, 0)
                                WHEN nri_category IN ('tsunami')
                                    THEN damage_adjusted::float / NULLIF (TSUN_EXPPE, 0)
                                WHEN nri_category IN ('tornado')
                                    THEN damage_adjusted::float / NULLIF (TRND_EXPPE, 0)
                                WHEN nri_category IN ('riverine')
                                    THEN (CASE WHEN damage_adjusted > RFLD_EXPPE THEN RFLD_EXPPE ELSE damage_adjusted END)::float / NULLIF (RFLD_EXPPE, 0)
                                WHEN nri_category IN ('lightning')
                                    THEN damage_adjusted::float / NULLIF (LTNG_EXPPE, 0)
                                WHEN nri_category IN ('landslide')
                                    THEN damage_adjusted::float / NULLIF (LNDS_EXPPE, 0)
                                WHEN nri_category IN ('icestorm')
                                    THEN damage_adjusted::float / NULLIF (ISTM_EXPPE, 0)
                                WHEN nri_category IN ('hurricane')
                                    THEN damage_adjusted::float / NULLIF (HRCN_EXPPE, 0)
                                WHEN nri_category IN ('heatwave')
                                    THEN damage_adjusted::float / NULLIF (HWAV_EXPPE, 0)
                                WHEN nri_category IN ('hail')
                                    THEN damage_adjusted::float / NULLIF (HAIL_EXPPE, 0)
                                WHEN nri_category IN ('avalanche')
                                    THEN damage_adjusted::float / NULLIF (AVLN_EXPPE, 0)
                                WHEN nri_category IN ('coldwave')
                                    THEN damage_adjusted::float / NULLIF (CWAV_EXPPE, 0)
                                WHEN nri_category IN ('winterweat')
                                    THEN damage_adjusted::float / NULLIF (WNTW_EXPPE, 0)
                                WHEN nri_category IN ('volcano')
                                    THEN damage_adjusted::float / NULLIF (VLCN_EXPPE, 0)
                                WHEN nri_category IN ('coastal')
                                    THEN damage_adjusted::float / NULLIF (CFLD_EXPPE, 0)
                                END, 0)
               END loss_ratio_per_basis
    FROM tmp_pb_normalised  pb
             JOIN national_risk_index.nri_counties_november_2021 nri
                  ON pb.geoid = nri.stcofips
-- 	WHERE nri_category = 'hurricane' and geoid = '37013' and event_day_date = '1996-07-12 10:00:00'
),
       national as (
           select ctype,
                  nri_category,
                  avg (loss_ratio_per_basis) av_n,
                  variance(loss_ratio_per_basis) va_n
           from lrpbs as a
           WHERE nri_category is not null
           group by 1, 2
           order by 1
       ),
       regional as (
           select ctype,
                  region,
                  nri_category,
                  count (1),
                  avg (loss_ratio_per_basis) av_r,
                  variance(loss_ratio_per_basis) va_r
           from lrpbs as a
                    join severe_weather_new.fips_to_regions_and_surrounding_counties as b
                         on b.fips = a.geoid
                             and nri_category != 'hurricane'
           WHERE nri_category is not null
           group by 1, 2, 3

           UNION ALL

           select ctype,
                  region,
                  nri_category,
                  count (1),
                  avg (loss_ratio_per_basis) av_r,
                  variance(loss_ratio_per_basis) va_r
           from lrpbs as a
                    join severe_weather_new.fips_to_regions_and_surrounding_counties_hurricane as b
                         on b.fips = a.geoid
                             and nri_category = 'hurricane'
           WHERE nri_category is not null
           group by 1, 2, 3
           order by 1, 2, 3

       ),
       county as (
           select ctype,
                  LEFT (b.fips, 5) fips,
                  b.region,
                  nri_category,
                  count (1),
                  avg (loss_ratio_per_basis) av_c,
                  variance(loss_ratio_per_basis) va_c
           from lrpbs as a

                    join severe_weather_new.fips_to_regions_and_surrounding_counties as b
                         on b.fips = a.geoid
                             and nri_category != 'hurricane'
           WHERE nri_category is not null
           group by 1, 2, 3, 4

           UNION ALL

           select ctype,
                  LEFT (b.fips, 5) fips,
                  b.region,
                  nri_category,
                  count (1),
                  avg (loss_ratio_per_basis) av_c,
                  variance(loss_ratio_per_basis) va_c
           from lrpbs as a
                    join severe_weather_new.fips_to_regions_and_surrounding_counties_hurricane as b
                         on b.fips = a.geoid
                             and nri_category = 'hurricane'
           WHERE nri_category is not null
           group by 1, 2, 3, 4
           order by 1, 2, 3, 4
       ),
       grid_variance as (
           select id, nri_category, variance(loss_ratio_per_basis) va
           from tmp_fips_to_grid_mapping_196_new grid
                    JOIN lrpbs
                         ON grid.fips = lrpbs.geoid
           where ctype = 'buildings'
           group by 1, 2
           order by 1, 2, 3),
       fips_to_id_ranking as (
           select grid.fips, grid.id, nri_category, va,
                  (covered_area * 100) / total_area percent_area_covered,
                  rank() over (partition by grid.fips, nri_category order by va, ((covered_area * 100) / total_area) desc ),
                  first_value(grid.id) over (partition by grid.fips, nri_category order by va, ((covered_area * 100) / total_area) desc ) lowest_var_highest_area_id
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
           select ctype, lowest_var_highest_area_id, lrpbs.nri_category,
                  avg (loss_ratio_per_basis) av_s,
                  variance(loss_ratio_per_basis) va_s
           from fips_to_id_mapping
                    JOIN lrpbs
                         ON fips = lrpbs.geoid
                             AND fips_to_id_mapping.nri_category = lrpbs.nri_category
           group by 1, 2, 3),
       surrounding as (
           SELECT fim.fips surrounding, gv.*
           FROM fips_to_id_mapping fim
                    JOIN grid_values gv
                         ON fim.lowest_var_highest_area_id = gv.lowest_var_highest_area_id
                             AND fim.nri_category = gv.nri_category
       ),
       hlr as (
           select county.ctype,
                  county.fips as geoid,
                  regional.region,
                  surrounding.surrounding surrounding,
                  county.nri_category,
                  CASE
                      WHEN county.nri_category not in ('coastal', 'drought', 'hurricane', 'landslide', 'riverine', 'winterweat')
                          THEN COALESCE(((
                                                 (1.0 / NULLIF(va_n, 0)) /
                                                 (
                                                         CASE WHEN county.nri_category not in ('coastal', 'drought', 'hurricane', 'landslide', 'riverine', 'winterweat') THEN COALESCE(1.0 / NULLIF(va_n, 0), 0) ELSE 0 END +
                                                         CASE  WHEN county.nri_category not in ('avalanche', 'earthquake', 'landslide', 'lightning', 'volcano', 'wildfire') THEN COALESCE(1.0 / NULLIF(va_r, 0), 0) ELSE 0 END +
                                                         CASE WHEN county.nri_category not in ('landslide') THEN COALESCE(1.0 / NULLIF(va_c, 0), 0) ELSE 0 END +
                                                         CASE WHEN county.nri_category not in ('avalanche', 'landslide', 'riverine') THEN COALESCE(1.0 / NULLIF(va_s, 0), 0) ELSE 0 END
                                                     )
                                             ) * av_n

                                            ), 0)
                      ELSE 0
                      END
                      +
                  CASE
                      WHEN county.nri_category not in ('avalanche', 'earthquake', 'landslide', 'lightning', 'volcano', 'wildfire')
                          THEN
                          COALESCE(((
                                            (1.0 / NULLIF(va_r, 0)) /
                                            (
                                                    CASE WHEN county.nri_category not in ('coastal', 'drought', 'hurricane', 'landslide', 'riverine', 'winterweat') THEN COALESCE(1.0 / NULLIF(va_n, 0), 0) ELSE 0 END +
                                                    CASE  WHEN county.nri_category not in ('avalanche', 'earthquake', 'landslide', 'lightning', 'volcano', 'wildfire') THEN COALESCE(1.0 / NULLIF(va_r, 0), 0) ELSE 0 END +
                                                    CASE WHEN county.nri_category not in ('landslide') THEN COALESCE(1.0 / NULLIF(va_c, 0), 0) ELSE 0 END +
                                                    CASE WHEN county.nri_category not in ('avalanche', 'landslide', 'riverine') THEN COALESCE(1.0 / NULLIF(va_s, 0), 0) ELSE 0 END
                                                )
                                        ) *
                                    av_r), 0)
                      ELSE 0
                      END
                      +
                  CASE
                      WHEN county.nri_category not in ('landslide')
                          THEN
                          COALESCE(((
                                            (1.0 / NULLIF(va_c, 0)) /
                                            (
                                                    CASE WHEN county.nri_category not in ('coastal', 'drought', 'hurricane', 'landslide', 'riverine', 'winterweat') THEN COALESCE(1.0 / NULLIF(va_n, 0), 0) ELSE 0 END +
                                                    CASE  WHEN county.nri_category not in ('avalanche', 'earthquake', 'landslide', 'lightning', 'volcano', 'wildfire') THEN COALESCE(1.0 / NULLIF(va_r, 0), 0) ELSE 0 END +
                                                    CASE WHEN county.nri_category not in ('landslide') THEN COALESCE(1.0 / NULLIF(va_c, 0), 0) ELSE 0 END +
                                                    CASE WHEN county.nri_category not in ('avalanche', 'landslide', 'riverine') THEN COALESCE(1.0 / NULLIF(va_s, 0), 0) ELSE 0 END
                                                )
                                        ) *
                                    av_c), 0)
                      ELSE 0
                      END
                      +
                  CASE
                      WHEN county.nri_category not in ('avalanche', 'landslide', 'riverine')
                          THEN
                          COALESCE(((
                                            (1.0 / NULLIF(va_s, 0)) /
                                            (
                                                    CASE WHEN county.nri_category not in ('coastal', 'drought', 'hurricane', 'landslide', 'riverine', 'winterweat') THEN COALESCE(1.0 / NULLIF(va_n, 0), 0) ELSE 0 END +
                                                    CASE  WHEN county.nri_category not in ('avalanche', 'earthquake', 'landslide', 'lightning', 'volcano', 'wildfire') THEN COALESCE(1.0 / NULLIF(va_r, 0), 0) ELSE 0 END +
                                                    CASE WHEN county.nri_category not in ('landslide') THEN COALESCE(1.0 / NULLIF(va_c, 0), 0) ELSE 0 END +
                                                    CASE WHEN county.nri_category not in ('avalanche', 'landslide', 'riverine') THEN COALESCE(1.0 / NULLIF(va_s, 0), 0) ELSE 0 END
                                                )
                                        ) *
                                    av_s), 0)
                      ELSE 0
                      END hlr
           FROM county
                    JOIN national
                         ON county.nri_category = national.nri_category
                             AND county.ctype = national.ctype
                    JOIN regional
                         ON county.nri_category = regional.nri_category
                             AND county.region = regional.region
                             AND county.ctype = regional.ctype
                    JOIN surrounding
                         ON county.nri_category = surrounding.nri_category
                             AND county.fips = surrounding.surrounding
                             AND county.ctype = surrounding.ctype
       )


SELECT * INTO tmp_hlr_normalised FROM hlr


