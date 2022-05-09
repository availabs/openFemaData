with lrpbs as (SELECT swd.*,
                      CASE
                          WHEN event_type IN ('High Wind','Strong Wind','Marine High Wind','Marine Strong Wind','Marine Thunderstorm Wind','Thunderstorm Wind','THUNDERSTORM WINDS LIGHTNING','TORNADOES, TSTM WIND, HAIL','THUNDERSTORM WIND/ TREES','THUNDERSTORM WINDS HEAVY RAIN','Heavy Wind','THUNDERSTORM WINDS/FLASH FLOOD','THUNDERSTORM WINDS/ FLOOD','THUNDERSTORM WINDS/HEAVY RAIN','THUNDERSTORM WIND/ TREE','THUNDERSTORM WINDS FUNNEL CLOU','THUNDERSTORM WINDS/FLOODING')
                              THEN property_damage/NULLIF(SWND_EXPB, 0)
                          WHEN event_type IN ('Wildfire')
                              THEN property_damage/NULLIF(WFIR_EXPB, 0)
                          WHEN event_type IN ('Tsunami','Seiche')
                              THEN property_damage/NULLIF(TSUN_EXPB, 0)
                          WHEN event_type IN ('Tornado','TORNADOES, TSTM WIND, HAIL','TORNADO/WATERSPOUT','Funnel Cloud','Waterspout')
                              THEN property_damage/NULLIF(TRND_EXPB, 0)
                          WHEN event_type IN ('Flood','Flash Flood','THUNDERSTORM WINDS/FLASH FLOOD','THUNDERSTORM WINDS/ FLOOD','Coastal Flood','Lakeshore Flood')
                              THEN property_damage/NULLIF(RFLD_EXPB, 0)
                          WHEN event_type IN ('Lightning','THUNDERSTORM WINDS LIGHTNING','Marine Lightning')
                              THEN property_damage/NULLIF(LTNG_EXPB, 0)
                          WHEN event_type IN ('Landslide','Debris Flow')
                              THEN property_damage/NULLIF(LNDS_EXPB, 0)
                          WHEN event_type IN ('Ice Storm','Sleet')
                              THEN property_damage/NULLIF(ISTM_EXPB, 0)
                          WHEN event_type IN ('Hurricane','Hurricane (Typhoon)','Marine Hurricane/Typhoon','Marine Tropical Storm','Tropical Storm','Tropical Depression','Marine Tropical Depression','Hurricane Flood')
                              THEN property_damage/NULLIF(HRCN_EXPB, 0)
                          WHEN event_type IN ('Heat','Excessive Heat')
                              THEN property_damage/NULLIF(HWAV_EXPB, 0)
                          WHEN event_type IN ('Hail','Marine Hail','TORNADOES, TSTM WIND, HAIL','HAIL/ICY ROADS','HAIL FLOODING')
                              THEN property_damage/NULLIF(HAIL_EXPB, 0)
                          --            WHEN event_type IN ('Drought')
--                THEN property_damage/NULLIF(DRGT_EXPB, 0)
                          WHEN event_type IN ('Avalanche')
                              THEN property_damage/NULLIF(AVLN_EXPB, 0)
                          WHEN event_type IN ('Cold/Wind Chill','Extreme Cold/Wind Chill','Frost/Freeze','Cold/Wind Chill')
                              THEN property_damage/NULLIF(CWAV_EXPB, 0)
                          WHEN event_type IN ('Winter Weather','Winter Storm','Heavy Snow','Blizzard','High Snow','Lake-Effect Snow')
                              THEN property_damage/NULLIF(WNTW_EXPB, 0)
                          WHEN event_type IN ('Volcanic Ash','Volcanic Ashfall')
                              THEN property_damage/NULLIF(VLCN_EXPB, 0)
                          WHEN event_type IN ('High Surf','Sneakerwave','Storm Surge/Tide','Rip Current')
                              THEN property_damage/NULLIF(CFLD_EXPB, 0)
                          END building_loss_ratio_per_basis,







                      CASE
                          WHEN event_type IN ('High Wind','Strong Wind','Marine High Wind','Marine Strong Wind','Marine Thunderstorm Wind','Thunderstorm Wind','THUNDERSTORM WINDS LIGHTNING','TORNADOES, TSTM WIND, HAIL','THUNDERSTORM WIND/ TREES','THUNDERSTORM WINDS HEAVY RAIN','Heavy Wind','THUNDERSTORM WINDS/FLASH FLOOD','THUNDERSTORM WINDS/ FLOOD','THUNDERSTORM WINDS/HEAVY RAIN','THUNDERSTORM WIND/ TREE','THUNDERSTORM WINDS FUNNEL CLOU','THUNDERSTORM WINDS/FLOODING')
                              THEN fema_property_damage/NULLIF(SWND_EXPB, 0)
                          WHEN event_type IN ('Wildfire')
                              THEN fema_property_damage/NULLIF(WFIR_EXPB, 0)
                          WHEN event_type IN ('Tsunami','Seiche')
                              THEN fema_property_damage/NULLIF(TSUN_EXPB, 0)
                          WHEN event_type IN ('Tornado','TORNADOES, TSTM WIND, HAIL','TORNADO/WATERSPOUT','Funnel Cloud','Waterspout')
                              THEN fema_property_damage/NULLIF(TRND_EXPB, 0)
                          WHEN event_type IN ('Flood','Flash Flood','THUNDERSTORM WINDS/FLASH FLOOD','THUNDERSTORM WINDS/ FLOOD','Coastal Flood','Lakeshore Flood')
                              THEN fema_property_damage/NULLIF(RFLD_EXPB, 0)
                          WHEN event_type IN ('Lightning','THUNDERSTORM WINDS LIGHTNING','Marine Lightning')
                              THEN fema_property_damage/NULLIF(LTNG_EXPB, 0)
                          WHEN event_type IN ('Landslide','Debris Flow')
                              THEN fema_property_damage/NULLIF(LNDS_EXPB, 0)
                          WHEN event_type IN ('Ice Storm','Sleet')
                              THEN fema_property_damage/NULLIF(ISTM_EXPB, 0)
                          WHEN event_type IN ('Hurricane','Hurricane (Typhoon)','Marine Hurricane/Typhoon','Marine Tropical Storm','Tropical Storm','Tropical Depression','Marine Tropical Depression','Hurricane Flood')
                              THEN fema_property_damage/NULLIF(HRCN_EXPB, 0)
                          WHEN event_type IN ('Heat','Excessive Heat')
                              THEN fema_property_damage/NULLIF(HWAV_EXPB, 0)
                          WHEN event_type IN ('Hail','Marine Hail','TORNADOES, TSTM WIND, HAIL','HAIL/ICY ROADS','HAIL FLOODING')
                              THEN fema_property_damage/NULLIF(HAIL_EXPB, 0)
                          --            WHEN event_type IN ('Drought')
--                THEN fema_property_damage/NULLIF(DRGT_EXPB, 0)
                          WHEN event_type IN ('Avalanche')
                              THEN fema_property_damage/NULLIF(AVLN_EXPB, 0)
                          WHEN event_type IN ('Cold/Wind Chill','Extreme Cold/Wind Chill','Frost/Freeze','Cold/Wind Chill')
                              THEN fema_property_damage/NULLIF(CWAV_EXPB, 0)
                          WHEN event_type IN ('Winter Weather','Winter Storm','Heavy Snow','Blizzard','High Snow','Lake-Effect Snow')
                              THEN fema_property_damage/NULLIF(WNTW_EXPB, 0)
                          WHEN event_type IN ('Volcanic Ash','Volcanic Ashfall')
                              THEN fema_property_damage/NULLIF(VLCN_EXPB, 0)
                          WHEN event_type IN ('High Surf','Sneakerwave','Storm Surge/Tide','Rip Current')
                              THEN fema_property_damage/NULLIF(CFLD_EXPB, 0)
                          END fema_building_loss_ratio_per_basis,





                      CASE
                          WHEN event_type IN ('High Wind','Strong Wind','Marine High Wind','Marine Strong Wind','Marine Thunderstorm Wind','Thunderstorm Wind','THUNDERSTORM WINDS LIGHTNING','TORNADOES, TSTM WIND, HAIL','THUNDERSTORM WIND/ TREES','THUNDERSTORM WINDS HEAVY RAIN','Heavy Wind','THUNDERSTORM WINDS/FLASH FLOOD','THUNDERSTORM WINDS/ FLOOD','THUNDERSTORM WINDS/HEAVY RAIN','THUNDERSTORM WIND/ TREE','THUNDERSTORM WINDS FUNNEL CLOU','THUNDERSTORM WINDS/FLOODING')
                              THEN crop_damage/NULLIF(SWND_EXPA, 0)
                          WHEN event_type IN ('Wildfire')
                              THEN crop_damage/NULLIF(WFIR_EXPA, 0)
                          --            WHEN event_type IN ('Tsunami','Seiche')
--                THEN crop_damage/NULLIF(TSUN_EXPA, 0)
                          WHEN event_type IN ('Tornado','TORNADOES, TSTM WIND, HAIL','TORNADO/WATERSPOUT','Funnel Cloud','Waterspout')
                              THEN crop_damage/NULLIF(TRND_EXPA, 0)
                          WHEN event_type IN ('Flood','Flash Flood','THUNDERSTORM WINDS/FLASH FLOOD','THUNDERSTORM WINDS/ FLOOD','Coastal Flood','Lakeshore Flood')
                              THEN crop_damage/NULLIF(RFLD_EXPA, 0)
                          --            WHEN event_type IN ('Lightning','THUNDERSTORM WINDS LIGHTNING','Marine Lightning')
--                THEN crop_damage/NULLIF(LTNG_EXPA, 0)
--            WHEN event_type IN ('Landslide','Debris Flow')
--                THEN crop_damage/NULLIF(LNDS_EXPA, 0)
--            WHEN event_type IN ('Ice Storm','Sleet')
--                THEN crop_damage/NULLIF(ISTM_EXPA, 0)
                          WHEN event_type IN ('Hurricane','Hurricane (Typhoon)','Marine Hurricane/Typhoon','Marine Tropical Storm','Tropical Storm','Tropical Depression','Marine Tropical Depression','Hurricane Flood')
                              THEN crop_damage/NULLIF(HRCN_EXPA, 0)
                          WHEN event_type IN ('Heat','Excessive Heat')
                              THEN crop_damage/NULLIF(HWAV_EXPA, 0)
                          WHEN event_type IN ('Hail','Marine Hail','TORNADOES, TSTM WIND, HAIL','HAIL/ICY ROADS','HAIL FLOODING')
                              THEN crop_damage/NULLIF(HAIL_EXPA, 0)
                          WHEN event_type IN ('Drought')
                              THEN crop_damage/NULLIF(DRGT_EXPA, 0)
                          --            WHEN event_type IN ('Avalanche')
--                THEN crop_damage/NULLIF(AVLN_EXPA, 0)
                          WHEN event_type IN ('Cold/Wind Chill','Extreme Cold/Wind Chill','Frost/Freeze','Cold/Wind Chill')
                              THEN crop_damage/NULLIF(CWAV_EXPA, 0)
                          WHEN event_type IN ('Winter Weather','Winter Storm','Heavy Snow','Blizzard','High Snow','Lake-Effect Snow')
                              THEN crop_damage/NULLIF(WNTW_EXPA, 0)
                          --            WHEN event_type IN ('Volcanic Ash','Volcanic Ashfall')
--                THEN crop_damage/NULLIF(VLCN_EXPA, 0)
--            WHEN event_type IN ('High Surf','Sneakerwave','Storm Surge/Tide','Rip Current')
--                THEN crop_damage/NULLIF(CFLD_EXPA, 0)
                          END crop_loss_ratio_per_basis,





                      CASE
                          WHEN event_type IN ('High Wind','Strong Wind','Marine High Wind','Marine Strong Wind','Marine Thunderstorm Wind','Thunderstorm Wind','THUNDERSTORM WINDS LIGHTNING','TORNADOES, TSTM WIND, HAIL','THUNDERSTORM WIND/ TREES','THUNDERSTORM WINDS HEAVY RAIN','Heavy Wind','THUNDERSTORM WINDS/FLASH FLOOD','THUNDERSTORM WINDS/ FLOOD','THUNDERSTORM WINDS/HEAVY RAIN','THUNDERSTORM WIND/ TREE','THUNDERSTORM WINDS FUNNEL CLOU','THUNDERSTORM WINDS/FLOODING')
                              THEN fatalities_dollar_value/NULLIF(SWND_EXPPE, 0)
                          WHEN event_type IN ('Wildfire')
                              THEN fatalities_dollar_value/NULLIF(WFIR_EXPPE, 0)
                          WHEN event_type IN ('Tsunami','Seiche')
                              THEN fatalities_dollar_value/NULLIF(TSUN_EXPPE, 0)
                          WHEN event_type IN ('Tornado','TORNADOES, TSTM WIND, HAIL','TORNADO/WATERSPOUT','Funnel Cloud','Waterspout')
                              THEN fatalities_dollar_value/NULLIF(TRND_EXPPE, 0)
                          WHEN event_type IN ('Flood','Flash Flood','THUNDERSTORM WINDS/FLASH FLOOD','THUNDERSTORM WINDS/ FLOOD','Coastal Flood','Lakeshore Flood')
                              THEN fatalities_dollar_value/NULLIF(RFLD_EXPPE, 0)
                          WHEN event_type IN ('Lightning','THUNDERSTORM WINDS LIGHTNING','Marine Lightning')
                              THEN fatalities_dollar_value/NULLIF(LTNG_EXPPE, 0)
                          WHEN event_type IN ('Landslide','Debris Flow')
                              THEN fatalities_dollar_value/NULLIF(LNDS_EXPPE, 0)
                          WHEN event_type IN ('Ice Storm','Sleet')
                              THEN fatalities_dollar_value/NULLIF(ISTM_EXPPE, 0)
                          WHEN event_type IN ('Hurricane','Hurricane (Typhoon)','Marine Hurricane/Typhoon','Marine Tropical Storm','Tropical Storm','Tropical Depression','Marine Tropical Depression','Hurricane Flood')
                              THEN fatalities_dollar_value/NULLIF(HRCN_EXPPE, 0)
                          WHEN event_type IN ('Heat','Excessive Heat')
                              THEN fatalities_dollar_value/NULLIF(HWAV_EXPPE, 0)
                          WHEN event_type IN ('Hail','Marine Hail','TORNADOES, TSTM WIND, HAIL','HAIL/ICY ROADS','HAIL FLOODING')
                              THEN fatalities_dollar_value/NULLIF(HAIL_EXPPE, 0)
                          --            WHEN event_type IN ('Drought')
--                THEN fatalities_dollar_value/NULLIF(DRGT_EXPPE, 0)
                          WHEN event_type IN ('Avalanche')
                              THEN fatalities_dollar_value/NULLIF(AVLN_EXPPE, 0)
                          WHEN event_type IN ('Cold/Wind Chill','Extreme Cold/Wind Chill','Frost/Freeze','Cold/Wind Chill')
                              THEN fatalities_dollar_value/NULLIF(CWAV_EXPPE, 0)
                          WHEN event_type IN ('Winter Weather','Winter Storm','Heavy Snow','Blizzard','High Snow','Lake-Effect Snow')
                              THEN fatalities_dollar_value/NULLIF(WNTW_EXPPE, 0)
                          WHEN event_type IN ('Volcanic Ash','Volcanic Ashfall')
                              THEN fatalities_dollar_value/NULLIF(VLCN_EXPPE, 0)
                          WHEN event_type IN ('High Surf','Sneakerwave','Storm Surge/Tide','Rip Current')
                              THEN fatalities_dollar_value/NULLIF(CFLD_EXPPE, 0)
                          END population_loss_ratio_per_basis
               FROM public.tmp_details_fema_per_basis swd
                        JOIN national_risk_index.nri_counties_november_2021 nri
                             ON substring(swd.geoid, 1, 5) = nri.stcofips),

     national as (select nri_category,
                         count(1),
                         avg(Least(COALESCE(building_loss_ratio_per_basis, 0), 1))           b_av_n,
                         avg(Least(COALESCE(crop_loss_ratio_per_basis, 0), 1))               c_av_n,
                         avg(Least(COALESCE(population_loss_ratio_per_basis, 0), 1))         p_av_n,
                         avg(Least(COALESCE(fema_building_loss_ratio_per_basis, 0), 1))      f_av_n,

                         variance(Least(COALESCE(building_loss_ratio_per_basis, 0), 1))      b_va_n,
                         variance(Least(COALESCE(crop_loss_ratio_per_basis, 0), 1))          c_va_n,
                         variance(Least(COALESCE(population_loss_ratio_per_basis, 0), 1))    p_va_n,
                         variance(Least(COALESCE(fema_building_loss_ratio_per_basis, 0), 1)) f_va_n

                  from lrpbs as a
                           join severe_weather_new.fips_to_regions_and_surrounding_counties as b
                                on b.fips = a.geoid
                  WHERE nri_category is not null
                  group by 1
                  order by 1),
     regional as (select region,
                         nri_category,
                         count(1),
                         avg(Least(COALESCE(building_loss_ratio_per_basis, 0), 1))           b_av_r,
                         avg(Least(COALESCE(crop_loss_ratio_per_basis, 0), 1))               c_av_r,
                         avg(Least(COALESCE(population_loss_ratio_per_basis, 0), 1))         p_av_r,
                         avg(Least(COALESCE(fema_building_loss_ratio_per_basis, 0), 1))      f_av_r,

                         variance(Least(COALESCE(building_loss_ratio_per_basis, 0), 1))      b_va_r,
                         variance(Least(COALESCE(crop_loss_ratio_per_basis, 0), 1))          c_va_r,
                         variance(Least(COALESCE(population_loss_ratio_per_basis, 0), 1))    p_va_r,
                         variance(Least(COALESCE(fema_building_loss_ratio_per_basis, 0), 1)) f_va_r

                  from lrpbs as a
                           join severe_weather_new.fips_to_regions_and_surrounding_counties as b
                                on b.fips = a.geoid
                  WHERE nri_category is not null
                  group by 1, 2
                  order by 1, 2),
     county as (select LEFT(b.fips, 5)                                                     fips,
                       nri_category,
                       count(1),
                       avg(Least(COALESCE(building_loss_ratio_per_basis, 0), 1))           b_av_c,
                       avg(Least(COALESCE(crop_loss_ratio_per_basis, 0), 1))               c_av_c,
                       avg(Least(COALESCE(population_loss_ratio_per_basis, 0), 1))         p_av_c,
                       avg(Least(COALESCE(fema_building_loss_ratio_per_basis, 0), 1))      f_av_c,

                       variance(Least(COALESCE(building_loss_ratio_per_basis, 0), 1))      b_va_c,
                       variance(Least(COALESCE(crop_loss_ratio_per_basis, 0), 1))          c_va_c,
                       variance(Least(COALESCE(population_loss_ratio_per_basis, 0), 1))    p_va_c,
                       variance(Least(COALESCE(fema_building_loss_ratio_per_basis, 0), 1)) f_va_c

                from lrpbs as a
                         join severe_weather_new.fips_to_regions_and_surrounding_counties as b
                              on b.fips = a.geoid
                WHERE nri_category is not null
                group by 1, 2
                order by 1, 2),

     surrounding as (select surrounding_counties                                                fips,
                            nri_category,
                            count(1),
                            avg(Least(COALESCE(building_loss_ratio_per_basis, 0), 1))           b_av_s,
                            avg(Least(COALESCE(crop_loss_ratio_per_basis, 0), 1))               c_av_s,
                            avg(Least(COALESCE(population_loss_ratio_per_basis, 0), 1))         p_av_s,
                            avg(Least(COALESCE(fema_building_loss_ratio_per_basis, 0), 1))      f_av_s,

                            variance(Least(COALESCE(building_loss_ratio_per_basis, 0), 1))      b_va_s,
                            variance(Least(COALESCE(crop_loss_ratio_per_basis, 0), 1))          c_va_s,
                            variance(Least(COALESCE(population_loss_ratio_per_basis, 0), 1))    p_va_s,
                            variance(Least(COALESCE(fema_building_loss_ratio_per_basis, 0), 1)) f_va_s

                     from lrpbs as a
                              join severe_weather_new.fips_to_regions_and_surrounding_counties as b
                                   on b.fips = a.geoid
                     WHERE nri_category is not null
                     group by 1, 2
                     order by 1, 2)

SELECT mapping.fips,
       mapping.region,
       mapping.surrounding_counties,
       county.*,
       national.*,
       regional.*,
       surrounding.*,

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
                 f_av_s), 0) AS hlr_f


FROM severe_weather_new.fips_to_regions_and_surrounding_counties mapping
         JOIN county
              on county.fips = mapping.fips
         LEFT JOIN national
                   ON county.nri_category = national.nri_category
         LEFT JOIN regional
                   ON mapping.region = regional.region AND county.nri_category = regional.nri_category
         LEFT JOIN surrounding
                   ON mapping.surrounding_counties = surrounding.fips and county.nri_category = surrounding.nri_category


