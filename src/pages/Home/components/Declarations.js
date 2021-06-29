import get from "lodash.get";
import React from "react";

export const Declarations = (disaster) => {
    return (
        <div className={`last:mb-5`}>
            <h4 className={`pt-5`}> declarations </h4>
            {disaster.declarations.map(declaration => (
                <div className={`border-t border-gray-200 bg-white grid grid-cols-1 divide-y divide-gray-200 sm:grid-cols-6 sm:divide-y-0 sm:divide-x`}>
                    <div className={`px-6 py-5 text-sm font-medium text-center`}>
                        <div>{get(declaration, 'declaration_title.value', '')}</div>
                        <div className='text-xs'>
                            <span className='text-gray-500'>DN </span>
                            {get(declaration, 'declaration_request_number.value', '')}
                        </div>
                        <div className='text-xs'>
                            <span className='text-gray-500'>Declared </span>
                            {get(declaration, 'declaration_date.value', '')}
                        </div>
                        <div className='text-xs'>
                            <span className='text-gray-500'>Type </span>
                            {get(declaration, 'fips_state_code.value', '')}{get(declaration, 'fips_county_code.value', '')}
                        </div>
                    </div>
                </div>
            ))}
        </div>
    )
}