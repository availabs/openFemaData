import React from "react"
import get from 'lodash.get'
import {Table, useFalcor, useTheme} from '@availabs/avl-components'
import AdminLayout from '../../../Layout'
import {BarGraph} from "../../../../components/avl-graph/src";
import {fnum} from "../../../../utils/fnum";
import {RenderTabs} from "./Tabs";

const ATTRIBUTES = ['year', 'geoid', 'hazard', 'group_by', 'disaster_title'];

const Fetch = (falcor, attr) => {
    React.useEffect(() => {
        function fetchData() {
            falcor.get(
                ['swdOfdMerge', 'fusion', 'year.hazard'],
                ['swdOfdMerge', 'fusion', 'year.disaster_number'],
                )
        }

        return fetchData()
    }, [attr, falcor])
}

const Process = (falcorCache, attr) => {
    return React.useMemo(() => {
        return {
            fusionByYearByHaz: get(falcorCache, ['swdOfdMerge', 'fusion', 'year.hazard', 'value'], []).filter(d => d.year >= 2000),
            fusionByYearByDN: get(falcorCache, ['swdOfdMerge', 'fusion', 'year.disaster_number', 'value'], []).filter(d => d.year >= 2000),
        }
    }, [falcorCache])
}

const ProcessDataForChart = (data, attrStack, attrX = 'year') => {
    return React.useMemo(() => {
        let result = [...new Set(data.map(d => d[attrX]))], indexValues = new Set()
        result = result.map(x => {
                    return {
                        [attrX]: x,
                        ...data.filter(d => d[attrX] === x)
                            .reduce((acc, curr) => {
                                let i = curr[attrStack] || `No ${attrStack.replace('_', ' ')}`
                                indexValues.add(i)
                                acc[i] = +curr.total_loss
                                return acc
                            }, {})
                    }
            })
        return {result, indexValues: [...indexValues]}
    }, [attrStack, attrX, data])
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

const renderChart = (merged, attr, colors = ['#6ee173', '#5f78c9'], keys = ['total_loss']) => {
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
        </>
    )
}

const renderTable = (data, idx) => {

    return (
        <Table
            data={data}
            columns={
                [
                    ...['hazard']
                        .map(c => ({
                            Header: c,
                            accessor: c,
                            disableFilters:true
                        })),
                    ...idx
                        .map(c => ({
                            Header: c.toString(),
                            accessor: c.toString(),
                            disableFilters: true,
                            sortMethod: (a, b) => Number(a) - Number(b),
                            Cell: d =>
                                fnum(d.cell.value || 0, true)
                            // d.cell.value.toLocaleString()
                        }))
                ]
            }
            initialPageSize={20}
        />

    )
}

const Fusion = (props) => {
    const [view, setView] = React.useState('Chart');
    const {falcor, falcorCache} = useFalcor();
    const attr = 'year'

    Fetch(falcor, attr)

    const data = Process(falcorCache, attr)

    const {result: dataByyearByHaz, indexValues} = ProcessDataForChart(data.fusionByYearByHaz, 'hazard')
    const {result: databyHazByyear, indexValues: idx} = ProcessDataForChart(data.fusionByYearByHaz, 'year', 'hazard')
    const {result: dataByyearByDN, indexValues: indexValuesDN} = ProcessDataForChart(data.fusionByYearByDN, 'disaster_number')

    return (
        <AdminLayout>
            <div className="w-full max-w-7xl mx-auto pb-5">
                <div className='pt-4 pb-3 px-6'>
                    <h3 className='inline font-bold text-3xl'>Fusion</h3>
                </div>
                {RenderTabs(view, setView)}
                {renderChart(dataByyearByDN, attr, null, indexValuesDN)}
                {renderChart(dataByyearByHaz, attr, null, indexValues)}
                {renderTable(databyHazByyear, idx)}
            </div>
        </AdminLayout>
    )
}

export default {
    path: "/fusion",
    exact: true,
    auth: false,
    component: Fusion,
    layout: 'Simple'
}