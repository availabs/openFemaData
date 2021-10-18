import {scaleLinear} from "d3-scale"
import _ from "lodash"
import get from "lodash.get"
import {LayerContainer} from "@availabs/avl-map"
import {getColorRange, useTheme} from "@availabs/avl-components";
import {fnum} from "../../utils/fnum";
import {ckmeans} from 'simple-statistics'

const mapping = {
    'Severe Weather with DN': 'swd_loss',
    'Open Fema + SBA': 'ofd_total',
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
            value: 'Open Fema + SBA',
            domain: ['Severe Weather', 'Open Fema + SBA', 'Difference (swd - ofd + sba)'],
        },
        disaster_number: {
            name: "Disaster Number with DN",
            type: "dropdown",
            multi: false,
            value: '1603',
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
                    [get(this.geoNames, [feature.properties.geoid, 'name'], feature.properties.geoid)],
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
            ['swdOfdMerge', 'summary', 'disaster_numbers']
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
                    ['swdOfdMerge', 'summary', 'geoid.disaster_number.disaster_title', disasterNumbers]
                )
            }
        }).then(() => {
            let data = falcor.getCache()
            this.data = get(data, 'swdOfdMerge.summary', {})
            console.log('fc', this,data)
            return _.chunk(get(this.data, 'indexValues.geoid', ['36']).filter(f => f !== 'None'), 100)
                .reduce((acc, curr) => falcor.get(['geo', curr, 'name']), Promise.resolve())
        }).then(names => {
            this.geoNames = get(falcor.getCache(), ['geo'], {})
        })
    }

    getColorScale(domain) {
        if (this.legend.range.length > domain.length) return this.legend.domain = []

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
            colors[d.geoid] = colorScale(+(d[attr]));
        });
        map.setPaintProperty('counties', 'fill-color',
            ['get', ['get', 'geoid'], ['literal', colors]]);
    }

    render(map, falcor) {

        let grouping = 'geoid.disaster_number.disaster_title'

        let tmpData = []
        if (mapping[this.filters.dataset.value].includes('Difference')){
            // let swd = this.data['swd'][grouping] || [],
            //     ofd = this.data[mapping[this.filters.dataset.value].includes('SBA') ? 'ofd_sba_new' : 'ofd'][grouping] || [];
            //
            // const filterAttrs = (data, geoid) =>
            //     data.geoid === geoid &&
            //     (
            //         grouping.split('.')
            //             .filter(g => g !== 'geoid')
            //             .reduce((acc, curr) => acc && data[curr] === this.filters[curr].value.split(' - ')[0], true)
            //     )
            //
            // get(this.data, 'indexValues.geoid', [])
            //     .forEach(geoid => {
            //         let swdLoss = parseFloat(get(swd.filter(s => filterAttrs(s, geoid)), [0, 'total_damage'], 0)),
            //             ofdLoss = parseFloat(get(ofd.filter(o => filterAttrs(o, geoid)), [0, 'total_loss'], 0))
            //
            //         tmpData.push(
            //             {
            //                 geoid,
            //                 swdLoss,
            //                 ofdLoss,
            //                 total_loss: swdLoss - ofdLoss
            //             }
            //         )
            //     })
            //
            // this.data = tmpData

        }else{
            tmpData = this.data[grouping] || [];
            this.data =
                Object.keys(tmpData)
                    .filter(d => tmpData[d] && (!this.filters.disaster_number.value || this.filters.disaster_number.value === d.toString()))
                    .reduce((acc, c) => [...acc, ...tmpData[c].value], [])
                    .filter(d => +d[mapping[this.filters.dataset.value]])
            console.log('filtered data by geo', this.data.filter(d => d.geoid === '22105'))
        }


        this.paintMap(map, this.data);
    }
}

export const MergeDataByDNFactory = (options = {}) => new mergeData(options)