import React, {useState} from "react"

import { useParams } from "react-router-dom"
import AdminLayout from '../Layout'
import get from 'lodash.get'
import {
	DISASTER_ATTRIBUTES,
	DISASTER_DECLARATIONS_ATTRIBUTES,
	SUMMARY_ATTRIBUTES,
} from './utils'

import {Top} from './components/Top'
import {IHPSummary} from './components/IHPSummary'
import {SevereWeatherDataTable} from "./components/SevereWeatherDataTable";
import {Declarations} from './components/Declarations'
import {Map} from './components/Map'
import _ from "lodash";

const ProcessSevereWeatherData = (falcorCache, disaster) => {
	let result = [];
	_.keys(get(falcorCache, 'severeWeather', {})).forEach(county => {
			_.keys(get(falcorCache, ['severeWeather', county, 'byTimeStampRange'], {})).forEach(startDate => {
					_.keys(get(falcorCache, ['severeWeather', county, 'byTimeStampRange', startDate], {})).forEach(endDate => {
							result.push(
								_.keys(get(falcorCache, ['severeWeather', county, 'byTimeStampRange', startDate, endDate, get(disaster, ['disaster_type', 'value'], 'hurricane')], {}))
									.reduce((a, attr) => {
										a[attr] = get(falcorCache, ['severeWeather', county, 'byTimeStampRange', startDate, endDate, get(disaster, ['disaster_type', 'value'], 'hurricane'), attr], '');
										return a;
									}, {county})
							)
						}
					)
				}
			)
		}
	)
	return result.filter(f => f.num_events).sort((a,b) => +a.num_events - +b.num_events)
}

const Home = ({ falcor, falcorCache, ...props }) => {

	const [groupEnabled, setGroupEnabled] = useState(false);
	const [mapFocus, setMapFocus] = useState(null);
	const { disasterNumber } = useParams();

    React.useEffect(() => {
        return falcor.get(
        	['fema','disasters','byId', disasterNumber , DISASTER_ATTRIBUTES],
        	['fema_disasters','byId', disasterNumber , 'ihp_summary', SUMMARY_ATTRIBUTES],
        	['fema_disasters','byId', disasterNumber , 'byZip', 'ihp_summary'],
			['fema','disasters', disasterNumber, 'declarations', 'length']
        ).then(dec => {
			let declarationLength = get(dec, ['json','fema', 'disasters', disasterNumber, 'declarations', 'length'], {});

			falcor.get(['fema','disasters', disasterNumber, 'declarations', 'byIndex',
				{from: 0, to: declarationLength-1},
				DISASTER_DECLARATIONS_ATTRIBUTES
			]);
		});
    }, [falcor, falcorCache, disasterNumber]);

    const {disaster, disasterByZip} =  React.useMemo(() => {
    	let disaster = {
    		...get(falcorCache, ['fema', 'disasters', 'byId', disasterNumber], {}),
    		...get(falcorCache, ['fema_disasters', 'byId', disasterNumber, 'ihp_summary'], {}),
			counties: [],
			earliestEventStart: null,
			latestEventEnd: null
    	},
			disasterByZip = get(falcorCache, ['fema_disasters', 'byId', disasterNumber, 'byZip', 'ihp_summary'], {})

    	disaster.declarations = Object.values(get(falcorCache, ['fema', 'disasters', disasterNumber, 'declarations', 'byIndex'],{}))
    		.map(ref => {
    			let county = get(falcorCache, [...ref.value, 'fips_state_code', 'value'], '') + get(falcorCache, [...ref.value, 'fips_county_code', 'value'], '');
    			let date1 = new Date(get(falcorCache, [...ref.value, 'incident_begin_date', 'value'], ''));
    			let date2 = new Date(get(falcorCache, [...ref.value, 'incident_end_date', 'value'], ''))

				if(!disaster.counties.includes(county)){
					disaster.counties.push(county)
				}
				disaster.earliestEventStart = date1 < disaster.earliestEventStart || !disaster.earliestEventStart ? date1 : disaster.earliestEventStart;
				disaster.latestEventEnd = date2 > disaster.latestEventEnd || !disaster.latestEventEnd ? date2 : disaster.latestEventEnd;

				return get(falcorCache, ref.value, {})
			})
	    return {disaster, disasterByZip}

    }, [falcorCache,disasterNumber]);

    React.useEffect(() => {
    	if(disaster.earliestEventStart && disaster.latestEventEnd){
			let date1 = `${disaster.earliestEventStart.getFullYear()}-${disaster.earliestEventStart.getMonth()+1}-${disaster.earliestEventStart.getDate()}`;
			let date2 = `${disaster.latestEventEnd.getFullYear()}-${disaster.latestEventEnd.getMonth()+1}-${disaster.latestEventEnd.getDate()}`;

			return falcor.get(
				['severeWeather', disaster.counties, 'byTimeStampRange', date1, date2, get(disaster, ['disaster_type', 'value'], 'hurricane'), ['geom', 'num_events', 'num_episodes', 'num_severe_events', 'total_damage', 'property_damage', 'crop_damage', 'injuries', 'fatalities']]
			)
		}
	}, [disaster, falcor, falcorCache])

	let severeWeatherData = ProcessSevereWeatherData(falcorCache, disaster)
    return (
      <AdminLayout>
	  		<div className="w-full max-w-7xl mx-auto">
				{Top(disaster, disasterNumber, groupEnabled, setGroupEnabled)}
				{IHPSummary(disaster, groupEnabled)}
				{Map(disasterNumber, severeWeatherData, mapFocus)}
				{SevereWeatherDataTable(severeWeatherData, mapFocus, setMapFocus)}
				{Declarations(disaster)}
        	</div>
		</AdminLayout>
    )
}

export default {
  path: "/disaster/:disasterNumber",
  exact: true,
  auth: false,
  component: {
    type: Home,
    wrappers: [
      "avl-falcor"
    ]
  },
  layout: 'Simple'
}