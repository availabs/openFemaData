import get from "lodash.get";
import React from "react";
import InfiniteScroll from "react-infinite-scroll-component";
import {compareGroups, IHPGroups} from "../config";
import {Link} from "react-router-dom";
import {fnum} from "utils/fnum";
import {getFinalValue} from "../dataUtils";

const RenderCustom = (disaster, col) => {
    const {value, title} = getFinalValue(disaster, col);

    return (
        <React.Fragment>
            <div className='text-gray-600 capitalize'>{col.title || title.replace(/_/g, ' ')}</div>
            {
                value.toFixed(5)
            }
        </React.Fragment>
    )
}

export const Disasters = (data, severeWeatherDataByDisaster, compareCols, setCompareCols) => {
    const [index, setIndex] = React.useState(10)
    return React.useMemo(() => {
        function renderUI() {
            return (
                <div className={`pt-4 pb-3`} style={{height: '650px'}} id="scrollableDiv">

                    <InfiniteScroll
                        dataLength={index}
                        next={() => {
                            console.log('i', index)
                            setIndex(Math.min(index + 10, data.disasters.length))
                        }}
                        height={650}
                        className={`overflow-auto scrollbarXsm`}
                        hasMore={true}
                        loader={<h4>Loading...</h4>}
                        scrollableTarget="scrollableDiv"
                    >
                        {data.disasters
                            .filter((d, i) => i < index)
                            .map((disaster, i) => (
                                    <div key={i}
                                         className={`border-t border-gray-200 bg-white grid grid-cols-1 divide-y divide-gray-200 sm:grid-cols-${compareGroups.length + compareCols.length + 6} sm:divide-y-0 sm:divide-x`}>
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
                                            {
                                                Object.keys(get(severeWeatherDataByDisaster, [get(disaster, 'disaster_number', 0)], {}))
                                                    .map(attr => (
                                                        <>
                                                            <div className='text-gray-600 capitalize'>{attr.replace(/_/g, ' ')}</div>
                                                            <div className='text-lg'>
                                                                {fnum(+get(severeWeatherDataByDisaster, [get(disaster, 'disaster_number', 0), attr], '') || 0, attr === 'total_damage')}
                                                            </div>
                                                        </>
                                                    ))
                                            }
                                        </div>

                                        {
                                            ([...compareGroups, ...(compareCols || [])]).map(col => (
                                                    <div
                                                        className="px-6 py-5 text-sm font-medium text-center bg-gray-50 shadow-lg break-all">
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
                                                                        {fnum(IHPGroups[col].attributes.reduce((a, c) => a +
                                                                            (+get(disaster, [c, 'value'], 0)), 0))}
                                                                    </React.Fragment>
                                                                ) :
                                                                col.type === 'simple' ?
                                                                    <React.Fragment>
                                                                        <div
                                                                            className='text-gray-600 capitalize'>{(col.disasterAttr || col.summaryAttr).replace(/_/g, ' ')}</div>
                                                                        {
                                                                            fnum(col.disasterAttr ? get(disaster, [col.disasterAttr], 0) :
                                                                                get(disaster, [col.summaryAttr, 'value'], 0))
                                                                        }
                                                                    </React.Fragment> :
                                                                    RenderCustom(disaster, col)
                                                        }
                                                    </div>
                                                )
                                            )
                                        }
                                    </div>
                                )
                            )}
                    </InfiniteScroll>
                    {/*<button className={`${index > 10 ? `block` : `block`} float-right -mt-5 z-10 fixed`} onClick={() => Document.getElementById('').scrollTo(0, 0)} href={'#'}>Back to top</button>*/}
                </div>
            )
        }

        return renderUI();
    }, [index, data.disasters, compareCols, severeWeatherDataByDisaster, setCompareCols])
}