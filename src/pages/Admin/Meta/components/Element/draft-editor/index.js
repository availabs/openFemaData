import React from "react"
import get from 'lodash.get'
// import { useTheme } from "components/avl-components/wrappers/with-theme"
import Editor, {createEmpty} from "components/dms/components/editor"
import ReadOnlyEditor from "components/dms/components/editor/editor.read-only"

import {convertFromRaw, convertToRaw, EditorState} from 'draft-js';

function isJson(str) {
    try {
        JSON.parse(str);
    } catch (e) {
        return false;
    }
    return true;
}


const Edit = ({value, onChange}) => {
    let data = value ? isJson(value) ? JSON.parse(value) : value : createEmpty()
    if (value) {
        data = convertFromRaw(data);
        data = EditorState.createWithContent(data)
    }
    return (
        <div className='w-full'>
            <div className='relative'>
                Draft Editor
                <Editor
                    value={!value ? createEmpty() : data}
                    onChange={(e) => {
                        onChange(JSON.stringify(convertToRaw(e.getCurrentContent())))
                    }}
                    imgUploadUrl ={'https://graph.availabs.org/img/new'}s
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
    let data = value['element-data']  // convertToRaw(value['element-data'])
    if(data){
        data = EditorState.createWithContent(convertFromRaw(JSON.parse(data)))
    }
    return (
        <div className='relative w-full border border-dashed p-1'>
            <ReadOnlyEditor value={data} isRaw={!!get(data, ['blocks'])}/>
        </div>
    )
}


export default {
    "name": 'DraftEditor',
    "edit": Edit,
    "view": View
}