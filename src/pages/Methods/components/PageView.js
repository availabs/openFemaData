import React from "react"
import get from 'lodash.get'

import {TopNav, withAuth} from '@availabs/avl-components'
import {SideNav} from 'components/avl-components/src'
import { Link } from 'react-router-dom'

import AuthMenu from 'pages/Auth/AuthMenu'
import SectionSideNav from './SideNav'

import Layout from 'pages/Layout'

import SectionView from "./SectionViewNew"

import logo from './Logo.js'

const View = withAuth(({item, dataItems, user, ...props}) => {

    dataItems = dataItems.sort((a, b) => a.data.index - b.data.index)
    if (!item) {
        item = dataItems.filter(d => d.data.sectionLanding && d.data.index === 0).pop()
    }
    if (!item || !item.data) return null //<div> <h4>Data Configuration Error</h4> We cannot find the driods you are looking for. </div>

    const {data} = item
    let navItems = dataItems
        .filter(d => d.data.sectionLanding)
        .map((d) => {
            return {
                name: d.data.section,
                id: d.id,
                path: `/methods/view/${d.id}`, // d.data['url-slug'],
                sectionClass: 'mb-4',
                itemClass: 'font-bold',
                subMenus: dataItems
                    .filter(({data}) => !data.sectionLanding && (data.section === d.data.section))
                    .map(p => ({
                        name: p.data.title, 
                        id:p.id, 
                        path: `/methods/view/${p.id}`, 
                        className: 'pl-4 ', 
                        customTheme: {
                            navitemSide: ' pl-2 hover:bg-gray-200 w-full py-2 text-sm font-base text-gray-400 inline-flex items-center border-b border-r border-gray-200  hover:pb-4 focus:outline-none focus:text-gray-700 focus:border-gray-300 transition duration-150 ease-in-out',
                            navitemSideActive: 'pl-2 py-2 inline-flex w-full items-center bg-white border border-gray-200 text-sm font-base text-blue-500 hover:pb-4 focus:outline-none focus:text-gray-700 focus:border-gray-300 transition duration-150 ease-in-out'
                        }
                    })),
                rest: props
            }
        })
    let activePage = props['doc-page'] || item
    let subNav = data.sectionLanding ? get(navItems.filter((data) => (data.id === get(activePage, `id`))), `[0].subMenus`, []) :
        get(navItems.filter((data) => (data.subMenus.map(c => c.id).includes(get(activePage, `id`)))), `[0].subMenus`, [])

    // console.log('render Page view', data)

    return (
        <Layout>
            <div className={`w-full h-full flex-1`}>
                <div className={'h-full flex justify-center flex-col lg:flex-row h-screen'}>
                    <div className='h-full hidden xl:block w-64'>
                        <SideNav
                            menuItems={navItems}
                            rightMenu={<AuthMenu />}
                            customTheme={{
                            sidebarW: '64',
                            sidebarBg: 'bg-gray-100 border-r border-gray-300 h-full fixed',
                            navitemSide: ' pl-4 hover:bg-gray-200 w-full py-2 text-base font-medium text-gray-600 inline-flex items-center border-b border-r border-gray-200  hover:pb-4 focus:outline-none focus:text-gray-700 focus:border-gray-300 transition duration-150 ease-in-out',
                            navitemSideActive: 'pl-4 py-2 inline-flex w-full items-center bg-white border border-gray-200 text-base font-medium text-blue-500 hover:pb-4 focus:outline-none focus:text-gray-700 focus:border-gray-300 transition duration-150 ease-in-out'
                        }} />
                        
                    </div>
                    <div className='h-full max-w-5xl w-full'>
                        <div className='pt-4 pb-3 px-6 flex items-center justify-between'>
                            <div><h3 className='inline font-bold text-3xl'>{data.title}</h3></div>
                            <div><Link to={`/meta/edit/${activePage.id}`}>Edit</Link></div>
                        </div>
                        <div className='bg-white py-8 px-12 font-sm font-light text-xl leading-9 '>
                            { get(data, `sections`, [])
                                .map((section, i) =>
                                  <SectionView key={ i } { ...section }/>
                                )
                            }
                        </div>
                    </div>
                    <div className='w-full hidden xl:block lg:w-56 order-first lg:order-last' >
                        <div className='fixed'>
                            { data.showSidebar?
                                <SectionSideNav sections={ get(data, `sections`, []) } /> : ''
                            }
                        </div>
                    </div>
                </div>
            </div>
        </Layout>
    )
})

export default View
