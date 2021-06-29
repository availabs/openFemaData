import React from "react";
import {groups, SUMMARY_ATTRIBUTES} from "../utils";
import get from "lodash.get";

export const IHPSummary = (disaster, groupEnabled) => {
    return (
        <React.Fragment>
            <h4 className={`pt-5`}>Individual and Household Program Summary</h4>
            <div className={`border-t border-gray-200 bg-white grid grid-cols-1 divide-y divide-gray-200 sm:grid-cols-${groupEnabled ? `1` : `6`} sm:divide-y-0 sm:divide-x`}>
                {
                    groupEnabled ?
                        Object.keys(groups)
                            .map(group => {
                                return (
                                    <div className="px-6 py-5 text-sm font-medium text-center space-x-0 sm:space-x-5"
                                         style={{
                                             background: groups[group].color
                                         }}>
                                        <div className={`block sm:inline-block`}>
                                            <div className='text-gray-600'>{group}</div>
                                            <div className='text-lg'>
                                                {
                                                    groups[group].attributes.reduce((a,c) => a + get(disaster, [c, 'value'], 0) , 0).toLocaleString()
                                                }
                                            </div>
                                        </div>

                                        {
                                            groups[group].attributes.map(attr => (
                                                <div className={`block sm:inline-block`}>
                                                    <div className='text-gray-600'>{attr.replace(	/_/g, ' ')}</div>
                                                    <div className='text-lg'>
                                                        {
                                                            get(disaster, [attr, 'value'], '').toLocaleString()
                                                        }
                                                    </div>
                                                </div>
                                            ))
                                        }

                                    </div>
                                )
                            }):
                        SUMMARY_ATTRIBUTES.map(attr => (
                            <div className="px-6 py-5 text-sm font-medium text-center"
                                 style={{
                                     background: get(Object.values(groups).filter(g => g.attributes.includes(attr)), [0, 'color'])
                                 }}>
                                <div className='text-gray-600'>{attr.replace(	/_/g, ' ')}</div>
                                <div className='text-lg'>
                                    {
                                        get(disaster, [attr, 'value'], '').toLocaleString()
                                    }
                                </div>
                            </div>
                        ))
                }
            </div>
        </React.Fragment>
    )
}