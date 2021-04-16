import React from "react"
// import { useTheme } from "components/avl-components/wrappers/with-theme"
import AssetsTable  from './AssetsTable'

const Edit = ({value, onChange, ...rest}) => {
    return (
        <div className='w-full'>
            <div className='relative'>
                Assets Table Editor
                <AssetsTable
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
            <AssetsTable
                viewOnly={true}
                value={ data }
            />
        </pre>
    )
}


export default {
    "name": 'AssetsTable',
    "edit": Edit,
    "view": View
}