with   lrpbs as (
    SELECT tmp_per_basis_data_zero_loss.*, RFLD_EXPB, RFLD_EXPA, RFLD_EXPPE,
           CASE
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
               END building_loss_ratio_per_basis,


           CASE
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
               END crop_loss_ratio_per_basis,

           CASE
               WHEN nri_category IN ('wind')
                   THEN fema_property_damage::float / NULLIF (SWND_EXPB, 0)
               WHEN nri_category IN ('wildfire')
                   THEN (CASE WHEN fema_property_damage > WFIR_EXPB THEN WFIR_EXPB ELSE fema_property_damage END)::float / NULLIF (WFIR_EXPB, 0)
               WHEN nri_category IN ('tsunami')
                   THEN fema_property_damage::float / NULLIF (TSUN_EXPB, 0)
               WHEN nri_category IN ('tornado')
                   THEN fema_property_damage::float / NULLIF (TRND_EXPB, 0)
               WHEN nri_category IN ('riverine')
                   THEN (CASE WHEN fema_property_damage > RFLD_EXPB THEN RFLD_EXPB ELSE fema_property_damage END)::float / NULLIF (RFLD_EXPB, 0)
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
                   THEN (CASE WHEN fema_crop_damage > RFLD_expa THEN RFLD_expa ELSE fema_crop_damage END)::float / NULLIF (RFLD_expa, 0)
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
               END population_loss_ratio_per_basis

    FROM tmp_per_basis_data_zero_loss
             JOIN national_risk_index.nri_counties_november_2021 nri
                  ON tmp_per_basis_data_zero_loss.geoid = nri.stcofips
-- 	where nri_category = 'coastal'
),
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
       )

select lowest_var_highest_area_id, lrpbs.nri_category,
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
from fips_to_id_mapping
         JOIN lrpbs
              ON fips = lrpbs.geoid
                  AND fips_to_id_mapping.nri_category = lrpbs.nri_category
group by 1, 2

