import {scaleLinear} from "d3-scale"
import _ from "lodash"
import get from "lodash.get"
import {LayerContainer} from "@availabs/avl-map"
import {getColorRange, useTheme} from "@availabs/avl-components";
import {fnum} from "../../utils/fnum";
import {ckmeans} from 'simple-statistics'

const mapping = {
    'Severe Weather': 'swd',
    'Open Fema': 'ofd',
    'Difference (swd - ofd)': 'Difference'
}
class mergeData extends LayerContainer {

    // setActive = !!this.viewId
    name = 'Merge Data'
    id = 'Merge Data'
    data = []
    filters = {
        dataset: {
            name: "Dataset",
            type: "dropdown",
            multi: false,
            value: ['Difference (swd - ofd)'],
            domain: ['Severe Weather', 'Open Fema', 'Difference (swd - ofd)'],
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
    }

    receiveProps(props, map, falcor, MapActions) {
        this.fetchData(falcor).then(() => this.render(map, falcor))
    }

    fetchData(falcor) {
        return falcor.get(
            ['swdOfdMerge', 'indexValues', ['geoid', 'hazard', 'year']],
            ['swdOfdMerge', 'swd', 'geoid'],
            ['swdOfdMerge', 'swd', 'geoid.hazard'],
            ['swdOfdMerge', 'swd', 'geoid.year'],
            ['swdOfdMerge', 'swd', 'geoid.hazard.year'],
            ['swdOfdMerge', 'ofd', 'geoid'],
            ['swdOfdMerge', 'ofd', 'geoid.hazard'],
            ['swdOfdMerge', 'ofd', 'geoid.year'],
            ['swdOfdMerge', 'ofd', 'geoid.hazard.year'],
        ).then(d => {
            this.data = get(d, 'json.swdOfdMerge', {})
            this.filters.year.domain = ['All Time', ...get(d, 'json.swdOfdMerge.indexValues.year', [])]
            this.filters.hazard.domain = ['All Hazards', ...get(d, 'json.swdOfdMerge.indexValues.hazard', [])]
        }).then(() => {
            return _.chunk(get(this.data, 'indexValues.geoid', ['36']).filter(f => f !== 'None'), 100)
                .reduce((acc, curr) => falcor.get(['geo', curr, 'name']), Promise.resolve())
        }).then(names => {
            this.geoNames = get(falcor.getCache(), ['geo'], {})
        })
    }

    getColorScale(domain) {
        if (this.legend.range.length > domain.length) return this.legend.domain = []

        this.legend.domain = ckmeans(domain, this.legend.range.length).map(d => Math.min(...d))

        return scaleLinear()
            .domain(this.legend.domain)
            .range(this.legend.range);
    }

    paintMap(map, data) {
        const colorScale = this.getColorScale(data.map(d => +(d.total_damage || d.total_loss)));
        let colors = {};

        data.forEach(d => {
            colors[d.geoid] = colorScale(+(d.total_damage || d.total_loss));
        });
        map.setPaintProperty('counties', 'fill-color',
            ['get', ['get', 'geoid'], ['literal', colors]]);
    }

    render(map, falcor) {
        
        let grouping =
            this.filters.hazard.value === 'All Hazards' && this.filters.year.value === 'All Time' ? 'geoid' :
            this.filters.hazard.value === 'All Hazards' && this.filters.year.value !== 'All Time' ? 'geoid.year' :
            this.filters.hazard.value !== 'All Hazards' && this.filters.year.value === 'All Time' ? 'geoid.hazard' :
            this.filters.hazard.value !== 'All Hazards' && this.filters.year.value !== 'All Time' ? 'geoid.hazard.year' : 'geoid'

        let tmpData = []
        if (mapping[this.filters.dataset.value] === 'Difference'){
            let swd = this.data['swd'][grouping],
                ofd = this.data['ofd'][grouping];

            const filterAttrs = (data, geoid) =>
                data.geoid === geoid &&
                (
                    grouping.split('.')
                        .filter(g => g !== 'geoid')
                        .reduce((acc, curr) => acc && data[curr] === this.filters[curr].value, true)
                )

            get(this.data, 'indexValues.geoid', [])
                .forEach(geoid => {
                    let swdLoss = parseFloat(get(swd.filter(s => filterAttrs(s, geoid)), [0, 'total_damage'], 0)),
                        ofdLoss = parseFloat(get(ofd.filter(o => filterAttrs(o, geoid)), [0, 'total_loss'], 0))

                    tmpData.push(
                        {
                            geoid,
                            swdLoss,
                            ofdLoss,
                            total_loss: swdLoss - ofdLoss
                        }
                    )
                })

            this.data = tmpData

        }else{
            tmpData = this.data[mapping[this.filters.dataset.value]][grouping];

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

export const MergeDataFactory = (options = {}) => new mergeData(options)