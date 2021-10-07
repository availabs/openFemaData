import React from "react"
import get from 'lodash.get'
import {useFalcor} from '@availabs/avl-components'
import AdminLayout from '../../../Layout'
import {RenderMap} from "./map";
import {RenderTabs} from "./Tabs";

const ATTRIBUTES = ['year', 'geoid', 'hazard', 'group_by', 'disaster_title'];

const Fetch = (falcor, attr) => {
    React.useEffect(() => {
        function fetchData() {
            falcor.get(['severeWeather', 'disasterNumbersList'], ['severeWeather', 'withoutDisasterNumber'])
                .then(response => falcor.get(
                    ['severeWeather', 'byDisaster', get(response, 'json.severeWeather.disasterNumbersList', ['0']), ['year', 'num_events', 'num_episodes', 'total_damage']],
                    ['swdOfdMerge', 'indexValues', ['geoid', 'hazard', 'year']],
                    ['swdOfdMerge', 'swd', attr],
                    ['swdOfdMerge', 'swd', 'hazard.year'],
                    ['swdOfdMerge', 'swd', 'geoid.hazard.year'],
                    ['swdOfdMerge', 'ofd_sba_new', attr],
                    ['swdOfdMerge', 'ofd_sba_new', 'year.disaster_number.disaster_title'],
                    ['swdOfdMerge', 'ofd_sba_new', 'hazard.year'],
                    ['swdOfdMerge', 'ofd_sba_new', 'geoid.hazard.year']
                ))
        }

        return fetchData()
    }, [attr, falcor])
}

const Process = (falcorCache, attr) => {
    return React.useMemo(() => {
        return {
            swd: convertDataToNumeric(get(falcorCache, ['swdOfdMerge', 'swd', attr, 'value'], []), attr),
            swdByHazByYear: convertDataToNumeric(get(falcorCache, ['swdOfdMerge', 'swd', 'hazard.year', 'value'], [])),
            swdByGeoByHazByYear: convertDataToNumeric(get(falcorCache, ['swdOfdMerge', 'swd', 'geoid.hazard.year', 'value'], [])),
            swdByDn: get(falcorCache, ['severeWeather', 'byDisaster'], []),
            swdWithoutDn: get(falcorCache, ['severeWeather', 'withoutDisasterNumber', 'value'], []),

            ofd: convertDataToNumeric(get(falcorCache, ['swdOfdMerge', 'ofd_sba_new', attr, 'value'], []), attr),
            ofdByHazByYear: convertDataToNumeric(get(falcorCache, ['swdOfdMerge', 'ofd_sba_new', 'hazard.year', 'value'], [])),
            ofdByYearByDn: convertDataToNumeric(get(falcorCache, ['swdOfdMerge', 'ofd_sba_new', 'year.disaster_number.disaster_title', 'value'], [])),
            ofdByGeoByHazByYear: convertDataToNumeric(get(falcorCache, ['swdOfdMerge', 'ofd_sba_new', 'geoid.hazard.year', 'value'], [])),

            indexValues: {
                hazard: get(falcorCache, ['swdOfdMerge', 'indexValues', 'hazard', 'value'], []),
                year: get(falcorCache, ['swdOfdMerge', 'indexValues', 'year', 'value'], []),
                geoid: get(falcorCache, ['swdOfdMerge', 'indexValues', 'geoid', 'value'], [])
            }
        }
    }, [falcorCache, attr])
}

const convertDataToNumeric = (data, index) => {
    return data.map(d => {
        return Object.keys(d)
            .reduce((acc, curr) => {
                acc[curr] = ATTRIBUTES.includes(curr) ? d[curr] : parseFloat(d[curr])
                return acc;
            }, {})
    })
}

const Merge = (props) => {
    const [view, setView] = React.useState('Map');
    const {falcor, falcorCache} = useFalcor();
    const attr = 'year'

    Fetch(falcor, attr)

    const data = Process(falcorCache, attr)

    return (
        <AdminLayout>
            <div className="w-full max-w-7xl mx-auto pb-5">
                <div className='pt-4 pb-3 px-6'>
                    <h3 className='inline font-bold text-3xl'>Merge</h3>
                </div>

                {RenderTabs(view, setView)}

                {RenderMap(data)}
            </div>
        </AdminLayout>
    )
}

export default {
    path: "/merge/map",
    exact: true,
    auth: false,
    component: Merge,
    layout: 'Simple'
}