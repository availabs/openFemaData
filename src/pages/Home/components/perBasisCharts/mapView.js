import React from "react"
import get from 'lodash.get'
import {useFalcor} from '@availabs/avl-components'
import AdminLayout from '../../../Layout'
import {RenderMap} from "./map";
import {RenderTabs} from "./Tabs";

const Merge = (props) => {
    const [view, setView] = React.useState('Map');

    return (
        <AdminLayout>
            <div className="w-full max-w-7xl mx-auto pb-5">
                <div className='pt-4 pb-3 px-6'>
                    <h3 className='inline font-bold text-3xl'>Merge</h3>
                </div>

                {RenderTabs(view, setView)}

                {RenderMap()}
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