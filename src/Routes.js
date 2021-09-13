
// --- Public Pages ------
import MethodsEdit from 'pages/Methods'
import Methods from 'pages/Methods/view'

import AdminHome from 'pages/Home'
import Merge from 'pages/Home/merge'
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
	Merge,
	Auth,

	// -- Misc
	NoMatch
];
