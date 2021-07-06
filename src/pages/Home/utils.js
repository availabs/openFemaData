import {Switch} from '@headlessui/react'

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
        color: 'gold'
    }
}