import React from "react";
import {groups, SUMMARY_ATTRIBUTES} from "../config";
import get from "lodash.get";
import {fnum} from "utils/fnum";

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
                                    <div className="px-6 py-5 text-sm font-medium space-x-0 sm:space-x-5"
                                         >
                                        <div className={`block sm:inline-block`}>
                                            <div className='text-white rounded' style={{
                                             background: groups[group].color
                                         }}>{group}</div>
                                            <div className='text-lg'>
                                                {
                                                    groups[group].attributes.reduce((a,c) => a + get(disaster, [c, 'value'], 0) , 0).toLocaleString()
                                                }
                                            </div>
                                            <div className='text-gray-600'>
                                                        {
                                                            fnum(groups[group].attributes.reduce((a,c) => a + get(disaster, [c, 'value'], 0) , 0))
                                                        }
                                            </div>
                                        </div>

                                        {
                                            groups[group].attributes.map(attr => (
                                                <div className={`block sm:inline-block`}>
                                                    <div className='text-white rounded' style={{
                                             background: groups[group].color
                                         }}>{attr.replace(	/_/g, ' ')}</div>
                                                    <div className='text-lg'>
                                                        {
                                                            get(disaster, [attr, 'value'], '').toLocaleString()
                                                        }
                                                    </div>
                                                    <div className='text-gray-600'>
                                                        {
                                                            fnum(get(disaster, [attr, 'value'], 0))
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
                                 >
                                <div className='text-white rounded' style={{
                                     background: get(Object.values(groups).filter(g => g.attributes.includes(attr)), [0, 'color'])
                                 }}>{attr.replace(	/_/g, ' ')}</div>
                                <div className='text-lg'>
                                    {
                                        get(disaster, [attr, 'value'], '').toLocaleString()
                                    }
                                </div>
                                <div className='text-gray-600'>
                                    {
                                        fnum(get(disaster, [attr, 'value'], 0))
                                    }
                                </div>
                            </div>
                        ))
                }
            </div>
        </React.Fragment>
    )
}