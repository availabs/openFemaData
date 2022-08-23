import React from "react"
import get from 'lodash.get'
import {Table, useFalcor, useTheme} from '@availabs/avl-components'
import AdminLayout from '../../../Layout'
import {BarGraph} from "../../../../components/avl-graph/src";
import {fnum} from "../../../../utils/fnum";
import {RenderTabs} from "./Tabs";

const hazards =
    {
        'avalanche': 'avln', 'coastal': 'cfld', 'coldwave': 'cwav', 'drought': 'drgt', 'earthquake': 'erqk', 'hail': 'hail', 'heatwave': 'hwav', 'hurricane': 'hrcn',
        'icestorm': 'istm', 'landslide': 'lnds', 'lightning': 'ltng', 'riverine': 'rfld', 'wind': 'swnd', 'tornado': 'trnd', 'tsunami': 'tsun', 'volcano': 'vlcn',
        'wildfire': 'wfir', 'winterweat': 'wntw'
    }

const Fetch = (falcor) => {
    React.useEffect(() => {
        function fetchData() {
            falcor.get(
                ['nri', 'hlr'],
                ['per_basis', 'hlr'],
                ['nri', 'exposure']
                )
        }

        return fetchData()
    }, [falcor])
}

const Process = (falcorCache) => {
    return React.useMemo(() => {
        console.log('fc', falcorCache)
        return {
            // nri: get(falcorCache, ['nri', 'totals', 'detailed', 'all', 'value', 0]),
            nri: get(falcorCache, ['nri', 'hlr', 'value']),
            per_basis_hlr: get(falcorCache, ['per_basis', 'hlr', 'value']),
            nri_exposure: get(falcorCache, ['nri', 'exposure', 'value']),
        }
    }, [falcorCache])
}

const ProcessDataForChart = (data, falcorCache) => {
    return React.useMemo(() => {
        console.log('data', data)
        if (!data.nri || !data.per_basis_hlr) return {};
        console.log('comes here')
        return {
            nri: Object.keys(hazards).map(h => {
                return data.nri.filter(d => d.nri_category === h)
                                        .reduce((acc, curr) => {
                                            let tmpNRIExposure = data.nri_exposure.find(ne => ne.nri_category === h && ne.geoid === curr.geoid);

                                            if(tmpNRIExposure || true){
                                                acc.buildings += +(get(curr, ['hlrb'], 0)
                                                    * tmpNRIExposure.expb * tmpNRIExposure.afreq
                                                ) || 0;
                                                acc.crop += +(get(curr, ['hlra'], 0)
                                                    * tmpNRIExposure.expa * tmpNRIExposure.afreq
                                                ) || 0;
                                                acc.population += +(get(curr, ['hlrp'], 0)
                                                    * tmpNRIExposure.exppe * tmpNRIExposure.afreq
                                                ) || 0;
                                            }

                                            return acc;
                                        }, {
                                            hazard: h,
                                            buildings: 0,
                                            crop: 0,
                                            population: 0
                                        })
            }),
            per_basis: Object.keys(hazards).map(h => {
                return data.per_basis_hlr.filter(d => d.nri_category === h)
                                            .reduce((acc, curr) => {
//                                                let tmpNRIExposure = data.nri_exposure.find(ne => ne.nri_category === h && ne.geoid === curr.geoid);
//                                                acc.buildings += (+get(curr, ['hlr_b'], 0) * tmpNRIExposure.expb * tmpNRIExposure.afreq) || 0;
//                                                acc.crop += (+get(curr, ['hlr_c'], 0) * tmpNRIExposure.expa * tmpNRIExposure.afreq) || 0;
//                                                acc.population += (+get(curr, ['hlr_p'], 0) * tmpNRIExposure.exppe * tmpNRIExposure.afreq) || 0;
//                                                acc.fema_buildings += (+get(curr, ['hlr_f'], 0) * tmpNRIExposure.expb * tmpNRIExposure.afreq) || 0;
//                                                acc.fema_crop += (+get(curr, ['hlr_fc'], 0) * tmpNRIExposure.expa * tmpNRIExposure.afreq) || 0;


                                                acc.buildings += (+get(curr, ['swd_building'], 0)) || 0;
                                                acc.crop += (+get(curr, ['swd_crop'], 0)) || 0;
//                                                acc.population += (+get(curr, ['swd_people'], 0)) || 0;
                                                acc.fema_buildings += (+get(curr, ['fema_building'], 0)) || 0;
                                                acc.fema_crop += (+get(curr, ['fema_crop'], 0)) || 0;

                                                return acc;
                                            }, {
                                                hazard: h,
                                                buildings: 0,
                                                crop: 0,
                                                population: 0,
                                                fema_buildings: 0,
                                                fema_crop: 0
                                            })
            })
        }
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
    if(!merged) return <></>
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

    const chartData = ProcessDataForChart(data, falcorCache)
    console.log('d?', chartData)
    return (
        <AdminLayout>
            <div className="w-full max-w-7xl mx-auto pb-5">
                <div className='pt-4 pb-3 px-6'>
                    <h3 className='inline font-bold text-3xl'>Fusion</h3>
                </div>
                {RenderTabs(view, setView)}

                {renderChart(chartData.nri, 'hazard', null, ['buildings'/*, 'population', 'crop'*/], 'NRI')}
                {renderChart(chartData.per_basis, 'hazard', null, ['buildings'/*, 'population', 'crop'*/
                ], 'SWD')}
                {renderChart(chartData.per_basis, 'hazard', null, ['fema_buildings'/*, 'fema_crop', 'fema_population'*/], 'FEMA')}
            </div>
        </AdminLayout>
    )
}

export default {
    path: "/perbasis/compare",
    exact: true,
    auth: false,
    component: Compare,
    layout: 'Simple'
}