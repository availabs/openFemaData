with non_mapped_events as (
    select event_type_formatted nri_category, string_agg(distinct event_type, ', ') ncei_type
    from severe_weather_new.details
    where event_type_formatted = event_type
    group by 1
    order by 1
), mapped_events as (
    select event_type_formatted nri_category, string_agg(distinct event_type, ', ') ncei_type
    from severe_weather_new.details
    where event_type_formatted != event_type
    group by 1
    order by 1
)


select * from mapped_events