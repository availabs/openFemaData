import {scaleLinear} from "d3-scale"
import get from "lodash.get"
import center from '@turf/center'
import {LayerContainer} from "@availabs/avl-map"
import {getColorRange, useTheme} from "@availabs/avl-components";
import {PA_SUMMARY_ATTRIBUTES} from 'pages/Home/config'
import {fnum} from "../../utils/fnum";
import {ckmeans} from 'simple-statistics'

class PASummaryByGeoidChoroplethoptions extends LayerContainer {
    constructor(props) {
        super(props);
    }

    // setActive = !!this.viewId
    name = 'PA Summary By Geoids'
    id = 'PA Summary By Geoids'
    data = []
    filters = {
        attribute: {
            name: "Attribute",
            type: "dropdown",
            multi: false,
            value: PA_SUMMARY_ATTRIBUTES[0],
            domain: PA_SUMMARY_ATTRIBUTES,
            accessor: d => d.replace(/_/g, ' '),
        },
    }

    legend = {
        Title: ({layer}) => get(layer.filters.attribute, 'value', '').replace(/_/g, ' '),
        type: "quantile",
        domain: [],
        format: fnum,
        range: getColorRange(7, "YlOrRd", true),
        show: true,
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
                return feature.layer.id === 'counties' ? [
                    ...a,
                    [get(this.geoNames[feature.properties.geoid], 'name', feature.properties.geoid),
                        get(this.data, [feature.properties.geoid], [])
                            .reduce((acc, f) => acc + +f[this.filters.attribute.value] , 0).toLocaleString()
                    ],
                    ...get(this.data, [feature.properties.geoid], [])
                        .reduce((acc, f) => {
                            acc.push([f.damage_categories])
                            acc.push(...PA_SUMMARY_ATTRIBUTES.map(attr => [attr, (+get(f, [attr], 0)).toLocaleString()]))
                            return acc;
                        }, [])
                ] : [
                    ...a,
                    ['Severe Weather Event'],
                    ...Object.keys(feature.properties)
                        .filter(p => !['geom', 'county'].includes(p))
                        .map(p => [p, feature.properties[p]])
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
        this.legend.format = newValue === 'num_valid_registrations' ? d => fnum(d, false) : fnum;
    }

    receiveProps(props, map, falcor, MapActions) {
        this.disasterNumber = props.disasterNumber;
        this.severeWeatherData = props.severeWeatherData;
        this.mapFocus = props.mapFocus
        this.fetchData(falcor).then(() => this.render(map, falcor))
    }

    fetchData(falcor) {
        if (!this.disasterNumber) return Promise.resolve();

        return falcor.get(
            ['fema_disasters', 'byId', this.disasterNumber, 'byGeoid', 'all', 'pa_summary']
        ).then(d => {
            this.data = get(d, ['json', 'fema_disasters', 'byId', this.disasterNumber, 'byGeoid', 'all', 'pa_summary'], {})
        }).then(() => falcor.get(['geo', Object.keys(this.data) , 'name']).then(names => this.geoNames = get(names, ['json', 'geo'], {})))
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
        const colorScale = this.getColorScale(Object.values(this.data).reduce((acc,d) => {
            acc.push(d.reduce((total, row) => total + +row[this.filters.attribute.value], 0));
            return acc;
        }, []));
        let colors = {};

        Object.values(this.data).forEach(d => {
            colors[d[0].geoid] = colorScale(d.reduce((total, row) => total + +row[this.filters.attribute.value], 0));
        });
        map.setPaintProperty('counties', 'fill-color',
            ['get', ['get', 'geoid'], ['literal', colors]]);
    }

    paintEventsPoints(map) {
        let data = {
            "type": "FeatureCollection",
            "features": []
        };

        if (map.getSource('events')) {
            map.removeLayer('events')
            map.removeSource('events')
        }
        map.addSource('events', {type: 'geojson', data: data});
        map.addLayer({
            'id': 'events',
            'type': 'circle',
            'source': 'events',
            'paint': {
                'circle-color': 'blue',
                'circle-stroke-color': 'white',
                'circle-stroke-width': 1,
            }
        });


        if (this.severeWeatherData) {
            this.severeWeatherData
                .forEach(event => {
                    data.features.push(
                        {
                            type: 'Feature',
                            properties: event,
                            geometry: center(JSON.parse(event.geom)).geometry
                        })
                })
            map.getSource('events').setData(data)
        }
    }

    render(map, falcor) {

        this.handleMapFocus(map);
        this.paintMap(map);
        this.paintEventsPoints(map);
    }
}

export const PASummaryByGeoidChoroplethFactory = (options = {}) => new PASummaryByGeoidChoroplethoptions(options)