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
                            THEN (CASE WHEN swd_property_damage > CFLD_EXPB THEN swd_property_damage ELSE swd_property_damage END)::float / NULLIF (CFLD_EXPB, 0)
                        END, 0) building_loss_ratio_per_basis

    FROM tmp_per_basis_data_zero_loss
             JOIN national_risk_index.nri_counties_november_2021 nri
                  ON tmp_per_basis_data_zero_loss.geoid = nri.stcofips
),
       national as (
           select nri_category,
                  count (1),
                  avg (building_loss_ratio_per_basis) b_av_n,
                  variance(building_loss_ratio_per_basis) b_va_n

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
                  variance(building_loss_ratio_per_basis) b_va_r

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
                  variance(building_loss_ratio_per_basis) b_va_r

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
                  variance(building_loss_ratio_per_basis) b_va_c

           from lrpbs as a

                    join severe_weather_new.fips_to_regions_and_surrounding_counties as b
                         on b.fips = a.geoid
                             and nri_category != 'hurricane'
           WHERE nri_category is not null
-- 		   and substring(b.fips, 1, 5) = '48201'
           group by 1, 2, 3

           UNION ALL

           select LEFT (b.fips, 5) fips,
                  b.region,
                  nri_category,
                  count (1),
                  avg (building_loss_ratio_per_basis) b_av_c,
                  variance(building_loss_ratio_per_basis) b_va_c

           from lrpbs as a
                    join severe_weather_new.fips_to_regions_and_surrounding_counties_hurricane as b
                         on b.fips = a.geoid
                             and nri_category = 'hurricane'
           WHERE nri_category is not null
-- 		   and substring(b.fips, 1, 5) = '48201'
           group by 1, 2, 3
           order by 1, 2, 3),
       grid_variance as (
           select id, nri_category, variance(building_loss_ratio_per_basis) b_va
           from tmp_fips_to_grid_mapping_196 grid
                    JOIN lrpbs
                         ON grid.fips = lrpbs.geoid
           group by 1, 2
           order by 1, 2, 3),
       fips_to_id_ranking as (
           select grid.fips, grid.id, nri_category, b_va,
                  (covered_area * 100) / total_area percent_area_covered,
                  rank() over (partition by grid.fips, nri_category order by b_va, ((covered_area * 100) / total_area) desc ),
                  first_value(grid.id) over (partition by grid.fips, nri_category order by b_va, ((covered_area * 100) / total_area) desc ) lowest_var_highest_area_id
           from tmp_fips_to_grid_mapping_196 grid
                    JOIN (select fips, sum(covered_area) total_area from tmp_fips_to_grid_mapping_196 group by 1) total_area
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
                  variance(building_loss_ratio_per_basis) b_va_s
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
--            where substring(fim.fips, 1, 5) = '48201'
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
                                ) * b_av_n

                               ), 0) wt_n_original,

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
                      END wt_n,

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
                      END wt_r,

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
                      END wt_c,

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
                      END wt_s,

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
                      END 	AS hlr_b

           FROM county
                    JOIN national
                         ON county.nri_category = national.nri_category
                    JOIN regional
                         ON county.nri_category = regional.nri_category
                             AND county.region = regional.region
                    JOIN surrounding
                         ON county.nri_category = surrounding.nri_category
                             AND county.fips = surrounding.surrounding
           where county.nri_category = 'coastal'
-- 		   and substring(county.fips, 1, 5) = '37129'
       ),
       totals as (SELECT nri_category, geoid,
                         sum(CASE
                                 WHEN nri_category IN ('coastal')
                                     THEN hlr_b * CFLD_EXPB  * CFLD_AFREQ
                             END) our_total,

                         sum(cfld_hlrb * CFLD_EXPB  * CFLD_AFREQ) nri_total
                  FROM hlr
                           JOIN national_risk_index.nri_counties_november_2021
                                ON geoid = stcofips
                  GROUP BY nri_category, geoid
                  ORDER BY nri_category
       )

select hlr.*, property_damage swd_raw_total, swd_raw_num_events, our_total, nri_total, ((our_total - nri_total) / nullif(nri_total, 0))  * 100 percent_diff_total
into tmp_full_data_table
from totals
         JOIN hlr
              ON totals.geoid = hlr.geoid
                  and totals.nri_category = hlr.nri_category
         JOIN (
    select substring(geoid, 1, 5) geoid, event_type_formatted, count(1) swd_raw_num_events, sum(property_damage) property_damage
    from severe_weather_new.details
    where event_type_formatted = 'coastal'
    group by 1, 2
) swd
              ON totals.geoid = swd.geoid
                  AND totals.nri_category = swd.event_type_formatted
order by 14 desc

