with cpi20 as (
    select *
    from cpi
    where year = 2020
),t as (
    select
        ctype,
        event_day_date,
        geoid,
        nri_category,
        extract(YEAR from event_day_date) as year,
        extract(MONTH from event_day_date) as month,
        damage,
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
    from tmp_pb_normalised_date, cpi20
    where ctype != 'population'
      and event_day_date is not null
),
     final as(
         select
             ctype,
             event_day_date,
             geoid,
             nri_category,
             damage,
             damage * month_2020_cpi /
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
                 ) adjusted_damage

         from t
                  LEFT JOIN cpi
                            ON t.year = cpi.year
     )

-- update tmp_pb_normalised_date
-- set damage_adjusted = damage
-- where ctype = 'population'

update tmp_pb_normalised_date dst
set damage_adjusted = final.adjusted_damage
from final
where dst.event_day_date = final.event_day_date
  and dst.geoid = final.geoid
  and dst.nri_category = final.nri_category
  and dst.ctype = final.ctype

