import React from "react"
import get from 'lodash.get'

import {TopNav, useTheme} from '@availabs/avl-components'

import {DmsButton} from "components/dms/components/dms-button"

import SectionSideNav from './SideNav'
import AuthMenu from 'pages/Auth/AuthMenu'

import logo from './Logo.js'




export const Create = ({createState, setValues, item, dataItems, ...props}) => {
    const theme = useTheme();
    dataItems = dataItems.sort((a, b) => a.data.index - b.data.index)

    if (!item) {
        item = dataItems.filter(d => d.data.sectionLanding && d.data.section === props.section).pop()
    }
    if (!item || !item.data) return null


// console.log("<PageEdit>", item, dataItems, props)

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
                children: dataItems
                    .filter(({data}) => !data.sectionLanding && (data.section === d.data.section))
                    .map(p => ({name: p.data.title, id:p.id, path: `/cms/edit/${p.id}`, itemClass: 'font-thin -mt-2'})),
                rest: props
            }
        })
    let activePage = props['doc-page'] || item
    let subNav = data.sectionLanding ? get(navItems.filter((data) => (data.id === get(activePage, `id`))), `[0].children`, []) :
        get(navItems.filter((data) => (data.children.map(c => c.id).includes(get(activePage, `id`)))), `[0].children`, [])


    let Title = createState.sections[0].attributes.filter(a => a.key === 'title').pop()
    let URL = createState.sections[0].attributes.filter(a => a.key === 'url-slug').pop()
    let ShowSidebar = createState.sections[0].attributes.filter(a => a.key === 'showSidebar').pop()
    let Sections = createState.sections[0].attributes.filter(a => a.key === 'sections').pop()


    return (
        <div className={`flex items-start flex-col min-h-screen`}>
            <div className='w-full fixed bg-white z-10'>
                <TopNav
                    menuItems={navItems}
                    logo={logo('SHMP')}
                    rightMenu={<AuthMenu />}
                />
                {subNav.length ?
                	<TopNav
                		menuItems={subNav}
                		customTheme={{
                            sidebarBg: 'bg-white',
                            topNavHeight: '12' ,
                            navitemTop: 'px-8 inline-flex items-center border-b border-r border-gray-200 text-base font-normal text-gray-800 hover:pb-4 focus:outline-none focus:text-gray-700 focus:border-gray-300 transition duration-150 ease-in-out',
                            navitemTopActive: 'px-8 inline-flex items-center border-b border-r border-gray-200 text-base font-normal text-blue-500 hover:pb-4 focus:outline-none focus:text-gray-700 focus:border-gray-300 transition duration-150 ease-in-out'
                        }} />
                	: null
               	}
            </div>

            <div className={`w-full hasValue flex-1 ${subNav.length ? 'mt-24' : 'mt-12'}`}>
                
                <div className={`h-full`}>
                    <div className={'bg-white h-full flex justify-justify flex-col lg:flex-row'}>
                        <div className='hidden xl:block xl:w-56'>
                            { ShowSidebar.value ?
                                <SectionSideNav sections={ get(data, `sections`, []) } /> : ''
                            }
                        </div>
                        <div className='py-8 flex-1 '>
                            <div className='font-sm font-light text-xl leading-9 max-w-4xl mx-auto p-4 md:p-6'>
                                <Sections.Input
                                    className={`p-4 border-none active:border-none focus:outline-none custom-bg h-full ${theme.text}`}
                                    value={Sections.value}
                                    onChange={Sections.onChange}
                                />
                            </div>
                        </div>
                        

                        <div className='w-full xl:block lg:w-64 order-first lg:order-last border-b lg:border-none'>
                            <div className="p-4 border-l fixed">
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
                        </div>
                    </div>
                </div>
            </div>
        </div>
    )
}

export default Create
