import React, {useState} from "react"
import get from 'lodash.get'
import {useFalcor} from '@availabs/avl-components'
import {BarGraph, generateTestBarData} from '../../components/avl-graph/src'
import AdminLayout from '../Layout'
import {fnum} from "utils/fnum";

const ATTRIBUTES = ['year', 'geoid', 'hazard', 'group_by']

const convertDataToNumeric = (data, index) => {
    return data.map(d => {
        return Object.keys(d)
            .reduce((acc, curr) => {
                acc[curr] = ATTRIBUTES.includes(curr) ? d[curr] : parseFloat(d[curr])
                return acc;
            }, {})
    })
}

const mergeData = ({swd, ofd, index, indexValues}) => {
    let result = [];

    indexValues[index].forEach((iv, i) => {
        result.push({
            [index]: iv,
            swd_loss: get(swd.filter(s => s[index] === iv), [0, 'total_damage'], 0),
            ofd_loss: get(ofd.filter(o => o[index] === iv), [0, 'total_loss'], 0)
        })
    })
    return result;
}

const mergeDataDeep = (swd, ofd, index, indexValues) => {
    let result = [];

    indexValues[index[0]].forEach((iv, i) => {
        indexValues[index[1]].forEach((iv1, i1) => {
            result.push({
                [index[0]]: iv,
                [index[1]]: iv1,
                swd_loss: get(swd.filter(s => s[index[0]] === iv && s[index[1]] === iv1), [0, 'total_damage'], 0),
                ofd_loss: get(ofd.filter(o => o[index[0]] === iv && o[index[1]] === iv1), [0, 'total_loss'], 0)
            })
        })
    })
    return result;
}

const Merge = (props) => {
    const {falcor, falcorCache} = useFalcor();
    const attr = 'year'
    React.useEffect(() => {
        function fetchData() {
            falcor.get(
                ['swdOfdMerge', 'indexValues', ['hazard', 'year']],
                ['swdOfdMerge', 'swd', attr],
                ['swdOfdMerge', 'swd', 'hazard.year'],
                ['swdOfdMerge', 'ofd', attr],
                ['swdOfdMerge', 'ofd', 'hazard.year'],
            )
        }
        return fetchData()
    })
    const data = React.useMemo(() => {

        return {
            swd: convertDataToNumeric(get(falcorCache, ['swdOfdMerge', 'swd', attr, 'value'], []), attr),
            swdByHazByYear: convertDataToNumeric(get(falcorCache, ['swdOfdMerge', 'swd', 'hazard.year', 'value'], [])),
            ofd: convertDataToNumeric(get(falcorCache, ['swdOfdMerge', 'ofd', attr, 'value'], []), attr),
            ofdByHazByYear: convertDataToNumeric(get(falcorCache, ['swdOfdMerge', 'ofd', 'hazard.year', 'value'], [])),
            indexValues: {
                hazard: get(falcorCache, ['swdOfdMerge', 'indexValues', 'hazard', 'value'], []),
                year: get(falcorCache, ['swdOfdMerge', 'indexValues', 'year', 'value'], [])
            }
        }
    }, [falcorCache])

    const merged = React.useMemo(() => {
        return mergeData({...data, index:attr})
    }, [data])

    const mergedByHazardByYear = React.useMemo(() => {
        return mergeDataDeep( data.swdByHazByYear, data.ofdByHazByYear, ['hazard', 'year'], data.indexValues)
            // .filter(f => f.swd_loss !== 0 || f.ofd_loss !== 0)
    }, [data])


    // const sortedHaz = data.indexValues["hazard"]
    //     .sort((a,b) =>
    //         mergedByHazardByYear.filter(m => m.hazard === b && (m.swd_loss !== 0 || m.ofd_loss !== 0)).length -
    //         mergedByHazardByYear.filter(m => m.hazard === a && (m.swd_loss !== 0 || m.ofd_loss !== 0)).length
    //     )
    // console.log(sortedHaz.map(h => `'${h}'`).join(','))

    const sortedHaz = ['tornado','hail','wind','coldwave','Dense Fog','Heavy Rain','hurricane','icestorm','lightning',
        'riverine','wildfire','winterweat','coastal','drought','Dust Storm','Dust Devil','landslide','avalanche',
        'heatwave','tsunami','Freezing Fog','earthquake','Dense Smoke','volcano','Astronomical Low Tide','Dam/Levee Break',
        'Marine Dense Fog','Northern Lights','OTHER']
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
                            keys={['swd_loss', 'ofd_loss']}
                            indexBy={attr}
                            axisBottom={d => d}
                            axisLeft={{format: fnum}}
                            indexFormat={fnum}
                            valueFormat={fnum}
                            groupMode={'grouped'}
                            colors={['#6ee173', '#5f78c9']}
                        /> : null}
                    </div>
                </div>

                <div className="pt-5 grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-2">
                    {
                        sortedHaz
                            .map(hazard => (
                                <div className='pt-4 pb-3 px-2 bg-white'>
                                    <label className={'font-bold'}>  {hazard} </label>
                                    <div className='p-2' style={{height:'300px'}}>
                                        {mergedByHazardByYear.length ? <BarGraph
                                            data={mergedByHazardByYear.filter(m => m.hazard === hazard)}
                                            keys={['swd_loss', 'ofd_loss']}
                                            indexBy={'year'}
                                            axisBottom={d => d}
                                            axisLeft={{format: fnum}}
                                            indexFormat={fnum}
                                            valueFormat={fnum}
                                            groupMode={'grouped'}
                                            colors={['#6ee173', '#5f78c9']}
                                        /> : null}
                                    </div>
                                </div>

                            ))
                    }
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