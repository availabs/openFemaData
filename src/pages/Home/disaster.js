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
import {Declarations} from './components/Declarations'
import {Map} from './components/Map'
const Home = ({ falcor, falcorCache, ...props }) => {

	const [groupEnabled, setGroupEnabled] = useState(false)
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
    	},
			disasterByZip = get(falcorCache, ['fema_disasters', 'byId', disasterNumber, 'byZip', 'ihp_summary'], {})

    	disaster.declarations = Object.values(get(falcorCache, ['fema', 'disasters', disasterNumber, 'declarations', 'byIndex'],{}))
    		.map(ref => get(falcorCache, ref.value , {}))
	    return {disaster, disasterByZip}

    }, [falcorCache,disasterNumber]);

    return (
      <AdminLayout>
	  		<div className="w-full max-w-7xl mx-auto">
				{Top(disaster, disasterNumber, groupEnabled, setGroupEnabled)}
				{IHPSummary(disaster, groupEnabled)}
				{Map(disasterNumber)}
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