import React from "react"

import { getInputData } from "components/dms/wrappers/utils/get-dms-input"

const SectionView = ({ title, section, element, isRaw = true }) => {
  const { /* key, name, */ type, value } = element;

  const DisplayComp = React.useMemo(() => {
    return getInputData(type).getDisplayComp() || DefaultDisplayComp;
  }, [type, /*value*/]);

  console.log('SectionView Value', value)

  return (
    <div>
      <div className="text-3xl font-bold">
        { title } <span className='text-sm text-blue-500'>{section}</span>
      </div>
      <div className="rounded py-4">
        <DisplayComp value={ value } isRaw={ isRaw }/>
      </div>
    </div>
  )
}

export default SectionView;

const DefaultDisplayComp = ({ value }) => (
  <div className="whitespace-pre-wrap">
    { typeof value !== "string" ? JSON.stringify(value, null, 3) : value }
  </div>
)
