with pa_data as (
    select disaster_number::text,
           state_number_code::text || lpad(county_code::text, 3, '0') geoid,
           extract(YEAR from declaration_date) as year,
           incident_type,
           sum(coalesce(project_amount, 0)) project_amount
    from open_fema_data.public_assistance_funded_projects_details_v1
    where dcc not in ('A', 'B', 'Z')
    group by 1, 2, 3, 4
), sba as (
    SELECT fema_disaster_number disaster_number,
           substring(geoid, 1, 5) geoid,
           year,
           SUM(coalesce(total_verified_loss, 0)) sba_loss
    FROM public.sba_disaster_loan_data_new
    GROUP BY 1, 2, 3
    ORDER BY 1, 2, 3, 4
), ihp as (
    SELECT ihp.geoid, ihp.disaster_number, extract(YEAR from ihp.declaration_date) as year, ihp.incident_type,
           sum(coalesce(rpfvl, 0) + coalesce(ppfvl, 0))                                   as ihp_verified_loss,
           sum(coalesce(ha_amount, 0)) 												   as ha_loss
    FROM open_fema_data.individuals_and_households_program_valid_registrations_v1 ihp
    where coalesce(rpfvl, 0) + coalesce(ppfvl, 0) + coalesce(ha_amount, 0) > 0
    group by 1,2,3,4
),
     ofd as
         (SELECT -- ihp.geoid, ihp.disaster_number, ihp.year, ihp.incident_type,
                 CASE
                     WHEN ihp.geoid IS NOT NULL
                         THEN ihp.geoid
                     ELSE pa.geoid
                     END geoid,
                 CASE
                     WHEN ihp.disaster_number IS NOT NULL
                         THEN ihp.disaster_number
                     ELSE pa.disaster_number
                     END disaster_number,
                 CASE
                     WHEN ihp.year IS NOT NULL
                         THEN ihp.year
                     ELSE pa.year
                     END as year,
                 CASE
                     WHEN ihp.incident_type IS NOT NULL
                         THEN ihp.incident_type
                     ELSE pa.incident_type
                     END hazard,
                 sum(coalesce(ihp_verified_loss, 0))                                   as ihp_verified_loss,
                 sum(coalesce(ha_loss, 0)) 												   as ha_loss,
                 sum(coalesce(project_amount)) 												   as project_amount
          FROM ihp
                   full join pa_data pa
                             on ihp.disaster_number = pa.disaster_number
                                 and ihp.geoid = pa.geoid
          where coalesce(ihp_verified_loss, 0) + coalesce(ha_loss, 0) + coalesce(project_amount, 0) > 0
          group by 1,2,3,4),
     ofd_sba as (
         select ofd.*, sba_loss
         from ofd full join sba
                            on ofd.disaster_number = sba.disaster_number
                                and ofd.geoid = sba.geoid
     )

INSERT INTO severe_weather_open_fema_data_merge.disaster_summaries(
    year, hazard, geoid, disaster_number, ihp_verified_loss, ha_loss, project_amount, sba_loss)
select year, hazard, geoid, disaster_number, ihp_verified_loss, ha_loss, project_amount, sba_loss
from ofd_sba
-- where disaster_number = '4085'