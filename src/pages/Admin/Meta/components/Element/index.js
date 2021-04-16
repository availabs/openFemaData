import React from "react"

import { useDms } from "components/dms/contexts/dms-context"
import { useAuth } from "components/dms/contexts/auth-context"

import { useSetSections } from "components/dms/wrappers/dms-create"

// import { createEmpty } from "components/dms/components/editor"

import { useDmsSections } from "components/dms/components/utils/dms-input-utils"
import {Select} from "@availabs/avl-components"

import ColorBox from './color-box'
import TextArea from './textArea'
import DraftEditor from './draft-editor'
import NFIPTable from "./NFIPTable";
import AssetsTable from "./AssetsTable";

import get from 'lodash.get'


// register components here
const ComponentRegistry = {
    "ColorBox": ColorBox,
    "TextArea": TextArea,
    "DraftEditor": DraftEditor,
    "NFIPTable": NFIPTable,
    "AssetsTable": AssetsTable
}



const Edit = React.forwardRef(({ Attribute, id, autoFocus = false, onFocus, onBlur, onChange, value, save, buttonDisabled, ...props }, ref) => {
    value = value || {};
  

    const Props = { ...props, ...useDms(), user: useAuth().user };
    const sections = useSetSections(Attribute.Format),
        Sections = useDmsSections(sections, value, onChange, Props);

    let ElementType = get(Sections, '[0].attributes',[]).filter(a => a.key === 'element-type').pop()
    let ElementData = get(Sections, '[0].attributes',[]).filter(a => a.key === 'element-data').pop()
    
    if(ElementType) {
        console.log(
            'trying element edit',
            ComponentRegistry,
            get(value, `[${ElementType.key}]`, ''),
            get(value, `[${ElementData.key}]`, '')
        )
    }

    return (
        <div className='w-full'>
            <div className='relative'>
                <div className='font-normal text-lg leading-8 text-gray-600'>
                    {ElementType ? 
                    <ElementType.Input
                        ref={ ref }
                        autoFocus={true}
                        value={ get(value, `[${ElementType.key}]`, '') }
                        placeholder={'Element Type'}
                        onChange={ElementType.onChange}
                        EditComp={Select}
                        domain={Object.keys(ComponentRegistry).map(k => ComponentRegistry[k].name)}
                        multi={false}
                    /> :''}
                </div>
                <div className='font-normal text-lg leading-8 text-gray-600'>
                    {ElementType && ComponentRegistry[get(value, `[${ElementType.key}]`, null)] ? 
                    <ElementData.Input
                        ref={ ref }
                        autoFocus={true}
                        value={ get(value, `[${ElementData.key}]`, '') }
                        placeholder={'Element Data'}
                        onChange={ElementData.onChange}
                        EditComp={ComponentRegistry[get(value, `[${ElementType.key}]`, null)].edit}
                    /> : ''}
                </div>

            </div>
        </div>
    )
})



Edit.settings = {
    hasControls: true,
    name: 'ElementEdit'
}



const View = ({value}) => {
    if (!value) return false

    // console.log('got into view', get(value, `element-type`, null))
    let Comp = ComponentRegistry[get(value, `element-type`, null)] ?  
        ComponentRegistry[get(value, `element-type`, null)].view : 
        () => <div> Component {value['element-type']} Not Registered </div>

    return (
        <div className='relative w-full'>
           <Comp value={value} />
        </div>
    )
}

export default {
    Edit,
    View
}