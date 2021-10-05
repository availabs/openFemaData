import React from "react"
import get from 'lodash.get'
import {useFalcor, useTheme, Table} from '@availabs/avl-components'
import {BarGraph} from '../../components/avl-graph/src'
import AdminLayout from '../Layout'
import {fnum} from "utils/fnum";
import { RenderMap } from "./components/merge/map";

const ATTRIBUTES = ['year', 'geoid', 'hazard', 'group_by', 'disaster_title'];
const allowedHaz = ["wind", "wildfire", "tsunami", "tornado", "riverine", "lightning", "landslide", "icestorm", "hurricane",
    "heatwave", "hail", "earthquake", "drought", "avalanche", "coldwave", "winterweat", "volcano", "coastal"];

const Fetch = (falcor, attr) => {
    React.useEffect(() => {
        function fetchData() {
            falcor.get(['severeWeather', 'disasterNumbersList'])
                .then(response => falcor.get(
                    ['severeWeather', 'byDisaster', get(response, 'json.severeWeather.disasterNumbersList', ['0']), ['num_events', 'num_episodes', 'total_damage']],
                    ['swdOfdMerge', 'indexValues', ['geoid', 'hazard', 'year']],
                    ['swdOfdMerge', 'swd', attr],
                    ['swdOfdMerge', 'swd', 'hazard.year'],
                    ['swdOfdMerge', 'swd', 'geoid.hazard.year'],
                    ['swdOfdMerge', 'ofd_sba_new', attr],
                    ['swdOfdMerge', 'ofd_sba_new', 'year.disaster_number.disaster_title'],
                    ['swdOfdMerge', 'ofd_sba_new', 'hazard.year'],
                    ['swdOfdMerge', 'ofd_sba_new', 'geoid.hazard.year']
                ))
        }

        return fetchData()
    }, [attr, falcor])
}

const Process = (falcorCache, attr) => {
    return React.useMemo(() => {
        return {
            swd: convertDataToNumeric(get(falcorCache, ['swdOfdMerge', 'swd', attr, 'value'], []), attr),
            swdByHazByYear: convertDataToNumeric(get(falcorCache, ['swdOfdMerge', 'swd', 'hazard.year', 'value'], [])),
            swdByGeoByHazByYear: convertDataToNumeric(get(falcorCache, ['swdOfdMerge', 'swd', 'geoid.hazard.year', 'value'], [])),
            swdByDn: get(falcorCache, ['severeWeather', 'byDisaster'], []),

            ofd: convertDataToNumeric(get(falcorCache, ['swdOfdMerge', 'ofd_sba_new', attr, 'value'], []), attr),
            ofdByHazByYear: convertDataToNumeric(get(falcorCache, ['swdOfdMerge', 'ofd_sba_new', 'hazard.year', 'value'], [])),
            ofdByYearByDn: convertDataToNumeric(get(falcorCache, ['swdOfdMerge', 'ofd_sba_new', 'year.disaster_number.disaster_title', 'value'], [])),
            ofdByGeoByHazByYear: convertDataToNumeric(get(falcorCache, ['swdOfdMerge', 'ofd_sba_new', 'geoid.hazard.year', 'value'], [])),

            indexValues: {
                hazard: get(falcorCache, ['swdOfdMerge', 'indexValues', 'hazard', 'value'], []),
                year: get(falcorCache, ['swdOfdMerge', 'indexValues', 'year', 'value'], []),
                geoid: get(falcorCache, ['swdOfdMerge', 'indexValues', 'geoid', 'value'], [])
            }
        }
    }, [falcorCache, attr])
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

const MergeData = ({swd, ofd, index, indexValues}) => {
    return React.useMemo(() => {
        let result = [];

        indexValues[index].forEach((iv, i) => {
            result.push({
                [index]: iv,
                swd_loss: get(swd.filter(s => s[index] === iv), [0, 'total_damage'], 0),
                ofd_loss: get(ofd.filter(o => o[index] === iv), [0, 'total_loss'], 0)
            })
        })
        return result;
    }, [indexValues, index, swd, ofd])
}

const MergeDataDeep = (swd, ofd, index, indexValues) => {
    return React.useMemo(() => {
        let result = [];

        if(index.length === 2){
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
        } else if (index.length === 3){
            indexValues[index[0]].forEach((iv, i) => {
                indexValues[index[1]].forEach((iv1, i1) => {
                    indexValues[index[2]].forEach((iv2, i2) => {
                        result.push({
                            [index[0]]: iv,
                            [index[1]]: iv1,
                            [index[2]]: iv2,
                            swd_loss: get(swd.filter(s => s[index[0]] === iv && s[index[1]] === iv1 && s[index[2]] === iv2), [0, 'total_damage'], 0),
                            ofd_loss: get(ofd.filter(o => o[index[0]] === iv && o[index[1]] === iv1 && o[index[2]] === iv2), [0, 'total_loss'], 0)
                        })
                    })
                })
            })
        }

        return result;
    }, [index, indexValues, ofd, swd])
}

const ProcessDataByyearByDn = (data, indexValues, attr) => {
    let result = [];
    let disaster_numbers = new Set();
    indexValues[attr]
        .forEach(i => {
            let tmpData = data.filter(d => d[attr] === i).sort((a,b) => a.total_loss - b.total_loss);
            if(tmpData.length){
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
}

const HoverComp = ({ data, keys, indexFormat, keyFormat, valueFormat }) => {
    const theme = useTheme();
    return (
        <div className={ `
      flex flex-col px-2 pt-1 rounded
      ${ keys.length <= 1 ? "pb-2" : "pb-1" }
      ${ theme.accent1 }
    ` }>
            <div className="font-bold text-lg leading-6 border-b-2 mb-1 pl-2">
                { indexFormat(get(data, "index", null)) }
            </div>
            { keys.slice()
                // .filter(k => get(data, ["data", k], 0) > 0)
                .filter(key => data.key === key)
                .reverse().map(key => (
                <div key={ key } className={ `
            flex items-center px-2 border-2 rounded transition
            ${ data.key === key ? "border-current" : "border-transparent" }
          `}>
                    <div className="mr-2 rounded-sm color-square w-5 h-5"
                         style={ {
                             backgroundColor: get(data, ["barValues", key, "color"], null),
                             opacity: data.key === key ? 1 : 0.2
                         } }/>
                    <div className="mr-4">
                        { keyFormat(key) }:
                    </div>
                    <div className="text-right flex-1">
                        { valueFormat(get(data, ["data", key], 0)) }
                    </div>
                </div>
            ))
            }
            { keys.length <= 1 ? null :
                <div className="flex pr-2">
                    <div className="w-5 mr-2"/>
                    <div className="mr-4 pl-2">
                        Total:
                    </div>
                    <div className="flex-1 text-right">
                        {  valueFormat(keys.reduce((a, c) => a + get(data, ["data", c], 0), 0)) }
                    </div>
                </div>
            }
        </div>
    )
}

const renderTabs = (tabs, setView, classNames) => {
    return (
        <div>
            <div className="sm:hidden">
                <label htmlFor="tabs" className="sr-only">
                    Select a tab
                </label>
                <select
                    id="tabs"
                    name="tabs"
                    className="block w-full focus:ring-indigo-500 focus:border-indigo-500 border-gray-300 rounded-md"
                    defaultValue={(tabs.find((tab) => tab.current) || {}).name}
                    onChange={e => setView(e.target.value)}
                >
                    {tabs.map((tab) => (
                        <option key={tab.name}>{tab.name}</option>
                    ))}
                </select>
            </div>


            <div className="hidden sm:block">
                <div className="border-b border-gray-200">
                    <nav className="-mb-px flex" aria-label="Tabs">
                        {tabs.map((tab) => (
                            <a
                                key={tab.name}
                                href={tab.href}
                                className={classNames(
                                    tab.current
                                        ? 'border-indigo-500 text-indigo-600'
                                        : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300',
                                    'w-1/4 py-4 px-1 text-center border-b-2 font-medium text-sm'
                                )}
                                aria-current={tab.current ? 'page' : undefined}
                                onClick={e => setView(tab.name)}
                            >
                                {tab.name}
                            </a>
                        ))}
                    </nav>
                </div>
            </div>
        </div>
    )
}

const renderChart = (merged, mergedByHazardByYear, attr,colors= ['#6ee173', '#5f78c9'],  keys = ['swd_loss', 'ofd_loss']) => {
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
                            valueFormat:fnum
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
                        sortMethod: (a, b) => Number(a)-Number(b),
                        Cell: d =>
                            fnum( d.cell.value, true)
                            // d.cell.value.toLocaleString()
                    }))
                ]
            }
        />

    )
}

