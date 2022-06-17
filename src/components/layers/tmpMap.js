import {scaleLinear} from "d3-scale"
import _ from "lodash"
import get from "lodash.get"
import {LayerContainer} from "@availabs/avl-map"
import {getColorRange, useTheme} from "@availabs/avl-components";
import {fnum} from "../../utils/fnum";
import {ckmeans} from 'simple-statistics'

class fusionData extends LayerContainer {

    // setActive = !!this.viewId
    name = 'Fusion Data'
    id = 'Fusion Data'
    data = ['56037', '56013']
    filters = {
        region: {
            name: 'region',
            domain: [],
            value: ''
        }
    }

    legend = {
        Title: ({layer}) => get(layer.filters.attribute, 'value', '').replace(/_/g, ' '),
        type: "quantile",
        domain: [],
        format: fnum,
        range: getColorRange(7, "YlOrRd", true),
        show: true,
    }

    onClick = {
        layers: ['counties'],
        callback: (layerId, features) => {

            if(this.filters.region.domain.includes(features[0].properties.geoid)){
                this.filters.region.domain = this.filters.region.domain.filter(d => d !== features[0].properties.geoid)
                this.onFilterChange('region', [this.filters.region.domain[0]])
            }else{
                this.filters.region.domain.push(features[0].properties.geoid)
                this.onFilterChange('region',[features[0].properties.geoid])
            }
        }

    }

    onFilterChange(filterName,value,preValue){
        console.log('changed?', this.filters[filterName])
        this.filters[filterName].value = value
        this.dispatchUpdate(this, {region: value})
    }

    onHover = {
        pinnable: undefined,
        layers: [''],
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
                return [
                    ...a,
                    [features.layer, feature.properties.geoid]
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

        {
            id: "states",
            source: {
                'type': "vector",
                'url': 'mapbox://am3081.1fysv9an'
            },
        },
    ]

    layers = [
        {
            'id': 'counties',
            'source': 'counties',
            'source-layer': 'counties',
            'type': 'fill',
            paint: {
                "fill-color": 'green',
                "fill-opacity": 1
            }
        },

        {
            'id': 'states',
            'source': 'states',
            'source-layer': 'us_states',
            'type': 'line',
            paint: {
                "line-color": 'blue',
                "line-width": 2
            }
        },

        {
            'id': 'counties-line',
            'source': 'counties',
            'source-layer': 'counties',
            'type': 'line',
            paint: {
                "line-color": '#e84242',
                "line-width": [
                    "case",
                    ["boolean", ["feature-state", "hover"], false],
                    2,
                    1
                ]
            },
        }
    ]


    init(map, falcor) {
        map.fitBounds([-125.0011, 24.9493, -66.9326, 49.5904])
    }

    fetchData(falcor) {
        return Promise.resolve()
    }


    render(map, falcor) {
        console.log('d?', this.filters.region.domain)
        map.setPaintProperty("counties", "fill-color",
            [
                'case',
                ['in', ["get", "geoid"], ['literal', this.filters.region.domain]], '#ea0e0e',
                'green'
            ])
    }
}

export const FusionDataFactory = (options = {}) => new fusionData(options)