import React from "react";
import get from "lodash.get";
import {Toggle} from "../tools/Toggle";
import {fnum} from "utils/fnum";
import {SBAGroups} from "../config";

export const Top = (disaster, disasterNumber, groupEnabled, setGroupEnabled) => {
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
                        {get(disaster, 'declaration_date.value', '')}
                    </div>
                    <div className='text-xs'>
                        <span className='text-gray-500'>County </span>
                        {get(disaster, 'disaster_type.value', '')}
                    </div>
                </div>

                <div className="px-6 py-5 text-sm font-medium text-center bg-gray-50">
                    <div className='text-gray-600'>Total</div>
                    <div className='text-lg'>
                        {
                            (parseFloat(get(disaster, 'total_cost.value', 0)) +
                                SBAGroups['Total'].categories
                                    .reduce((acc, loan) => acc + get(disaster, ['sba', loan, 'total_loss'], 0), 0))
                                .toLocaleString()}
                    </div>
                    <div className='text-gray-600'>declarations</div>
                    <div>
                        {get(disaster, 'numDeclarations', '')}
                    </div>
                </div>

                <div className="px-6 py-5 text-sm font-medium text-center">
                    <div className='text-gray-600'>Total IHP</div>
                    <div className='text-lg'>
                        { parseFloat(get(disaster, 'total_amount_ihp_approved.value', 0) || 0).toLocaleString()}
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
                        { parseFloat(get(disaster, 'total_obligated_amount_pa.value', 0) || 0).toLocaleString()}
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
                        { parseFloat(get(disaster, 'total_obligated_amount_hmgp.value', 0) || 0).toLocaleString()}
                    </div>
                </div>

                <div className="px-6 py-5 text-sm font-medium text-center">
                    <div className='text-gray-600'>SBA</div>
                    <div className={'text-lg'}>
                        {
                            (SBAGroups['Total'].categories
                                .reduce((acc, loan) => acc + get(disaster, ['sba', loan, 'total_loss'], 0), 0)).toLocaleString()
                        }
                    </div>
                </div>
            </div>
        </React.Fragment>
    )
}