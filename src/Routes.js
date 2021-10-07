
// --- Public Pages ------
import MethodsEdit from 'pages/Methods'
import Methods from 'pages/Methods/view'

import AdminHome from 'pages/Home'
import ChartView from 'pages/Home/components/merge/chartView'
import MapView from 'pages/Home/components/merge/mapView'
import ChartByDisView from 'pages/Home/components/merge/chartByDisView'
import FemaDisaster from 'pages/Home/disaster'

import Auth from "pages/Auth"
import NoMatch from 'pages/404';

export default [
	// -- Public -- //
	...Methods,
	FemaDisaster,
	// -- Authed -- //
	MethodsEdit,
	AdminHome,

	// -- Data Merge -- //
	ChartView,
	MapView,
	ChartByDisView,

	Auth,

	// -- Misc
	NoMatch
];
