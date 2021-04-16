import React from "react"

const SectionSideNav = ({sections}) => (
    <div className='bg-white shadow w-56 h-full hidden sm:block fixed' >
        <ul className='py-6 pl-4 pr-4 text-md'>
            { 
               sections.map((section,i) => {

                    return (
                        <React.Fragment key={i}>
                        {(i === 0 || (sections[i-1] && sections[i-1].section !== section.section)) ? 
                            <li 
                                key={section.section+i} 
                                className={`${i === 0 ? '' : 'pt-6' } text-blue-500 font-medium`}>
                                {section.section}
                            </li> : ''
                        }
                        <li 
                            key={i} 
                            className='cursor-pointer hover:text-blue-500 pl-4'>
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