import React from "react"
// import { useTheme } from "components/avl-components/wrappers/with-theme"
import {TextArea} from "@availabs/avl-components"

const Edit = ({value, onChange}) => {
    return (
        <div className='w-full'>
            <div className='relative'>
                TextArea Editor
                <TextArea
                    value={value}
                    onChange={onChange}
                />
            </div>
        </div>
    )
}

Edit.settings = {
    hasControls: true,
    name: 'ElementEdit'
}

const View = ({value}) => {
    if (!value) return false
    let data = value['element-data']
    return (
        <pre className='relative w-full border border-dashed p-1'>
            {data}
        </pre>
    )
}


export default {
    "name": 'TextArea',
    "edit": Edit,
    "view": View
}