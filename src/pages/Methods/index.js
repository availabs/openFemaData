import React from "react"

import get from "lodash.get"

import { Button } from "@availabs/avl-components"

import { metaDoc } from './metadocs.type'
import PageManager from './components/PageManager'
import PageEdit from './components/PageEditNew'
import { API_HOST } from 'config'
import { addInput, setDefaultArrayProps } from "components/dms/wrappers/utils/get-dms-input"
import AssetTable from './components/Element/AssetsTable'
import TypeSelect from "./components/ShmpTypeSelect"
import DmsInput from "./components/ShmpDmsInput"

const AssetTableComp = {
    InputComp: AssetTable.edit,
    getInputProps: (att, props) => ({ Attribute: att }),
    getArrayProps: (att, props) => ({ showControls: false }), // <== NEW PROP
    getDisplayComp: (att, props) => AssetTable.view,
    getEmptyValueFunc: (att, props) => () => ''
}
addInput("asset-table", AssetTableComp);
addInput("type-select", { InputComp: TypeSelect });
addInput("dms-format", { InputComp: DmsInput });

const CreateButton = ({ create, opened }) => (
  <div className="ml-2">
    <Button className="p-2"
      onClick={ create }
      buttonTheme={ opened ? "buttonDanger" : "buttonPrimary" }>
      { opened ? 'cancel' : 'add new section' }
    </Button>
  </div>
)
const DisplayControls = ({ value, edit, remove, moveUp, canMoveUp, moveDown, canMoveDown, children }) => (
  <div>
    <div className="flex w-full items-center px-2">
      <div className="flex-1 font-bold text-2xl text-gray-700">
        { get(value, "title", "Untitled Section") } 
        <span className='text-sm text-blue-400'> { get(value, "section", "") } </span>
      </div>
      <div className="flex-0">
        <div className={ `
            text-blue-400 hover:text-blue-700
            pt-2 pr-1 inline-block cursor-pointer
          ` }
          disabled={ !canMoveUp }
          onClick={ moveUp }>
          <svg width="22" height="22" fill="currentColor" viewBox="0 0 20 20" stroke="currentColor">
            <path fillRule="evenodd" clipRule="evenodd" d="M14.7071 12.7071C14.3166 13.0976 13.6834 13.0976 13.2929 12.7071L10 9.41421L6.70711 12.7071C6.31658 13.0976 5.68342 13.0976 5.29289 12.7071C4.90237 12.3166 4.90237 11.6834 5.29289 11.2929L9.29289 7.29289C9.68342 6.90237 10.3166 6.90237 10.7071 7.29289L14.7071 11.2929C15.0976 11.6834 15.0976 12.3166 14.7071 12.7071Z"/>
          </svg>
        </div>
        <div className={ `
            text-blue-400 hover:text-blue-700
            pt-2 pr-1 inline-block cursor-pointer
          ` }
          disabled={ !canMoveDown }
          onClick={ moveDown }>
          <svg width="22" height="22" viewBox="0 0 20 20" fill="currentColor" stroke="currentColor">
            <path fillRule="evenodd" clipRule="evenodd" d="M5.29289 7.29289C5.68342 6.90237 6.31658 6.90237 6.70711 7.29289L10 10.5858L13.2929 7.29289C13.6834 6.90237 14.3166 6.90237 14.7071 7.29289C15.0976 7.68342 15.0976 8.31658 14.7071 8.70711L10.7071 12.7071C10.3166 13.0976 9.68342 13.0976 9.29289 12.7071L5.29289 8.70711C4.90237 8.31658 4.90237 7.68342 5.29289 7.29289Z"/>
           </svg>
        </div>
        <div className={ `
            text-blue-400 hover:text-blue-700
            pt-2 pr-1 inline-block cursor-pointer
          ` }
          onClick={ edit }>
          <svg width="22" height="22" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"/>
          </svg>
        </div>
        <div className={ `
            text-blue-400 hover:text-blue-700
            pt-2 pr-1 inline-block cursor-pointer
          ` }
          onClick={ remove }>
            <svg width="22" height="22" viewBox="0 0 20 20" fill="currentColor" stroke="currentColor">
                <path fillRule="evenodd" clipRule="evenodd" d="M4.29289 4.29289C4.68342 3.90237 5.31658 3.90237 5.70711 4.29289L10 8.58579L14.2929 4.29289C14.6834 3.90237 15.3166 3.90237 15.7071 4.29289C16.0976 4.68342 16.0976 5.31658 15.7071 5.70711L11.4142 10L15.7071 14.2929C16.0976 14.6834 16.0976 15.3166 15.7071 15.7071C15.3166 16.0976 14.6834 16.0976 14.2929 15.7071L10 11.4142L5.70711 15.7071C5.31658 16.0976 4.68342 16.0976 4.29289 15.7071C3.90237 15.3166 3.90237 14.6834 4.29289 14.2929L8.58579 10L4.29289 5.70711C3.90237 5.31658 3.90237 4.68342 4.29289 4.29289Z"/>
            </svg>
        </div>
      </div>
    </div>
    <div className="p-2">
      { children }
    </div>
  </div>
)

const EditComponent = React.forwardRef(({ Input, children, controls = {}, ...props }, ref) => {
  const {
    addToArray,
    buttonDisabled,
    cancelEdit
  } = controls;
  return (
    <div className="w-full p-2">
      <div className="mb-2">
        <Input { ...props } ref={ ref }/>
      </div>
      <div className="flex">
        <div className="flex-1">
          <Button onClick={ addToArray }
            buttonTheme="buttonPrimary"
            disabled={ buttonDisabled }>
            add section
          </Button>
        </div>
        <div className="flex-0">
          <Button onClick={ cancelEdit }
            buttonTheme="buttonDanger">
            cancel
          </Button>
        </div>
      </div>

      { children }

    </div>
  )
})
setDefaultArrayProps({ CreateButton, DisplayControls, EditComponent });

let config = {
    type: ({ children }) => <div>{ children }</div>,
    wrappers: [
        "dms-manager",
        {
            type:"dms-provider",
            options: {
                imgUploadUrl: `${ API_HOST }/img/new`,
            }
        },
        "dms-router",
        "show-loading",
        "dms-falcor",
        "with-auth"
      ],
    props: {
        format: metaDoc,
        title: "Documentation",
    },
    children: [
        {
            type: PageManager,
            props: { dmsAction: "list" }
        },
        {
            type: PageEdit,
            props: { dmsAction: "create" },
            wrappers: ["dms-create", "with-auth"]
        },

        {
            type: PageEdit,
            props: { dmsAction: "edit" },
            wrappers: ["dms-edit", "with-auth"]
        }
    ]
}

export default {
    path: "/meta",
    mainNav: false,
    // exact: true,
    auth: true,
    name: 'Meta',
    authLevel: 5,
    icon: '',
    layout: 'Simple',
    layoutSettings: {
        fixed: true,
        nav: 'side',
        maxWidth: '',
        headerBar: false,

    },
    component: config
}
