import React from "react"
import get from 'lodash.get'
import {Table, useFalcor, useTheme} from '@availabs/avl-components'
import {BarGraph} from '../../../../components/avl-graph/src'
import AdminLayout from '../../../Layout'
import {fnum} from "utils/fnum";
import {RenderTabs} from "./Tabs";

const ATTRIBUTES = ['year', 'geoid', 'hazard', 'group_by', 'disaster_title'];
const allowedHaz = ["wind", "wildfire", "tsunami", "tornado", "riverine", "lightning", "landslide", "icestorm", "hurricane",
    "heatwave", "hail", "earthquake", "drought", "avalanche", "coldwave", "winterweat", "volcano", "coastal"];

const Fetch = (falcor, attr) => {
    React.useEffect(() => {
        function fetchData() {
            falcor.get(
                ['severeWeather', 'disasterNumbersList'], ['swdOfMerge', 'swd', 'withoutDisasterNumber', 'year'])
                .then(response => falcor.get(
                    ['severeWeather', 'byDisaster', get(response, 'json.severeWeather.disasterNumbersList', ['0']), ['year', 'num_events', 'num_episodes', 'total_damage']],
                    ['swdOfdMerge', 'indexValues', ['year']],
                    ['swdOfdMerge', 'ofd_sba_new', 'year.disaster_number.disaster_title']
                ))
        }

        return fetchData()
    }, [attr, falcor])
}

const Process = (falcorCache) => {
    return React.useMemo(() => {
        return {
            swdByDn: get(falcorCache, ['severeWeather', 'byDisaster'], []),
            swdWithoutDn: get(falcorCache, ['severeWeather', 'swd', 'withoutDisasterNumber', 'year', 'value'], []),

            ofdByYearByDn: convertDataToNumeric(get(falcorCache, ['swdOfdMerge', 'ofd_sba_new', 'year.disaster_number.disaster_title', 'value'], [])).filter(data => data.year >= 2000),

            indexValues: {
                year: get(falcorCache, ['swdOfdMerge', 'indexValues', 'year', 'value'], []).filter(year => year >= 2000),
            }
        }
    }, [falcorCache])
}

const convertDataToNumeric = (data, index) => {
    return data.map(d => {
        return Object.keys(d)
            .reduce((acc, curr) => {
                acc[curr] = ATTRIBUTES.includes(curr) ? d[curr] : parseFloat(d[curr])
                return acc;
            }, {})
    })
}

const ProcessDataByyearByDn = (data, indexValues, attr) => React.useMemo(() => {
    let result = [];
    let disaster_numbers = new Set();
    indexValues[attr]
        .forEach(i => {
            let tmpData = data.filter(d => d[attr] === i);
            if (tmpData.length) {
                result.push({
                    [attr]: i,
                    ...tmpData.reduce((acc, curr) => {
                        disaster_numbers.add(curr['disaster_number']);
                        acc[curr['disaster_number']] = curr['total_loss']
                        return acc;
                    }, {})
                })
            }
        })
    return {result, disaster_numbers: [...disaster_numbers]}
}, [attr, data, indexValues])

const HoverComp = ({data, keys, indexFormat, keyFormat, valueFormat}) => {
    const theme = useTheme();
    return (
        <div className={`
      flex flex-col px-2 pt-1 rounded
      ${keys.length <= 1 ? "pb-2" : "pb-1"}
      ${theme.accent1}
    `}>
            <div className="font-bold text-lg leading-6 border-b-2 mb-1 pl-2">
                {indexFormat(get(data, "index", null))}
            </div>
            {keys.slice()
                // .filter(k => get(data, ["data", k], 0) > 0)
                .filter(key => data.key === key)
                .reverse().map(key => (
                    <div key={key} className={`
            flex items-center px-2 border-2 rounded transition
            ${data.key === key ? "border-current" : "border-transparent"}
          `}>
                        <div className="mr-2 rounded-sm color-square w-5 h-5"
                             style={{
                                 backgroundColor: get(data, ["barValues", key, "color"], null),
                                 opacity: data.key === key ? 1 : 0.2
                             }}/>
                        <div className="mr-4">
                            {keyFormat(key)}:
                        </div>
                        <div className="text-right flex-1">
                            {valueFormat(get(data, ["data", key], 0))}
                        </div>
                    </div>
                ))
            }
            {keys.length <= 1 ? null :
                <div className="flex pr-2">
                    <div className="w-5 mr-2"/>
                    <div className="mr-4 pl-2">
                        Total:
                    </div>
                    <div className="flex-1 text-right">
                        {valueFormat(keys.reduce((a, c) => a + get(data, ["data", c], 0), 0))}
                    </div>
                </div>
            }
        </div>
    )
}

