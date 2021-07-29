import React from "react";
import {PAGroups, PA_SUMMARY_ATTRIBUTES, PACategoriesMappings} from "../config";
import get from "lodash.get";
import {fnum} from "utils/fnum";

export const PASummary = (disaster, groupEnabled) => {
    return (
        <React.Fragment>
            <h4 className={`pt-5`}>Public Assistance Summary</h4>
            <div className={`border-t border-gray-200 bg-white grid grid-cols-1 divide-y divide-gray-200 sm:grid-cols-${groupEnabled ? `1` : `6`} sm:divide-y-0 sm:divide-x`}>
                {
                    groupEnabled ?
                        Object.keys(PAGroups)
                            .map(group => {
                                return (
                                    <div className="px-6 py-5 text-sm font-medium space-x-0 sm:space-x-5"
                                         >
                                        <div className={`block sm:inline-block text-center`}>
                                            <div className='text-white rounded' style={{
                                             background: PAGroups[group].color
                                         }}>{group}</div>
                                            {
                                                PA_SUMMARY_ATTRIBUTES.map(attr => (
                                                    <>
                                                        <div className='text-gray-600'>
                                                            {
                                                                attr.replace(/_/g, ' ')
                                                            }
                                                            ({
                                                            fnum(PAGroups[group].categories.reduce((a, c) => a + +get(get(disaster, ['paSummary', 'value'], []).filter(categoryValues => categoryValues.damage_categories === c)
                                                                , [0, attr], 0) , 0))
                                                        })
                                                        </div>
                                                        <div className='text-lg'>
                                                            {
                                                                PAGroups[group].categories.reduce((a, c) => {
                                                                        return a +
                                                                        +get(get(disaster, ['paSummary', 'value'], []).filter(categoryValues => categoryValues.damage_categories === c)
                                                                            , [0, attr], 0)
                                                                    }
                                                                    , 0).toLocaleString()
                                                            }
                                                        </div>
                                                    </>
                                                ))
                                            }
                                        </div>

                                        {
                                            PAGroups[group].categories.map(cat => (
                                                <div className={`block sm:inline-block`}>
                                                    {
                                                        get(disaster, ['paSummary', 'value'], [])
                                                            .filter(categoryValues => categoryValues.damage_categories === cat)
                                                            .map(categoryValues => (
                                                                <div>
                                                                    {
                                                                        <div className="px-6 py-5 text-sm font-medium text-center"
                                                                        >
                                                                            <div className='text-white rounded' style={{
                                                                                background: get(Object.values(PAGroups).filter(g => g.categories.includes(categoryValues.damage_categories)), [0, 'color'])
                                                                            }}>{PACategoriesMappings[categoryValues.damage_categories]}</div>
                                                                            {
                                                                                PA_SUMMARY_ATTRIBUTES.map(attr => (
                                                                                    <>
                                                                                        <div className='text-gray-600'>
                                                                                            {
                                                                                                attr.replace(/_/g, ' ')
                                                                                            }
                                                                                            ({fnum(get(categoryValues, [attr], 0))})
                                                                                        </div>
                                                                                        <div className='text-lg'>
                                                                                            {
                                                                                                (+get(categoryValues, [attr], 0)).toLocaleString()
                                                                                            }
                                                                                        </div>
                                                                                    </>
                                                                                ))
                                                                            }
                                                                        </div>
                                                                    }
                                                                </div>
                                                            ))
                                                    }
                                                </div>
                                            ))
                                        }

                                    </div>
                                )
                            }):

                            get(disaster, ['paSummary', 'value'], []).map(categoryValues => (
                                <div>
                                    {
                                        <div className="px-6 py-5 text-sm font-medium text-center"
                                        >
                                            <div className='text-white rounded' style={{
                                                background: get(Object.values(PAGroups).filter(g => g.categories.includes(categoryValues.damage_categories)), [0, 'color'])
                                            }}>{PACategoriesMappings[categoryValues.damage_categories]}</div>
                                            {
                                                PA_SUMMARY_ATTRIBUTES.map(attr => (
                                                    <>
                                                        <div className='text-gray-600'>
                                                            {
                                                                attr.replace(/_/g, ' ')
                                                            }
                                                        </div>
                                                        <div className='text-lg'>
                                                            {
                                                                fnum(get(categoryValues, [attr], 0))
                                                            }
                                                        </div>
                                                    </>
                                                ))
                                            }
                                        </div>
                                    }
                                </div>
                            ))

                }
            </div>
        </React.Fragment>
    )
}