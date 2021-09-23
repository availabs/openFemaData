INSERT INTO public.datasources(
    id, title,
    description, "table",
    data_url, data_dictionary,
    landing_page, publisher,
    last_refresh,
    start_date, end_date, record_count)
SELECT 13 id, 'Severe Weather Annual Loss by County By Hazard' title,
       'last refresh source: 2021-08-05' description, 'severe_weather_open_fema_data_merge.severe_weather_annual_loss_by_county_by_hazard' "table",
       'https://www.ncei.noaa.gov/pub/data/swdi/stormevents/csvfiles/' data_url, '' data_dictionary,
       '' data_url, 'AVAIL' publisher,
       (SELECT NOW()) last_refresh,
       null start_date, null end_date,
       (select count(1) record_count from severe_weather_open_fema_data_merge.severe_weather_annual_loss_by_county_by_hazard) record_count
