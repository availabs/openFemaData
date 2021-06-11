import React from "react"

// import { useDms } from "../contexts/dms-context"
// import { useAuth } from "../contexts/auth-context"
// import { useTheme } from "@availabs/avl-components"

// import { useSetSections } from "../wrappers/dms-create"

import dmsInputWrapper from "components/dms/wrappers/dms-input"

const DmsInput = dmsInputWrapper(({ Sections, hasFocus, id, autoFocus = false, onFocus, onBlur, value, ref, ...props }) => {

  return (
    <div id={ id } className={ `w-full p-2`}>
      { Sections.map(section =>
          <div key={ section.index }>
            { !section.title ? null :
              <div className="text-2xl font-bold">{ section.title }<span className='text-sm text-blue-500'>{section}</span></div>
            }
            { section.attributes.map(({ Input, key, ...att }, i) =>
                <div key={ key }>
                  <label htmlFor={ att.id }>{ att.name }</label>
                  <Input { ...props } onChange={ att.onChange } value={ value[key] }
                    ref={ (section.index === 0) && (i === 0) ? ref : null }
                    autoFocus={ autoFocus && (section.index === 0) && (i === 0) }
                    onFocus={ onFocus } onBlur={ onBlur }/>
                </div>
              )
            }
          </div>
        )
      }
    </div>
  )
})
export default DmsInput;
