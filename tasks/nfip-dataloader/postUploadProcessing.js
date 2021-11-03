const db = require('../open-fema-dataloader/db.js');

const updateCountyRemoveDecimal = async () => {
    let query = `
        UPDATE open_fema_data.nfip_claims
        SET county_code = REPLACE(county_code, '.0', '')
`
    return db.query(query);
}

const postProcess = async () => {
    // await updateCountyRemoveDecimal();
}

postProcess()