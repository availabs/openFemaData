with cpi20 as (
    select *
    from cpi
    where year = 2020
),t as (
    select event_id,
           begin_date_time,
           extract(YEAR from begin_date_time) as year,
           extract(MONTH from begin_date_time) as month,
           property_damage,
           crop_damage,
           CASE WHEN extract(MONTH from begin_date_time) = 1
                    THEN jan
                WHEN extract(MONTH from begin_date_time) = 2
                    THEN feb
                WHEN extract(MONTH from begin_date_time) = 3
                    THEN mar
                WHEN extract(MONTH from begin_date_time) = 4
                    THEN apr
                WHEN extract(MONTH from begin_date_time) = 5
                    THEN may
                WHEN extract(MONTH from begin_date_time) = 6
                    THEN jun
                WHEN extract(MONTH from begin_date_time) = 7
                    THEN jul
                WHEN extract(MONTH from begin_date_time) = 8
                    THEN aug
                WHEN extract(MONTH from begin_date_time) = 9
                    THEN sep
                WHEN extract(MONTH from begin_date_time) = 10
                    THEN oct
                WHEN extract(MONTH from begin_date_time) = 11
                    THEN nov
                WHEN extract(MONTH from begin_date_time) = 12
                    THEN dec
               END AS month_2020_cpi
    from severe_weather_new.details, cpi20
),
     final as(
         select event_id,
                begin_date_time,
                property_damage,
                crop_damage,
                property_damage * month_2020_cpi /
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
                    ) property_adjusted_dollar,
                crop_damage * month_2020_cpi /
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
                    ) crop_adjusted_dollar
         from t
                  JOIN cpi
                       ON t.year = cpi.year )

update severe_weather_new.details dst
set property_damage_adjusted = final.property_adjusted_dollar,
    crop_damage_adjusted = final.crop_adjusted_dollar
from final
where dst.event_id = final.event_id