import _ from "lodash";
import get from 'lodash'
import React from "react";
import {Table} from '@availabs/avl-components'
import {fnum} from "../../../utils/fnum";

export const MergeSummaryTable = (data, totals) => {
    let summary = totals;
    let colGridLen = Object.keys(summary).filter(c => !['group_by'].includes(c)).length
    const cols = _.keys(data[0])
        .filter(c => !['group_by'].includes(c))
        .map(c => ({
            Header: c.replace(/_/g, ' '),
            accessor: c,
            align: 'center',
            disableFilters: true,
            sortMethod: (a, b) => Number(a) - Number(b),
            Cell: !['geoid', 'disaster_number'].includes(c) ? d => fnum(d.cell.value, true) : d => d.cell.value
        }))

    return (
        <div className={`mt-20`}>
            <h4 className={`pt-5`}> Summary Data </h4>
            <div className={`flex flex-col sm:flex-row bg-white grid grid-cols-1 sm:grid-cols-${colGridLen} divide-y divide-gray-200 sm:divide-y-0 sm:divide-x mb-5`}>
                {
                    Object.keys(summary)
                        .filter(c => !['group_by'].includes(c))
                        .map(attr => (
                            <div className={`px-6 py-5 text-sm font-medium text-center`}>
                                <div className={`text-gray-600 capitalize`}>{attr.replace(/_/g, ' ')}</div>
                                <div className={`text-lg`}>{
                                    !['geoid', 'disaster_number'].includes(attr) ?
                                        fnum(summary[attr]) :
                                        summary[attr]
                                }</div>
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