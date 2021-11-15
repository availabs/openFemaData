with disasters as (SELECT
                       disaster_number,
                       incident_type,
                       fips_state_code || fips_county_code    county,
                       EXTRACT(YEAR FROM MIN(incident_begin_date) ) begin_year,
                       EXTRACT(YEAR FROM MAX(incident_end_date)) end_year,
                       EXTRACT(MONTH FROM MIN(incident_begin_date) ) begin_month,
                       EXTRACT(MONTH FROM MAX(incident_end_date)) end_month
                   FROM open_fema_data.disaster_declarations_summaries_v2
                   GROUP BY 1, 2, 3
                   ORDER BY 1 DESC),
     crop_loss as (SELECT
                           state_fips || county_fips geoid,
                           commodity_year_identifier::int "year",
                           month_of_loss::int "month",
                           CASE
                               WHEN cause_of_loss_desc IN ('Excess Moisture/Precipitation/Rain','Flood','Poor Drainage')
                                   THEN 'Flood'
                               WHEN cause_of_loss_desc IN ('Hail')
                                   THEN 'Severe Storm(s)'
                               WHEN cause_of_loss_desc IN ('Storm Surge')
                                   THEN 'Coastal Storm'
                               WHEN cause_of_loss_desc IN ('Hurricane/Tropical Depression')
                                   THEN 'Hurricane'
                               WHEN cause_of_loss_desc IN ('Tidal Wave/Tsunami')
                                   THEN 'Tsunami'
                               WHEN cause_of_loss_desc IN ('Tornado')
                                   THEN 'Tornado'
                               WHEN cause_of_loss_desc IN ('Other (Snow,Lightning,etc)','Other (Snow,Lightning,etc)','Other (Snow, Lightning, Etc.)','Other (Volcano,Snow,Lightning,etc)','Other (Volcano,Snow,Lightning,etc)')
                                   THEN 'Snow'
                               WHEN cause_of_loss_desc IN ('Freeze','Cold Winter','Cold Wet Weather','Frost','Ice Flow','Ice Floe')
                                   THEN 'Freezing'
                               WHEN cause_of_loss_desc IN ('Cyclone')
                                   THEN 'Typhoon'
                               WHEN cause_of_loss_desc IN ('Earthquake')
                                   THEN 'Earthquake'
                               WHEN cause_of_loss_desc IN ('Volcanic Eruption')
                                   THEN 'Volcano'
                               WHEN cause_of_loss_desc IN ('Force Fire','House burn (Pole burn)','Fire','Pit Burn','House Burn (Pole Burn)')
                                   THEN 'Fire'
                               WHEN cause_of_loss_desc IN ('Drought','Drought Deviation')
                                   THEN 'Drought'
                               ELSE cause_of_loss_desc
                               END cause_of_loss_desc,
                           indemnity_amount
                   FROM open_fema_data.usda_crop_insurance_cause_of_loss
                   WHERE cause_of_loss_desc in (
                                                'Excess Moisture/Precipitation/Rain','Flood','Poor Drainage','Hail','Storm Surge','Hurricane/Tropical Depression','Tidal Wave/Tsunami','Tornado','Other (Snow,Lightning,etc)','Other (Snow,Lightning,etc)','Other (Snow, Lightning, Etc.)','Other (Volcano,Snow,Lightning,etc)','Other (Volcano,Snow,Lightning,etc)','Freeze','Cold Winter','Cold Wet Weather','Frost','Ice Flow','Ice Floe','Cyclone','Earthquake','Volcanic Eruption','Force Fire','House burn (Pole burn)','Fire','Pit Burn','House Burn (Pole Burn)','Drought','Drought Deviation'
                       )
                     AND month_of_loss != ''
     ),
     mapping as (
         SELECT disaster_number::text, geoid, SUM(indemnity_amount) crop_loss
         FROM disasters d
                  JOIN crop_loss c
                       ON d.county = c.geoid
                           AND (c.year BETWEEN d.begin_year AND d.end_year OR c.year = d.begin_year)
                           AND (c.month BETWEEN d.begin_month AND d.end_month OR c.month = d.begin_month)
                           AND d.incident_type = c.cause_of_loss_desc
         GROUP BY 1, 2
         ORDER BY 1, 2
     )

UPDATE severe_weather_open_fema_data_merge.disaster_summaries_merge_without_hazard_type dst
set usda_crop_damage = crop_loss
from mapping
where dst.disaster_number = mapping.disaster_number
  and dst.geoid = mapping.geoid