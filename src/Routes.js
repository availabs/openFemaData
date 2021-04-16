
// --- Public Pages ------
import Meta from 'pages/Admin/Meta'

import Public from 'pages/Admin/Meta/view'
import AdminHome from 'pages/Home'
import FemaDisaster from 'pages/Home/disaster'
import DataSources from 'pages/Admin/DataSources'

import Auth from "pages/Auth"
import NoMatch from 'pages/404';

export default [
	// -- Public -- //
	...Public,
	FemaDisaster,
	// -- Authed -- //
	AdminHome,
	...DataSources,
	Meta,
	Auth,

	// -- Misc
	NoMatch
];
