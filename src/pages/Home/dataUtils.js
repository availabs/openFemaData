import React from "react";
import get from "lodash.get";
import _ from "lodash";
import {
    DISASTER_ATTRIBUTES,
    DISASTER_DECLARATIONS_ATTRIBUTES, IHPGroups,
    SEVERE_WEATHER_ATTRIBUTES,
    IHP_SUMMARY_ATTRIBUTES
} from './config';

export const LoadFEMADisasters = (falcor, falcorCache, setLoadingIHPSummaryData, loadingIHPSummaryData) => {
    return React.useEffect(() => {
        async function fetchData() {
            return falcor.get(['fema_disasters', 'length'])
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
                        return _.chunk(disasterNumbers, 50).reduce((a, c, cI) => {
                            return a.then(() => {
                                setLoadingIHPSummaryData({
                                    progress: (cI + 1) * 100 / (disasterNumbers.length / 50),
                                    type: 'FEMA Disasters'
                                })

                                return falcor.get(
                                    ['fema_disasters', c, 'declarations', 'length'],
                                    ['fema_disasters', 'byId', c, 'ihp_summary', IHP_SUMMARY_ATTRIBUTES],
                                    ['fema_disasters', 'byId', c, DISASTER_ATTRIBUTES],
                                    ['fema_disasters', c, 'declarations', 'length']
                                )
                            })
                        }, Promise.resolve());
                    }
                    return Promise.resolve();
                });
        }

        return fetchData();
    }, [falcorCache]);
}
const fetchDecData = (falcor, falcorCache, loadingIHPSummaryData) => {
    if (loadingIHPSummaryData.progress > 95 && loadingIHPSummaryData.type === 'FEMA Disasters') {
        let disasters = get(falcorCache, ['fema_disasters'], {});
        let reqs = [];
        Object.keys(disasters)
            .forEach(disasterNumber => {
                let declarationLength = get(disasters, [disasterNumber, 'declarations', 'length', 'value'], {});
                if(declarationLength > 50){
                    for(let i = 0; i < declarationLength; i += 50){
                        reqs.push(
                            ['fema_disasters', disasterNumber, 'declarations', 'byIndex',
                                {from: i, to: Math.min(i+49, declarationLength - 1)},
                                DISASTER_DECLARATIONS_ATTRIBUTES
                            ]
                        )
                    }
                }else{
                    reqs.push(
                        ['fema_disasters', disasterNumber, 'declarations', 'byIndex',
                            {from: 0, to: declarationLength - 1},
                            DISASTER_DECLARATIONS_ATTRIBUTES
                        ]
                    )
                }
            })

        return _.chunk(reqs, 50).reduce((acc, currReqs, cI) => acc.then(() => falcor.get(...currReqs)), Promise.resolve());
    }
}
export const LoadFEMADisasterDeclarations = (falcor, falcorCache, loadingIHPSummaryData) => {
    return React.useEffect(() => {
        return fetchDecData(falcor, falcorCache, loadingIHPSummaryData);
    }, [falcor, falcorCache, falcorCache.fema, loadingIHPSummaryData]);
}

export const LoadSWD = (falcor, falcorCache, loadingIHPSummaryData, setLoadingIHPSummaryData, severeWeatherDataByDisaster, setSevereWeatherDataByDisaster) => {
    return React.useEffect(() => {
        function fetchData() {
            const disasterNumbers = Object.values(get(falcorCache, ['fema_disasters', 'byIndex'], {}))
                .map(d => get(falcorCache, get(d, 'value', []), {}))
                .map(d => get(d, 'disaster_number', null))
                .filter(d => d);

            let SWD = {}

            return _.chunk(disasterNumbers, 500).reduce((acc, disasterNumbers, cI) => {
                return acc.then(() => {
                    return falcor.get(
                        ['severeWeather', 'byDisaster', disasterNumbers, ['num_events', 'num_episodes', 'total_damage']]
                    ).then(swd => {
                        disasterNumbers.forEach(dns => {
                            if(
                                ['num_events', 'num_episodes', 'total_damage'].reduce((acc, attr) =>
                                    acc || get(swd, ['json', 'severeWeather', 'byDisaster', dns, attr], null) , null)
                            ){
                                // only store valid data to save space
                                SWD[dns] = ['num_events', 'num_episodes', 'total_damage'].reduce((acc, attr) => {
                                    acc[attr] = +get(swd, ['json', 'severeWeather', 'byDisaster', dns, attr], 0)
                                    return acc;
                                }, {})

                            }
                        });
                        setSevereWeatherDataByDisaster(SWD);

                        return swd
                    })
                })
            }, Promise.resolve())
                .then(() => {
                    setSevereWeatherDataByDisaster(SWD);
                    SWD = {}
                })
        }

        return fetchData();
    }, [falcor, falcorCache, falcorCache.fema_disasters, setSevereWeatherDataByDisaster])
}

export const ProcessData = (falcor, falcorCache) => {
    return React.useMemo(() => {
        const disasters = Object.values(get(falcorCache, ['fema_disasters', 'byIndex'], {}))
            .filter(d => d)
            .map(d => {
                return {
                    ...get(falcorCache, get(d, 'value', []), {}),
                    ...get(falcorCache, ['fema_disasters', 'byId', get(d, ['value', 2], []), 'ihp_summary'], {})
                }
            })
            .sort((a, b) =>
                get(b, 'total_cost', 0) - get(a, 'total_cost', 0));

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
        }

    }, [falcorCache]);
}

export const calcCol = (col1, col2, op) =>
    op === '/' ? col1 / col2 :
        op === '+' ? col1 + col2 :
            op === '-' ? col1 - col2 : null;

export const getFinalValue = (disaster, col) => {
    const getValue = {
        disasterAttr: (attr) => typeof attr === "string" ?
            get(disaster, [attr], 0) :
            getFinalValue(disaster, attr),
        summaryAttr: (attr) => typeof attr === "string" ?
            Object.keys(IHPGroups).includes(attr) ?
                IHPGroups[attr].attributes.reduce((a, c) => a + (+get(disaster, [c, 'value'], 0)), 0)
                : get(disaster, [attr, 'value'], 0) :
            getFinalValue(disaster, attr)
    }

    let attr1, attr2, title = col.title;
    let sequence = get(col, 'sequence', 'disasterAttr::summaryAttr').split('::');

    if (col.type === 'operation') {

        attr1 = getValue[sequence[0]](col[sequence[0]]);
        attr2 = getValue[sequence[1]](col[sequence[1]]);
    } else if (col.type.split('::')[1]) {
        attr1 = getValue[col.type.split('::')[1]](col.attrs[0]);
        attr2 = getValue[col.type.split('::')[1]](col.attrs[1]);
    }

    if (!title) {
        title = `${attr1.title || col[sequence[0]] || col.attrs[0]} ${col.operation} ${attr2.title || col[sequence[1]] || col.attrs[1]}`
    }

    return {value: calcCol(+attr1.value || +attr1, +attr2.value || +attr2, col.operation), title}
}