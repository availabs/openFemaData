import React, {useMemo} from 'react'
import {AvlMap} from '@availabs/avl-map'
import {MAPBOX_TOKEN} from "mapboxConfig";
import {IHPSummaryByZipChoroplethFactory} from "components/layers/IHPSummaryByZipChoropleth";

export const Map = (disasterNumber) => {
    let options = useMemo(() => ({disasterNumber}), [disasterNumber]);

    const Layers = React.useRef([IHPSummaryByZipChoroplethFactory()]);

    return (
        <div className='flex-1 flex flex-col pt-5' style={{height: '500px'}}>
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
                        'IHP Summary By Zipcodes': options
                    }
                }
            />
        </div>
    )
}