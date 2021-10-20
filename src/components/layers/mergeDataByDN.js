import {scaleLinear} from "d3-scale"
import _ from "lodash"
import get from "lodash.get"
import {LayerContainer} from "@availabs/avl-map"
import {getColorRange, useTheme} from "@availabs/avl-components";
import {fnum} from "../../utils/fnum";

const mapping = {
    'Severe Weather with DN': 'total_damage',
    'Severe Weather without DN': 'total_damage',
    'Merge: Open Fema': 'ofd_total',
    'Merge: SWD': 'swd_loss',
    'Difference (swd - ofd + sba)': 'Difference with SBA'
}
class mergeData extends LayerContainer {

    // setActive = !!this.viewId
    name = 'Merge Data by Disaster Number'
    id = 'Merge Data by Disaster Number'
    data = []
    filters = {
        dataset: {
            name: "Dataset",
            type: "dropdown",
            multi: false,
            value: 'Severe Weather with DN',
            domain: ['Merge: Open Fema', 'Merge: SWD', 'Severe Weather with DN', 'Severe Weather without DN'],
        },
        disaster_number: {
            name: "Disaster Number",
            type: "dropdown",
            multi: false,
            value: '',
            domain: [],
        },
    }

    legend = {
        Title: ({layer}) => get(layer.filters.attribute, 'value', '').replace(/_/g, ' '),
        type: "quantile",
        domain: ['60000000', '150000000', '500000000', '1000000000', '5000000000', '10000000000', '20000000000'],
        format: fnum,
        range: getColorRange(7, "YlOrRd", true),
        show: true,
    }

    onHover = {
        layers: ['counties'],
        HoverComp: ({data, layer}) => {
            const theme = useTheme();
            return (
                <div style={{maxHeight: '300px'}} className={`${theme.bg} rounded relative px-1 overflow-auto scrollbarXsm`}>
                    {
                        data.map((row, i) =>
                            <div key={i} className="flex">
                                {
                                    row.map((d, ii) =>
                                        <div key={ii}
                                             style={{maxWidth: '200px'}}
                                             className={`
                                                    ${ii === 0 ? "flex-1 font-bold" : "overflow-auto scrollbarXsm"}
                                                    ${row.length > 1 && ii === 0 ? "mr-4" : ""}
                                                    ${row.length === 1 && ii === 0 ? `border-b-2 text-lg ${i > 0 ? "mt-1" : ""}` : ""}
                                                    `}>
                                            {d}
                                        </div>
                                    )
                                }
                            </div>
                        )
                    }
                </div>
            )
        },
        callback: (layerId, features, lngLat) => {

            return features.reduce((a, feature) => {
                let data = get(this.data.filter(d => d.geoid === feature.properties.geoid), [0], {})

                return [
                    ...a,
                    [get(this.geoNames, [feature.properties.geoid, 'name'], feature.properties.geoid), feature.properties.geoid],
                    ...Object.keys(data)
                        .filter(d => !['geoid', 'group_by'].includes(d))
                        .reduce((acc, curr) => {
                            acc.push([curr.replace(/_/g, ' '), parseFloat(data[curr]).toLocaleString()])
                            return acc;
                        }, [])
                ]
            }, []);
        }
    }

    sources = [
        {
            id: "counties",
            source: {
                'type': "vector",
                'url': 'mapbox://am3081.a8ndgl5n'
            },
        },
    ]

    layers = [
        {
            'id': 'counties',
            'source': 'counties',
            'source-layer': 'counties',
            'type': 'fill',
        },
        {
            'id': 'counties-line',
            'source': 'counties',
            'source-layer': 'counties',
            'type': 'line',
            paint: {
                "line-width": [
                    'interpolate',
                    ['linear'],
                    ['zoom'],
                    4, 0,
                    22, 0
                ],
                "line-color": '#ccc',
                "line-opacity": 0.5
            }
        }
    ]


    init(map, falcor) {
        map.fitBounds([-125.0011, 24.9493, -66.9326, 49.5904])
    }

    receiveProps(props, map, falcor, MapActions) {
        this.fetchData(falcor).then(() => this.render(map, falcor))
    }

