import React from "react"
import get from 'lodash.get'

import {TopNav, withAuth, useTheme} from '@availabs/avl-components'
import {SideNav} from 'components/avl-components/src'
import { Link } from 'react-router-dom'

import AuthMenu from 'pages/Auth/AuthMenu'
import SectionSideNav from './SideNav'

import Layout from 'pages/Layout'

import SectionEdit from "./SectionViewNew"
import {DmsButton} from "components/dms/components/dms-button"

import logo from './Logo.js'

const Create = ({createState, setValues, item, dataItems, ...props}) => {
    const theme = useTheme();
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
                path: `/meta/edit/${d.id}`, // d.data['url-slug'],
                sectionClass: 'mb-4',
                itemClass: 'font-bold',
                subMenus: dataItems
                    .filter(({data}) => !data.sectionLanding && (data.section === d.data.section))
                    .map(p => ({
                        name: p.data.title, 
                        id:p.id, 
                        path: `/meta/edit/${p.id}`, 
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
    let Title = createState.sections[0].attributes.filter(a => a.key === 'title').pop()
    let URL = createState.sections[0].attributes.filter(a => a.key === 'url-slug').pop()
    let ShowSidebar = createState.sections[0].attributes.filter(a => a.key === 'showSidebar').pop()
    let Sections = createState.sections[0].attributes.filter(a => a.key === 'sections').pop()

    return (
        <Layout>
            <div className={`w-full flex-1`}>
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
                    <div className='h-full max-w-5xl flex-1'>
                        <div className='pt-4 pb-3 px-6 flex items-center justify-between'>
                            <div><h3 className='inline font-bold text-3xl'>{data.title}</h3></div>
                            <div><Link to={`/methods/view/${activePage.id}`}>View</Link></div>
                        </div>
                        <div className='bg-white py-8 px-12 font-sm font-light text-xl leading-9 '>
                           <Sections.Input
                                className={`p-4 border-none active:border-none focus:outline-none custom-bg h-full ${theme.text}`}
                                value={Sections.value}
                                onChange={Sections.onChange}
                            />
                        </div>
                    </div>
                    <div className='w-full lg:w-56 order-first lg:order-last' >
                        <div className="p-4 border-l border-gray-300 fixed">
                            <h4 className='font-bold '> Page Settings </h4>
                            <div>
                                Title
                                <Title.Input
                                    autoFocus={true}
                                    value={Title.value}
                                    placeholder={'Title'}
                                    onChange={Title.onChange}
                                />
                            </div>
                            <div>
                                url
                                <URL.Input
                                    className={`ml-2 ${theme.text}`}
                                    autoFocus={true}
                                    value={URL.value}
                                    placeholder={'/url'}
                                    onChange={URL.onChange}
                                />
                            </div>
                            <div>
                                Show Sidebar
                                <ShowSidebar.Input
                                    className={`ml-2 ${theme.text}`}
                                    autoFocus={true}
                                    value={ShowSidebar.value}
                                    placeholder={'/url'}
                                    onChange={ShowSidebar.onChange}
                                />
                            </div>
                             <div className="mt-2 mb-4 max-w-2xl">
                                <DmsButton
                                    className="w-full"
                                    large
                                    type="submit"
                                    label='Save'
                                    action={createState.dmsAction}
                                    item={item}
                                    props={props}/>
                            </div>

                        </div>
                        <div className='fixed mt-64 border-l border-gray-300'>
                            { ShowSidebar.value ?
                                <SectionSideNav sections={ get(data, `sections`, []) } /> : ''
                            }
                        </div>
                    </div>
                </div>
            </div>
        </Layout>
    )
}

export default Create
