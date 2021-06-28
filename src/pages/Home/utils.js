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
    'IHP': {
        attributes: ["ihp_amount", "ha_amount", "ona_amount"],
        color: '#ecb074'
    },
    'FEMA determined disaster values': {
        attributes: ["rpfvl", "ppfvl"],
        color: '#a4de57'
    },

    'FEMA determined disaster value by Flood (real + personal)': {
        attributes: ["flood_damage_amount"],
        color: '#7aade3'
    },
    'FEMA determined specific real damages': {
        attributes: ["foundation_damage_amount", "roof_damage_amount"],
        color: '#e88f8f'
    },
    'Assistance given': {
        attributes: ["fip_amount", "rental_assistance_amount", "repair_amount", "replacement_amount", "personal_property_amount"],
        color: '#f1e4a5'
    }
}

export const Toggle = (enabled, setEnabled) => {

    return (
        <Switch.Group as="div" className="flex items-center float-right">
            <Switch
                checked={enabled}
                onChange={setEnabled}
                className={
                    `${enabled ? `bg-indigo-600` : `bg-gray-200`} relative inline-flex flex-shrink-0 h-6 w-11 border-2 border-transparent rounded-full cursor-pointer transition-colors ease-in-out duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500`
                }
            >
        <span
            aria-hidden="true"
            className={
                `${enabled ? `translate-x-5` : `translate-x-0`} pointer-events-none inline-block h-5 w-5 rounded-full bg-white shadow transform ring-0 transition ease-in-out duration-200`
            }
        />
            </Switch>
            <Switch.Label as="span" className="ml-3">
                <span className="text-sm font-medium text-gray-900">View Grouped</span>
            </Switch.Label>
        </Switch.Group>
    )
}