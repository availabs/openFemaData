WITH t AS (
    SELECT a.region, a.event_type,
           SUM(POWER(building_loss_ratio_per_basis - avg_lrb_buildings, 2)) / num_events_buildings AS var_lrb_buildings,
           SUM(POWER(crop_loss_ratio_per_basis - avg_lrb_crop, 2)) / num_events_crop AS var_lrb_crop,
           SUM(POWER(population_loss_ratio_per_basis - avg_lrb_population, 2)) / num_events_population AS var_lrb_population,
           SUM(POWER(fema_building_loss_ratio_per_basis - avg_lrb_fema, 2)) / num_events_fema AS var_lrb_fema
    FROM severe_weather_new.calculations_regions a
             JOIN (
        SELECT a.*, b.region
        FROM severe_weather_new.details_fema_per_day_basis a
                 JOIN severe_weather_new.fips_to_regions_and_surrounding_counties b
                      ON a.geoid = b.fips
    ) b
                  ON a.event_type = b.event_type
                      AND a.region = b.region
    GROUP BY 1, 2, num_events_buildings, num_events_crop, num_events_population, num_events_fema)

UPDATE severe_weather_new.calculations_regions dst
SET var_lrb_buildings = t.var_lrb_buildings,
    var_lrb_crop = t.var_lrb_crop,
    var_lrb_population = t.var_lrb_population,
    var_lrb_fema = t.var_lrb_fema
FROM t
WHERE dst.event_type = t.event_type
  AND dst.region = t.region
