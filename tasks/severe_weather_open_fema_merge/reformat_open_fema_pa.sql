with t as (
    SELECT disaster_number, pa.state, state_number_code::text || lpad(county_code::text, 3, '0') geoid, state_code, pa.county, sum(pa.project_amount) pa
    FROM open_fema_data.public_assistance_funded_projects_details_v1 pa
             join
         severe_weather_open_fema_data_merge.fema_presidential_disasters_annual_loss_by_county_by_hazard summary
         on pa.disaster_number::text = any(summary.disaster_ids)
             and state_number_code::text || lpad(county_code::text, 3, '0') = summary.geoid
-- 	where disaster_number = 4085
    group by 1,2,3,4,5
)


update severe_weather_open_fema_data_merge.fema_presidential_disasters_annual_loss_by_county_by_hazard dst
set project_amount = t.pa
from t
where t.disaster_number::text = any(dst.disaster_ids)
  and t.geoid = dst.geoid