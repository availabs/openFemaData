import React, {useState} from "react"
import get from 'lodash.get'
import {useFalcor} from '@availabs/avl-components'
import {BarGraph, generateTestBarData} from '../../components/avl-graph/src'
import AdminLayout from '../Layout'
import {fnum} from "utils/fnum";

const ATTRIBUTES = ['year', 'geoid', 'hazard']

const convertDataToNumberic = (data, index) => {
    return data.map(d => {
        return Object.keys(d)
            .reduce((acc, curr) => {
                acc[curr] = curr === index ? d[index] : parseFloat(d[curr])
                return acc;
            }, {})
    })
}

const mergeData = ({swd, ofd, index, indexValues}) => {
    let result = [];

    indexValues.forEach((iv, i) => {
        result.push({
            [index]: index === 'year' ? iv : i,
            swd_loss: get(swd.filter(s => s[index] === iv), [0, 'total_damage'], 0),
            ofd_loss: get(ofd.filter(o => o[index] === iv), [0, 'total_loss'], 0)
        })
    })
    return result;
}
const Merge = (props) => {
    const {falcor, falcorCache} = useFalcor();
    const attr = 'year'
    React.useEffect(() => {
        function fetchData() {
            falcor.get(['swdOfdMerge', 'indexValues', attr], ['swdOfdMerge', 'swd', attr], ['swdOfdMerge', 'ofd', attr])
        }
        return fetchData()
    })

    const data = React.useMemo(() => {
        return {
            swd: convertDataToNumberic(get(falcorCache, ['swdOfdMerge', 'swd', attr, 'value'], []), attr),
            ofd: convertDataToNumberic(get(falcorCache, ['swdOfdMerge', 'ofd', attr, 'value'], []), attr),
            indexValues: get(falcorCache, ['swdOfdMerge', 'indexValues', attr, 'value'], [])
        }
    }, [falcorCache])

    const merged = React.useMemo(() => {
        return mergeData({...data, index:attr})
    }, [data])

    console.log(merged)

    return (
        <AdminLayout>
            <div className="w-full max-w-7xl mx-auto">
                <div className='pt-4 pb-3 px-6'>
                    <h3 className='inline font-bold text-3xl'>Merge</h3>
                </div>

                <div className='pt-4 pb-3 px-4 bg-white'>
                    <div className='p-2' style={{height:'500px'}}>
                        {merged.length ? <BarGraph
                            data={merged}
                            keys={[attr, 'swd_loss', 'ofd_loss']}
                            indexBy={attr}
                            axisBottom={true}
                            axisLeft={true}
                            indexFormat={fnum}
                            valueFormat={fnum}
                        /> : null}
                    </div>
                </div>


            </div>
        </AdminLayout>
    )
}

export default {
    path: "/merge",
    exact: true,
    auth: false,
    component: Merge,
    layout: 'Simple'
}