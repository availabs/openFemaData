import React, {useState} from "react"

import { useParams } from "react-router-dom"
import AdminLayout from '../Layout'
import get from 'lodash.get'
import {fnum} from 'utils/fnum'
import {
	DISASTER_ATTRIBUTES,
	DISASTER_DECLARATIONS_ATTRIBUTES,
	SUMMARY_ATTRIBUTES,
	groups,
	Toggle,
} from './utils'

const Top = (disaster, disasterNumber, groupEnabled, setGroupEnabled) => {
	return (
		<React.Fragment>
			<div className='pt-4 pb-3'>
				<h3 className='inline font-bold text-3xl'>{get(disaster, 'name.value', '')} {disasterNumber || ''}</h3>
				{Toggle(groupEnabled, setGroupEnabled)}
			</div>

			<div className={`border-t border-gray-200 bg-white grid grid-cols-1 divide-y divide-gray-200 sm:grid-cols-6 sm:divide-y-0 sm:divide-x`}>
				<div className={`px-6 py-5 text-sm font-medium text-center`}>
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
						<span className='text-gray-500'>County </span>
						{get(disaster, 'disaster_type.value', '')}
					</div>
				</div>

				<div className="px-6 py-5 text-sm font-medium text-center bg-gray-50">
					<div className='text-gray-600'>Total</div>
					<div className='text-lg'>
						{get(disaster, 'total_cost.value', '').toLocaleString()}
					</div>
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
			</div>
		</React.Fragment>
	)
}

const IHPSummary = (disaster, groupEnabled) => {
	return (
		<React.Fragment>
			<h4 className={`pt-5`}>Individual and Household Program Summary</h4>
			<div className={`border-t border-gray-200 bg-white grid grid-cols-1 divide-y divide-gray-200 sm:grid-cols-${groupEnabled ? `1` : `6`} sm:divide-y-0 sm:divide-x`}>
				{
					groupEnabled ?
						Object.keys(groups)
							.map(group => {
								return (
									<div className="px-6 py-5 text-sm font-medium text-center space-x-0 sm:space-x-5"
										 style={{
											 background: groups[group].color
										 }}>
										<div className={`block sm:inline-block`}>
											<div className='text-gray-600'>{group}</div>
											<div className='text-lg'>
												{
													groups[group].attributes.reduce((a,c) => a + get(disaster, [c, 'value'], 0) , 0).toLocaleString()
												}
											</div>
										</div>

										{
											groups[group].attributes.map(attr => (
												<div className={`block sm:inline-block`}>
													<div className='text-gray-600'>{attr.replace(	/_/g, ' ')}</div>
													<div className='text-lg'>
														{
															get(disaster, [attr, 'value'], '').toLocaleString()
														}
													</div>
												</div>
											))
										}

									</div>
								)
							}):
						SUMMARY_ATTRIBUTES.map(attr => (
							<div className="px-6 py-5 text-sm font-medium text-center"
								 style={{
									 background: get(Object.values(groups).filter(g => g.attributes.includes(attr)), [0, 'color'])
								 }}>
								<div className='text-gray-600'>{attr.replace(	/_/g, ' ')}</div>
								<div className='text-lg'>
									{
										get(disaster, [attr, 'value'], '').toLocaleString()
									}
								</div>
							</div>
						))
				}
			</div>
		</React.Fragment>
	)
}

const Declarations = (disaster) => {
	return (
		<div className={`last:mb-5`}>
			<h4 className={`pt-5`}> declarations </h4>
			{disaster.declarations.map(declaration => (
				<div className={`border-t border-gray-200 bg-white grid grid-cols-1 divide-y divide-gray-200 sm:grid-cols-6 sm:divide-y-0 sm:divide-x`}>
					<div className={`px-6 py-5 text-sm font-medium text-center`}>
						<div>{get(declaration, 'declaration_title.value', '')}</div>
						<div className='text-xs'>
							<span className='text-gray-500'>DN </span>
							{get(declaration, 'declaration_request_number.value', '')}
						</div>
						<div className='text-xs'>
							<span className='text-gray-500'>Declared </span>
							{get(declaration, 'declaration_date.value', '')}
						</div>
						<div className='text-xs'>
							<span className='text-gray-500'>Type </span>
							{get(declaration, 'fips_state_code.value', '')}{get(declaration, 'fips_county_code.value', '')}
						</div>
					</div>
				</div>
			))}
		</div>
	)
}

const Home = ({ falcor, falcorCache, ...props }) => {

	const [groupEnabled, setGroupEnabled] = useState(false)
	const { disasterNumber } = useParams();

    React.useEffect(() => {
        return falcor.get(
        	['fema','disasters','byId', disasterNumber , DISASTER_ATTRIBUTES],
        	['fema_disasters','byId', disasterNumber , 'ihp_summary', SUMMARY_ATTRIBUTES],
			['fema','disasters', disasterNumber, 'declarations', 'length']
        ).then(dec => {
			let declarationLength = get(dec, ['json','fema', 'disasters', disasterNumber, 'declarations', 'length'], {})

			falcor.get(['fema','disasters', disasterNumber, 'declarations', 'byIndex',
				{from: 0, to: declarationLength-1},
				DISASTER_DECLARATIONS_ATTRIBUTES
			])
		})
    }, [falcor, falcorCache, disasterNumber]);

    const disaster =  React.useMemo(() => {
    	let disaster = {
    		...get(falcorCache, ['fema', 'disasters', 'byId', disasterNumber], {}),
    		...get(falcorCache, ['fema_disasters', 'byId', disasterNumber, 'ihp_summary'], {}),
    	}
    	disaster.declarations = Object.values(get(falcorCache, ['fema', 'disasters', disasterNumber, 'declarations', 'byIndex'],{}))
    		.map(ref => get(falcorCache, ref.value , {}))
	    return disaster

    }, [falcorCache,disasterNumber])

    return (
      <AdminLayout>
	  		<div className="w-full max-w-7xl mx-auto">
				{Top(disaster, disasterNumber, groupEnabled, setGroupEnabled)}
				{IHPSummary(disaster, groupEnabled)}
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