import _ from "lodash";
import React from "react";
import {Table} from '@availabs/avl-components'

export const SevereWeatherDataTable = (data = [], mapFocus, setMapFocus) => {
    data = data.map(d =>
        Object.assign({},
            {
                location:
                    <div
                        className={`fas fa-map-marker-alt text-blue-${mapFocus === d.geom ? 400 : 200} hover:text-blue-500 cursor-pointer transform duration-300 ease-out transition`}
                        onClick={() => setMapFocus(mapFocus === d.geom ? null : d.geom)}
                    />
            }, d
        ))
    return (
        <div className={`mt-20`}>
            <h4 className={`pt-5`}> Severe Weather Data </h4>
            <Table
                data={data}
                columns={
                    _.keys(data[0])
                        .filter(c => c !== 'geom')
                        .map(c => ({
                            Header: c,
                            accessor: c,
                            align: 'center',
                            disableFilters: true,
                            disableSortBy: true
                        }))
                }
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