import React from "react"

import { metaDoc } from './metadocs.type'
import PageManager from './components/PageManager'
import PageEdit from './components/PageEdit'
import { API_HOST } from 'config'
import { addInput } from "components/dms/wrappers/utils/get-dms-input"
import AssetTable from './components/Element/AssetsTable'


const AssetTableComp = {
    InputComp: AssetTable.edit,
    getInputProps: (att, props) => ({ Attribute: att }),
    getArrayProps: (att, props) => ({ showControls: false }), // <== NEW PROP
    getDisplayComp: (att, props) => AssetTable.view,
    getEmptyValueFunc: (att, props) => () => ''
}


const DmsFormatOverwrite = {
    getArrayProps: (att, props) => ({ showControls: false }), // <== NEW PROP
}

addInput("asset-table", AssetTableComp);
addInput("dms-format", DmsFormatOverwrite)
// import PageView from './components/PageView'


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
