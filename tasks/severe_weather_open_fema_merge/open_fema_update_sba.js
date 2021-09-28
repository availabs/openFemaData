const reformat_open_fema_sba = (table) => `with t as (
    SELECT fema_disaster_number, substring(geoid, 1, 5) geoid, SUM(total_verified_loss) total_loss
    FROM public.sba_disaster_loan_data
    GROUP BY 1, 2
    ORDER BY 1, 2, 3
)


update severe_weather_open_fema_data_merge.${table} dst
set sba_loss = t.total_loss
from t
where t.fema_disaster_number = any(dst.disaster_ids)
  and t.geoid = dst.geoid`

module.exports = reformat_open_fema_sba