with cpi20 as (
    select *
    from cpi
    where year = 2020
),t as (
    select
        event_day_date,
        extract(YEAR from event_day_date) as year,
        extract(MONTH from event_day_date) as month,
        geoid,
        nri_category,
        swd_property_damage,
        swd_crop_damage,
        CASE WHEN extract(MONTH from event_day_date) = 1
                 THEN jan
             WHEN extract(MONTH from event_day_date) = 2
                 THEN feb
             WHEN extract(MONTH from event_day_date) = 3
                 THEN mar
             WHEN extract(MONTH from event_day_date) = 4
                 THEN apr
             WHEN extract(MONTH from event_day_date) = 5
                 THEN may
             WHEN extract(MONTH from event_day_date) = 6
                 THEN jun
             WHEN extract(MONTH from event_day_date) = 7
                 THEN jul
             WHEN extract(MONTH from event_day_date) = 8
                 THEN aug
             WHEN extract(MONTH from event_day_date) = 9
                 THEN sep
             WHEN extract(MONTH from event_day_date) = 10
                 THEN oct
             WHEN extract(MONTH from event_day_date) = 11
                 THEN nov
             WHEN extract(MONTH from event_day_date) = 12
                 THEN dec
            END AS month_2020_cpi
    from tmp_per_basis_data_swd_non_adjusted, cpi20
),
     final as(
         select
             event_day_date,
             geoid,
             nri_category,
             swd_property_damage,
             swd_crop_damage,
             swd_property_damage * month_2020_cpi /
             (
                 CASE
                     WHEN month = 1
                         THEN jan
                     WHEN month = 2
                         THEN feb
                     WHEN month = 3
                         THEN mar
                     WHEN month = 4
                         THEN apr
                     WHEN month = 5
                         THEN may
                     WHEN month = 6
                         THEN jun
                     WHEN month = 7
                         THEN jul
                     WHEN month = 8
                         THEN aug
                     WHEN month = 9
                         THEN sep
                     WHEN month = 10
                         THEN oct
                     WHEN month = 11
                         THEN nov
                     WHEN month = 12
                         THEN dec
                     END
                 ) property_adjusted_dollar

         from t
                  full JOIN cpi
                            ON t.year = cpi.year )


-- select dst.swd_property_damage, final.swd_property_damage, final.property_adjusted_dollar
-- from tmp_per_basis_data_swd_non_adjusted dst
-- full join final
-- on dst.swd_property_damage = final.swd_property_damage
-- and dst.swd_crop_damage = final.swd_crop_damage
-- and dst.event_day_date = final.event_day_date
-- and dst.geoid = final.geoid
-- and dst.nri_category = final.nri_category
-- where final.property_adjusted_dollar is null
-- and dst.swd_property_damage > 0

update tmp_per_basis_data_swd_non_adjusted dst
set property_damage_adjusted = final.property_adjusted_dollar
--     crop_damage_adjusted = final.crop_adjusted_dollar
from final
where dst.event_day_date = final.event_day_date
  and dst.geoid = final.geoid
  and dst.nri_category = final.nri_category