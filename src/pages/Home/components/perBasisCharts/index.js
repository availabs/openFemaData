import React, {useState} from "react"
import get from 'lodash.get'
import {useFalcor, useTheme, Select} from '@availabs/avl-components'
import AdminLayout from '../../../Layout'
import {BarGraph} from "../../../../components/avl-graph/src";

const Fetch = (falcor, attr) => {
    React.useEffect(() => {
        function fetchData() {
            falcor.get(
                ['per_basis', 'index', 'event_type'],
                ['per_basis', 'stat'],
                ['per_basis', 'bins', ['building_loss_ratio_per_basis', 'crop_loss_ratio_per_basis', 'population_loss_ratio_per_basis', 'fema_building_loss_ratio_per_basis']],
                ['per_basis', 'zero_loss', ['building_loss_ratio_per_basis', 'crop_loss_ratio_per_basis', 'population_loss_ratio_per_basis', 'fema_building_loss_ratio_per_basis']],
                )
        }

        return fetchData()
    }, [attr, falcor])
}

const Process = (falcorCache) => {
    return React.useMemo(() => {
        return {
            femaEventTypeIndex: get(falcorCache, ['per_basis', 'index', 'event_type', 'value'], []),
            stat: get(falcorCache, ['per_basis', 'stat', 'value'], {}),
            bins: {
                building_loss_ratio_per_basis: get(falcorCache, ['per_basis', 'bins', 'building_loss_ratio_per_basis', 'value'], []),
                crop_loss_ratio_per_basis: get(falcorCache, ['per_basis', 'bins', 'crop_loss_ratio_per_basis', 'value'], []),
                population_loss_ratio_per_basis: get(falcorCache, ['per_basis', 'bins', 'population_loss_ratio_per_basis', 'value'], []),
                fema_loss_ratio_per_basis: get(falcorCache, ['per_basis', 'bins', 'fema_building_loss_ratio_per_basis', 'value'], []),
            },
            zero_loss: {
                building_loss_ratio_per_basis: get(falcorCache, ['per_basis', 'zero_loss', 'building_loss_ratio_per_basis', 'value'], []),
                crop_loss_ratio_per_basis: get(falcorCache, ['per_basis', 'zero_loss', 'crop_loss_ratio_per_basis', 'value'], []),
                population_loss_ratio_per_basis: get(falcorCache, ['per_basis', 'zero_loss', 'population_loss_ratio_per_basis', 'value'], []),
                fema_loss_ratio_per_basis: get(falcorCache, ['per_basis', 'zero_loss', 'fema_building_loss_ratio_per_basis', 'value'], []),
            },
        }
    }, [falcorCache])
}

const ProcessDataForChart = (data, attrX = 'bin') => {
    return React.useMemo(() => {
        let res = {}

        data.map(d => d.event_type)
            .forEach(event => {
                let tmpData = get(data.filter(d => d.event_type === event),[0], {});

                res[event] = Object.keys(tmpData)
                    .filter(key => key.includes('bin'))
                    .map((curr) => {
                        return {bin: curr, value: +tmpData[curr]}
                    })
            })

        return res
    }, [data])
}

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

const renderChart = (merged, attr='bin', colors = ['#6ee173', '#5f78c9'], keys = ['value']) => {
    return (
        <>
            <div className='pt-4 pb-3 px-4 bg-white'>
                <div className='p-2' style={{height: '500px'}}>
                    {merged.length ? <BarGraph
                        data={merged}
                        keys={keys}
                        indexBy={attr}
                        axisBottom={d => d}
                        yScale={5}
                        axisLeft={{format: d => d.toLocaleString() }}
                        // indexFormat={fnum}
                        // valueFormat={fnum}
                        hoverComp={{
                            HoverComp: HoverComp,
                            // valueFormat: fnum
                        }}
                        // groupMode={'grouped'}
                        colors={colors}
                    /> : null}
                </div>
            </div>
        </>
    )
}

const renderDropdown = (consequenceType, setConsequenceType) => {
    return(
        <Select
            domain={['Building', 'Crop', 'Population', 'Fema']}
            value={consequenceType}
            onChange={e => setConsequenceType(e || 'Building')}
            multi={false}
        />
    )
}

const Index = (props) => {
    const {falcor, falcorCache} = useFalcor();
    const [consequenceType, setConsequenceType] = useState('Building')
    const attr = 'bin'

    Fetch(falcor, attr)

    const data = Process(falcorCache)
    const chartData = ProcessDataForChart(data.bins[`${consequenceType.toLowerCase()}_loss_ratio_per_basis`])
    const zeroLossData = data.zero_loss[`${consequenceType.toLowerCase()}_loss_ratio_per_basis`]

    return (
        <AdminLayout>
            <div className="w-full max-w-7xl mx-auto pb-5">
                <div className='pt-4 pb-3 px-6 grid grid-cols-2'>
                    <h3 className='inline font-bold text-3xl'>Ratios Per Basis</h3>
                    <span className={`center-right`}>{renderDropdown(consequenceType, setConsequenceType)}</span>
                </div>
                {
                    Object.keys(data.stat)
                        .filter(event => event !== 'null')
                        .map(event =>
                            <div className={`p-4 pb-3 px-6`}>
                                <div className={`text-2xl capitalize font-bold pt-4`}>{event}</div>
                                <div className={`pt-4 grid gap-3 grid-cols-4`}>
                                    {
                                        Object.keys(data.stat[event])
                                            .filter(s => s !== 'event_type')
                                            .map(s => (
                                                <div className={`grid grid-cols-1 ${s.split('_')[0] === consequenceType.toLowerCase() ? 'font-bold' : ''}`}>
                                                    <div className={`text-center capitalize`}>{s.split('_').join(' ')}</div>
                                                    <div className={`text-center`}>{data.stat[event][s]}</div>
                                                </div>))
                                    }
                                    <div className={`grid grid-cols-1`}>
                                        <div className={`text-center capitalize`}># Zero Loss Events</div>
                                        <div className={`text-center`}>{zeroLossData[event]}</div>
                                    </div>
                                </div>
                                {renderChart(get(chartData, event, []))}
                            </div>
                        )
                }
            </div>
        </AdminLayout>
    )
}

export default {
    path: "/perbasis",
    exact: true,
    auth: false,
    component: Index,
    layout: 'Simple'
}