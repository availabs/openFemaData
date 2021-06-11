import React from "react"

const SectionSideNav = ({sections}) => (
    <div className='w-56 h-full hidden sm:block' >
        <ul className='py-6 px-6 pr-4 text-md'>
            { 
               sections.map((section,i) => {

                    return (
                        <React.Fragment key={i}>
                        {(i === 0 || (sections[i-1] && sections[i-1].section !== section.section)) ? 
                            <li 
                                key={section.section+i} 
                                className={`${i === 0 ? '' : 'pt-6' } text-blue-500  pb-2 uppercase text-sm`}>
                                {section.section}
                            </li> : ''
                        }
                        <li 
                            key={i} 
                            className='cursor-pointer hover:text-blue-500 '>
                                {section.title}
                        </li>
                        </React.Fragment>
                    )
                })
            }
        </ul>
    </div>
)

export default SectionSideNav