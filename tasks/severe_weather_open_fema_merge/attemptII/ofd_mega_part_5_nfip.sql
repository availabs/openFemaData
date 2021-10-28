with nfipPayout as (
    select year_of_loss, county_code, disaster_number::text,
           coalesce(sum(amount_paid_on_contents_claim), 0) +
           coalesce(sum(amount_paid_on_building_claim), 0) +
           coalesce(sum(amount_paid_on_increased_cost_of_compliance_claim), 0) total_amount_paid

    FROM open_fema_data.nfip_claims nfip
             join open_fema_data.disaster_declarations_summaries_v2 dd
                  on date_of_loss BETWEEN incident_begin_date AND incident_end_date
                      and dd.incident_type IN ('Flood', 'Hurricane', 'Severe Storm(s)', 'Coastal Storm', 'Tornado', 'Dam/Levee Break', 'Typhoon')
                      and county_code = fips_state_code || fips_county_code
    group by 1, 2, 3)


UPDATE severe_weather_open_fema_data_merge.disaster_summaries_merge_without_hazard_type dst
set nfip = total_amount_paid
from nfipPayout
where year = year_of_loss
  and geoid = county_code
  and dst.disaster_number = nfipPayout.disaster_number