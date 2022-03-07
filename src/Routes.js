
// --- Public Pages ------
import MethodsEdit from 'pages/Methods'
import Methods from 'pages/Methods/view'

import AdminHome from 'pages/Home'
import ChartView from 'pages/Home/components/merge/chartView'
import MapView from 'pages/Home/components/merge/mapView'
import ChartByDisView from 'pages/Home/components/merge/chartByDisView'
import FemaDisaster from 'pages/Home/disaster'
import Fusion from 'pages/Home/components/fusion/fusion'
import PerBasisCharts from "./pages/Home/components/perBasisCharts";
import FusionMapView from 'pages/Home/components/fusion/fusionMapView'
import FusionCompare from 'pages/Home/components/fusion/nri'

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

	Fusion,
	FusionMapView,
	FusionCompare,

	PerBasisCharts,
	Auth,

	// -- Misc
	NoMatch
];
