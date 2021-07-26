import _ from "lodash";
import get from 'lodash'
import React from "react";
import {Table} from '@availabs/avl-components'

export const SevereWeatherDataTable = (totals = {}, data = [], mapFocus, setMapFocus) => {
    let summary = totals;
    data = data.map(d => {
        return Object.assign({},
            {
                location:
                    <div
                        className={`fas fa-map-marker-alt text-blue-${mapFocus === d.geom ? 400 : 200} hover:text-blue-500 cursor-pointer transform duration-300 ease-out transition`}
                        onClick={() => setMapFocus(mapFocus === d.geom ? null : d.geom)}
                    />
            }, d
        )
    })
    const cols = _.keys(data[0])
        .filter(c => !['geom', 'episode_narrative', 'event_narrative', 'county'].includes(c))
        .map(c => ({
            Header: c.replace(/_/g, ' ').replace(/num/g, '#'),
            accessor: c,
            align: 'center',
            disableFilters: true,
            disableSortBy: true,
        }))

    return (
        <div className={`mt-20`}>
            <h4 className={`pt-5`}> Severe Weather Data </h4>
            <div className={`flex flex-col sm:flex-row bg-white grid grid-cols-1 sm:grid-cols-${Object.keys(summary).length} divide-y divide-gray-200 sm:divide-y-0 sm:divide-x mb-5`}>
                {
                    Object.keys(summary)
                        .map(attr => (
                            <div className={`px-6 py-5 text-sm font-medium text-center`}>
                                <div className={`text-gray-600 capitalize`}>{attr.replace(/_/g, ' ').replace(/num/g, 'total #')}</div>
                                <div className={`text-lg`}>{summary[attr]}</div>
                            </div>
                        ))
                }
            </div>

            <Table
                data={data}
                columns={cols}
                initialPageSize={data.length || 10}
            />
        </div>
    )
}

// <div className={`last:mb-5`}>
//     <h4 className={`pt-5`}> Severe Weather Data </h4>
//     {
//         data.map(d => (
//             <div
//                 className={`border-t border-gray-200 bg-white grid grid-cols-1 divide-y divide-gray-200 sm:grid-cols-6 sm:divide-y-0 sm:divide-x`}>
//                 <div className={`px-6 py-5 text-sm font-medium text-center`}>
//                     <div>{get(d, 'county', '')}</div>
//                     <div className='text-xs'>
//                         <span className='text-gray-500'>DN </span>
//                         {get(d, 'declaration_request_number.value', '')}
//                     </div>
//                     <div className='text-xs'>
//                         <span className='text-gray-500'>Declared </span>
//                         {get(d, 'declaration_date.value', '')}
//                     </div>
//                     <div className='text-xs'>
//                         <span className='text-gray-500'>Type </span>
//                         {get(d, 'fips_state_code.value', '')}{get(d, 'fips_county_code.value', '')}
//                     </div>
//                 </div>
//             </div>
//         ))
//     }
// </div>