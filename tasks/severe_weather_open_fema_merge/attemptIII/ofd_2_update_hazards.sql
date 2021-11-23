update severe_weather_open_fema_data_merge.disaster_summaries_merge_without_hazard_type_2 ihp
set hazard = CASE
                 when ihp.hazard = 'Fire' then 'wildfire'
                 when ihp.hazard = 'Tsunami' then 'tsunami'
                 when ihp.hazard = 'Tornado' then 'tornado'
                 when ihp.hazard = 'Flood' then 'riverine'
                 when ihp.hazard = 'Severe Storm(s)' then 'riverine'
                 when ihp.hazard = 'Mud/Landslide' then 'landslide'
                 when ihp.hazard = 'Severe Ice Storm' then 'icestorm'
                 when ihp.hazard = 'Hurricane' then 'hurricane'
                 when ihp.hazard = 'Typhoon' then 'hurricane'
                 when ihp.hazard = 'Earthquake' then 'earthquake'
                 when ihp.hazard = 'Drought' then 'drought'
                 when ihp.hazard = 'Freezing' then 'coldwave'
                 when ihp.hazard = 'Snow' then 'winterweat'
                 when ihp.hazard = 'Volcano' then 'volcano'
                 when ihp.hazard = 'Coastal Storm' then 'coastal'
                 else ihp.hazard
    END