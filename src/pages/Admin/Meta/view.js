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

export default [{
  path: "/off",
  mainNav: true,
  exact: true,
  auth: false,
  name: 'Mitigate NY',
  icon: '',
  layout: 'Simple',
  component: config
},
{
  path: "/p",
  mainNav: false,
  exact: false,
  auth: false,
  name: 'Home',
  icon: '',
  layout: 'Simple',
  component: config
}]
