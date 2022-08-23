update severe_weather_new.details
set nri_category = 'hurricane'
where nri_category = 'coastal'
  and (lower(event_narrative) like '%hurricane%' or lower(episode_narrative) like '%hurricane%')

