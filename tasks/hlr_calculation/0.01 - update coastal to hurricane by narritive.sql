update severe_weather_new.details  set event_type_formatted = 'hurricane'
where event_type_formatted = 'coastal' 
and (lower(event_narrative) like '%hurricane%' or lower(episode_narrative) like '%hurricane%')