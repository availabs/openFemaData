import React from "react"
// import ElementComp from './Element'
import Element from './Element'
// import ReadOnlyEditor from "components/dms/components/editor/editor.read-only"
// import { useTheme } from '@availabs/avl-components'


const ValueItem = ({ isPlaceholder, remove, edit, moveUp, moveDown, disabled = false }) => {
  // const theme = useTheme();
  return (
    <div >
      { isPlaceholder || disabled || !moveUp ? null :
        <div className={ `
            text-blue-400 hover:text-blue-700
            pt-2 pr-1 inline-block cursor-pointer
          ` }
          onClick={ moveUp }>
          <svg width="22" height="22" fill="currentColor" viewBox="0 0 20 20" stroke="currentColor">
            <path fill-rule="evenodd" clip-rule="evenodd" d="M14.7071 12.7071C14.3166 13.0976 13.6834 13.0976 13.2929 12.7071L10 9.41421L6.70711 12.7071C6.31658 13.0976 5.68342 13.0976 5.29289 12.7071C4.90237 12.3166 4.90237 11.6834 5.29289 11.2929L9.29289 7.29289C9.68342 6.90237 10.3166 6.90237 10.7071 7.29289L14.7071 11.2929C15.0976 11.6834 15.0976 12.3166 14.7071 12.7071Z"/>
          </svg>
        </div>
      }
      { isPlaceholder || disabled || !moveDown ? null :
        <div className={ `
            text-blue-400 hover:text-blue-700
            pt-2 pr-1 inline-block cursor-pointer
          ` }
          onClick={ moveDown }>
          <svg width="22" height="22" viewBox="0 0 20 20" fill="currentColor" stroke="currentColor">
            <path fill-rule="evenodd" clip-rule="evenodd" d="M5.29289 7.29289C5.68342 6.90237 6.31658 6.90237 6.70711 7.29289L10 10.5858L13.2929 7.29289C13.6834 6.90237 14.3166 6.90237 14.7071 7.29289C15.0976 7.68342 15.0976 8.31658 14.7071 8.70711L10.7071 12.7071C10.3166 13.0976 9.68342 13.0976 9.29289 12.7071L5.29289 8.70711C4.90237 8.31658 4.90237 7.68342 5.29289 7.29289Z"/>
           </svg>
        </div>
      }
      { isPlaceholder || disabled || !edit ? null :
        <div className={ `
            text-blue-400 hover:text-blue-700
            pt-2 pr-1 inline-block cursor-pointer
          ` }
          onClick={ edit }>
          <svg width="22" height="22" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"/>
          </svg>
        </div>
      }
      { isPlaceholder || disabled || !remove ? null :
        <div className={ `
            text-blue-400 hover:text-blue-700
            pt-2 pr-1 inline-block cursor-pointer 
          ` }
          onClick={ remove }>
            <svg width="22" height="22" viewBox="0 0 20 20" fill="currentColor" stroke="currentColor">
                <path fill-rule="evenodd" clip-rule="evenodd" d="M4.29289 4.29289C4.68342 3.90237 5.31658 3.90237 5.70711 4.29289L10 8.58579L14.2929 4.29289C14.6834 3.90237 15.3166 3.90237 15.7071 4.29289C16.0976 4.68342 16.0976 5.31658 15.7071 5.70711L11.4142 10L15.7071 14.2929C16.0976 14.6834 16.0976 15.3166 15.7071 15.7071C15.3166 16.0976 14.6834 16.0976 14.2929 15.7071L10 11.4142L5.70711 15.7071C5.31658 16.0976 4.68342 16.0976 4.29289 15.7071C3.90237 15.3166 3.90237 14.6834 4.29289 14.2929L8.58579 10L4.29289 5.70711C3.90237 5.31658 3.90237 4.68342 4.29289 4.29289Z"/>
            </svg>
        </div>
      }
    </div>
  )
}

const View = ({value, edit, remove, moveUp, moveDown,}) => {
    if(!value) return false
    return (
        <div className='relative px-4 sm:px-6 lg:px-12 w-full'>
            <h2 className='section-header text-xl tracking-wider mx-auto my-2 font-medium  py-1 flex'>
                <div className='flex-1 py-1'>{value.title} <span className='text-sm font-normal text-blue-500'>{value.section && edit ? ` #${value.section}` : `` }</span></div>
                <ValueItem edit={edit} remove={remove}  moveUp={moveUp} moveDown={moveDown} />
            </h2>
            <Element.View value={value.element} />
        </div>
    )
               
}

View.settings = {
    hasControls: true
}

export default View
