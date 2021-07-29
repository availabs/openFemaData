import React, {useMemo} from 'react'
import {AvlMap} from '@availabs/avl-map'
import {MAPBOX_TOKEN} from "mapboxConfig";
import {IHPSummaryByZipChoroplethFactory} from "components/layers/IHPSummaryByZipChoropleth";
import {PASummaryByGeoidChoroplethFactory} from "../../../components/layers/PASummaryByGeoidChoropleth";

export const Map = (disasterNumber, severeWeatherData, mapFocus) => {
    let options = useMemo(() => ({disasterNumber, severeWeatherData, mapFocus}), [disasterNumber, severeWeatherData, mapFocus]);

    const Layers = React.useRef([IHPSummaryByZipChoroplethFactory(), PASummaryByGeoidChoroplethFactory()]);

    return (
        <div className='flex-1 flex flex-col pt-5 shadow-lg' style={{height: '500px'}}>
            <AvlMap
                accessToken={ MAPBOX_TOKEN }
                layers={ Layers.current }
                sidebar={{
                    title: "Map",
                    tabs: ["layers", "styles"],
                    open: false
                }}
                layerProps={
                    {
                        'IHP Summary By Zipcodes': options,
                        'PA Summary By Geoids': options
                    }
                }
            />
        </div>
    )
}