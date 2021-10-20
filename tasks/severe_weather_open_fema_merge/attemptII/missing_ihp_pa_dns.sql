with t as (select distinct disaster_number::text from open_fema_data.disaster_declarations_summaries_v2),
     s as (select distinct disaster_number from
         (
             select distinct disaster_number from open_fema_data.individuals_and_households_program_valid_registrations_v1
             UNION
             select distinct disaster_number::text from open_fema_data.public_assistance_funded_projects_details_v1
         ) tmp
     )
select disaster_number
from t
except
select disaster_number
from s