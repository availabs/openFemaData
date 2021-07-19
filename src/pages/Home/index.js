import React, {useState} from "react"
import {useFalcor} from '@availabs/avl-components'
import AdminLayout from '../Layout'
import {fnum} from "utils/fnum";
import {LoadFEMADisasterDeclarations, LoadFEMADisasters, LoadSWD, ProcessData} from './dataUtils'
import {Disasters} from './components/Disasters'
import {AddCompareCol} from "./tools/AddCompareCol";

const Home = (props) => {
    const {falcor, falcorCache} = useFalcor();
    const [compareCols, setCompareCols] = React.useState(JSON.parse(localStorage.getItem('compareCols') || '[]'));
    const [showCompareColsSetup, setShowCompareColsSetup] = useState(false);
    const [loadingIHPSummaryData, setLoadingIHPSummaryData] = useState({progress: 0, type: 'FEMA Disasters'});
    const [severeWeatherDataByDisaster, setSevereWeatherDataByDisaster] = useState({});

    LoadFEMADisasters(falcor, falcorCache, setLoadingIHPSummaryData, loadingIHPSummaryData);
    // LoadFEMADisasterDeclarations(falcor, falcorCache, loadingIHPSummaryData); // not needed anymore.
    LoadSWD(falcor, falcorCache, loadingIHPSummaryData, setLoadingIHPSummaryData, severeWeatherDataByDisaster, setSevereWeatherDataByDisaster);

    const data = ProcessData(falcor, falcorCache)

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
                        className={`float-right p-2 text-sm text-gray-500`}>{loadingIHPSummaryData.progress < 100 ? `Loading ${loadingIHPSummaryData.type}... ${fnum(loadingIHPSummaryData.progress, false)} %` : ''}</span>
                    {AddCompareCol(showCompareColsSetup, setShowCompareColsSetup, compareCols, setCompareCols)}
                </div>

                {
                    Disasters(data, severeWeatherDataByDisaster, compareCols, setCompareCols)
                }
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