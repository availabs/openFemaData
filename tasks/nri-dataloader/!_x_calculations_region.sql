INSERT INTO severe_weather_new.calculations_regions(
    region, event_type, total_lrb_buildings, num_events_buildings, avg_lrb_buildings, total_lrb_crop, num_events_crop, avg_lrb_crop, total_lrb_population, num_events_population, avg_lrb_population, total_lrb_fema, num_events_fema, avg_lrb_fema)

SELECT
    b.region, event_type,
    sum(building_loss_ratio_per_basis) total_lrb_buildings, count(1) num_events_buildings, sum(building_loss_ratio_per_basis) / count(1) avg_lrb_buildings,
    sum(crop_loss_ratio_per_basis) total_lrb_crop, count(1) num_events_crop, sum(crop_loss_ratio_per_basis) / count(1) avg_lrb_crop,
    sum(population_loss_ratio_per_basis) total_lrb_population, count(1) num_events_population, sum(population_loss_ratio_per_basis) / count(1) avg_lrb_population,
    sum(fema_building_loss_ratio_per_basis) total_lrb_fema, count(1) num_events_fema, sum(fema_building_loss_ratio_per_basis) / count(1) avg_lrb_fema
FROM severe_weather_new.details_fema_per_day_basis a
         JOIN severe_weather_new.fips_to_regions_and_surrounding_counties b
              ON a.geoid = b.fips
GROUP BY 1, 2
ORDER BY 1, 2

