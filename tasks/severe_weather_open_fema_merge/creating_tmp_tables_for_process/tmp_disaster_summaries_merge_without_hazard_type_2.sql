with pa_data as (
    select disaster_number::text,
           lpad(state_number_code::text, 2, '0') || lpad(county_code::text, 3, '0') geoid,
           extract(YEAR from declaration_date) as year,
           incident_type,
           sum(coalesce(project_amount, 0)) project_amount
    from open_fema_data.public_assistance_funded_projects_details_v1
    where dcc not in ('A', 'B', 'Z')
    group by 1, 2, 3, 4
),
     ihp as (
         SELECT substring(ihp.geoid, 1, 5) geoid,
                ihp.disaster_number,
                extract(YEAR from ihp.declaration_date) as year,
                ihp.incident_type,
                sum(coalesce(rpfvl, 0) + coalesce(ppfvl, 0))                                as ihp_verified_loss,
                sum(coalesce(ha_amount, 0)) 												   as ha_loss
         FROM open_fema_data.individuals_and_households_program_valid_registrations_v1 ihp
         where coalesce(rpfvl, 0) + coalesce(ppfvl, 0) + coalesce(ha_amount, 0) > 0
         group by 1,2,3,4
     ),
     ofd as (
         SELECT coalesce(ihp.geoid, pa.geoid) as geoid,
                coalesce(ihp.disaster_number, pa.disaster_number) as disaster_number,
                coalesce(ihp.year, pa.year) as year,
                coalesce(ihp.incident_type, pa.incident_type) as incident_type,

                sum(coalesce(ihp_verified_loss, 0))                                   as ihp_verified_loss,
                sum(coalesce(ha_loss, 0)) 											   as ha_loss,
                sum(coalesce(project_amount,0)) 									   as project_amount
         FROM ihp
                  FULL OUTER JOIN pa_data pa
                                  on ihp.disaster_number = pa.disaster_number
                                      and ihp.geoid = pa.geoid
         where coalesce(ihp_verified_loss, 0) + coalesce(ha_loss, 0) + coalesce(project_amount, 0) > 0
         group by 1,2,3,4
     ),
     sba as (
         SELECT
             year,
             substring(geoid, 1, 5) geoid,
             fema_disaster_number disaster_number,
             SUM(coalesce(total_verified_loss, 0)) sba_loss
         FROM public.sba_disaster_loan_data_new
         GROUP BY 1, 2, 3
     ),
     nfipPayout as (
         select year_of_loss, county_code, disaster_number::text,
                coalesce(sum(amount_paid_on_contents_claim), 0) +
                coalesce(sum(amount_paid_on_building_claim), 0) +
                coalesce(sum(amount_paid_on_increased_cost_of_compliance_claim), 0) total_amount_paid

         FROM open_fema_data.nfip_claims nfip
                  JOIN open_fema_data.disaster_declarations_summaries_v2 dd
                       on date_of_loss BETWEEN incident_begin_date AND incident_end_date
                           and dd.incident_type IN ('Flood', 'Hurricane', 'Severe Storm(s)', 'Coastal Storm', 'Tornado', 'Dam/Levee Break', 'Typhoon')
                           and county_code = fips_state_code || fips_county_code
         group by 1, 2, 3),

     disasters as (SELECT
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
         SELECT disaster_number::text, geoid,
                year,
                SUM(indemnity_amount) crop_loss
         FROM disasters d
                  JOIN crop_loss c
                       ON d.county = c.geoid
                           AND (c.year BETWEEN d.begin_year AND d.end_year OR c.year = d.begin_year)
                           AND (c.month BETWEEN d.begin_month AND d.end_month OR c.month = d.begin_month)
                           AND d.incident_type = c.cause_of_loss_desc
         GROUP BY 1, 2, 3
         ORDER BY 1, 2
     ),
     swd as (SELECT
                 disaster_number::text,
                 substring(geoid, 1, 5) geoid,
                 sum(property_damage)                        as swd_property_damage,
                 sum(crop_damage) 							 as swd_crop_damage
             FROM severe_weather_new.details sw
                      join tmp_disaster_number_to_event_id_mapping_without_hazard_type dn_eid
                           on sw.event_id = dn_eid.event_id
             group by 1, 2
             order by 1, 2)
insert into tmp_disaster_summaries_merge_without_hazard_type_2
select ofd.year,
       CASE
           WHEN lower(incident_type) = 'coastal storm'
               THEN 'coastal'
           WHEN lower(incident_type) IN ('dam/levee break', 'flood', 'severe storm', 'severe storm(s)')
               THEN 'riverine'
           WHEN lower(incident_type) = 'drought'
               THEN 'drought'
           WHEN lower(incident_type) = 'fire'
               THEN 'wildfire'
           WHEN lower(incident_type) = 'freezing'
               THEN 'coldwave'
           WHEN lower(incident_type) IN ('hurricane', 'typhoon')
               THEN 'hurricane'
           WHEN lower(incident_type) = 'mud/landslide'
               THEN 'landslide'
           WHEN lower(incident_type) = 'severe ice storm'
               THEN 'icestorm'
           WHEN lower(incident_type) = 'snow'
               THEN 'winterweat'
           WHEN lower(incident_type) = 'earthquake'
               THEN 'earthquake'
           WHEN lower(incident_type) = 'severe storm(s)'
               THEN 'riverine'
           WHEN lower(incident_type) = 'tornado'
               THEN 'tornado'
           WHEN lower(incident_type) = 'tsunami'
               THEN 'tsunami'
           WHEN lower(incident_type) = 'volcano'
               THEN 'volcano'
           ELSE incident_type
           END hazard,
       ofd.geoid, ofd.disaster_number,
       coalesce(ihp_verified_loss, 0) + coalesce(project_amount, 0) + coalesce(sba_loss, 0) +
       coalesce(total_amount_paid, 0) fema_property_damage,
       coalesce(crop_loss, 0) fema_crop_damage,
       swd.swd_property_damage,
       swd.swd_crop_damage
from ofd left join sba
                   on ofd.disaster_number = sba.disaster_number
                       and ofd.geoid = sba.geoid
                       and ofd.year = sba.year

         left join nfipPayout nfip
                   ON ofd.year = nfip.year_of_loss
                       AND ofd.geoid = nfip.county_code
                       AND ofd.disaster_number = nfip.disaster_number

         left join mapping
                   ON ofd.disaster_number = mapping.disaster_number
                       and ofd.geoid = mapping.geoid
                       and ofd.year = mapping.year

         left join swd
                   ON ofd.disaster_number = swd.disaster_number
                       and ofd.geoid = swd.geoid