    fetchData(falcor) {
        return falcor.get(
            ['swdOfdMerge', 'indexValues', ['geoid', 'hazard', 'year']],
            ['severeWeather', 'disasterNumbersList'],
            ['swdOfMerge', 'swd', 'withoutDisasterNumber', 'geoid'],
            ['swdOfdMerge', 'summary', 'disaster_numbers'],
        ).then(d => {
            let disasterNumbers = [...new Set(
                [
                    ...get(d, `json.severeWeather.disasterNumbersList`, []),
                    ...get(d, `json.swdOfdMerge.summary.disaster_numbers`, []),
                ]
            )]

            this.filters.disaster_number.domain = disasterNumbers
            if(disasterNumbers.length){
                return falcor.get(
                    ['swdOfdMerge', 'summary', 'geoid.disaster_number.disaster_title', disasterNumbers],
                    ['severeWeather', 'byDisaster', disasterNumbers, ['geoid', 'total_damage']],
                )
            }
        }).then(() => {
            let data = falcor.getCache()

            this.data = {
                indexValues: get(data, 'swdOfdMerge.indexValues', {}),
                merge: get(data, 'swdOfdMerge.summary', {}),
                swd: get(data, 'severeWeather.byDisaster', {}),
                swdWithoutDN: get(data, ['swdOfMerge', 'swd', 'withoutDisasterNumber', 'geoid', 'value'], {})
            }

            return _.chunk(get(this.data, 'indexValues.geoid.value', ['36']).filter(f => f !== 'None'), 100)
                .reduce((acc, curr) => falcor.get(['geo', curr, 'name']), Promise.resolve())
        }).then(names => {
            this.geoNames = get(falcor.getCache(), ['geo'], {})
        })
    }

    getColorScale(domain) {
        if (this.legend.range.length > domain.length) {
            // this.legend.domain = []
            // return () => '#ccc'
        }

        // this.legend.domain = ckmeans(domain, this.legend.range.length).map(d => Math.min(...d))

        return scaleLinear()
            .domain(this.legend.domain)
            .range(this.legend.range);
    }

    paintMap(map, data) {
        const attr = mapping[this.filters.dataset.value]

        const colorScale = this.getColorScale(data.map(d => +(d[attr])));

        let colors = {};

        data.forEach(d => {
            colors[d.geoid.toString()] = colorScale(+(d[attr]));
        });
        map.setPaintProperty('counties', 'fill-color',
            ['get', ['get', 'geoid'], ['literal', colors]]);
    }

    render(map, falcor) {

        let grouping = 'geoid.disaster_number.disaster_title'

        let tmpData = [];

        tmpData =
            this.filters.dataset.value === 'Severe Weather with DN' ? this.data.swd :
                this.filters.dataset.value === 'Severe Weather without DN' ? this.data.swdWithoutDN :
                    this.data['merge'][grouping] || [];

        this.data =
            this.filters.dataset.value === 'Severe Weather with DN' ?
                Object.keys(tmpData)
                    .filter(d => tmpData[d] && (!this.filters.disaster_number.value || this.filters.disaster_number.value === d.toString()))
                    .map(d => ({disaster_number: d, ...tmpData[d]})) :
                this.filters.dataset.value === 'Severe Weather without DN' ?
                    tmpData :
                    Object.keys(tmpData)
                        .filter(d => tmpData[d] && (!this.filters.disaster_number.value || this.filters.disaster_number.value === d.toString()))
                        .reduce((acc, c) => [...acc, ...tmpData[c].value], [])
                        .filter(d => +d[mapping[this.filters.dataset.value]])

        if(this.filters.dataset.value !== 'Severe Weather without DN'){
            let geoids = [...new Set(this.data.map(f => f.geoid))]
            let summedData = geoids.reduce((acc, curr) => {
                let tmpData =
                    this.data.filter(f => f.geoid === curr)
                        .reduce((accTmp, currTemp) => {
                            Object.keys(currTemp)
                                .forEach(k => {
                                    accTmp[k] = !['disaster_number', 'disaster_title', 'geoid'].includes(k) ? (accTmp[k] || 0) + +currTemp[k] : currTemp[k]
                                })
                            return accTmp
                        }, {})

                return [...acc, {...tmpData, geoid: curr}]
            }, [])

            this.data = summedData
        }
        // console.log('filtered data', this.data, this.filters.disaster_number.value, !this.filters.disaster_number.value)

        this.paintMap(map, this.data);
    }
}

export const MergeDataByDNFactory = (options = {}) => new mergeData(options)