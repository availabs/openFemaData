with pb as (
    select CASE
               WHEN lead(event_day_date, 1) OVER(partition by geoid, nri_category, ctype order by event_day_date) - event_day_date = 1
                   then 1
               WHEN lag(event_day_date, 1) OVER(partition by geoid, nri_category, ctype order by event_day_date) - event_day_date = -1
                   then 1
               else 0
               END consec_days, *
    FROM tmp_pb_fusion
-- where nri_category IN ('hail', 'wind', 'tornado') -- requires consecutive days agg
    where event_day_date is not null
-- and nri_category IN ('coastal', 'hurricane', 'tsunami') -- max expansion days = 1
      and nri_category IN ('hail', 'wind', 'tornado', 'coastal', 'hurricane', 'tsunami')
),
     final_pb as (
         select geoid, nri_category, ctype, event_day_date::character varying grouping_col, damage_adjusted
         FROM tmp_pb_fusion
         WHERE nri_category NOT IN ('hail', 'wind', 'tornado', 'coastal', 'hurricane', 'tsunami')
            OR (
                     nri_category IN ('hail', 'wind', 'tornado', 'coastal', 'hurricane', 'tsunami') AND
                     event_day_date is null
             )

         UNION ALL

         select geoid, nri_category, ctype,
                CASE WHEN consec_days = 1 THEN consec_days::character varying ELSE event_day_date::character varying END grouping_col,
                sum(damage_adjusted) damage_adjusted
         from pb
         group by 1, 2, 3, 4
         order by 1, 2, 3, 4
     )

SELECT *
INTO tmp_pb_fusion_consec
FROM final_pb

