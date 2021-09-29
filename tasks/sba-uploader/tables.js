const tables = {
    sba_disaster_loan_data_new: {
        name: 'sba_disaster_loan_data_new',
        schema: 'public',
        columns: [
            'year',
            'sba_physical_declaration_number',
            'sba_eidl_declaration_number',
            'fema_disaster_number',
            'sba_disaster_number',
            'damaged_property_city_name',
            'damaged_property_zip_code',
            'damaged_property_county_or_parish_name',
            'damaged_property_state_code',

            'total_verified_loss',
            'verified_loss_real_estate',
            'verified_loss_content',
            'total_approved_loan_amount',
            'approved_amount_real_estate',
            'approved_amount_content',
            'approved_amount_eidl',
            'loan_type',
            'incidenttype',
            'geoid',
            'fema_date',
            // 'entry_id',
        ],
        numericColumns: [
            'year'
        ],
        floatColumns: [
            'total_verified_loss',
            'verified_loss_real_estate',
            'verified_loss_content',
            'total_approved_loan_amount',
            'approved_amount_real_estate',
            'approved_amount_content',
            'approved_amount_eidl',
        ],
        dateColumns: [
          'fema_date'
        ],
    }
}


module.exports = {
    tables
}