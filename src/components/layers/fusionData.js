import {scaleLinear} from "d3-scale"
import _ from "lodash"
import get from "lodash.get"
import {LayerContainer} from "@availabs/avl-map"
import {getColorRange, useTheme} from "@availabs/avl-components";
import {fnum} from "../../utils/fnum";
import {ckmeans} from 'simple-statistics'

const mapping = {
    'Fusion': 'fusion',
    'NRI': 'nri'
}
class fusionData extends LayerContainer {

    // setActive = !!this.viewId
    name = 'Fusion Data'
    id = 'Fusion Data'
    data = []
    filters = {
        dataset: {
            name: "Dataset",
            type: "dropdown",
            multi: false,
            value: 'fusion',
            domain: ['fusion', 'nri'],
        },
        year: {
            name: "Year",
            type: "dropdown",
            multi: false,
            value: 'All Time',
            domain: [],
        },
        hazard: {
            name: "Hazard",
            type: "dropdown",
            multi: false,
            value: 'All Hazards',
            domain: [],
        },
        disaster_number: {
            name: "Disaster Number",
            type: "dropdown",
            multi: false,
            value: 'All',
            domain: [],
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

    onFilterChange(filterName, newValue, prevValue) {
        // this.legend.format = newValue === 'num_valid_registrations' ? d => fnum(d, false) : fnum;
        if(filterName === 'dataset' && newValue === 'nri'){
            this.filters.year.disabled = true;
            this.filters.disaster_number.disabled = true;
        }
        else if(filterName === 'dataset' && newValue === 'fusion'){
            this.filters.year.disabled = false;
            this.filters.disaster_number.disabled = false;
        }
    }

    receiveProps(props, map, falcor, MapActions) {
        this.fetchData(falcor).then(() => this.render(map, falcor))
    }

    fetchData(falcor) {
        return falcor.get(
            ['swdOfdMerge', 'fusion', 'geoid'],
            ['swdOfdMerge', 'fusion', 'geoid.hazard'],
            ['swdOfdMerge', 'fusion', 'geoid.year'],
            ['swdOfdMerge', 'fusion', 'geoid.hazard.year'],

            ['swdOfdMerge', 'fusion', 'geoid.disaster_number'],
            ['swdOfdMerge', 'fusion', 'geoid.hazard.disaster_number'],
            ['swdOfdMerge', 'fusion', 'geoid.year.disaster_number'],
            ['swdOfdMerge', 'fusion', 'geoid.hazard.year.disaster_number'],

            ['nri', 'totals', 'geoid'],

            ['swdOfdMerge', 'fusion', 'indexValues', ['hazard', 'year', 'geoid', 'disaster_number']],
        ).then(d => {
            this.data = this.filters.dataset.value === 'fusion' ? get(d, 'json.swdOfdMerge.fusion', {}) : get(d, 'json.nri.totals.geoid', [])
            this.filters.year.domain = ['All Time', ...get(d, 'json.swdOfdMerge.fusion.indexValues.year', [])]
            this.filters.hazard.domain = ['All Hazards', ...get(d, 'json.swdOfdMerge.fusion.indexValues.hazard', [])]
            this.filters.disaster_number.domain = ['All', ...get(d, 'json.swdOfdMerge.fusion.indexValues.disaster_number', [])]
        }).then(() => {
            return _.chunk(get(this.data, 'indexValues.geoid', ['36']).filter(f => f !== 'None'), 100)
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
        if (!domain.length) {
            return () => '#000'
        }

        this.legend.domain = ckmeans(domain, this.legend.range.length).map(d => Math.min(...d))

        return scaleLinear()
            .domain(this.legend.domain)
            .range(this.legend.range);
    }

    paintMap(map, data) {
        const attrSelector = (selectedHazard = this.filters.hazard.value) => {
            return this.filters.dataset.value === 'fusion' ? 'total_loss' :
                selectedHazard === 'All Hazards' ? 'total' : selectedHazard
        }
        const colorScale = this.getColorScale(data.map(d => +(d[attrSelector()])));
        let colors = {};

        data.forEach(d => {
            colors[d.geoid] = colorScale(+(d[attrSelector()]));
        });
        map.setPaintProperty('counties', 'fill-color',
            ['get', ['get', 'geoid'], ['literal', colors]]);
    }

    render(map, falcor) {

        if(this.filters.dataset.value === 'fusion'){
            let grouping =
                this.filters.hazard.value === 'All Hazards' && this.filters.year.value === 'All Time' ? 'geoid' :
                    this.filters.hazard.value === 'All Hazards' && this.filters.year.value !== 'All Time' ? 'geoid.year' :
                        this.filters.hazard.value !== 'All Hazards' && this.filters.year.value === 'All Time' ? 'geoid.hazard' :
                            this.filters.hazard.value !== 'All Hazards' && this.filters.year.value !== 'All Time' ? 'geoid.hazard.year' : 'geoid'

            if (this.filters.disaster_number.value !== 'All') grouping = grouping + '.disaster_number'

            let tmpData = this.data[grouping] || [];

            this.data =
                grouping.split('.')
                    .filter(g => g !== 'geoid')
                    .reduce((acc, curr) =>
                            acc.filter(a => a[curr] === this.filters[curr].value)
                        , tmpData)

        }

        this.paintMap(map, this.data);
    }
}

export const FusionDataFactory = (options = {}) => new fusionData(options)