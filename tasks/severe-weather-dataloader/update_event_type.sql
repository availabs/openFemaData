update severe_weather_new.details
set event_type_formatted =
        CASE
            WHEN lower (event_type) IN (
                                        'high wind','strong wind','marine high wind','marine strong wind','marine thunderstorm wind','thunderstorm wind','thunderstorm winds lightning','tornadoes, tstm wind, hail','thunderstorm wind/ trees','thunderstorm winds heavy rain','heavy wind','thunderstorm winds/flash flood','thunderstorm winds/ flood','thunderstorm winds/heavy rain','thunderstorm wind/ tree','thunderstorm winds funnel clou','thunderstorm winds/flooding'
                )
                THEN 'wind'

            WHEN lower (event_type) IN (
                'wildfire'
                )
                THEN 'wildfire'


            WHEN lower (event_type) IN (
                                        'tsunami','seiche'
                )
                THEN 'tsunami'


            WHEN lower (event_type) IN (
                                        'tornado','tornadoes, tstm wind, hail','tornado/waterspout','funnel cloud','waterspout'
                )
                THEN'tornado'


            WHEN lower (event_type) IN (
                                        'flood','flash flood','thunderstorm winds/flash flood','thunderstorm winds/ flood','coastal flood','lakeshore flood'
                )
                THEN 'riverine'


            WHEN lower (event_type) IN (
                                        'lightning','thunderstorm winds lightning','marine lightning'
                )
                THEN 'lightning'


            WHEN lower (event_type) IN (
                                        'landslide','debris flow'
                )
                THEN 'landslide'


            WHEN lower (event_type) IN (
                                        'ice storm','sleet'
                )
                THEN 'icestorm'


            WHEN lower (event_type) IN (
                                        'hurricane','hurricane (typhoon)','marine hurricane/typhoon','marine tropical storm','tropical storm','tropical depression','marine tropical depression','hurricane flood'
                )
                THEN 'hurricane'


            WHEN lower (event_type) IN (
                                        'heat','excessive heat'
                )
                THEN 'heatwave'


            WHEN lower (event_type) IN (
                                        'hail','marine hail','tornadoes, tstm wind, hail','hail/icy roads','hail flooding'
                )
                THEN 'hail'


            WHEN lower (event_type) IN (
                'earthquake'
                )
                THEN 'earthquake'


            WHEN lower (event_type) IN (
                'drought'
                )
                THEN 'drought'


            WHEN lower (event_type) IN (
                'avalanche'
                )
                THEN 'avalanche'


            WHEN lower (event_type) IN (
                                        'cold/wind chill','extreme cold/wind chill','frost/freeze','cold/wind chill'
                )
                THEN 'coldwave'


            WHEN lower (event_type) IN (
                                        'winter weather','winter storm','heavy snow','blizzard','high snow','lake-effect snow'
                )
                THEN 'winterweat'


            WHEN lower (event_type) IN (
                                        'volcanic ash','volcanic ashfall'
                )
                THEN 'volcano'


            WHEN lower (event_type) IN (
                                        'high surf','sneakerwave','storm surge/tide','rip current'
                )
                THEN 'coastal'


            ELSE event_type
            END