export const DISASTER_ATTRIBUTES = [
    "disaster_number",
    "name",
    "total_cost",
    "declaration_date",
    "year",
    "geoid",
    "disaster_type",
    "total_number_ia_approved",
    'total_amount_ihp_approved',
    'total_amount_ha_approved',
    "total_amount_ona_approved",
    'total_obligated_amount_pa',
    'total_obligated_amount_cat_ab',
    'total_obligated_amount_cat_c2g',
    'pa_load_date',
    'ia_load_date',
    'total_obligated_amount_hmgp',
    'last_refresh'
];

export const DISASTER_DECLARATIONS_ATTRIBUTES = [
    'declaration_title',
    'declaration_request_number',
    'state',
    'declaration_type',
    'declaration_date',
    'incident_begin_date',
    'incident_end_date',
    'disaster_number',
    'fips_state_code',
    'fips_county_code',
    'designated_area'
];

export const SUMMARY_ATTRIBUTES = [
    "num_valid_registrations",
    "ihp_amount",
    "ha_amount",
    "ona_amount",
    "rpfvl",
    "ppfvl",
    "fip_amount",
    "rental_assistance_amount",
    "repair_amount",
    "replacement_amount",
    "personal_property_amount",
    "flood_damage_amount",
    "foundation_damage_amount",
    "roof_damage_amount",
];

export const groups = {
    'Total': {
        attributes: ["ihp_amount"],
        color: '#333'
    },
    'IHP': {
        attributes: ["ha_amount", "ona_amount"],
        color: '#ecb074'
    },
    'FEMA determined disaster values': {
        attributes: ["rpfvl", "ppfvl"],
        color: '#a4de57'
    },

    'FEMA determined disaster value ': {
        attributes: ["flood_damage_amount","foundation_damage_amount", "roof_damage_amount"],
        color: '#7aade3'
    },
    'Assistance given': {
        attributes: ["fip_amount", "rental_assistance_amount", "repair_amount", "replacement_amount", "personal_property_amount"],
        color: '#f1e4a5'
    }
}


/*
    There are two types of column configs:

    1. {title: 'title1', type: 'operation::summaryAttr', attrs: ['Assistance given', 'personal_property_amount'], operation: '-'}
    2. {
        title: 'Title 1',
        type: 'operation',
        disasterAttr: 'total_amount_ha_approved',
        summaryAttr: 'personal_property_amount',
        operation: '/'}

    #1 can be nested in #2:
    {
        title: 'Title 1',
        type: 'operation',
        disasterAttr: 'total_amount_ha_approved',
        summaryAttr: {type: 'operation::summaryAttr', attrs: ['Assistance given', 'personal_property_amount'], operation: '-'},
        operation: '/'}
*/
export const compareGroups = [
    {
        title: 'Title 1',
        type: 'operation',
        disasterAttr: 'total_amount_ha_approved',
        summaryAttr: {type: 'operation::summaryAttr', attrs: ['Assistance given', 'personal_property_amount'], operation: '-'},
        operation: '/'},

    {
        // title: 'Title 1',
        type: 'operation',
        disasterAttr: 'total_amount_ona_approved',
        summaryAttr: 'personal_property_amount',
        operation: '/'},

    {
        type: 'operation',
        disasterAttr: 'total_amount_ihp_approved',
        summaryAttr: {type: 'operation::summaryAttr', attrs: ['rpfvl', 'ppfvl'], operation: '+'},
        sequence: 'summaryAttr::disasterAttr',
        operation: '/'},
]