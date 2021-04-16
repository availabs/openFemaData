import React from "react"
// import { useTheme } from "components/avl-components/wrappers/with-theme"
import NFIPTable  from './NFIPTable'

const Edit = ({value, onChange, ...rest}) => {
    return (
        <div className='w-full'>
            <div className='relative'>
                NFIP Table Editor
                <NFIPTable
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
        <pre className='relative w-full'>
            <NFIPTable
                viewOnly={true}
                value={ data }
            />
        </pre>
    )
}


export default {
    "name": 'NFIPTable',
    "edit": Edit,
    "view": View
}