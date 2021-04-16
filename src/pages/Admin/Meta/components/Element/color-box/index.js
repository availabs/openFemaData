import React from "react"
import { Select } from '@availabs/avl-components'

function isJson(str) {
    try {
        JSON.parse(str);
    } catch (e) {
        return false;
    }
    return true;
}

const Edit = ({value, onChange}) => {
    //console.log('props', props)
    let data = value && isJson(value) ? JSON.parse(value) : {}
    const ColorSelect = (v) => {
        let newValue = Object.assign({}, data, {'color': v})
        onChange(JSON.stringify(newValue))
    }
    return (
        <div className='w-full'>
            <div className='relative'>
                ColorBox Editor
                <Select
                    domain={['red', 'blue']}
                    value={data.color}
                    multi={false}
                    onChange={ColorSelect}
                />
                <div className='relative w-full border border-dashed p-1'>
                    <div style={{height: '150px', backgroundColor: data.color}}></div>
                </div>
            </div>
        </div>
    )
}

Edit.settings = {
    hasControls: true,
    name: 'ElementEdit'
}

const View = ({value}) => {
    if(!value) return false
    let data = JSON.parse(value['element-data'])
    return (
        <div className='relative w-full border border-dashed p-1'>
            <div style={{height: '150px', backgroundColor: data.color}}></div>
        </div>
    )           
}


export default {
    "name": 'ColorBox',
    "edit": Edit,
    "view": View
}