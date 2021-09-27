import React from "react";
import get from "lodash.get";
import {fnum} from "utils/fnum";
import {SBAGroups} from "../config";

export const SBA = (disaster) => {
    return (
        <React.Fragment>
            <h4 className={`pt-5`}>SBA Summary</h4>
            <div className={`border-t border-gray-200 bg-white grid grid-cols-1 divide-y divide-gray-200 sm:grid-cols-6 sm:divide-y-0 sm:divide-x`}>
                {
                    Object.keys(SBAGroups).map(loanType => (
                        <div className="px-6 py-5 text-sm font-medium text-center">
                            <div className='text-white rounded' style={{
                                background: SBAGroups[loanType].color
                            }}>{loanType}</div>
                            <>
                                <div className='text-gray-600'>
                                    {
                                        'Total Loss'
                                    }
                                </div>
                                <div className='text-lg'>
                                    {
                                        fnum(SBAGroups[loanType].categories
                                            .reduce((acc, loan) => acc + get(disaster, ['sba', loan, 'total_loss'], 0), 0))
                                    }
                                </div>
                            </>
                        </div>
                    ))
                }
            </div>
        </React.Fragment>
    )
}