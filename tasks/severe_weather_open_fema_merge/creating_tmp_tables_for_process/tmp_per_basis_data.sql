with
    pa_data as (
        select disaster_number::text,
               lpad(state_number_code::text, 2, '0') || lpad(county_code::text, 3, '0') geoid,
               extract(YEAR from declaration_date) as year,
               incident_type,
               sum(project_amount) project_amount
        from open_fema_data.public_assistance_funded_projects_details_v1
        where dcc not in ('A', 'B', 'Z')
          and lpad(state_number_code::text, 2, '0') || lpad(county_code::text, 3, '0') not like '*'
          and extract(YEAR from declaration_date) >= 1996 and extract(YEAR from declaration_date) <= 2019
        group by 1, 2, 3, 4
    ),
    ihp as (
        SELECT substring(ihp.geoid, 1, 5) geoid,
               ihp.disaster_number,
               extract(YEAR from ihp.declaration_date) as year,
               ihp.incident_type,
               NULLIF(sum(coalesce(rpfvl, 0) + coalesce(ppfvl, 0)), 0)                                as ihp_verified_loss,
               sum(ha_amount) 												   as ha_loss
        FROM open_fema_data.individuals_and_households_program_valid_registrations_v1 ihp
        where extract(YEAR from ihp.declaration_date) >= 1996 and extract(YEAR from ihp.declaration_date) <= 2019
          and substring(ihp.geoid, 1, 5) not like '*'
        group by 1,2,3,4
    ),
    ihp_pa_merge as (
        SELECT coalesce(ihp.geoid, pa.geoid) as geoid,
               coalesce(ihp.disaster_number, pa.disaster_number) as disaster_number,
               coalesce(ihp.year, pa.year) as year,
               coalesce(ihp.incident_type, pa.incident_type) as incident_type,

               sum(ihp_verified_loss)                                   as ihp_verified_loss,
               sum(ha_loss) 											   as ha_loss,
               sum(project_amount) 									   as project_amount
        FROM ihp
                 FULL OUTER JOIN pa_data pa
                                 ON ihp.disaster_number = pa.disaster_number
                                     AND ihp.geoid = pa.geoid
        WHERE coalesce(ihp_verified_loss, 0) + coalesce(ha_loss, 0) + coalesce(project_amount, 0) > 0
        GROUP BY 1,2,3,4
    ),
    ofd as (
        SELECT
            dd.disaster_number::text,
            coalesce(dd.incident_type, ihp_pa_merge.incident_type)		 incident_type,
            fips_state_code || fips_county_code                           geoid,
            extract(YEAR from incident_begin_date)                        AS year,
            min(incident_begin_date::date)                                      fema_incident_begin_date,
            max(incident_end_date::date)                                        fema_incident_end_date,
            sum(ihp_verified_loss)                                        ihp_verified_loss,
            sum(ha_loss) 											     ha_loss,
            sum(project_amount) 									         project_amount
        FROM  open_fema_data.disaster_declarations_summaries_v2 dd
                  FULL OUTER JOIN ihp_pa_merge
                                  ON dd.disaster_number::text = ihp_pa_merge.disaster_number
                                      AND fips_state_code || fips_county_code = geoid
        WHERE coalesce(fy_declared, extract(YEAR from incident_begin_date)) >= 1996 and coalesce(fy_declared, extract(YEAR from incident_begin_date)) <= 2019
          AND dd.fips_state_code || dd.fips_county_code not like '*'
          AND dd.incident_type not in ('Biological', 'Other', 'Terrorist', 'Chemical', 'Human Cause', 'Toxic Substances',
                                       'Dense Fog','Dense Smoke','Dust Devil','Dust Storm'
            )
        GROUP BY 1, 2, 3, 4
        ORDER BY ihp_verified_loss, ha_loss, project_amount
    ),
    sba as (
        SELECT fema_disaster_number                  disaster_number,
               incident_type,
               substring(geoid, 1, 5)                geoid,
               year,
               SUM(total_verified_loss) sba_loss
        FROM public.sba_disaster_loan_data_new sba
                 JOIN open_fema_data.disaster_declarations_summaries_v2 dd
                      ON dd.disaster_number::text = sba.fema_disaster_number
                          AND geoid = fips_state_code || fips_county_code
        WHERE year >= 1996 and year <= 2019
          AND substring(geoid, 1, 5) not like '*'
        GROUP BY 1, 2, 3, 4
    ),
    nfipPayout as (
        select year_of_loss, county_code, disaster_number::text, incident_type,
               sum(
                       NULLIF(coalesce(amount_paid_on_contents_claim, 0) +
                              coalesce(amount_paid_on_building_claim, 0) +
                              coalesce(amount_paid_on_increased_cost_of_compliance_claim, 0), 0)
                   ) total_amount_paid

        FROM open_fema_data.nfip_claims nfip
                 JOIN open_fema_data.disaster_declarations_summaries_v2 dd
                      ON date_of_loss BETWEEN incident_begin_date AND incident_end_date
                          AND dd.incident_type IN ('Flood', 'Hurricane', 'Severe Storm(s)', 'Coastal Storm', 'Tornado', 'Dam/Levee Break', 'Typhoon')
                          AND county_code = fips_state_code || fips_county_code
        WHERE year_of_loss >= 1996 and year_of_loss <= 2019
          AND county_code not like '*'
        group by 1, 2, 3, 4
    ),
    disasters as (
        SELECT disaster_number,
               incident_type,
               fips_state_code || fips_county_code          county,
               EXTRACT(YEAR FROM MIN(incident_begin_date))  begin_year,
               EXTRACT(YEAR FROM MAX(incident_end_date))    end_year,
               EXTRACT(MONTH FROM MIN(incident_begin_date)) begin_month,
               EXTRACT(MONTH FROM MAX(incident_end_date))   end_month
        FROM open_fema_data.disaster_declarations_summaries_v2
        WHERE EXTRACT(YEAR FROM incident_begin_date ) >= 1996 and EXTRACT(YEAR FROM incident_begin_date ) <= 2019
          AND fips_state_code || fips_county_code not like '*'
        GROUP BY 1, 2, 3
        ORDER BY 1 DESC
    ),
    crop_loss as (
        SELECT state_fips || county_fips geoid,
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
                                     'Excess Moisture/Precipitation/Rain','Flood','Poor Drainage','Hail','Storm Surge',
                                     'Hurricane/Tropical Depression','Tidal Wave/Tsunami','Tornado','Other (Snow,Lightning,etc)',
                                     'Other (Snow,Lightning,etc)','Other (Snow, Lightning, Etc.)','Other (Volcano,Snow,Lightning,etc)',
                                     'Other (Volcano,Snow,Lightning,etc)','Freeze','Cold Winter','Cold Wet Weather','Frost','Ice Flow',
                                     'Ice Floe','Cyclone','Earthquake','Volcanic Eruption','Force Fire','House burn (Pole burn)','Fire',
                                     'Pit Burn','House Burn (Pole Burn)','Drought','Drought Deviation'
            )
          AND state_fips || county_fips not like '*'
          AND month_of_loss != ''
          AND commodity_year_identifier::int >= 1996
          AND commodity_year_identifier::int <= 2019
    ),
    croploss as (
        SELECT geoid, disaster_number::text, incident_type, year, SUM(indemnity_amount) crop_loss
        FROM disasters d
                 JOIN crop_loss c
                      ON d.county = c.geoid
                          AND (c.year BETWEEN d.begin_year AND d.end_year OR c.year = d.begin_year)
                          AND (c.month BETWEEN d.begin_month AND d.end_month OR c.month = d.begin_month)
                          AND d.incident_type = c.cause_of_loss_desc
        WHERE geoid not like '*'
        GROUP BY 1, 2, 3, 4
        ORDER BY 1, 2
    ),
    disaster_declarations_summary as (
        SELECT
            coalesce(coalesce(coalesce(ofd.disaster_number, sba.disaster_number),
                              nfip.disaster_number), croploss.disaster_number)                                            disaster_number,
            CASE
                WHEN lower(coalesce(coalesce(coalesce(ofd.incident_type, sba.incident_type),
                                             nfip.incident_type), croploss.incident_type)) = 'coastal storm'
                    THEN 'coastal'
                WHEN lower(coalesce(coalesce(coalesce(ofd.incident_type, sba.incident_type),
                                             nfip.incident_type), croploss.incident_type)) IN ('dam/levee break', 'flood', 'severe storm', 'severe storm(s)', 'heavy rain')
                    THEN 'riverine'
                WHEN lower(coalesce(coalesce(coalesce(ofd.incident_type, sba.incident_type),
                                             nfip.incident_type), croploss.incident_type)) = 'drought'
                    THEN 'drought'
                WHEN lower(coalesce(coalesce(coalesce(ofd.incident_type, sba.incident_type),
                                             nfip.incident_type), croploss.incident_type)) = 'fire'
                    THEN 'wildfire'
                WHEN lower(coalesce(coalesce(coalesce(ofd.incident_type, sba.incident_type),
                                             nfip.incident_type), croploss.incident_type)) = 'freezing'
                    THEN 'coldwave'
                WHEN lower(coalesce(coalesce(coalesce(ofd.incident_type, sba.incident_type),
                                             nfip.incident_type), croploss.incident_type)) IN ('hurricane', 'typhoon')
                    THEN 'hurricane'
                WHEN lower(coalesce(coalesce(coalesce(ofd.incident_type, sba.incident_type),
                                             nfip.incident_type), croploss.incident_type)) = 'mud/landslide'
                    THEN 'landslide'
                WHEN lower(coalesce(coalesce(coalesce(ofd.incident_type, sba.incident_type),
                                             nfip.incident_type), croploss.incident_type)) = 'severe ice storm'
                    THEN 'icestorm'
                WHEN lower(coalesce(coalesce(coalesce(ofd.incident_type, sba.incident_type),
                                             nfip.incident_type), croploss.incident_type)) IN ('snow', 'freezing fog')
                    THEN 'winterweat'
                WHEN lower(coalesce(coalesce(coalesce(ofd.incident_type, sba.incident_type),
                                             nfip.incident_type), croploss.incident_type)) = 'earthquake'
                    THEN 'earthquake'
                WHEN lower(coalesce(coalesce(coalesce(ofd.incident_type, sba.incident_type),
                                             nfip.incident_type), croploss.incident_type)) = 'tornado'
                    THEN 'tornado'
                WHEN lower(coalesce(coalesce(coalesce(ofd.incident_type, sba.incident_type),
                                             nfip.incident_type), croploss.incident_type)) = 'tsunami'
                    THEN 'tsunami'
                WHEN lower(coalesce(coalesce(coalesce(ofd.incident_type, sba.incident_type),
                                             nfip.incident_type), croploss.incident_type)) = 'volcano'
                    THEN 'volcano'
                END 																						incident_type,
            coalesce(coalesce(coalesce(ofd.geoid, sba.geoid), nfip.county_code), croploss.geoid)        geoid,
            min(ofd.fema_incident_begin_date)                                                           fema_incident_begin_date,
            max(ofd.fema_incident_end_date)                                                             fema_incident_end_date,
            sum(NULLIF(coalesce(ihp_verified_loss, 0) + coalesce(project_amount, 0) +
                       coalesce(sba_loss, 0) + coalesce(total_amount_paid, 0), 0))                             fema_property_damage,
            sum(crop_loss)                                                                              fema_crop_damage

        FROM ofd
                 FULL OUTER JOIN sba
                                 ON ofd.disaster_number = sba.disaster_number
                                     AND ofd.geoid = sba.geoid
                                     AND ofd.year = sba.year

                 FULL OUTER JOIN nfipPayout nfip
                                 ON ofd.geoid = nfip.county_code
                                     AND ofd.disaster_number = nfip.disaster_number

                 FULL OUTER JOIN croploss
                                 ON ofd.disaster_number = croploss.disaster_number
                                     AND ofd.geoid = croploss.geoid
                                     AND ofd.year = croploss.year
        WHERE (
                          ihp_verified_loss > 0 OR project_amount > 0 OR sba_loss > 0 OR total_amount_paid > 0  OR crop_loss > 0
                  )

        GROUP BY 1, 2, 3
    ),
    disaster_declarations_summary_grouped_for_merge as (
        SELECT disaster_number,
               incident_type,
               ARRAY_AGG(geoid) counties,
               min(fema_incident_begin_date::date)                     fema_incident_begin_date,
               max(fema_incident_end_date::date)                       fema_incident_end_date
        FROM disaster_declarations_summary
        GROUP BY 1, 2
    ),
    disaster_number_to_event_id_mapping_without_hazard_type as (
        SELECT distinct disaster_number, event_id
        FROM severe_weather_new.details sw
                 JOIN disaster_declarations_summary_grouped_for_merge d
                      ON substring(geoid, 1, 5) = any (d.counties)
                          AND (begin_date_time::date, end_date_time::date) OVERLAPS (fema_incident_begin_date, fema_incident_end_date)
                          AND (
                                     incident_type = event_type_formatted OR
                                     (incident_type = 'hurricane' AND event_type_formatted = 'riverine') OR
                                     (incident_type = 'icestorm' AND event_type_formatted = 'coldwave') OR
--                                      (incident_type = 'icestorm' AND event_type_formatted = 'hail') OR
                                     (incident_type = 'winterweat' AND event_type_formatted = 'coldwave') OR
                                     (incident_type = 'winterweat' AND event_type_formatted = 'icestorm') OR
                                     (incident_type = 'earthquake' AND event_type_formatted = 'landslide') OR
                                 --                 (incident_type = 'tornado' AND event_type_formatted = 'coastal') OR
--                 (incident_type = 'tornado' AND event_type_formatted = 'Heavy Rain') OR
                                     (incident_type = 'tornado' AND event_type_formatted = 'wind') OR
--                 (incident_type = 'tornado' AND event_type_formatted = 'hail') OR
                                     (incident_type = 'icestorm' AND event_type_formatted = 'winterweat')
                             )
        WHERE year >= 1996 and year <= 2019
--           AND (property_damage > 0 OR crop_damage > 0 OR injuries_direct > 0 OR injuries_indirect > 0 OR deaths_direct > 0 OR deaths_indirect > 0)
          AND event_type_formatted not in ('Dense Fog', 'Dense Smoke', 'Dust Devil', 'Dust Storm', 'Astronomical Low Tide')
          AND geoid is not null
        ORDER BY disaster_number
    ),
    disaster_division_factor as (
        select disaster_number, count(1) division_factor
        from disaster_number_to_event_id_mapping_without_hazard_type
        group by disaster_number
        order by 1 desc
    ),
    event_division_factor as (
        select event_id, count(1) division_factor
        from disaster_number_to_event_id_mapping_without_hazard_type
        group by event_id
        order by 1 desc
    ),
    swd as (SELECT
                dd.disaster_number::text,
                substring(sw.geoid, 1, 5) geoid,
                sw.episode_id,
                sw.event_id,
                count(1),
                event_type_formatted,
                min(fema_incident_begin_date)                                               as fema_incident_begin_date,
                max(fema_incident_end_date)                                                 as fema_incident_end_date,
                min(begin_date_time::date) swd_begin_date,
                max(end_date_time::date) swd_end_date,
                sum(property_damage/coalesce(edf.division_factor, 1))                        as swd_property_damage,
                sum(crop_damage/coalesce(edf.division_factor, 1)) 							 as swd_crop_damage,
                sum(injuries_direct/coalesce(edf.division_factor, 1))                        as injuries_direct,
                sum(injuries_indirect/coalesce(edf.division_factor, 1))                         injuries_indirect,
                sum(deaths_direct/coalesce(edf.division_factor, 1))                             deaths_direct,
                sum(deaths_indirect/coalesce(edf.division_factor, 1))                           deaths_indirect
            FROM severe_weather_new.details sw
                     LEFT JOIN disaster_number_to_event_id_mapping_without_hazard_type dn_eid
                               on sw.event_id = dn_eid.event_id
                     LEFT JOIN disaster_declarations_summary dd
                               on dd.disaster_number::text = dn_eid.disaster_number
                                   AND substring(sw.geoid, 1, 5) = dd.geoid
                     LEFT JOIN event_division_factor edf
                               ON edf.event_id = sw.event_id

            WHERE year >= 1996 and year <= 2019
              AND substring(sw.geoid, 1, 5) not like '*'
--               AND (property_damage > 0 OR crop_damage > 0 OR injuries_direct > 0 OR injuries_indirect > 0 OR deaths_direct > 0 OR deaths_indirect > 0)
              AND event_type_formatted not in ('Dense Fog', 'Dense Smoke', 'Dust Devil', 'Dust Storm', 'Astronomical Low Tide')
--             	AND sw.event_id = 5696210
              AND sw.geoid is not null
            group by 1, 2, 3, 4
            order by 1, 2)

        ,fusion_events as (
    select
        coalesce(ofd.geoid, swd.geoid) geoid,
        event_id,
        coalesce(event_type_formatted , incident_type)   						  nri_category,
        swd_begin_date			  											      swd_begin_date,
        swd_end_date		  											          swd_end_date,
        string_agg(distinct ofd.disaster_number, ', ')						  					  disaster_numbers,
        min(coalesce(ofd.fema_incident_begin_date, swd.fema_incident_begin_date))  fema_incident_begin_date,
        max(coalesce(ofd.fema_incident_end_date, swd.fema_incident_end_date))     fema_incident_end_date,
        sum(fema_property_damage/coalesce(ddf.division_factor, 1)) 				  fema_property_damage,
        sum(fema_crop_damage/coalesce(ddf.division_factor, 1))     				  fema_crop_damage,
        sum(swd.swd_property_damage) 											  swd_property_damage,
        sum(swd.swd_crop_damage)												  swd_crop_damage,
        sum(injuries_direct)  													  injuries_direct,
        sum(injuries_indirect) 													  injuries_indirect,
        sum(deaths_direct) 														  deaths_direct,
        sum(deaths_indirect) 													  deaths_indirect

    FROM disaster_declarations_summary ofd
             FULL OUTER JOIN swd
                             ON ofd.disaster_number = swd.disaster_number
                                 AND ofd.geoid = swd.geoid
             LEFT JOIN disaster_division_factor ddf
                       ON ofd.disaster_number = ddf.disaster_number
    GROUP BY 1, 2, 3, 4, 5
    ORDER BY 1, 2, 3, 4, 5
),
    details_fema_per_basis as (
        SELECT generate_series(coalesce(swd_begin_date, fema_incident_begin_date)::date,
                               LEAST(
                                       coalesce(swd_end_date, fema_incident_end_date)::date,
                                       CASE WHEN nri_category = 'drought' THEN coalesce(swd_begin_date, fema_incident_begin_date)::date + INTERVAL '365 days' ELSE coalesce(swd_begin_date, fema_incident_begin_date)::date + INTERVAL '31 days' END
                                   ), '1 day'::interval)::date event_day_date,
               nri_category hazard,
               geoid,
               sum(swd_property_damage::double precision/LEAST(
                               coalesce(swd_end_date, fema_incident_end_date)::date - coalesce(swd_begin_date, fema_incident_begin_date)::date + 1,
                               CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END)) swd_property_damage,

               sum(swd_crop_damage::double precision/LEAST(
                               coalesce(swd_end_date, fema_incident_end_date)::date - coalesce(swd_begin_date, fema_incident_begin_date)::date + 1,
                               CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END)) swd_crop_damage,

               sum(injuries_direct::double precision/LEAST(
                               coalesce(swd_end_date, fema_incident_end_date)::date - coalesce(swd_begin_date, fema_incident_begin_date)::date + 1,
                               CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END)) injuries_direct,
               sum(injuries_indirect::double precision/LEAST(
                               coalesce(swd_end_date, fema_incident_end_date)::date - coalesce(swd_begin_date, fema_incident_begin_date)::date + 1,
                               CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END)) injuries_indirect,
               sum(deaths_direct::double precision/LEAST(
                               coalesce(swd_end_date, fema_incident_end_date)::date - coalesce(swd_begin_date, fema_incident_begin_date)::date + 1,
                               CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END)) deaths_direct,
               sum(deaths_indirect::double precision /LEAST(
                               coalesce(swd_end_date, fema_incident_end_date)::date - coalesce(swd_begin_date, fema_incident_begin_date)::date + 1,
                               CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END)) deaths_inderect,
               sum(fema_property_damage/LEAST(
                               coalesce(swd_end_date, fema_incident_end_date)::date - coalesce(swd_begin_date, fema_incident_begin_date)::date + 1,
                               CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END)) fema_property_damage,
               sum(fema_crop_damage/LEAST(
                               coalesce(swd_end_date, fema_incident_end_date)::date - coalesce(swd_begin_date, fema_incident_begin_date)::date + 1,
                               CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END)) fema_crop_damage,
               sum(((
                                injuries_direct / LEAST(
                                            coalesce(swd_end_date, fema_incident_end_date)::date - coalesce(swd_begin_date, fema_incident_begin_date)::date + 1,
                                            CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END) +
                                injuries_indirect / LEAST(
                                                coalesce(swd_end_date, fema_incident_end_date)::date - coalesce(swd_begin_date, fema_incident_begin_date)::date + 1,
                                                CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END) +
                                deaths_direct / LEAST(
                                                coalesce(swd_end_date, fema_incident_end_date)::date - coalesce(swd_begin_date, fema_incident_begin_date)::date + 1,
                                                CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END) +
                                deaths_indirect / LEAST(
                                                coalesce(swd_end_date, fema_incident_end_date)::date - coalesce(swd_begin_date, fema_incident_begin_date)::date + 1,
                                                CASE WHEN nri_category = 'drought' THEN 365 ELSE 31 END)
                        )/10)*7600000) fatalities_dollar_value
        FROM fusion_events
        WHERE nri_category in ('coldwave', 'drought', 'heatwave', 'icestorm', 'riverine', 'winterweat')
          AND geoid is not null
        group by 1, 2, 3
        order by 1, 2, 3),
    aggregation as (
        SELECT
            nri_category hazard,
            geoid,
            coalesce(swd_begin_date, fema_incident_begin_date) event_day_date,
            ARRAY_AGG(event_id)	  event_ids,
            ARRAY_AGG(distinct disaster_numbers) disaster_number,
            count(1) 					num_events,
            sum (swd_property_damage) swd_property_damage,
            sum (swd_crop_damage) swd_crop_damage,
            sum(injuries_direct) injuries_direct,
            sum(injuries_indirect) injuries_indirect,
            sum(deaths_direct) deaths_direct,
            sum(deaths_indirect) deaths_indirect,
            sum (fema_property_damage) fema_property_damage,
            sum (fema_crop_damage) fema_crop_damage,
            sum((
                        NULLIF(coalesce(injuries_direct, 0) +
                               coalesce(injuries_indirect, 0) +
                               coalesce(deaths_direct, 0) +
                               coalesce(deaths_indirect, 0), 0
                            )/10 ) * 7600000) fatalities_dollar_value
        from fusion_events
        where nri_category NOT IN ('coldwave', 'drought', 'heatwave', 'icestorm', 'riverine', 'winterweat')
        group by  1, 2, 3
    ),
    final as (
        select hazard nri_category, geoid, event_day_date,
               event_ids, disaster_number, num_events,
               swd_property_damage, swd_crop_damage, fema_property_damage, fema_crop_damage, fatalities_dollar_value
        from aggregation

        UNION ALL

        select hazard nri_category, geoid, event_day_date,
               null as event_ids, null as disaster_number, null as num_events,
               swd_property_damage, swd_crop_damage, fema_property_damage, fema_crop_damage, fatalities_dollar_value
        from details_fema_per_basis

        order by 1, 2, 3
    )

SELECT * INTO tmp_per_basis_data_zero_loss_detailed FROM final;


