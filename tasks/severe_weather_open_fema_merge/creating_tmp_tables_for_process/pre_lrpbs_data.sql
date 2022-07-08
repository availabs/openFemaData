with
    disaster_declarations_summary as (
        SELECT dd.disaster_number,
               CASE
                   WHEN lower(dd.incident_type) = 'coastal storm'
                       THEN 'coastal'
                   WHEN lower(dd.incident_type) IN ('dam/levee break', 'flood', 'severe storm', 'severe storm(s)')
                       THEN 'riverine'
                   WHEN lower(dd.incident_type) = 'drought'
                       THEN 'drought'
                   WHEN lower(dd.incident_type) = 'fire'
                       THEN 'wildfire'
                   WHEN lower(dd.incident_type) = 'freezing'
                       THEN 'coldwave'
                   WHEN lower(dd.incident_type) IN ('hurricane', 'typhoon')
                       THEN 'hurricane'
                   WHEN lower(dd.incident_type) = 'mud/landslide'
                       THEN 'landslide'
                   WHEN lower(dd.incident_type) = 'severe ice storm'
                       THEN 'icestorm'
                   WHEN lower(dd.incident_type) = 'snow'
                       THEN 'winterweat'
                   WHEN lower(dd.incident_type) = 'earthquake'
                       THEN 'earthquake'
                   WHEN lower(dd.incident_type) = 'severe storm(s)'
                       THEN 'riverine'
                   WHEN lower(dd.incident_type) = 'tornado'
                       THEN 'tornado'
                   WHEN lower(dd.incident_type) = 'tsunami'
                       THEN 'tsunami'
                   WHEN lower(dd.incident_type) = 'volcano'
                       THEN 'volcano'
                   ELSE dd.incident_type
                   END incident_type,
               ARRAY_AGG(fips_state_code || fips_county_code)    counties,
               MIN(incident_begin_date)                          incident_begin_date,
               MAX(incident_end_date)                            incident_end_date
        FROM open_fema_data.disaster_declarations_summaries_v2 dd
        WHERE fy_declared >= 2000
          AND fips_state_code ||fips_county_code not like '*'
        GROUP BY 1, 2
    ),
    disaster_number_to_event_id_mapping_without_hazard_type as (
        SELECT distinct disaster_number, event_id
        FROM severe_weather_new.details sw
                 JOIN disaster_declarations_summary d
                      ON substring(geoid, 1, 5) = any (d.counties)
                          AND (begin_date_time, end_date_time) OVERLAPS (incident_begin_date, incident_end_date)
                          AND (
                                     incident_type = event_type_formatted OR
                                     (incident_type = 'hurricane' AND event_type_formatted = 'riverine') OR
                                     (incident_type = 'riverine' AND event_type_formatted = 'tornado') OR
                                     (incident_type = 'riverine' AND event_type_formatted = 'coastal') OR
                                     (incident_type = 'icestorm' AND event_type_formatted = 'coldwave') OR
                                     (incident_type = 'icestorm' AND event_type_formatted = 'hail') OR
                                     (incident_type = 'winterweat' AND event_type_formatted = 'coldwave') OR
                                     (incident_type = 'winterweat' AND event_type_formatted = 'icestorm') OR
                                     (incident_type = 'coastal' AND event_type_formatted = 'hurricane') OR
                                     (incident_type = 'coastal' AND event_type_formatted = 'tornado') OR
                                     (incident_type = 'earthquake' AND event_type_formatted = 'landslide') OR
                                     (incident_type = 'tornado' AND event_type_formatted = 'coastal') OR
                                     (incident_type = 'tornado' AND event_type_formatted = 'Heavy Rain') OR
                                     (incident_type = 'tornado' AND event_type_formatted = 'lightning') OR
                                     (incident_type = 'tornado' AND event_type_formatted = 'wind') OR
                                     (incident_type = 'tornado' AND event_type_formatted = 'hail')
                             )
        WHERE year >= 2000
        ORDER BY disaster_number
    ),
    disaster_division_factor as (
        select disaster_number, count(1) division_factor
        from disaster_number_to_event_id_mapping_without_hazard_type
        group by disaster_number
        order by 1 desc
    ),
    pa_data as (
        select disaster_number::text,
               lpad(state_number_code::text, 2, '0') || lpad(county_code::text, 3, '0') geoid,
               extract(YEAR from declaration_date) as year,
               incident_type,
               sum(coalesce(project_amount, 0)) project_amount
        from open_fema_data.public_assistance_funded_projects_details_v1
        where dcc not in ('A', 'B', 'Z')
          and lpad(state_number_code::text, 2, '0') || lpad(county_code::text, 3, '0') not like '*'
          and extract(YEAR from declaration_date) >= 2000
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
          and substring(ihp.geoid, 1, 5) not like '*'
          and extract(YEAR from ihp.declaration_date) >= 2000
        group by 1,2,3,4
    ),
    ihp_pa_merge as (
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
    ofd as (
        SELECT fips_state_code || fips_county_code geoid,
               dd.disaster_number::text,
               extract(YEAR from incident_begin_date) as year,
               dd.incident_type,
               min(incident_begin_date)                                      fema_incident_begin_date,
               max(incident_end_date)                                        fema_incident_end_date,
               sum(ihp_verified_loss)                                     as ihp_verified_loss,
               sum(ha_loss) 											   as ha_loss,
               sum(project_amount) 									   as project_amount
        FROM  open_fema_data.disaster_declarations_summaries_v2 dd
                  LEFT JOIN ihp_pa_merge
                            ON dd.disaster_number::text = ihp_pa_merge.disaster_number
                                AND fips_state_code || fips_county_code = geoid
        WHERE fy_declared >= 2000
          AND dd.fips_state_code || dd.fips_county_code not like '*'
          AND dd.incident_type not in ('Biological', 'Other', 'Terrorist', 'Chemical', 'Human Cause', 'Toxic Substances')
        GROUP BY 1, 2, 3, 4
        ORDER BY ihp_verified_loss, ha_loss, project_amount
    ),
    sba as (
        SELECT
            year,
            substring(geoid, 1, 5) geoid,
            fema_disaster_number disaster_number,
            SUM(coalesce(total_verified_loss, 0)) sba_loss
        FROM public.sba_disaster_loan_data_new
        WHERE year >= 2000
          AND substring(geoid, 1, 5) not like '*'
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
        WHERE year_of_loss >= 2000
          AND county_code not like '*'
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
                  WHERE EXTRACT(YEAR FROM incident_begin_date ) >= 2000
                    AND fips_state_code || fips_county_code not like '*'
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
                    AND state_fips || county_fips not like '*'
                    AND month_of_loss != ''
                    AND commodity_year_identifier::int >= 2000
    ),
    croploss as (
        SELECT geoid, disaster_number::text, year, SUM(indemnity_amount) crop_loss
        FROM disasters d
                 JOIN crop_loss c
                      ON d.county = c.geoid
                          AND (c.year BETWEEN d.begin_year AND d.end_year OR c.year = d.begin_year)
                          AND (c.month BETWEEN d.begin_month AND d.end_month OR c.month = d.begin_month)
                          AND d.incident_type = c.cause_of_loss_desc
        WHERE geoid not like '*'
        GROUP BY 1, 2, 3
        ORDER BY 1, 2
    ),
    swd as (SELECT
                dd.disaster_number::text,
                substring(geoid, 1, 5) geoid,
                sw.episode_id,
                sw.event_id,
                event_type,
                min(incident_begin_date) fema_incident_begin_date,
                max(incident_end_date) fema_incident_end_date,
                min(begin_date_time) swd_begin_date,
                max(end_date_time) swd_end_date,
                sum(property_damage)                        as swd_property_damage,
                sum(crop_damage) 							 as swd_crop_damage,
                sum(injuries_direct) injuries_direct,
                sum(injuries_indirect) injuries_indirect,
                sum(deaths_direct) deaths_direct,
                sum(deaths_indirect) deaths_indirect
            FROM severe_weather_new.details sw
                     LEFT JOIN disaster_number_to_event_id_mapping_without_hazard_type dn_eid
                               on sw.event_id = dn_eid.event_id
                     LEFT JOIN open_fema_data.disaster_declarations_summaries_v2 dd
                               on dd.disaster_number = dn_eid.disaster_number
                                   AND substring(geoid, 1, 5) = fips_state_code || fips_county_code
            WHERE year >= 2000
              AND substring(geoid, 1, 5) not like '*'
            group by 1, 2, 3, 4
            order by 1, 2),
    disaster_summaries_merge_without_hazard_type_2 as (
        select
            coalesce(ofd.geoid, swd.geoid) geoid,
            ofd.disaster_number, swd.episode_id,
            STRING_AGG(distinct event_id::text, ',') event_id,

            CASE
                WHEN event_type IN ('High Wind','Strong Wind','Marine High Wind','Marine Strong Wind','Marine Thunderstorm Wind','Thunderstorm Wind','THUNDERSTORM WINDS LIGHTNING','TORNADOES, TSTM WIND, HAIL','THUNDERSTORM WIND/ TREES','THUNDERSTORM WINDS HEAVY RAIN','Heavy Wind','THUNDERSTORM WINDS/FLASH FLOOD','THUNDERSTORM WINDS/ FLOOD','THUNDERSTORM WINDS/HEAVY RAIN','THUNDERSTORM WIND/ TREE','THUNDERSTORM WINDS FUNNEL CLOU','THUNDERSTORM WINDS/FLOODING')
                    THEN 'wind'
                WHEN event_type IN ('Wildfire')
                    THEN 'wildfire'
                WHEN event_type IN ('Tsunami','Seiche')
                    THEN 'tsunami'
                WHEN event_type IN ('Tornado','TORNADOES, TSTM WIND, HAIL','TORNADO/WATERSPOUT','Funnel Cloud','Waterspout')
                    THEN 'tornado'
                WHEN event_type IN ('Flood','Flash Flood','THUNDERSTORM WINDS/FLASH FLOOD','THUNDERSTORM WINDS/ FLOOD','Coastal Flood','Lakeshore Flood')
                    THEN 'riverine'
                WHEN event_type IN ('Lightning','Marine Lightning')
                    THEN 'lightning'
                WHEN event_type IN ('Landslide','Debris Flow')
                    THEN 'landslide'
                WHEN event_type IN ('Ice Storm','Sleet')
                    THEN 'icestorm'
                WHEN event_type IN ('Hurricane','Hurricane (Typhoon)','Marine Hurricane/Typhoon','Marine Tropical Storm','Tropical Storm','Tropical Depression','Marine Tropical Depression','Hurricane Flood')
                    THEN 'hurricane'
                WHEN event_type IN ('Heat','Excessive Heat')
                    THEN 'heatwave'
                WHEN event_type IN ('Hail','Marine Hail','TORNADOES, TSTM WIND, HAIL','HAIL/ICY ROADS','HAIL FLOODING')
                    THEN 'hail'
                WHEN event_type IN ('Drought')
                    THEN 'drought'
                WHEN event_type IN ('Avalanche')
                    THEN 'avalanche'
                WHEN event_type IN ('Cold/Wind Chill','Extreme Cold/Wind Chill','Frost/Freeze','Cold/Wind Chill')
                    THEN 'coldwave'
                WHEN event_type IN ('Winter Weather','Winter Storm','Heavy Snow','Blizzard','High Snow','Lake-Effect Snow')
                    THEN 'winterweat'
                WHEN event_type IN ('Volcanic Ash','Volcanic Ashfall')
                    THEN 'volcano'
                WHEN event_type IN ('High Surf','Sneakerwave','Storm Surge/Tide','Rip Current')
                    THEN 'coastal'
                END
                event_type,
            STRING_AGG(distinct CASE
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
                                    WHEN lower(incident_type) = 'tornado'
                                        THEN 'tornado'
                                    WHEN lower(incident_type) = 'tsunami'
                                        THEN 'tsunami'
                                    WHEN lower(incident_type) = 'volcano'
                                        THEN 'volcano'
                                    ELSE incident_type
                END, ',') hazard,
            min(coalesce(swd.fema_incident_begin_date, ofd.fema_incident_begin_date)) fema_incident_begin_date,
            max(coalesce(swd.fema_incident_end_date, ofd.fema_incident_end_date))   fema_incident_end_date,
            min(swd_begin_date)			  swd_begin_date,
            max(swd_end_date)			  swd_end_date,

            sum(coalesce(ihp_verified_loss, 0) +
                coalesce(project_amount, 0) +
                coalesce(sba_loss, 0) +
                coalesce(total_amount_paid, 0)) fema_property_damage,

            sum(coalesce(crop_loss, 0))     fema_crop_damage,
            sum(swd.swd_property_damage) 	swd_property_damage,
            sum(swd.swd_crop_damage)		swd_crop_damage,
            sum(injuries_direct) injuries_direct,
            sum(injuries_indirect) injuries_indirect,
            sum(deaths_direct) deaths_direct,
            sum(deaths_indirect) deaths_indirect

        from ofd full outer join sba
                                 on ofd.disaster_number = sba.disaster_number
                                     and ofd.geoid = sba.geoid
                                     and ofd.year = sba.year

                 full outer join nfipPayout nfip
                                 ON ofd.year = nfip.year_of_loss
                                     AND ofd.geoid = nfip.county_code
                                     AND ofd.disaster_number = nfip.disaster_number

                 full outer join croploss
                                 ON ofd.disaster_number = croploss.disaster_number
                                     and ofd.geoid = croploss.geoid
                                     and ofd.year = croploss.year

                 full outer join swd
                                 ON ofd.disaster_number = swd.disaster_number
                                     and ofd.geoid = swd.geoid
        GROUP BY 1, 2, 3, 5
    ),
    details_fema_per_basis as (
        SELECT
            generate_series(coalesce(fema_incident_begin_date, swd_begin_date)::date,
                            LEAST(
                                    coalesce(fema_incident_end_date, swd_end_date)::date,
                                    CASE WHEN coalesce(hazard, event_type) = 'drought' THEN coalesce(fema_incident_begin_date, swd_begin_date)::date + INTERVAL '365 days' ELSE coalesce(fema_incident_begin_date, swd_begin_date)::date + INTERVAL '31 days' END
                                ), '1 day'::interval)::date event_day_date,
            coalesce(event_type, hazard) hazard,
            geoid,
            sum(swd_property_damage::double precision/LEAST(
                    (select array_length(array_agg(i), 1) from generate_series(coalesce(fema_incident_begin_date, swd_begin_date)::date,
                                                                               coalesce(fema_incident_end_date, swd_end_date)::date, '1 day'::interval) i),
                    CASE WHEN coalesce(hazard, event_type) = 'drought' THEN 365 ELSE 31 END)) swd_property_damage,

            sum(swd_crop_damage::double precision/LEAST(
                    (select array_length(array_agg(i), 1) from generate_series(coalesce(fema_incident_begin_date, swd_begin_date)::date,
                                                                               coalesce(fema_incident_end_date, swd_end_date)::date, '1 day'::interval) i),
                    CASE WHEN coalesce(hazard, event_type) = 'drought' THEN 365 ELSE 31 END)) swd_crop_damage,

            sum(injuries_direct::double precision/LEAST(
                    (select array_length(array_agg(i), 1) from generate_series(coalesce(fema_incident_begin_date, swd_begin_date)::date,
                                                                               coalesce(fema_incident_end_date, swd_end_date)::date, '1 day'::interval) i),
                    CASE WHEN coalesce(hazard, event_type) = 'drought' THEN 365 ELSE 31 END)) injuries_direct,
            sum(injuries_indirect::double precision/LEAST(
                    (select array_length(array_agg(i), 1) from generate_series(coalesce(fema_incident_begin_date, swd_begin_date)::date,
                                                                               coalesce(fema_incident_end_date, swd_end_date)::date, '1 day'::interval) i),
                    CASE WHEN coalesce(hazard, event_type) = 'drought' THEN 365 ELSE 31 END)) injuries_indirect,
            sum(deaths_direct::double precision/LEAST(
                    (select array_length(array_agg(i), 1) from generate_series(coalesce(fema_incident_begin_date, swd_begin_date)::date,
                                                                               coalesce(fema_incident_end_date, swd_end_date)::date, '1 day'::interval) i),
                    CASE WHEN coalesce(hazard, event_type) = 'drought' THEN 365 ELSE 31 END)) deaths_direct,
            sum(deaths_indirect::double precision /LEAST(
                    (select array_length(array_agg(i), 1) from generate_series(coalesce(fema_incident_begin_date, swd_begin_date)::date,
                                                                               coalesce(fema_incident_end_date, swd_end_date)::date, '1 day'::interval) i),
                    CASE WHEN coalesce(hazard, event_type) = 'drought' THEN 365 ELSE 31 END)) deaths_inderect,
            sum(fema_property_damage/LEAST(
                    (select array_length(array_agg(i), 1) from generate_series(coalesce(fema_incident_begin_date, swd_begin_date)::date,
                                                                               coalesce(fema_incident_end_date, swd_end_date)::date, '1 day'::interval) i),
                    CASE WHEN coalesce(hazard, event_type) = 'drought' THEN 365 ELSE 31 END)) fema_property_damage,
            sum(fema_crop_damage/LEAST(
                    (select array_length(array_agg(i), 1) from generate_series(coalesce(fema_incident_begin_date, swd_begin_date)::date,
                                                                               coalesce(fema_incident_end_date, swd_end_date)::date, '1 day'::interval) i),
                    CASE WHEN coalesce(hazard, event_type) = 'drought' THEN 365 ELSE 31 END)) fema_crop_damage,
            sum(((
                             injuries_direct / LEAST(
                                 (select array_length(array_agg(i), 1) from generate_series(coalesce(fema_incident_begin_date, swd_begin_date)::date,
                                                                                            coalesce(fema_incident_end_date, swd_end_date)::date, '1 day'::interval) i),
                                 CASE WHEN coalesce(hazard, event_type) = 'drought' THEN 365 ELSE 31 END) +
                             injuries_indirect / LEAST(
                                     (select array_length(array_agg(i), 1) from generate_series(coalesce(fema_incident_begin_date, swd_begin_date)::date,
                                                                                                coalesce(fema_incident_end_date, swd_end_date)::date, '1 day'::interval) i),
                                     CASE WHEN coalesce(hazard, event_type) = 'drought' THEN 365 ELSE 31 END) +
                             deaths_direct / LEAST(
                                     (select array_length(array_agg(i), 1) from generate_series(coalesce(fema_incident_begin_date, swd_begin_date)::date,
                                                                                                coalesce(fema_incident_end_date, swd_end_date)::date, '1 day'::interval) i),
                                     CASE WHEN coalesce(hazard, event_type) = 'drought' THEN 365 ELSE 31 END) +
                             deaths_indirect / LEAST(
                                     (select array_length(array_agg(i), 1) from generate_series(coalesce(fema_incident_begin_date, swd_begin_date)::date,
                                                                                                coalesce(fema_incident_end_date, swd_end_date)::date, '1 day'::interval) i),
                                     CASE WHEN coalesce(hazard, event_type) = 'drought' THEN 365 ELSE 31 END)
                     )/10)*7600000) fatalities_dollar_value
        FROM disaster_summaries_merge_without_hazard_type_2
        WHERE coalesce(hazard, event_type) in ('coldwave', 'drought', 'heatwave', 'icestorm', 'riverine', 'winterweat')
          AND geoid is not null
        group by 1, 2, 3
        order by 1, 2, 3
    ),
    aggregation as (
        SELECT
            -- 		coalesce(fema_incident_begin_date, swd_begin_date) begin_date,
            -- 		coalesce(fema_incident_end_date, swd_end_date) end_date,
            coalesce(event_type, hazard) hazard,
            geoid,
            sum (swd_property_damage) swd_property_damage,
            sum (swd_crop_damage) swd_crop_damage,
            sum(injuries_direct) injuries_direct,
            sum(injuries_indirect) injuries_indirect,
            sum(deaths_direct) deaths_direct,
            sum(deaths_indirect) deaths_indirect,
            avg (fema_property_damage) fema_property_damage,
            avg (fema_crop_damage) fema_crop_damage,
            sum((
                        (coalesce(injuries_direct, 0) +
                         coalesce(injuries_indirect, 0) +
                         coalesce(deaths_direct, 0) +
                         coalesce(deaths_indirect, 0)
                            )/10 ) * 7600000) fatalities_dollar_value
        from disaster_summaries_merge_without_hazard_type_2
        where coalesce(event_type, hazard) NOT IN ('coldwave', 'drought', 'heatwave', 'icestorm', 'riverine', 'winterweat')
        group by disaster_number, geoid, 1
    ),
    tmp_calculations as (

        select 'agg' src, hazard nri_category, geoid, swd_property_damage, swd_crop_damage, fema_property_damage, fema_crop_damage, fatalities_dollar_value
        from aggregation

        UNION

        select 'pb' src, hazard nri_category, geoid, swd_property_damage, swd_crop_damage, fema_property_damage, fema_crop_damage, fatalities_dollar_value
        from details_fema_per_basis

        order by 1, 2, 3
    ),
    lrpbs as (
        SELECT tmp_calculations.*,
               CASE
                   WHEN nri_category IN ('wind')
                       THEN swd_property_damage/ NULLIF (SWND_EXPB, 0)
                   WHEN nri_category IN ('wildfire')
                       THEN swd_property_damage/ NULLIF (WFIR_EXPB, 0)
                   WHEN nri_category IN ('tsunami')
                       THEN swd_property_damage/ NULLIF (TSUN_EXPB, 0)
                   WHEN nri_category IN ('tornado')
                       THEN swd_property_damage/ NULLIF (TRND_EXPB, 0)
                   WHEN nri_category IN ('riverine')
                       THEN swd_property_damage/ NULLIF (RFLD_EXPB, 0)
                   WHEN nri_category IN ('lightning')
                       THEN swd_property_damage/ NULLIF (LTNG_EXPB, 0)
                   WHEN nri_category IN ('landslide')
                       THEN swd_property_damage/ NULLIF (LNDS_EXPB, 0)
                   WHEN nri_category IN ('icestorm')
                       THEN swd_property_damage/ NULLIF (ISTM_EXPB, 0)
                   WHEN nri_category IN ('hurricane')
                       THEN swd_property_damage/ NULLIF (HRCN_EXPB, 0)
                   WHEN nri_category IN ('heatwave')
                       THEN swd_property_damage/ NULLIF (HWAV_EXPB, 0)
                   WHEN nri_category IN ('hail')
                       THEN swd_property_damage/ NULLIF (HAIL_EXPB, 0)
                   WHEN nri_category IN ('avalanche')
                       THEN swd_property_damage/ NULLIF (AVLN_EXPB, 0)
                   WHEN nri_category IN ('coldwave')
                       THEN swd_property_damage/ NULLIF (CWAV_EXPB, 0)
                   WHEN nri_category IN ('winterweat')
                       THEN swd_property_damage/ NULLIF (WNTW_EXPB, 0)
                   WHEN nri_category IN ('volcano')
                       THEN swd_property_damage/ NULLIF (VLCN_EXPB, 0)
                   WHEN nri_category IN ('coastal')
                       THEN swd_property_damage/ NULLIF (CFLD_EXPB, 0)
                   END building_loss_ratio_per_basis,
               CASE
                   WHEN nri_category IN ('wind')
                       THEN fema_property_damage/ NULLIF (SWND_EXPB, 0)
                   WHEN nri_category IN ('wildfire')
                       THEN fema_property_damage/ NULLIF (WFIR_EXPB, 0)
                   WHEN nri_category IN ('tsunami')
                       THEN fema_property_damage/ NULLIF (TSUN_EXPB, 0)
                   WHEN nri_category IN ('tornado')
                       THEN fema_property_damage/ NULLIF (TRND_EXPB, 0)
                   WHEN nri_category IN ('riverine')
                       THEN fema_property_damage/ NULLIF (RFLD_EXPB, 0)
                   WHEN nri_category IN ('lightning')
                       THEN fema_property_damage/ NULLIF (LTNG_EXPB, 0)
                   WHEN nri_category IN ('landslide')
                       THEN fema_property_damage/ NULLIF (LNDS_EXPB, 0)
                   WHEN nri_category IN ('icestorm')
                       THEN fema_property_damage/ NULLIF (ISTM_EXPB, 0)
                   WHEN nri_category IN ('hurricane')
                       THEN fema_property_damage/ NULLIF (HRCN_EXPB, 0)
                   WHEN nri_category IN ('heatwave')
                       THEN fema_property_damage/ NULLIF (HWAV_EXPB, 0)
                   WHEN nri_category IN ('hail')
                       THEN fema_property_damage/ NULLIF (HAIL_EXPB, 0)
                   WHEN nri_category IN ('avalanche')
                       THEN fema_property_damage/ NULLIF (AVLN_EXPB, 0)
                   WHEN nri_category IN ('coldwave')
                       THEN fema_property_damage/ NULLIF (CWAV_EXPB, 0)
                   WHEN nri_category IN ('winterweat')
                       THEN fema_property_damage/ NULLIF (WNTW_EXPB, 0)
                   WHEN nri_category IN ('volcano')
                       THEN fema_property_damage/ NULLIF (VLCN_EXPB, 0)
                   WHEN nri_category IN ('coastal')
                       THEN fema_property_damage/ NULLIF (CFLD_EXPB, 0)
                   END fema_building_loss_ratio_per_basis,

               CASE
                   WHEN nri_category IN ('wind')
                       THEN fema_crop_damage/ NULLIF (SWND_expa, 0)
                   WHEN nri_category IN ('wildfire')
                       THEN fema_crop_damage/ NULLIF (WFIR_expa, 0)
                   WHEN nri_category IN ('tornado')
                       THEN fema_crop_damage/ NULLIF (TRND_expa, 0)
                   WHEN nri_category IN ('riverine')
                       THEN fema_crop_damage/ NULLIF (RFLD_expa, 0)
                   WHEN nri_category IN ('hurricane')
                       THEN fema_crop_damage/ NULLIF (HRCN_expa, 0)
                   WHEN nri_category IN ('heatwave')
                       THEN fema_crop_damage/ NULLIF (HWAV_expa, 0)
                   WHEN nri_category IN ('hail')
                       THEN fema_crop_damage/ NULLIF (HAIL_expa, 0)
                   WHEN nri_category IN ('drought')
                       THEN fema_crop_damage/NULLIF(DRGT_expa, 0)
                   WHEN nri_category IN ('coldwave')
                       THEN fema_crop_damage/ NULLIF (CWAV_expa, 0)
                   WHEN nri_category IN ('winterweat')
                       THEN fema_crop_damage/ NULLIF (WNTW_expa, 0)
                   END fema_crop_loss_ratio_per_basis,

               CASE
                   WHEN nri_category IN ('wind')
                       THEN swd_crop_damage/ NULLIF (SWND_EXPA, 0)
                   WHEN nri_category IN ('wildfire')
                       THEN swd_crop_damage/ NULLIF (WFIR_EXPA, 0)
                   WHEN nri_category IN ('tornado')
                       THEN swd_crop_damage/ NULLIF (TRND_EXPA, 0)
                   WHEN nri_category IN ('riverine')
                       THEN swd_crop_damage/ NULLIF (RFLD_EXPA, 0)
                   WHEN nri_category IN ('hurricane')
                       THEN swd_crop_damage/ NULLIF (HRCN_EXPA, 0)
                   WHEN nri_category IN ('heatwave')
                       THEN swd_crop_damage/ NULLIF (HWAV_EXPA, 0)
                   WHEN nri_category IN ('hail')
                       THEN swd_crop_damage/ NULLIF (HAIL_EXPA, 0)
                   WHEN nri_category IN ('drought')
                       THEN swd_crop_damage/ NULLIF (DRGT_EXPA, 0)
                   WHEN nri_category IN ('coldwave')
                       THEN swd_crop_damage/ NULLIF (CWAV_EXPA, 0)
                   WHEN nri_category IN ('winterweat')
                       THEN swd_crop_damage/ NULLIF (WNTW_EXPA, 0)
                   END crop_loss_ratio_per_basis,
               CASE
                   WHEN nri_category IN ('wind')
                       THEN fatalities_dollar_value/ NULLIF (SWND_EXPPE, 0)
                   WHEN nri_category IN ('wildfire')
                       THEN fatalities_dollar_value/ NULLIF (WFIR_EXPPE, 0)
                   WHEN nri_category IN ('tsunami')
                       THEN fatalities_dollar_value/ NULLIF (TSUN_EXPPE, 0)
                   WHEN nri_category IN ('tornado')
                       THEN fatalities_dollar_value/ NULLIF (TRND_EXPPE, 0)
                   WHEN nri_category IN ('riverine')
                       THEN fatalities_dollar_value/ NULLIF (RFLD_EXPPE, 0)
                   WHEN nri_category IN ('lightning')
                       THEN fatalities_dollar_value/ NULLIF (LTNG_EXPPE, 0)
                   WHEN nri_category IN ('landslide')
                       THEN fatalities_dollar_value/ NULLIF (LNDS_EXPPE, 0)
                   WHEN nri_category IN ('icestorm')
                       THEN fatalities_dollar_value/ NULLIF (ISTM_EXPPE, 0)
                   WHEN nri_category IN ('hurricane')
                       THEN fatalities_dollar_value/ NULLIF (HRCN_EXPPE, 0)
                   WHEN nri_category IN ('heatwave')
                       THEN fatalities_dollar_value/ NULLIF (HWAV_EXPPE, 0)
                   WHEN nri_category IN ('hail')
                       THEN fatalities_dollar_value/ NULLIF (HAIL_EXPPE, 0)
                   WHEN nri_category IN ('avalanche')
                       THEN fatalities_dollar_value/ NULLIF (AVLN_EXPPE, 0)
                   WHEN nri_category IN ('coldwave')
                       THEN fatalities_dollar_value/ NULLIF (CWAV_EXPPE, 0)
                   WHEN nri_category IN ('winterweat')
                       THEN fatalities_dollar_value/ NULLIF (WNTW_EXPPE, 0)
                   WHEN nri_category IN ('volcano')
                       THEN fatalities_dollar_value/ NULLIF (VLCN_EXPPE, 0)
                   WHEN nri_category IN ('coastal')
                       THEN fatalities_dollar_value/ NULLIF (CFLD_EXPPE, 0)
                   END population_loss_ratio_per_basis
        FROM tmp_calculations
                 JOIN national_risk_index.nri_counties_november_2021 nri
                      ON tmp_calculations.geoid = nri.stcofips),
    national as (
        select nri_category,
               count (1),
               avg (Least(COALESCE (building_loss_ratio_per_basis, 0), 1)) b_av_n,
               avg (Least(COALESCE (crop_loss_ratio_per_basis, 0), 1)) c_av_n,
               avg (Least(COALESCE (population_loss_ratio_per_basis, 0), 1)) p_av_n,
               avg (Least(COALESCE (fema_building_loss_ratio_per_basis, 0), 1)) f_av_n,
               avg (Least(COALESCE (fema_crop_loss_ratio_per_basis, 0), 1)) fc_av_n,
               variance(Least(COALESCE (building_loss_ratio_per_basis, 0), 1)) b_va_n,
               variance(Least(COALESCE (crop_loss_ratio_per_basis, 0), 1)) c_va_n,
               variance(Least(COALESCE (population_loss_ratio_per_basis, 0), 1)) p_va_n,
               variance(Least(COALESCE (fema_building_loss_ratio_per_basis, 0), 1)) f_va_n,
               variance(Least(COALESCE (fema_crop_loss_ratio_per_basis, 0), 1)) fc_va_n

        from lrpbs as a
        WHERE nri_category is not null
        group by 1
        order by 1),
    regional as (
        select a.geoid, region,
               nri_category,
               count (1),
               avg (Least(COALESCE (building_loss_ratio_per_basis, 0), 1)) b_av_r,
               avg (Least(COALESCE (crop_loss_ratio_per_basis, 0), 1)) c_av_r,
               avg (Least(COALESCE (population_loss_ratio_per_basis, 0), 1)) p_av_r,
               avg (Least(COALESCE (fema_building_loss_ratio_per_basis, 0), 1)) f_av_r,
               avg (Least(COALESCE (fema_crop_loss_ratio_per_basis, 0), 1)) fc_av_r,
               variance(Least(COALESCE (building_loss_ratio_per_basis, 0), 1)) b_va_r,
               variance(Least(COALESCE (crop_loss_ratio_per_basis, 0), 1)) c_va_r,
               variance(Least(COALESCE (population_loss_ratio_per_basis, 0), 1)) p_va_r,
               variance(Least(COALESCE (fema_building_loss_ratio_per_basis, 0), 1)) f_va_r,
               variance(Least(COALESCE (fema_crop_loss_ratio_per_basis, 0), 1)) fc_va_r

        from lrpbs as a
                 join severe_weather_new.fips_to_regions_and_surrounding_counties as b
                      on b.fips = a.geoid
                          and nri_category != 'hurricane'
        WHERE nri_category is not null
        group by 1, 2, 3

        UNION

        select a.geoid, region,
               nri_category,
               count (1),
               avg (Least(COALESCE (building_loss_ratio_per_basis, 0), 1)) b_av_r,
               avg (Least(COALESCE (crop_loss_ratio_per_basis, 0), 1)) c_av_r,
               avg (Least(COALESCE (population_loss_ratio_per_basis, 0), 1)) p_av_r,
               avg (Least(COALESCE (fema_building_loss_ratio_per_basis, 0), 1)) f_av_r,
               avg (Least(COALESCE (fema_crop_loss_ratio_per_basis, 0), 1)) fc_av_r,
               variance(Least(COALESCE (building_loss_ratio_per_basis, 0), 1)) b_va_r,
               variance(Least(COALESCE (crop_loss_ratio_per_basis, 0), 1)) c_va_r,
               variance(Least(COALESCE (population_loss_ratio_per_basis, 0), 1)) p_va_r,
               variance(Least(COALESCE (fema_building_loss_ratio_per_basis, 0), 1)) f_va_r,
               variance(Least(COALESCE (fema_crop_loss_ratio_per_basis, 0), 1)) fc_va_r

        from lrpbs as a
                 join severe_weather_new.fips_to_regions_and_surrounding_counties_hurricane as b
                      on b.fips = a.geoid
                          and nri_category = 'hurricane'
        WHERE nri_category is not null
        group by 1, 2, 3
        order by 1, 2, 3

    ),
    county as (
        select LEFT (b.fips, 5) fips,
               nri_category,
               count (1),
               avg (Least(COALESCE (building_loss_ratio_per_basis, 0), 1)) b_av_c,
               avg (Least(COALESCE (crop_loss_ratio_per_basis, 0), 1)) c_av_c,
               avg (Least(COALESCE (population_loss_ratio_per_basis, 0), 1)) p_av_c,
               avg (Least(COALESCE (fema_building_loss_ratio_per_basis, 0), 1)) f_av_c,
               avg (Least(COALESCE (fema_crop_loss_ratio_per_basis, 0), 1)) fc_av_c,
               variance(Least(COALESCE (building_loss_ratio_per_basis, 0), 1)) b_va_c,
               variance(Least(COALESCE (crop_loss_ratio_per_basis, 0), 1)) c_va_c,
               variance(Least(COALESCE (population_loss_ratio_per_basis, 0), 1)) p_va_c,
               variance(Least(COALESCE (fema_building_loss_ratio_per_basis, 0), 1)) f_va_c,
               variance(Least(COALESCE (fema_crop_loss_ratio_per_basis, 0), 1)) fc_va_c

        from lrpbs as a
                 join severe_weather_new.fips_to_regions_and_surrounding_counties as b
                      on b.fips = a.geoid
                          and nri_category != 'hurricane'
        WHERE nri_category is not null
        group by 1, 2

        UNION

        select LEFT (b.fips, 5) fips,
               nri_category,
               count (1),
               avg (Least(COALESCE (building_loss_ratio_per_basis, 0), 1)) b_av_c,
               avg (Least(COALESCE (crop_loss_ratio_per_basis, 0), 1)) c_av_c,
               avg (Least(COALESCE (population_loss_ratio_per_basis, 0), 1)) p_av_c,
               avg (Least(COALESCE (fema_building_loss_ratio_per_basis, 0), 1)) f_av_c,
               avg (Least(COALESCE (fema_crop_loss_ratio_per_basis, 0), 1)) fc_av_c,
               variance(Least(COALESCE (building_loss_ratio_per_basis, 0), 1)) b_va_c,
               variance(Least(COALESCE (crop_loss_ratio_per_basis, 0), 1)) c_va_c,
               variance(Least(COALESCE (population_loss_ratio_per_basis, 0), 1)) p_va_c,
               variance(Least(COALESCE (fema_building_loss_ratio_per_basis, 0), 1)) f_va_c,
               variance(Least(COALESCE (fema_crop_loss_ratio_per_basis, 0), 1)) fc_va_c

        from lrpbs as a
                 join severe_weather_new.fips_to_regions_and_surrounding_counties_hurricane as b
                      on b.fips = a.geoid
                          and nri_category = 'hurricane'
        WHERE nri_category is not null
        group by 1, 2
        order by 1, 2),
    surrounding as (
        select a.geoid, surrounding_counties fips,
               nri_category,
               count (1),
               avg (Least(COALESCE (building_loss_ratio_per_basis, 0), 1)) b_av_s,
               avg (Least(COALESCE (crop_loss_ratio_per_basis, 0), 1)) c_av_s,
               avg (Least(COALESCE (population_loss_ratio_per_basis, 0), 1)) p_av_s,
               avg (Least(COALESCE (fema_building_loss_ratio_per_basis, 0), 1)) f_av_s,
               avg (Least(COALESCE (fema_crop_loss_ratio_per_basis, 0), 1)) fc_av_s,
               variance(Least(COALESCE (building_loss_ratio_per_basis, 0), 1)) b_va_s,
               variance(Least(COALESCE (crop_loss_ratio_per_basis, 0), 1)) c_va_s,
               variance(Least(COALESCE (population_loss_ratio_per_basis, 0), 1)) p_va_s,
               variance(Least(COALESCE (fema_building_loss_ratio_per_basis, 0), 1)) f_va_s,
               variance(Least(COALESCE (fema_crop_loss_ratio_per_basis, 0), 1)) fc_va_s

        from lrpbs as a
                 join severe_weather_new.fips_to_regions_and_surrounding_counties as b
                      on b.fips = a.geoid
                          and nri_category != 'hurricane'
        WHERE nri_category is not null
        group by 1, 2, 3


        UNION

        select a.geoid, surrounding_counties fips,
               nri_category,
               count (1),
               avg (Least(COALESCE (building_loss_ratio_per_basis, 0), 1)) b_av_s,
               avg (Least(COALESCE (crop_loss_ratio_per_basis, 0), 1)) c_av_s,
               avg (Least(COALESCE (population_loss_ratio_per_basis, 0), 1)) p_av_s,
               avg (Least(COALESCE (fema_building_loss_ratio_per_basis, 0), 1)) f_av_s,
               avg (Least(COALESCE (fema_crop_loss_ratio_per_basis, 0), 1)) fc_av_s,
               variance(Least(COALESCE (building_loss_ratio_per_basis, 0), 1)) b_va_s,
               variance(Least(COALESCE (crop_loss_ratio_per_basis, 0), 1)) c_va_s,
               variance(Least(COALESCE (population_loss_ratio_per_basis, 0), 1)) p_va_s,
               variance(Least(COALESCE (fema_building_loss_ratio_per_basis, 0), 1)) f_va_s,
               variance(Least(COALESCE (fema_crop_loss_ratio_per_basis, 0), 1)) fc_va_s
        from lrpbs as a
                 join severe_weather_new.fips_to_regions_and_surrounding_counties_hurricane as b
                      on b.fips = a.geoid
                          and nri_category = 'hurricane'
        WHERE nri_category is not null
        group by 1, 2, 3
        order by 1, 2, 3
    ),

    hlr as (
        SELECT county.fips geoid,
               regional.region,
               surrounding.fips surrounding,
               county.nri_category,

               COALESCE(((
                                 (1.0 / NULLIF(b_va_n, 0)) /
                                 (
                                         COALESCE(1.0 / NULLIF(b_va_n, 0), 0) +
                                         COALESCE(1.0 / NULLIF(b_va_r, 0), 0) +
                                         COALESCE(1.0 / NULLIF(b_va_c, 0), 0) +
                                         COALESCE(1.0 / NULLIF(b_va_s, 0), 0)
                                     )
                             ) *
                         b_av_n), 0) +
               COALESCE(((
                                 (1.0 / NULLIF(b_va_r, 0)) /
                                 (
                                         COALESCE(1.0 / NULLIF(b_va_n, 0), 0) +
                                         COALESCE(1.0 / NULLIF(b_va_r, 0), 0) +
                                         COALESCE(1.0 / NULLIF(b_va_c, 0), 0) +
                                         COALESCE(1.0 / NULLIF(b_va_s, 0), 0)
                                     )
                             ) *
                         b_av_r), 0) +
               COALESCE(((
                                 (1.0 / NULLIF(b_va_c, 0)) /
                                 (
                                         COALESCE(1.0 / NULLIF(b_va_n, 0), 0) +
                                         COALESCE(1.0 / NULLIF(b_va_r, 0), 0) +
                                         COALESCE(1.0 / NULLIF(b_va_c, 0), 0) +
                                         COALESCE(1.0 / NULLIF(b_va_s, 0), 0)
                                     )
                             ) *
                         b_av_c), 0) +
               COALESCE(((
                                 (1.0 / NULLIF(b_va_s, 0)) /
                                 (
                                         COALESCE(1.0 / NULLIF(b_va_n, 0), 0) +
                                         COALESCE(1.0 / NULLIF(b_va_r, 0), 0) +
                                         COALESCE(1.0 / NULLIF(b_va_c, 0), 0) +
                                         COALESCE(1.0 / NULLIF(b_va_s, 0), 0)
                                     )
                             ) *
                         b_av_s), 0) AS hlr_b,

               COALESCE(((
                                 (1.0 / NULLIF(c_va_n, 0)) /
                                 (
                                         COALESCE(1.0 / NULLIF(c_va_n, 0), 0) +
                                         COALESCE(1.0 / NULLIF(c_va_r, 0), 0) +
                                         COALESCE(1.0 / NULLIF(c_va_c, 0), 0) +
                                         COALESCE(1.0 / NULLIF(c_va_s, 0), 0)
                                     )
                             ) *
                         c_av_n), 0) +
               COALESCE(((
                                 (1.0 / NULLIF(c_va_r, 0)) /
                                 (
                                         COALESCE(1.0 / NULLIF(c_va_n, 0), 0) +
                                         COALESCE(1.0 / NULLIF(c_va_r, 0), 0) +
                                         COALESCE(1.0 / NULLIF(c_va_c, 0), 0) +
                                         COALESCE(1.0 / NULLIF(c_va_s, 0), 0)
                                     )
                             ) *
                         c_av_r), 0) +
               COALESCE(((
                                 (1.0 / NULLIF(c_va_c, 0)) /
                                 (
                                         COALESCE(1.0 / NULLIF(c_va_n, 0), 0) +
                                         COALESCE(1.0 / NULLIF(c_va_r, 0), 0) +
                                         COALESCE(1.0 / NULLIF(c_va_c, 0), 0) +
                                         COALESCE(1.0 / NULLIF(c_va_s, 0), 0)
                                     )
                             ) *
                         c_av_c), 0) +
               COALESCE(((
                                 (1.0 / NULLIF(c_va_s, 0)) /
                                 (
                                         COALESCE(1.0 / NULLIF(c_va_n, 0), 0) +
                                         COALESCE(1.0 / NULLIF(c_va_r, 0), 0) +
                                         COALESCE(1.0 / NULLIF(c_va_c, 0), 0) +
                                         COALESCE(1.0 / NULLIF(c_va_s, 0), 0)
                                     )
                             ) *
                         c_av_s), 0) AS hlr_c,

               COALESCE(((
                                 (1.0 / NULLIF(p_va_n, 0)) /
                                 (
                                         COALESCE(1.0 / NULLIF(p_va_n, 0), 0) +
                                         COALESCE(1.0 / NULLIF(p_va_r, 0), 0) +
                                         COALESCE(1.0 / NULLIF(p_va_c, 0), 0) +
                                         COALESCE(1.0 / NULLIF(p_va_s, 0), 0)
                                     )
                             ) *
                         p_av_n), 0) +
               COALESCE(((
                                 (1.0 / NULLIF(p_va_r, 0)) /
                                 (
                                         COALESCE(1.0 / NULLIF(p_va_n, 0), 0) +
                                         COALESCE(1.0 / NULLIF(p_va_r, 0), 0) +
                                         COALESCE(1.0 / NULLIF(p_va_c, 0), 0) +
                                         COALESCE(1.0 / NULLIF(p_va_s, 0), 0)
                                     )
                             ) *
                         p_av_r), 0) +
               COALESCE(((
                                 (1.0 / NULLIF(p_va_c, 0)) /
                                 (
                                         COALESCE(1.0 / NULLIF(p_va_n, 0), 0) +
                                         COALESCE(1.0 / NULLIF(p_va_r, 0), 0) +
                                         COALESCE(1.0 / NULLIF(p_va_c, 0), 0) +
                                         COALESCE(1.0 / NULLIF(p_va_s, 0), 0)
                                     )
                             ) *
                         p_av_c), 0) +
               COALESCE(((
                                 (1.0 / NULLIF(p_va_s, 0)) /
                                 (
                                         COALESCE(1.0 / NULLIF(p_va_n, 0), 0) +
                                         COALESCE(1.0 / NULLIF(p_va_r, 0), 0) +
                                         COALESCE(1.0 / NULLIF(p_va_c, 0), 0) +
                                         COALESCE(1.0 / NULLIF(p_va_s, 0), 0)
                                     )
                             ) *
                         p_av_s), 0) AS hlr_p,

               COALESCE(((
                                 (1.0 / NULLIF(f_va_n, 0)) /
                                 (
                                         COALESCE(1.0 / NULLIF(f_va_n, 0), 0) +
                                         COALESCE(1.0 / NULLIF(f_va_r, 0), 0) +
                                         COALESCE(1.0 / NULLIF(f_va_c, 0), 0) +
                                         COALESCE(1.0 / NULLIF(f_va_s, 0), 0)
                                     )
                             ) *
                         f_av_n), 0) +
               COALESCE(((
                                 (1.0 / NULLIF(f_va_r, 0)) /
                                 (
                                         COALESCE(1.0 / NULLIF(f_va_n, 0), 0) +
                                         COALESCE(1.0 / NULLIF(f_va_r, 0), 0) +
                                         COALESCE(1.0 / NULLIF(f_va_c, 0), 0) +
                                         COALESCE(1.0 / NULLIF(f_va_s, 0), 0)
                                     )
                             ) *
                         f_av_r), 0) +
               COALESCE(((
                                 (1.0 / NULLIF(f_va_c, 0)) /
                                 (
                                         COALESCE(1.0 / NULLIF(f_va_n, 0), 0) +
                                         COALESCE(1.0 / NULLIF(f_va_r, 0), 0) +
                                         COALESCE(1.0 / NULLIF(f_va_c, 0), 0) +
                                         COALESCE(1.0 / NULLIF(f_va_s, 0), 0)
                                     )
                             ) *
                         f_av_c), 0) +
               COALESCE(((
                                 (1.0 / NULLIF(f_va_s, 0)) /
                                 (
                                         COALESCE(1.0 / NULLIF(f_va_n, 0), 0) +
                                         COALESCE(1.0 / NULLIF(f_va_r, 0), 0) +
                                         COALESCE(1.0 / NULLIF(f_va_c, 0), 0) +
                                         COALESCE(1.0 / NULLIF(f_va_s, 0), 0)
                                     )
                             ) *
                         f_av_s), 0) AS hlr_f,

               COALESCE(((
                                 (1.0 / NULLIF(fc_va_n, 0)) /
                                 (
                                         COALESCE(1.0 / NULLIF(fc_va_n, 0), 0) +
                                         COALESCE(1.0 / NULLIF(fc_va_r, 0), 0) +
                                         COALESCE(1.0 / NULLIF(fc_va_c, 0), 0) +
                                         COALESCE(1.0 / NULLIF(fc_va_s, 0), 0)
                                     )
                             ) *
                         fc_av_n), 0) +
               COALESCE(((
                                 (1.0 / NULLIF(fc_va_r, 0)) /
                                 (
                                         COALESCE(1.0 / NULLIF(fc_va_n, 0), 0) +
                                         COALESCE(1.0 / NULLIF(fc_va_r, 0), 0) +
                                         COALESCE(1.0 / NULLIF(fc_va_c, 0), 0) +
                                         COALESCE(1.0 / NULLIF(fc_va_s, 0), 0)
                                     )
                             ) *
                         fc_av_r), 0) +
               COALESCE(((
                                 (1.0 / NULLIF(fc_va_c, 0)) /
                                 (
                                         COALESCE(1.0 / NULLIF(fc_va_n, 0), 0) +
                                         COALESCE(1.0 / NULLIF(fc_va_r, 0), 0) +
                                         COALESCE(1.0 / NULLIF(fc_va_c, 0), 0) +
                                         COALESCE(1.0 / NULLIF(fc_va_s, 0), 0)
                                     )
                             ) *
                         fc_av_c), 0) +
               COALESCE(((
                                 (1.0 / NULLIF(fc_va_s, 0)) /
                                 (
                                         COALESCE(1.0 / NULLIF(fc_va_n, 0), 0) +
                                         COALESCE(1.0 / NULLIF(fc_va_r, 0), 0) +
                                         COALESCE(1.0 / NULLIF(fc_va_c, 0), 0) +
                                         COALESCE(1.0 / NULLIF(fc_va_s, 0), 0)
                                     )
                             ) *
                         fc_av_s), 0) AS hlr_fc


        FROM county
                 JOIN national
                      ON county.nri_category = national.nri_category
                 JOIN regional
                      ON county.nri_category = regional.nri_category
                          AND county.fips = regional.geoid
                 JOIN surrounding
                      ON county.nri_category = surrounding.nri_category
                          AND county.fips = surrounding.geoid)




SELECT geoid, region, surrounding, nri_category,
       CASE
           WHEN nri_category IN ('coastal')
               THEN hlr_b * CFLD_EXPB  * CFLD_AFREQ
           WHEN nri_category IN ('coldwave')
               THEN hlr_b * CWAV_EXPB  * CWAV_AFREQ
           WHEN nri_category IN ('drought')
               THEN hlr_b * CWAV_EXPB  * CWAV_AFREQ
           WHEN nri_category IN ('hurricane')
               THEN hlr_b * HRCN_EXPB  * HRCN_AFREQ
           WHEN nri_category IN ('heatwave')
               THEN hlr_b * HWAV_EXPB  * HWAV_AFREQ
           WHEN nri_category IN ('hail')
               THEN hlr_b * HAIL_EXPB  * HAIL_AFREQ
           WHEN nri_category IN ('tornado')
               THEN hlr_b * TRND_EXPB  * TRND_AFREQ
           WHEN nri_category IN ('riverine')
               THEN hlr_b * RFLD_EXPB  * RFLD_AFREQ
           WHEN nri_category IN ('lightning')
               THEN hlr_b * LTNG_EXPB  * LTNG_AFREQ
           WHEN nri_category IN ('landslide')
               THEN hlr_b * LNDS_EXPB  * LNDS_AFREQ
           WHEN nri_category IN ('icestorm')
               THEN hlr_b * ISTM_EXPB  * ISTM_AFREQ
           WHEN nri_category IN ('wind')
               THEN hlr_b * SWND_EXPB  * SWND_AFREQ
           WHEN nri_category IN ('wildfire')
               THEN hlr_b * WFIR_EXPB  * WFIR_AFREQ
           WHEN nri_category IN ('winterweat')
               THEN hlr_b * WNTW_EXPB  * WNTW_AFREQ
           WHEN nri_category IN ('tsunami')
               THEN hlr_b * TSUN_EXPB  * TSUN_AFREQ
           WHEN nri_category IN ('avalanche')
               THEN hlr_b * AVLN_EXPB  * AVLN_AFREQ
           WHEN nri_category IN ('volcano')
               THEN hlr_b * VLCN_EXPB  * VLCN_AFREQ
           END swd_building,

       CASE
           WHEN nri_category IN ('coastal')
               THEN hlr_f * CFLD_EXPB  * CFLD_AFREQ
           WHEN nri_category IN ('coldwave')
               THEN hlr_f * CWAV_EXPB  * CWAV_AFREQ
           WHEN nri_category IN ('drought')
               THEN hlr_f * CWAV_EXPB  * CWAV_AFREQ
           WHEN nri_category IN ('hurricane')
               THEN hlr_f * HRCN_EXPB  * HRCN_AFREQ
           WHEN nri_category IN ('heatwave')
               THEN hlr_f * HWAV_EXPB  * HWAV_AFREQ
           WHEN nri_category IN ('hail')
               THEN hlr_f * HAIL_EXPB  * HAIL_AFREQ
           WHEN nri_category IN ('tornado')
               THEN hlr_f * TRND_EXPB  * TRND_AFREQ
           WHEN nri_category IN ('riverine')
               THEN hlr_f * RFLD_EXPB  * RFLD_AFREQ
           WHEN nri_category IN ('lightning')
               THEN hlr_f * LTNG_EXPB  * LTNG_AFREQ
           WHEN nri_category IN ('landslide')
               THEN hlr_f * LNDS_EXPB  * LNDS_AFREQ
           WHEN nri_category IN ('icestorm')
               THEN hlr_f * ISTM_EXPB  * ISTM_AFREQ
           WHEN nri_category IN ('wind')
               THEN hlr_f * SWND_EXPB  * SWND_AFREQ
           WHEN nri_category IN ('wildfire')
               THEN hlr_f * WFIR_EXPB  * WFIR_AFREQ
           WHEN nri_category IN ('winterweat')
               THEN hlr_f * WNTW_EXPB  * WNTW_AFREQ
           WHEN nri_category IN ('tsunami')
               THEN hlr_f * TSUN_EXPB  * TSUN_AFREQ
           WHEN nri_category IN ('avalanche')
               THEN hlr_f * AVLN_EXPB  * AVLN_AFREQ
           WHEN nri_category IN ('volcano')
               THEN hlr_f * VLCN_EXPB  * VLCN_AFREQ
           END fema_building,

       CASE
           WHEN nri_category IN ('coldwave')
               THEN hlr_c * CWAV_EXPA  * CWAV_AFREQ
           WHEN nri_category IN ('drought')
               THEN hlr_c * CWAV_EXPA  * CWAV_AFREQ
           WHEN nri_category IN ('hurricane')
               THEN hlr_c * HRCN_EXPA  * HRCN_AFREQ
           WHEN nri_category IN ('heatwave')
               THEN hlr_c * HWAV_EXPA  * HWAV_AFREQ
           WHEN nri_category IN ('hail')
               THEN hlr_c * HAIL_EXPA  * HAIL_AFREQ
           WHEN nri_category IN ('tornado')
               THEN hlr_c * TRND_EXPA  * TRND_AFREQ
           WHEN nri_category IN ('riverine')
               THEN hlr_c * RFLD_EXPA  * RFLD_AFREQ
           WHEN nri_category IN ('wind')
               THEN hlr_c * SWND_EXPA  * SWND_AFREQ
           WHEN nri_category IN ('wildfire')
               THEN hlr_c * WFIR_EXPA  * WFIR_AFREQ
           WHEN nri_category IN ('winterweat')
               THEN hlr_c * WNTW_EXPA  * WNTW_AFREQ
           END swd_crop,

       CASE
           WHEN nri_category IN ('coldwave')
               THEN hlr_fc * CWAV_EXPA  * CWAV_AFREQ
           WHEN nri_category IN ('drought')
               THEN hlr_fc * CWAV_EXPA  * CWAV_AFREQ
           WHEN nri_category IN ('hurricane')
               THEN hlr_fc * HRCN_EXPA  * HRCN_AFREQ
           WHEN nri_category IN ('heatwave')
               THEN hlr_fc * HWAV_EXPA  * HWAV_AFREQ
           WHEN nri_category IN ('hail')
               THEN hlr_fc * HAIL_EXPA  * HAIL_AFREQ
           WHEN nri_category IN ('tornado')
               THEN hlr_fc * TRND_EXPA  * TRND_AFREQ
           WHEN nri_category IN ('riverine')
               THEN hlr_fc * RFLD_EXPA  * RFLD_AFREQ
           WHEN nri_category IN ('wind')
               THEN hlr_fc * SWND_EXPA  * SWND_AFREQ
           WHEN nri_category IN ('wildfire')
               THEN hlr_fc * WFIR_EXPA  * WFIR_AFREQ
           WHEN nri_category IN ('winterweat')
               THEN hlr_fc * WNTW_EXPA  * WNTW_AFREQ
           END fema_crop
FROM hlr
         JOIN national_risk_index.nri_counties_november_2021
              ON geoid = stcofips
ORDER BY geoid, nri_category
			




					
					
					
					