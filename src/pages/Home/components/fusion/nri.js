import React from "react"
import get from 'lodash.get'
import {Table, useFalcor, useTheme} from '@availabs/avl-components'
import AdminLayout from '../../../Layout'
import {BarGraph} from "../../../../components/avl-graph/src";
import {fnum} from "../../../../utils/fnum";
import {RenderTabs} from "./Tabs";

const hazards = [
    'avalanche', 'coastal', 'coldwave', 'drought', 'earthquake', 'hail', 'heatwave', 'hurricane',
    'icestorm', 'landslide', 'lightning', 'riverine', 'wind', 'tornado', 'tsunami', 'volcano',
    'wildfire', 'winterweat'
]

const Fetch = (falcor) => {
    React.useEffect(() => {
        function fetchData() {
            falcor.get(
                ['nri', 'totals', 'all'],
                ['swdOfdMerge', 'fusion', 'hazard']
                )
        }

        return fetchData()
    }, [falcor])
}

const Process = (falcorCache) => {
    return React.useMemo(() => {
        return {
            nri: get(falcorCache, ['nri', 'totals', 'all', 'value', 0], []),
            fusion: get(falcorCache, ['swdOfdMerge', 'fusion', 'hazard', 'value'], []),
        }
    }, [falcorCache])
}

const ProcessDataForChart = (data) => {
    const divider = (hazard) =>
        ['wind', 'hail'].includes(hazard) ? 66 :
            ['tornado'].includes(hazard) ? 71 : 25;

    return React.useMemo(() => {
        const result = hazards.map(h => ({
            hazard: h,
            nri: data.nri[h],
            fusion: +get(data.fusion.filter(d => d.hazard === h), [0, 'total_loss'], 0) / divider(h)
        }))
        return {result}
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

const renderChart = (merged, attr, colors = ['#6ee173', '#5f78c9'], keys, title='') => {
    return (
        <>
            <div className='pt-4 pb-3 px-4 bg-white'>
                <h4>{title}</h4>
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
        </>
    )
}


const Compare = (props) => {
    const [view, setView] = React.useState('Compare');
    const {falcor, falcorCache} = useFalcor();


    Fetch(falcor)

    const data = Process(falcorCache)

    const {result: chartData} = ProcessDataForChart(data)

    return (
        <AdminLayout>
            <div className="w-full max-w-7xl mx-auto pb-5">
                <div className='pt-4 pb-3 px-6'>
                    <h3 className='inline font-bold text-3xl'>Fusion</h3>
                </div>
                {RenderTabs(view, setView)}

                {renderChart(chartData, 'hazard', null, ['nri'], 'NRI')}
                {renderChart(chartData, 'hazard', null, ['fusion'], 'Fusion')}
            </div>
        </AdminLayout>
    )
}

export default {
    path: "/fusion/compare",
    exact: true,
    auth: false,
    component: Compare,
    layout: 'Simple'
}