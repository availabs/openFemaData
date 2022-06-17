import React from "react"
import get from 'lodash.get'
import {Table, useFalcor, useTheme} from '@availabs/avl-components'
import AdminLayout from '../../../Layout'
import {BarGraph} from "../../../../components/avl-graph/src";
import {fnum} from "../../../../utils/fnum";
import {RenderMap} from "./map";
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

const Fusion = (props) => {
    const [view, setView] = React.useState('Map');
    const {falcor, falcorCache} = useFalcor();
    const attr = 'year'

    Fetch(falcor, attr)

    const data = Process(falcorCache, attr)

    return (
        <AdminLayout>
            <div className="w-full max-w-7xl mx-auto pb-5">
                <div className='pt-4 pb-3 px-6'>
                    <h3 className='inline font-bold text-3xl'>Fusion</h3>
                </div>
                {RenderTabs(view, setView)}
                {RenderMap()}
            </div>
        </AdminLayout>
    )
}

export default {
    path: "/tmp/map",
    exact: true,
    auth: false,
    component: Fusion,
    layout: 'Simple'
}