with sba_data as (
    SELECT fema_disaster_number disaster_number, year, substring(geoid, 1, 5) geoid, SUM(coalesce(total_verified_loss, 0)) sba_loss
    FROM public.sba_disaster_loan_data_new
    GROUP BY 1, 2, 3
    ORDER BY 1, 2, 3, 4
)

update severe_weather_open_fema_data_merge.test_merge dst
set sba_loss = sba_data.sba_loss
from sba_data
where dst.disaster_number = sba_data.disaster_number
  and dst.geoid = sba_data.geoid