import React from "react"
import get from 'lodash.get'
import {useFalcor} from '@availabs/avl-components'
import AdminLayout from '../../../Layout'
import {RenderMap} from "./map";
import {RenderTabs} from "./Tabs";

const ATTRIBUTES = ['year', 'geoid', 'hazard', 'group_by', 'disaster_title'];

const Fetch = (falcor) => {
    React.useEffect(() => {
        function fetchData() {
            falcor.get(['per_basis', 'hlr'])
        }
        return fetchData()
    }, [falcor])
}

const Process = (falcorCache) => {
    return React.useMemo(() => {
        return {
            hlr: get(falcorCache, ['per_basis', 'hlr'], []),
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

const Merge = (props) => {
    const [view, setView] = React.useState('Map');
    const {falcor, falcorCache} = useFalcor();

    Fetch(falcor)

    const data = Process(falcorCache)
    console.log('data?', data)
    return (
        <AdminLayout>
            <div className="w-full max-w-7xl mx-auto pb-5">
                <div className='pt-4 pb-3 px-6'>
                    <h3 className='inline font-bold text-3xl'>Merge</h3>
                </div>

                {RenderTabs(view, setView)}

                {RenderMap(data)}
            </div>
        </AdminLayout>
    )
}

export default {
    path: "/perbasis/map",
    exact: true,
    auth: false,
    component: Merge,
    layout: 'Simple'
}