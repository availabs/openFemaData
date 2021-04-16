import React  from "react"
// import {useTheme} from '@availabs/avl-components'
import { Link } from 'react-router-dom'
import AdminLayout from '../Layout'
import get from 'lodash.get'

import { 
	DISASTER_ATTRIBUTES, 
	DISASTER_DECLARATIONS_ATTRIBUTES, 
	fnum 
} from './utils'
import { format, precisionPrefix, formatPrefix}  from 'd3-format'

const Home = ({ falcor, falcorCache, ...props }) => {

    // const [geoid, setGeoid] = React.useState(36)
    // const params = useParams();

    React.useEffect(() => {
    	console.time('disastersFetch')
    	falcor.get(['fema','disasters','length'])
		  	.then(res => {
		    	const numDisasters = get(res.json,  ['fema','disasters','length'], 0)
		        return falcor.get(
		        	['fema','disasters','byIndex', {from: 0, to: numDisasters-1 }, DISASTER_ATTRIBUTES]
		        ).then(d => console.timeEnd('disastersFetch'))
		  	});
    }, [falcor]);

    React.useEffect(() => {
    	const disasterNumbers = Object.values(get(falcorCache, ['fema','disasters','byIndex'], {}))
      		.map(d => get(falcorCache, d.value, {}))
      		.map(d => get(d, 'disaster_number.value', null))
      		.filter(d => d)

      	if(disasterNumbers.length === 0) { return }
    	console.time('declarationsFetch')	
	        return falcor.get(
	        	['fema','disasters', disasterNumbers, 'declarations', 'length']
	        ).then(dec => {
	        	let declarations = get(dec, ['json','fema', 'disasters'], {})
	        	let mostDeclarations = Math.max(...Object.keys(declarations)
	        		.map((k) =>  get(declarations, `${k}.declarations.length`,0)))
	        	console.timeEnd('declarationsFetch')
	        	console.time('declarationsFetch2')
	        	
	       	})
      	
    }, [falcor,falcorCache]);


    const data =  React.useMemo(() => {
    	console.time('data processing')
    	const disasters = Object.values(get(falcorCache, ['fema','disasters','byIndex'], {}))
      		.map(d => get(falcorCache, d.value, {}))
      		.filter(d => d)
      		.map(d => {
      			d.numDeclarations =  get(
      				falcorCache, 
      				['fema','disasters', get(d, 'disaster_number.value',0), 'declarations', 'length', 'value'], 
      				0
      			)
      			return d
      		})

     	const disaster_types = disasters.reduce((types,cur) => {
      		const type = get(cur, 'disaster_type.value',null)
      		if(!type) {
      			return types
      		}
      		if(!types[type]){
      			types[type] = { count: 0, cost: 0}
      		}
      		types[type].count += 1

      		return types
      	},{})
     	console.timeEnd('data processing')
	    
	    return {
	      	numDisasters: get(falcorCache, ['fema','disasters','length'], 0),
	      	disasterTypes: disaster_types,
	      	disasters: disasters
	      		.sort((a,b) => get(b, 'total_cost.value', 0) - get(a, 'total_cost.value', 0))
	     } 
     
    }, [falcorCache])
    
    return (
      <AdminLayout>
	  		<div className="w-full max-w-7xl mx-auto">
	  			<div className='pt-4 pb-3'>
          			<h3 className='inline font-bold text-3xl'>Home</h3>
        		</div>
        		<div className='pt-4 pb-3 px-4 bg-white'>
        		<div className='p-2'>{JSON.stringify(data.disasters[0])}</div>
        		<div className='p-2'>TYPES:{JSON.stringify(data.disasterTypes)}</div>
        		</div>
          		{data.disasters
          			.filter((d,i) => i < 100)
          			.map((disaster,i) => ( 
          			<div key={i} className={`border-t border-gray-200 bg-white grid grid-cols-1 divide-y divide-gray-200 sm:grid-cols-6 sm:divide-y-0 sm:divide-x`}>
				        <div className={`px-6 py-5 text-sm font-medium text-center`}>
				          	<Link to={`/disaster/${get(disaster, 'disaster_number.value', 0)}`}>
					          	<div>{get(disaster, 'name.value', '')}</div>
					          	<div className='text-xs'>
					          		<span className='text-gray-500'>DN </span>
					          		{get(disaster, 'disaster_number.value', '')}
					          	</div>
					          	<div className='text-xs'>
					          		<span className='text-gray-500'>Declared </span>
					          		{get(disaster, 'declaration_date.value', '').split('T')[0]}
					          	</div>
					          	<div className='text-xs'>
					          		<span className='text-gray-500'>Type </span>
					          		{get(disaster, 'disaster_type.value', '')}
					          	</div>
				          	</Link>
				        </div>
				        <div className="px-6 py-5 text-sm font-medium text-center bg-gray-50">
				            <div className='text-gray-600'>Total</div>
				            <div className='text-lg'>
				            	{get(disaster, 'total_cost.value', '').toLocaleString()}
				            </div>
				            {/*<div className='text-gray-600 text-sm'>check</div>
			            	<div>	
			            	{((get(disaster, 'total_amount_ihp_approved.value', 0) || 0)
			            		 + (get(disaster, 'total_obligated_amount_pa.value', 0) || 0)
			            		 + (get(disaster, 'total_obligated_amount_hmgp.value', 0) || 0)).toLocaleString()
			            		}
			            	</div> */}
			            	<div className='text-gray-600'>declarations</div>
			            	<div>
			            		{get(disaster, 'numDeclarations', '')}
			            	</div>

				        </div>
				        <div className="px-6 py-5 text-sm font-medium text-center">
				            <div className='text-gray-600'>Total IHP</div>
				            <div className='text-lg'>
				            	{ (get(disaster, 'total_amount_ihp_approved.value', '') || '0').toLocaleString()}
				            </div>
				            <div className='flex'>
				            	<div className='text-lg flex-1'>
				            		<div className='text-gray-600 text-sm'>Total HA</div>
				            		{fnum((get(disaster, 'total_amount_ha_approved.value', 0) || 0))}
				            	</div>
				            	<div className='text-lg flex-1'>
				            		<div className='text-gray-600 text-sm'>Total ONA</div>
				            		{fnum((get(disaster, 'total_amount_ona_approved.value', 0) || 0))}

				            	</div>
				            </div>
				        </div>
				        <div className="px-6 py-5 text-sm font-medium text-center">
				            <div className='text-gray-600'>Total PA</div>
				            <div className='text-lg'>
				            	{ (get(disaster, 'total_obligated_amount_pa.value', '') || '0').toLocaleString()}
				            </div>
				            <div className='text-lg '>
			            		<div className='text-gray-600 text-sm'>check</div>
			            		{((get(disaster, 'total_obligated_amount_cat_ab.value', 0) || 0)
			            		 + (get(disaster, 'total_obligated_amount_cat_c2g.value', 0) || 0)).toLocaleString()
			            		}
				            </div>

				            <div className='flex'>
				            	<div className='text-lg flex-1'>
				            		<div className='text-gray-600 text-sm'>CAT AB</div>
				            		{fnum((get(disaster, 'total_obligated_amount_cat_ab.value', 0) || 0))}
				            	</div>
				            	<div className='text-lg flex-1'>
				            		<div className='text-gray-600 text-sm'>CAT C2G</div>
				            		{fnum((get(disaster, 'total_obligated_amount_cat_c2g.value', 0) || 0))}

				            	</div>
				            </div>

				        </div>
				        <div className="px-6 py-5 text-sm font-medium text-center">
				            <div className='text-gray-600'>Total HMGP</div>
				            <div className='text-lg'>
				            	{ (get(disaster, 'total_obligated_amount_hmgp.value', '') || '0').toLocaleString()}
				            </div>
				        </div>
				        <div className="px-6 py-5 text-sm font-medium text-center">
				            <div className='text-gray-600'>Severe Weather</div>
				            
				        </div>
			        	
			        </div>)
          		)}
        	</div>
	  		
		</AdminLayout>
    )
}

export default {
  path: "/",
  exact: true,
  auth: true,
  component: Home,
  component: {
    type: Home,
    wrappers: [
      "avl-falcor"
    ]
  },
  layout: 'Simple'
}