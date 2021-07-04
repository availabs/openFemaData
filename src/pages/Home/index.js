import React, {useState} from "react"
import {useFalcor} from '@availabs/avl-components'
import {Link} from 'react-router-dom'
import _ from 'lodash'
import AdminLayout from '../Layout'
import get from 'lodash.get'
import {fnum} from "utils/fnum";
import {DISASTER_ATTRIBUTES, SUMMARY_ATTRIBUTES, groups} from './utils'
import {AddCompareCol} from "./tools/AddCompareCol";

const calcCol = (col1, col2, op) =>
    op === '/' ? col1 / col2 :
        op === '+' ? col1 + col2 :
            op === '-' ? col1 - col2 : null;

const Home = (props) => {
    const {falcor, falcorCache} = useFalcor();
    const [compareCols, setCompareCols] = React.useState(JSON.parse(localStorage.getItem('compareCols') || '[]'));
    const [showCompareColsSetup, setShowCompareColsSetup] = useState(false);
    const [loadingIHPSummaryData, setLoadingIHPSummaryData] = useState(0);

    React.useEffect(() => {
        async function fetchData() {
            falcor.get(['fema_disasters', 'length'])
                .then(async res => {
                    const numDisasters = get(res.json, ['fema_disasters', 'length'], 0)
                    await falcor.get(['fema_disasters', 'byIndex', {
                        from: 0,
                        to: numDisasters - 1
                    }, DISASTER_ATTRIBUTES]);

                    const disasterNumbers = Object.values(get(falcorCache, ['fema_disasters', 'byIndex'], {}))
                        .map(d => get(falcorCache, get(d, 'value', []), {}))
                        .map(d => get(d, 'disaster_number', null))
                        .filter(d => d);

                    if (disasterNumbers.length) {

                        console.time('summaryData')
                        let d = await _.chunk(disasterNumbers, 100).reduce((a, c, cI) => {
                            return a.then(() => {
                                setLoadingIHPSummaryData(cI * 100 / (disasterNumbers.length / 100))
                                return falcor.get(
                                    ['fema_disasters', c, 'declarations', 'length'],
                                    ['fema_disasters', 'byId', c, 'ihp_summary', SUMMARY_ATTRIBUTES]
                                )
                            })
                        }, Promise.resolve());
                        setLoadingIHPSummaryData(100)
                        console.timeEnd('summaryData')

                        return d
                    }
                    return Promise.resolve();
                });
        }

        return fetchData();
    }, [falcor, falcorCache]);


    const data = React.useMemo(() => {
        const disasters = Object.values(get(falcorCache, ['fema_disasters', 'byIndex'], {}))
            .filter(d => d)
            .map(d => {
                return {
                    ...get(falcorCache, get(d, 'value', []), {}),
                    ...get(falcorCache, ['fema_disasters', 'byId', get(d, ['value', 2], []), 'ihp_summary'], {})
                }
            });

        const disaster_types = disasters.reduce((types, cur) => {
            const type = get(cur, 'disaster_type', null)
            if (!type) {
                return types
            }
            if (!types[type]) {
                types[type] = {count: 0, cost: 0}
            }
            types[type].count += 1

            return types
        }, {})

        return {
            numDisasters: get(falcorCache, ['fema_disasters', 'length'], 0),
            disasterTypes: disaster_types,
            disasters: disasters
                .sort((a, b) => get(b, 'total_cost', 0) - get(a, 'total_cost', 0))
        }

    }, [falcorCache]);

    return (
        <AdminLayout>
            <div className="w-full max-w-7xl mx-auto">
                <div className='pt-4 pb-3 px-6'>
                    <h3 className='inline font-bold text-3xl'>Home</h3>
                </div>

                <div className='pt-4 pb-3 px-4 bg-white'>
                    <div className='p-2'>TYPES:{JSON.stringify(data.disasterTypes)}</div>
                </div>

                <div className='pt-4 pb-10'>
                    <button
                        type="button"
                        className={`items-center p-1 border border-transparent rounded-full shadow-sm text-white w-full
                        ${showCompareColsSetup ? `sm:w-9 sm:h-9 rounded-full bg-red-600 hover:bg-red-700 focus:ring-red-500` : `sm:w-auto bg-indigo-600 hover:bg-indigo-700 focus:ring-indigo-500`} 
                        focus:outline-none focus:ring-2 focus:ring-offset-2 
                        sm:float-right `}
                        onClick={() => {
                            setShowCompareColsSetup(!showCompareColsSetup);
                        }}
                    >{showCompareColsSetup ? <i className="fas fa-times"></i> : 'compare'} </button>
                    <span
                        className={`float-right p-2 text-sm text-gray-500`}>{loadingIHPSummaryData < 100 ? `Loading Compare Data... ${fnum(loadingIHPSummaryData, false)} %` : ''}</span>
                    {AddCompareCol(showCompareColsSetup, setShowCompareColsSetup, compareCols, setCompareCols)}
                </div>

                <div className={`pt-4 pb-3`}>
                    {data.disasters
                        .filter((d, i) => i < 100)
                        .map((disaster, i) => (
                                <div key={i}
                                     className={`border-t border-gray-200 bg-white grid grid-cols-1 divide-y divide-gray-200 sm:grid-cols-${compareCols.length + 6} sm:divide-y-0 sm:divide-x`}>
                                    <div className={`px-6 py-5 text-sm font-medium text-center`}>
                                        <Link to={`/disaster/${get(disaster, 'disaster_number', 0)}`}>
                                            <div>{get(disaster, 'name', '')}</div>
                                            <div className='text-xs'>
                                                <span className='text-gray-500'>DN </span>
                                                {get(disaster, 'disaster_number', '')}
                                            </div>
                                            <div className='text-xs'>
                                                <span className='text-gray-500'>Declared </span>
                                                {get(disaster, 'declaration_date', '')}
                                            </div>
                                            <div className='text-xs'>
                                                <span className='text-gray-500'>Type </span>
                                                {get(disaster, 'disaster_type', '')}
                                            </div>
                                        </Link>
                                    </div>

                                    <div
                                        className="px-6 py-5 text-sm font-medium text-center bg-gray-50 overflow-auto scrollbarXsm">
                                        <div className='text-gray-600'>Total</div>
                                        <div className='text-lg'>
                                            {fnum(+get(disaster, 'total_cost', ''))}
                                        </div>
                                        <div className='text-gray-600'>declarations</div>
                                        <div>
                                            {get(disaster, 'numDeclarations', '')}
                                        </div>

                                    </div>

                                    <div
                                        className="px-6 py-5 text-sm font-medium text-center overflow-auto scrollbarXsm flex flex-wrap justify-center">
                                        <div>
                                            <div className='text-gray-600'>Total IHP</div>
                                            <div className='text-lg'>
                                                {fnum(+get(disaster, 'total_amount_ihp_approved', '') || 0)}
                                            </div>
                                        </div>
                                        <div className='flex flex-wrap justify-center'>
                                            <div className='text-lg p-1'>
                                                <div className='text-gray-600 text-sm'>Total HA</div>
                                                {fnum((get(disaster, 'total_amount_ha_approved', 0) || 0))}
                                            </div>
                                            <div className='text-lg p-1'>
                                                <div className='text-gray-600 text-sm'>Total ONA</div>
                                                {fnum((get(disaster, 'total_amount_ona_approved', 0) || 0))}

                                            </div>
                                        </div>
                                    </div>

                                    <div
                                        className="px-6 py-5 text-sm font-medium text-center overflow-auto scrollbarXsm flex flex-wrap justify-center">
                                        <div>
                                            <div className='text-gray-600'>Total PA</div>
                                            <div className='text-lg'>
                                                {fnum(+get(disaster, 'total_obligated_amount_pa', '') || 0)}
                                            </div>
                                            <div className='text-lg'>
                                                <div className='text-gray-600 text-sm'>check</div>
                                                {fnum((+get(disaster, 'total_obligated_amount_cat_ab', 0) || 0)
                                                    + (+get(disaster, 'total_obligated_amount_cat_c2g', 0) || 0))
                                                }
                                            </div>
                                        </div>

                                        <div className='flex flex-wrap justify-center'>
                                            <div className='text-lg p-1'>
                                                <div className='text-gray-600 text-sm'>CAT AB</div>
                                                {fnum((get(disaster, 'total_obligated_amount_cat_ab', 0) || 0))}
                                            </div>
                                            <div className='text-lg p-1'>
                                                <div className='text-gray-600 text-sm'>CAT C2G</div>
                                                {fnum((get(disaster, 'total_obligated_amount_cat_c2g', 0) || 0))}

                                            </div>
                                        </div>
                                    </div>

                                    <div className="px-6 py-5 text-sm font-medium text-center overflow-auto scrollbarXsm">
                                        <div className='text-gray-600'>Total HMGP</div>
                                        <div className='text-lg'>
                                            {fnum(+get(disaster, 'total_obligated_amount_hmgp', '') || 0)}
                                        </div>
                                    </div>

                                    <div className="px-6 py-5 text-sm font-medium text-center overflow-auto scrollbarXsm">
                                        <div className='text-gray-600'>Severe Weather</div>
                                    </div>

                                    {
                                        (compareCols || []).map(col => (
                                                <div className="px-6 py-5 text-sm font-medium text-center bg-gray-50 shadow-lg break-all">
                                                    <span
                                                        className={`float-right cursor-pointer text-gray-300 hover:text-gray-500 transform ease-out duration-300 transition`}
                                                        onClick={() => {
                                                            localStorage.setItem('compareCols', JSON.stringify(compareCols.filter(cc => cc !== col)))
                                                            setCompareCols(compareCols.filter(cc => cc !== col))
                                                        }
                                                        }
                                                    >{!i ? 'x' : null}</span>

                                                    {
                                                        typeof col === "string" ?
                                                            (
                                                                <React.Fragment>
                                                                    <div className='text-gray-600'>{col}</div>
                                                                    {fnum(groups[col].attributes.reduce((a, c) => a +
                                                                        (+get(disaster, [c, 'value'], 0)), 0))}
                                                                </React.Fragment>
                                                            ) :
                                                            col.type === 'simple' ?
                                                                <React.Fragment>
                                                                    <div className='text-gray-600 capitalize'>{(col.disasterAttr || col.summaryAttr).replace(/_/g, ' ')}</div>
                                                                    {
                                                                        fnum(col.disasterAttr ? get(disaster, [col.disasterAttr], 0) :
                                                                            get(disaster, [col.summaryAttr, 'value'], 0))
                                                                    }
                                                                </React.Fragment> :
                                                                (
                                                                    <React.Fragment>
                                                                        <div className='text-gray-600 capitalize'>{`${col.disasterAttr.replace(/_/g, ' ')} ${col.operation} ${col.summaryAttr.replace(/_/g, ' ')}`}</div>
                                                                        {
                                                                            calcCol(
                                                                                get(disaster, [col.disasterAttr], 0),
                                                                                Object.keys(groups).includes(col.summaryAttr) ?
                                                                                    groups[col.summaryAttr].attributes.reduce((a, c) => a +
                                                                                        (+get(disaster, [c, 'value'], 0)), 0)
                                                                                    : get(disaster, [col.summaryAttr, 'value'], 0),
                                                                                col.operation).toFixed(5)
                                                                        }
                                                                    </React.Fragment>
                                                                )
                                                    }
                                                </div>
                                            )
                                        )
                                    }
                                </div>
                            )
                        )}
                </div>
            </div>
        </AdminLayout>
    )
}

export default {
    path: "/",
    exact: true,
    auth: false,
    component: Home,
    layout: 'Simple'
}