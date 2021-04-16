import React  from "react"
// import {useTheme} from '@availabs/avl-components'
import {withRouter} from "react-router-dom";
import AdminLayout from '../Layout'
import get from 'lodash.get'


const Home = ({children,match}) => {
	// const theme = useTheme()
	
	const Source = get(match ,'params.source', '')
	return (
	  	<AdminLayout>
	  		<div className="w-full max-w-7xl mx-auto p-2">
	  			<div className='pt-4 pb-3'>
          			<h3 className='inline font-bold text-3xl '>
          				Data Sources 
          				<span className='uppercase text-blue-600 font-medium'> {Source}</span>
          			</h3>
        		</div>
	  		</div>
		</AdminLayout>
	)
}

export default [
	{
	  path: "/data/",
	  exact: true,
	  auth: true,
	  component: withRouter(Home),
	  layout: 'Simple'
	},
	{
	  path: "/data/:source",
	  exact: false,
	  auth: true,
	  component: withRouter(Home),
	  layout: 'Simple'
	}
]