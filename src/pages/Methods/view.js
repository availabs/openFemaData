import { metaDoc } from './metadocs.type'
import PageView from './components/PageView'




let config = {
  type: PageView, // top level component for managing data items
  wrappers: [
    "dms-provider",
    "dms-router",
    "show-loading",
    "dms-falcor",
    "with-auth"
  ],
  props: {
    format: metaDoc
  }
}

export default [
  {
    path: "/methods",
    mainNav: false,
    exact: false,
    auth: false,
    name: 'Methodology',
    icon: '',
    layout: 'Simple',
    component: config
  }
]
