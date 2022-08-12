with diff AS (
    SELECT hlr.*, cfld_hlrb, ((hlr_b - cfld_hlrb) / nullif(cfld_hlrb, 0)) * 100 percent_hlr_diff,
           hlr_b * cfld_expb * cfld_afreq our_total,
           cfld_hlrb * cfld_expb * cfld_afreq nri_total
    FROM tmp_hlr_zero_loss_tmp_geoid_without_type_mapping hlr
             JOIN national_risk_index.nri_counties_november_2021
                  ON geoid = stcofips
    WHERE nri_category = 'coastal'
    ORDER BY 7 DESC
)

SELECT diff.geoid,
       episode_id,
       event_id,
       begin_date_time,
       event_type,
       state,
       cz_name,
       round(percent_hlr_diff::numeric, 2) 		percent_diff,
       to_char(our_total, 'FM9,999,999,999.99') our_total,
       to_char(nri_total, 'FM9,999,999,999.99') nri_total,
       to_char(property_damage, 'FM9,999,999,999') property_damage

FROM severe_weather_new.details
         JOIN diff
              ON diff.geoid = LPAD(state_fips::TEXT, 2, '0') || LPAD(cz_fips::TEXT, 3, '0')
                  AND nri_category = event_type_formatted
                  AND percent_hlr_diff is not null
WHERE event_type_formatted = 'coastal'
  AND year >= 1996 and year <= 2019
ORDER BY percent_hlr_diff DESC