const renderChart = (merged, mergedByHazardByYear, attr, colors = ['#6ee173', '#5f78c9'], keys = ['swd_loss', 'ofd_loss']) => {
    return (
        <>
            <div className='pt-4 pb-3 px-4 bg-white'>
                <div className='p-2' style={{height: '500px'}}>
                    {merged.length ? <BarGraph
                        data={merged}
                        keys={keys}
                        indexBy={attr}
                        axisBottom={d => d}
                        axisLeft={{format: fnum}}
                        indexFormat={fnum}
                        valueFormat={fnum}
                        hoverComp={{
                            HoverComp: HoverComp,
                            valueFormat: fnum
                        }}
                        // groupMode={'grouped'}
                        colors={colors}
                    /> : null}
                </div>
            </div>

            {mergedByHazardByYear.length ?
                <div className="pt-5 grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-2">
                    {
                        allowedHaz
                            .map(hazard => (
                                <div className='pt-4 pb-3 px-2 bg-white'>
                                    <label className={'font-bold'}>  {hazard} </label>
                                    <div className='p-2' style={{height: '300px'}}>
                                        {mergedByHazardByYear.length ? <BarGraph
                                            data={mergedByHazardByYear.filter(m => m.hazard === hazard)}
                                            keys={keys}
                                            indexBy={'year'}
                                            axisBottom={d => d}
                                            axisLeft={{format: fnum}}
                                            indexFormat={fnum}
                                            valueFormat={fnum}
                                            // groupMode={'grouped'}
                                            colors={['#6ee173', '#5f78c9']}
                                        /> : null}
                                    </div>
                                </div>

                            ))
                    }
                </div> : null}
        </>
    )
}

const renderTable = (ofdByYearByDn, swdByDn) => {

    return (
        <Table
            data={ofdByYearByDn}
            columns={
                [
                    ...['disaster_title', 'disaster_number', 'year']
                        .map(c => ({
                            Header: c,
                            accessor: c
                        })),
                    ...['ihp_verified_loss', 'project_amount', 'sba_loss', 'total_loss', 'swd_loss']
                        .map(c => ({
                            Header: c,
                            accessor: c,
                            sortMethod: (a, b) => Number(a) - Number(b),
                            Cell: d =>
                                fnum(d.cell.value, true)
                            // d.cell.value.toLocaleString()
                        }))
                ]
            }
        />

    )
}

const Merge = (props) => {
    const [view, setView] = React.useState('ChartByDis');
    const {falcor, falcorCache} = useFalcor();
    const attr = 'year'

    Fetch(falcor, attr)

    const data = Process(falcorCache, attr)

    const {
        result: dataByYearByDm,
        disaster_numbers
    } = ProcessDataByyearByDn(data.ofdByYearByDn, data.indexValues, attr);

    let ofdSwdByDn = React.useMemo(() => {
        return data.ofdByYearByDn
            .map(r => {
                r['swd_loss'] = get(data.swdByDn, [r.disaster_number, 'total_damage'], 0)
                return r
            })
    }, [data.ofdByYearByDn, data.swdByDn])

    let swdByYear = React.useMemo(() => {
        return data.indexValues.year.map(year => {
            let noDN = +(data.swdWithoutDn.filter(d => d.year === year)[0] || {}).total_damage
            let withDN = Object.keys(data.swdByDn).filter(d => data.swdByDn[d].year === year).reduce((acc, curr) => {
                acc[curr] = data.swdByDn[curr].total_damage;
                return acc
            }, {})

            return {
                ...withDN,
                'No DN': noDN,
                year,
            }
        })
    }, [data.indexValues.year, data.swdWithoutDn, data.swdByDn])

    return (
        <AdminLayout>
            <div className="w-full max-w-7xl mx-auto pb-5">
                <div className='pt-4 pb-3 px-6'>
                    <h3 className='inline font-bold text-3xl'>Merge</h3>
                </div>

                {RenderTabs(view, setView)}

                {renderChart(dataByYearByDm, {}, attr, null, disaster_numbers)}

                {/*storm events data on the below chart will be lesser than the original chart on the first tab 'Chart'. */}
                {/*This happens because there are disaster numbers which exist in open_fema_data.disaster_declarations_summaries_v2, */}
                {/*but are not present in open_fema_data.public_assistance_funded_projects_details_v1 or */}
                {/*open_fema_data.individuals_and_households_program_valid_registrations_v1.*/}

                {renderChart(swdByYear, {}, attr, null, [...disaster_numbers, 'No DN'])}
                {renderTable(ofdSwdByDn)}

            </div>
        </AdminLayout>
    )
}

export default {
    path: "/merge/chartbydis",
    exact: true,
    auth: false,
    component: Merge,
    layout: 'Simple'
}