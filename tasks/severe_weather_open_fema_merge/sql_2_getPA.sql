with pa_data as (
    select disaster_number::text, state_number_code::text || lpad(county_code::text, 3, '0') geoid,
           sum(coalesce(project_amount, 0)) project_amount
    from open_fema_data.public_assistance_funded_projects_details_v1
    where dcc not in ('A', 'B', 'Z')
    group by 1, 2
)

update severe_weather_open_fema_data_merge.test_merge dst
set project_amount = pa_data.project_amount
from pa_data
where dst.disaster_number = pa_data.disaster_number
  and dst.geoid = pa_data.geoid