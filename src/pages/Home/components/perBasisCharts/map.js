import React from 'react'
import {AvlMap} from '@availabs/avl-map'
import {MAPBOX_TOKEN} from "mapboxConfig";
import {HLRChoroplethFactory} from "components/layers/HLRChoropleth";
import {PASummaryByGeoidChoroplethFactory} from "../../../../components/layers/PASummaryByGeoidChoropleth";

export const RenderMap = (data) => {
    const Layers = React.useRef([
        HLRChoroplethFactory()
    ]);

    return (
        <div className='flex-1 flex flex-col pt-5 shadow-lg' style={{height: '800px'}}>
            <AvlMap
                accessToken={ MAPBOX_TOKEN }
                layers={ Layers.current }
                sidebar={{
                    title: "Map",
                    tabs: ["layers", "styles"],
                    open: false
                }}
            />
        </div>
    )
}