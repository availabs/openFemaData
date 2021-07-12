import {scaleLinear} from "d3-scale"
import get from "lodash.get"
import center from '@turf/center'
import {LayerContainer} from "@availabs/avl-map"
import {getColorRange, useTheme} from "@availabs/avl-components";
import {SUMMARY_ATTRIBUTES} from 'pages/Home/utils'
import {fnum} from "../../utils/fnum";
import {ckmeans} from 'simple-statistics'

class IHPSummaryByZipChoroplethoptions extends LayerContainer {
    constructor(props) {
        super(props);
    }

    // setActive = !!this.viewId
    name = 'IHP Summary By Zipcodes'
    id = 'IHP Summary By Zipcodes'
    data = []
    filters = {
        attribute: {
            name: "Attribute",
            type: "dropdown",
            multi: false,
            value: 'ihp_amount',
            domain: SUMMARY_ATTRIBUTES,
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
        layers: ['zipcodes', 'events'],
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
                return feature.layer.id === 'zipcodes' ? [
                    ...a,
                    [feature.properties.geoid],
                    ...Object.keys(get(this.data, [feature.properties.geoid], {}))
                        .map(f => [f, get(this.data, [feature.properties.geoid, f], '')])
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
            id: "zipcodes",
            source: {
                'type': "vector",
                'url': 'mapbox://am3081.5g46sdxi'
            },
        },
    ]

    layers = [
        {
            'id': 'zipcodes',
            'source': 'zipcodes',
            'source-layer': 'zipcodes',
            'type': 'fill',
        },
        {
            'id': 'zipcodes-line',
            'source': 'zipcodes',
            'source-layer': 'zipcodes',
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

        return falcor.get(['fema_disasters', 'byId', this.disasterNumber, 'byZip', 'ihp_summary']).then(d => {
            this.data = get(d, ['json', 'fema_disasters', 'byId', this.disasterNumber, 'byZip', 'ihp_summary'], {})
        })
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
        const colorScale = this.getColorScale(Object.values(this.data).map(d => d[this.filters.attribute.value]));
        let colors = {};

        Object.values(this.data).forEach(d => {
            colors[d.damaged_zip_code] = colorScale(d[this.filters.attribute.value]);
        });

        map.setPaintProperty('zipcodes', 'fill-color',
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

export const IHPSummaryByZipChoroplethFactory = (options = {}) => new IHPSummaryByZipChoroplethoptions(options)