import {scaleLinear} from "d3-scale"
import get from "lodash.get"
import center from '@turf/center'
import {LayerContainer} from "@availabs/avl-map"
import {getColorRange, useTheme} from "@availabs/avl-components";
import {fnum} from "../../utils/fnum";
import {ckmeans} from 'simple-statistics'
import _ from 'lodash'
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
            value: 'riverine',
            domain: [
                "avalanche", "coastal", "coldwave", "drought", "earthquake", "hail", "heatwave", "hurricane", "icestorm", "landslide", "lightning", "riverine", "tornado", "tsunami", "volcano", "wildfire", "wind", "winterweat"
            ],
        },

        consq: {
            name: "Consequence Type",
            type: "dropdown",
            multi: false,
            value: 'hlr_b',
            domain: [{key: 'hlr_b', label: 'Buildings'}, {key: 'hlr_c', label: 'Crop'}, {key: 'hlr_p', label: 'Population'}, {key: 'hlr_f', label: 'Fema Buildings'},
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
                let d = this.data[this.dataSRC].filter(d => d.geoid === feature.properties.geoid && d.nri_category === this.filters.hazard.value)
                return [
                    ...a,
                    ['County', get(this.geoNames[feature.properties.geoid], 'name', feature.properties.geoid)],

                       [ this.filters.consq.domain.reduce((acc, d) => d.key === this.filters.consq.value ? d.label : acc, ''),
                           get(d, [0, this.filters.consq.value], 'N/a')]
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

    onFilterChange(filterName, newValue, prevValue) {

        this.dataSRC =
            filterName === 'consq' ?
                get(this.filters[filterName].domain.filter(d => d.key === newValue), [0, 'label'], '').includes('NRI') ? 'nri' : 'per_basis' :
                this.dataSRC

    }

    receiveProps(props, map, falcor, MapActions) {
        this.fetchData(falcor).then(() => this.render(map, falcor))
    }

    fetchData(falcor) {
        return falcor.get(
            ['per_basis', 'hlr'],
            ['nri', 'hlr']
        ).then(d => {
            this.data = {
                per_basis: get(d, ['json', 'per_basis', 'hlr'], []),
                nri: get(d, ['json', 'nri', 'hlr'], [])
            }
        }).then(() => {
            return falcor.get(['geo', _.uniq(this.data[this.dataSRC].map(d => d.geoid)), 'name']).then(names => {
                this.geoNames = get(names, ['json', 'geo'], {})
            })
        })
    }

    getColorScale(domain) {
        if (this.legend.range.length > domain.length) return this.legend.domain = []
        this.legend.domain = ckmeans(domain, this.legend.range.length).map(d => Math.min(...d))

        return scaleLinear()
            .domain(this.legend.domain)
            .range(this.legend.range);
    }

    paintMap(map) {
        const colorScale = this.getColorScale(
            this.data[this.dataSRC]
                .filter(d => d.nri_category === this.filters.hazard.value)
                .map(d => d[this.filters.consq.value]).filter(d => d));
        let colors = {};

        this.data[this.dataSRC]
            .filter(d => d.nri_category === this.filters.hazard.value && d[this.filters.consq.value])
            .forEach(d => {
            colors[d.geoid] = colorScale(d[this.filters.consq.value]);
        });

        map.setPaintProperty('counties', 'fill-color',
            ['get', ['get', 'geoid'], ['literal', colors]]);
    }

    render(map, falcor) {

        this.paintMap(map);
    }
}

export const HLRChoroplethFactory = (options = {}) => new HLRChoroplethoptions(options)