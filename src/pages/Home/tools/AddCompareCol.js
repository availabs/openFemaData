import { Fragment, useState } from 'react'
import { Transition } from '@headlessui/react'
import { Select } from '@availabs/avl-components'
import { groups, SUMMARY_ATTRIBUTES, DISASTER_ATTRIBUTES } from "../utils";

const nav = (activeNav, setActiveNav) => {
    const tabs = ['Groups', 'Custom']
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
                    defaultValue={activeNav}
                    onChange={e => console.log('e', e)}
                >
                    {tabs.map((tab) => (
                        <option key={tab}>{tab}</option>
                    ))}
                </select>
            </div>
            <div className="hidden sm:block">
                <div className="border-b border-gray-200">
                    <nav className="-mb-px flex" aria-label="Tabs">
                        {tabs.map((tab) => (
                            <a
                                key={tab}
                                href={'#'}
                                className={`${tab === activeNav 
                                        ? 'border-indigo-500 text-indigo-600'
                                        : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'} 
                                    w-1/4 py-4 px-1 text-center border-b-2 font-medium text-sm`}
                                onClick={() => setActiveNav(tab)}
                            >
                                {tab}
                            </a>
                        ))}
                    </nav>
                </div>
            </div>
        </div>
    )
}

const RenderGroups = (compareCols, setCompareCols, visible = false) => {
    return (
        <div className={`space-y-3 ${visible ? `block` : `hidden`}`}>
            {
                Object.keys(groups)
                    .map(g => (
                        <div
                            className={`bg-blue-300 hover:bg-blue-500 width-auto inline-block p-3 ml-0 m-3 cursor-pointer transform ease-out duration-300 transition`}
                            onClick={() => {
                                localStorage.setItem('compareCols', JSON.stringify([...compareCols, g]))
                                setCompareCols([...compareCols, g])
                            }}
                        > {g} </div>
                    ))
            }
        </div>
    )
}

