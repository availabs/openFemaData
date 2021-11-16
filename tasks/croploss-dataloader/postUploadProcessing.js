const db = require('../open-fema-dataloader/db.js');

const updateDataSource = async () => {
    let query = `
        INSERT INTO public.datasources(
            title,
            description, "table",
            data_url, data_dictionary,
            landing_page, publisher,
            last_refresh,
            start_date, end_date, record_count)
        SELECT 'USDA Crop Insurance Data' title,
               '' description, 'open_fema_data.usda_crop_insurance_cause_of_loss' "table",
               '' data_url, 'https://www.rma.usda.gov/en/Information-Tools/Summary-of-Business/Cause-of-Loss' data_dictionary,
               '' landing_page, 'USDA' publisher,
               (SELECT NOW()) last_refresh,
               null start_date, null end_date,
               (select count(1) record_count from open_fema_data.usda_crop_insurance_cause_of_loss) record_count
`
    return db.query(query);
}

const postProcess = async () => {
    // await updateDataSource();
}

postProcess()