const Merge = (props) => {
    const [view, setView] = React.useState('Map');
    const {falcor, falcorCache} = useFalcor();
    const attr = 'year'

    Fetch(falcor, attr)

    const data = Process(falcorCache, attr)

    const merged = MergeData({...data, index: attr})

    const mergedByHazardByYear = MergeDataDeep(data.swdByHazByYear, data.ofdByHazByYear, ['hazard', 'year'], data.indexValues)

    const {result:dataByYearByDm, disaster_numbers} = ProcessDataByyearByDn(data.ofdByYearByDn, data.indexValues, attr);

    const tabs = [{ name: 'Chart', href: '#', current: view === 'Chart' },
        { name: 'Map', href: '#', current: view === 'Map' },
        { name: 'ChartByDis', href: '#', current: view === 'ChartByDis' },
    ];

    function classNames(...classes) {
        return classes.filter(Boolean).join(' ')
    }

    let ofdSwdByDn =
        data.ofdByYearByDn
            .map(r => {
                r['swd_loss'] = get(data.swdByDn, [r.disaster_number, 'total_damage'], 0)
                return r
            })
    return (
        <AdminLayout>
            <div className="w-full max-w-7xl mx-auto">
                <div className='pt-4 pb-3 px-6'>
                    <h3 className='inline font-bold text-3xl'>Merge</h3>
                </div>

                {renderTabs(tabs, setView, classNames)}

                <div className={view === 'Chart' ? 'block' : 'hidden'}>
                    {renderChart(merged, mergedByHazardByYear, attr,  ['#6ee173', '#5f78c9'], ['swd_loss', 'ofd_loss'])}
                </div>

                <div className={view === 'Map' ? 'block' : 'hidden'}>
                    {RenderMap(data)}
                </div>

                <div className={view === 'ChartByDis' ? 'block' : 'hidden'}>
                    {renderChart(dataByYearByDm, {}, attr, null, disaster_numbers)}
                    {renderTable(ofdSwdByDn)}
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