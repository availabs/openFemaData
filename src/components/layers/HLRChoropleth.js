import {scaleLinear} from "d3-scale"
import _ from 'lodash'
import get from "lodash.get"
import center from '@turf/center'
import {LayerContainer} from "@availabs/avl-map"
import {getColorRange, useTheme} from "@availabs/avl-components";
import {PA_SUMMARY_ATTRIBUTES, PACategoriesMappings} from 'pages/Home/config'
import {fnum} from "../../utils/fnum";
import {ckmeans} from 'simple-statistics'

class HLRChoroplethoptions extends LayerContainer {
    constructor(props) {
        super(props);
    }

    // setActive = !!this.viewId
    name = 'HLR'
    id = 'HLR'
    data = []
    dataSRC = 'per_basis'
    filters = {
        hazard: {
            name: "Hazard",
            type: "dropdown",
            multi: false,
            value: 'hurricane',
            domain: [
                "avalanche", "coastal", "coldwave", "drought", "earthquake", "hail", "heatwave", "hurricane", "icestorm", "landslide", "lightning", "riverine", "tornado", "tsunami", "volcano", "wildfire", "wind", "winterweat"
            ],
        },

        consq: {
            name: "Consequence Type",
            type: "dropdown",
            multi: false,
            value: 'hlr_f',
            domain: [
                {key: 'hlr_b', label: 'SWD Buildings'}, {key: 'hlr_c', label: 'SWD Crop'}, //{key: 'hlr_p', label: 'SWD Population'},
                {key: 'hlr_f', label: 'Fema Buildings'}, {key: 'hlr_fc', label: 'Fema Crop'},
                {key: 'hlrb', label: 'NRI Buildings'}, {key: 'hlra', label: 'NRI Crop'}, {key: 'hlrp', label: 'NRI Population'},],
            valueAccessor: d => d.key,
            accessor: d => d.label
        },
    }

    legend = {
        Title: ({layer}) => get(layer.filters.attribute, 'value', '').replace(/_/g, ' '),
        type: "quantile",
        domain: [],
        range: getColorRange(7, "YlOrRd", true),
        show: false,
    }

    onHover = {
        layers: ['counties', 'events'],
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
                                             // style={{maxWidth: '200px'}}
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
                let record = this.data[this.dataSRC].find(d => d.nri_category === this.filters.hazard.value && d.geoid === feature.properties.geoid),
                    response = [
                        [this.filters.consq.domain.find(d => d.key === this.filters.consq.value).label, get(record, this.filters.consq.value)],
                    ];

                if(this.dataSRC === 'per_basis'){
                    // get nri data to compare
                    const label = this.filters.consq.domain.find(d => d.key === this.filters.consq.value).label.replace('Fema', 'NRI').replace('SWD', 'NRI');
                    const value = this.data.nri.find(d => d.nri_category === this.filters.hazard.value && d.geoid === feature.properties.geoid)[this.filters.consq.domain.find(d => d.label === label).key]
                    response.push(
                        [label,
                            <div className={`text-${value -  get(record, this.filters.consq.value) > 0 ? `green` : `red` }-900`}>
                            {value} ({(((value -  get(record, this.filters.consq.value)) /  get(record, this.filters.consq.value)) * 100).toFixed(2)})%
                            </div>
                        ])
                }
                return response
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

    onFilterChange(filterName, newValue, prevValue) {
        switch(filterName){
            case 'consq': {
                this.dataSRC = newValue.includes('_') ? 'per_basis' : 'nri'
            }
        }

    }

    receiveProps(props, map, falcor, MapActions) {
        this.disasterNumber = props.disasterNumber;
        this.severeWeatherData = props.severeWeatherData;
        this.mapFocus = props.mapFocus
        this.fetchData(falcor).then(() => this.render(map, falcor))
    }

    fetchData(falcor) {
        return falcor.get(
            ['nri', 'hlr'],
            ['per_basis', 'hlr'],
        ).then(d => {
            this.data = {
                nri: get(d, ['json', 'nri', 'hlr'], []),
                per_basis: get(d, ['json', 'per_basis', 'hlr'], [])
            }
            console.log('d?', this.data)
            // return _.uniq([
            //     ...get(this.data, ['nri'], []).map(d => d.geoid),
            //     ...get(this.data, ['per_basis'], []).map(d => d.fips),
            // ])
        })//.then((r) => r.length && falcor.get(['geo', r , 'name']).then(names => this.geoNames = get(names, ['json', 'geo'], {})))
    }

    getColorScale(domain) {
        if (this.legend.range.length > domain.length) return this.legend.domain = []
        this.legend.domain = ckmeans(domain, this.legend.range.length).map(d => Math.min(...d))

        return scaleLinear()
            .domain(this.legend.domain)
            .range(this.legend.range);
    }

    handleMapFocus(map) {
        if (this.mapFocus) {
            try {
                map.flyTo(
                    {
                        center: get(center(JSON.parse(this.mapFocus)), ['geometry', 'coordinates']),
                        zoom: 9
                    })
            } catch (e) {
                map.fitBounds([-125.0011, 24.9493, -66.9326, 49.5904])
            }
        } else {
            map.fitBounds([-125.0011, 24.9493, -66.9326, 49.5904])
        }
    }

    paintMap(map) {
        const colorScale = this.getColorScale(
            this.data[this.dataSRC].filter(d => d.nri_category === this.filters.hazard.value).map((d) => d[this.filters.consq.value]).filter(d => d)
        )
        let colors = {};

        Object.values(this.data[this.dataSRC])
            .filter(d => d.nri_category === this.filters.hazard.value)
            .forEach(d => {
            colors[d.geoid] = colorScale(d[this.filters.consq.value])
        });

        map.setPaintProperty('counties', 'fill-color',
            ['get', ['get', 'geoid'], ['literal', colors]]);
    }

    render(map, falcor) {
        console.log(this.legend)
        this.handleMapFocus(map);
        this.paintMap(map);
    }
}

export const HLRChoroplethFactory = (options = {}) => new HLRChoroplethoptions(options)