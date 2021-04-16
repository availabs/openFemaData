import React  from "react"
import {useTheme, TopNav} from '@availabs/avl-components'
//import { SideNav } from 'components/avl-components/src/components'
import AuthMenu from 'pages/Auth/AuthMenu'
import logo from './Logo.js'

const AdminLayout = ({children}) => {
	const theme = useTheme()
	return (
	  	<div className={`flex items-start flex-col min-h-screen`}>
            <div className='w-full fixed bg-white z-10'>
		  		<TopNav  
		  			logo={<div className='border-b border-gray-200'>{logo('SHMP')}</div>}
		  			menuItems={[
		    			
		    			{
			                name: 'Home',
			                path: `/`,
			                //icon: 'fa fa-home',
			                className: 'font-medium text-lg'
			                
			            },
		    			{
			                name: 'Methodology',
			                path: `/p/`,
			                //icon: 'fa fa-edit',
			                className: 'font-medium text-lg'
			            },
		    		]}
		    	/>
		    </div>
		    
            <div className={`w-full hasValue flex-1 mt-12`}>
		    	
	    			{children}
	    		
	    	</div>
		</div>
	)
}

export default AdminLayout

//{/*rightMenu={<div className='border-b border-gray-200 pb-3'><AuthMenu /></div>}*/}
		    		