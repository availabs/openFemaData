import React  from "react"
import {SideNav, useTheme} from '@availabs/avl-components'
import AuthMenu from 'pages/Auth/AuthMenu'
import Logo from './Logo.js'

const AdminTheme = {
  sidebarBg: 'bg-white'
}

const AdminLayout = ({children}) => {
	const theme = useTheme()
	return (
	  	<div className="w-full bg-gray-50">
	  		I am here
	  		<div className="flex min-h-screen">
		  		<SideNav  
		  			logo={<div className=' p-4'><Logo /></div>}
		  			topMenu={<div className='pb- pt-6'><AuthMenu /></div>}
		    		menuItems={[
		    			
		    			{
			                name: 'Meta 123',
			                id: 0,
			                path: `/meta/`
			            }
		    		]}
		    		fixed={true}
		    		customTheme={AdminTheme}
		    	/>
		    	<div className={`flex-1 md:ml-${theme.sidebarW}`}>	
	    			{children}
	    		</div>
	    	</div>
		</div>
	)
}

export default AdminLayout