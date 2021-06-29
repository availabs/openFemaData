import {scaleQuantile, scaleQuantize} from "d3-scale"
import get from "lodash.get"
import {extent} from "d3-array";
import {LayerContainer} from "@availabs/avl-map"
import {getColorRange} from "@availabs/avl-components";
import {SUMMARY_ATTRIBUTES} from 'pages/Home/utils'
import {fnum} from "../../utils/fnum";


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
        range: getColorRange(5, "YlOrRd", true),
        show: true,
    }

    onHover = {
        layers: ['zipcodes'],
        callback: (layerId, features, lngLat) => {
            return features.reduce((a, feature) => [
                ...a,
                [feature.properties.geoid],
                ...Object.keys(get(this.data, [feature.properties.geoid], {}))
                    .map(f => [f, get(this.data, [feature.properties.geoid, f], '')])
            ], []);
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
        map.fitBounds([ -125.0011, 24.9493, -66.9326, 49.5904 ])
    }

    onFilterChange(filterName, newValue, prevValue) {
        this.legend.format = newValue === 'num_valid_registrations' ? d => fnum(d, false) : fnum;
    }

    receiveProps(props, map, falcor, MapActions) {
        this.disasterNumber = props.disasterNumber;
        this.fetchData(falcor).then(() => this.render(map, falcor))
    }

    fetchData(falcor) {
        if(!this.disasterNumber) return Promise.resolve();

        return falcor.get(['fema_disasters','byId', this.disasterNumber , 'byZip', 'ihp_summary']).then(d => {
            this.data = get(d, ['json', 'fema_disasters','byId', this.disasterNumber , 'byZip', 'ihp_summary'], {})
        })
    }

    getColorScale(domain) {
        switch (this.legend.type) {
            case "quantile":
                this.legend.domain = domain;
                return scaleQuantile()
                    .domain(this.legend.domain)
                    .range(this.legend.range);
            case "quantize":
                this.legend.domain = extent(domain)
                return scaleQuantize()
                    .domain(this.legend.domain)
                    .range(this.legend.range);
        }
    }

    render(map, falcor) {
        const colorScale = this.getColorScale(Object.values(this.data).map(d => d[this.filters.attribute.value]));
        let colors = {};

        Object.values(this.data).forEach(d => {
            colors[d.damaged_zip_code] = colorScale(d[this.filters.attribute.value]);
        });
        map.setPaintProperty('zipcodes', 'fill-color',
            ['get', ['get', 'geoid'], ['literal', colors]]);
    }
}

export const IHPSummaryByZipChoroplethFactory = (options = {}) => new IHPSummaryByZipChoroplethoptions(options)