const RenderCustom = (compareCols, setCompareCols, visible = false) => {
    const [customCols, setCustomCols] = useState([]);
    const [disasterAttr, setDisasterAttr] = useState()
    const [disasterAttrVisible, setDisasterAttrVisible] = useState(false)
    const [summaryAttr, setSummaryAttr] = useState()
    const [summaryAttrVisible, setSummaryAttrVisible] = useState(false)
    const [operationVisible, setOperationVisible] = useState(false)
    const [operation, setOperation] = useState()

    return (
        <div className={`flex flex-col divide-y divide-gray-200 space-y-3 max-h-80 overflow-auto scrollbarXsm ${visible ? `block` : `hidden`}`}>

            <div className={`flex flex-row flex-wrap place-items-center`}>
                <div className={`flex p-1 place-items-center`} onClick={() => setDisasterAttrVisible(!disasterAttrVisible)}>
                    {disasterAttr ?
                        <div
                            className={`bg-blue-300 hover:bg-blue-500 width-auto inline-block p-3 ml-0 m-3 cursor-pointer transform ease-out duration-300 transition`}
                        >
                            {disasterAttr}
                            <span
                                className={`float-right cursor-pointer text-gray-300 hover:text-white transform ease-out duration-300 transition pl-3`}
                                onClick={() => {setDisasterAttr(null)}}
                            > x </span>
                        </div> : <div className={`text-gray-200`}>Select a Disaster attribute</div>
                    }
                    <i className={`fas fa-angle-down p-1`} /> </div>
            </div>
            <div className={disasterAttrVisible ? `block` : `hidden`}>
                {
                    DISASTER_ATTRIBUTES.map(g => (
                        <div
                            className={`bg-blue-300 hover:bg-blue-500 width-auto inline-block p-3 ml-0 m-3 cursor-pointer transform ease-out duration-300 transition`}
                            onClick={() => {
                                setDisasterAttr(g)
                                setDisasterAttrVisible(!disasterAttrVisible)
                            }}
                        > {g} </div>
                    ))
                }
            </div>

            <div className={`flex flex-row flex-wrap place-items-center`}>
                <div className={`flex p-1 place-items-center`} onClick={() => setOperationVisible(!operationVisible)}>
                    {operation ?
                        <div
                            className={`bg-blue-300 hover:bg-blue-500 width-auto inline-block p-3 ml-0 m-3 cursor-pointer transform ease-out duration-300 transition`}
                        >
                            {operation}
                            <span
                                className={`float-right cursor-pointer text-gray-300 hover:text-white transform ease-out duration-300 transition pl-3`}
                                onClick={() => {setOperation(null)}}
                            > x </span>
                        </div> : <div className={`text-gray-200`}>Select operation</div>
                    }
                    <i className={`fas fa-angle-down p-1`} /> </div>
            </div>
            <div className={operationVisible ? `block` : `hidden`}>
                {
                    ['+', '-', '/'].map(g => (
                        <div
                            className={`bg-blue-300 hover:bg-blue-500 width-auto inline-block p-3 ml-0 m-3 cursor-pointer transform ease-out duration-300 transition`}
                            onClick={() => {
                                setOperation(g)
                                setOperationVisible(!operationVisible)
                            }}
                        > {g} </div>
                    ))
                }
            </div>

            <div className={`flex flex-row flex-wrap place-items-center`}>
                <div className={`flex p-1 place-items-center`} onClick={() => setSummaryAttrVisible(!summaryAttrVisible)}>
                    {summaryAttr ?
                        <div
                            className={`bg-blue-300 hover:bg-blue-500 width-auto inline-block p-3 ml-0 m-3 cursor-pointer transform ease-out duration-300 transition`}
                        >
                            {summaryAttr}
                            <span
                                className={`float-right cursor-pointer text-gray-300 hover:text-white transform ease-out duration-300 transition pl-3`}
                                onClick={() => {setSummaryAttr(null)}}
                            > x </span>
                        </div> : <div className={`text-gray-200`}>Select a Summary attribute</div>
                    }
                    <i className={`fas fa-angle-down p-1`} /> </div>
            </div>

            <div className={summaryAttrVisible ? `block` : `hidden`}>
                {
                    Object.keys(groups).map(g => (
                        <div
                            className={`bg-indigo-300 hover:bg-indigo-500 width-auto inline-block p-3 ml-0 m-3 cursor-pointer transform ease-out duration-300 transition`}
                            onClick={() => {
                                setSummaryAttr(g)
                                setSummaryAttrVisible(!summaryAttrVisible)
                            }}
                        > {g} </div>
                    ))
                }
                {
                    SUMMARY_ATTRIBUTES.map(g => (
                        <div
                            className={`bg-blue-300 hover:bg-blue-500 width-auto inline-block p-3 ml-0 m-3 cursor-pointer transform ease-out duration-300 transition`}
                            onClick={() => {
                                setSummaryAttr(g)
                                setSummaryAttrVisible(!summaryAttrVisible)
                            }}
                        > {g} </div>
                    ))
                }
            </div>

            <div>
                Output: {`${disasterAttr} ${operation} ${summaryAttr}`}
            </div>

            <button
                className={`bg-blue-300 hover:bg-blue-500 transform ease-out duration-300 transition`}
                onClick={() => {
                    let finalCol;

                    if(disasterAttr && operation && summaryAttr){
                        finalCol = {type: 'operation', disasterAttr, summaryAttr, operation}
                    }else if(disasterAttr || summaryAttr){
                        finalCol = {type: 'simple', disasterAttr, summaryAttr}
                    }else{
                        return;
                    }
                    localStorage.setItem('compareCols', JSON.stringify([...compareCols, finalCol]))
                    setCompareCols([...compareCols, finalCol])
                }}
            >Add</button>
        </div>
    )
}
export const AddCompareCol = (show, setShow, compareCols, setCompareCols) => {
    // setCompareCols([...compareCols, {primary: '', operation: '', secondary: ''}]);
    const [activeNav, setActiveNav] = useState('Custom')
    return (
        <>
            <div
                aria-live="assertive"
                className="relative sm:fixed inset-x-0 sm:inset-1/3 w-full sm:w-auto flex items-end px-4 py-6 pointer-events-none sm:p-6 sm:items-start"
            >
                <div className="w-full flex flex-col items-center space-y-4 sm:items-end">
                    <Transition
                        show={show}
                        as={Fragment}
                        enter="transform ease-out duration-300 transition"
                        enterFrom="translate-y-2 opacity-0 sm:translate-y-0 sm:translate-x-2"
                        enterTo="translate-y-0 opacity-100 sm:translate-x-0"
                        leave="transition ease-in duration-100"
                        leaveFrom="opacity-100"
                        leaveTo="opacity-0"
                    >
                        <div className="max-w-sm w-full bg-white shadow-lg rounded-lg pointer-events-auto ring-1 ring-black ring-opacity-5 overflow-hidden">
                            <div className="p-4">
                                <div className="flex items-start">
                                    <div className="flex-shrink-0">
                                        <i className="fas fa-cogs"></i>
                                    </div>
                                    <div className="ml-3 w-0 flex-1 pt-0.5">
                                        <p className="text-sm font-medium text-gray-900">Configure</p>
                                        <p className="mt-1 text-sm text-gray-500">Select one or more attributes to display.</p>
                                        {nav(activeNav, setActiveNav)}

                                        {RenderGroups(compareCols, setCompareCols, activeNav === 'Groups')}
                                        {RenderCustom(compareCols, setCompareCols, activeNav === 'Custom')}

                                    </div>

                                    <div className="ml-4 flex-shrink-0 flex">
                                        <button
                                            className="bg-white rounded-md inline-flex text-gray-400 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                                            onClick={() => {
                                                setShow(false)
                                            }}
                                        >
                                            <span className="sr-only">Close</span>
                                            <i className="fas fa-times"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </Transition>
                </div>
            </div>
        </>
    )
}