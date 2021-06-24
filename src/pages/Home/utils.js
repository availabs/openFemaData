import { format, /*precisionPrefix, formatPrefix*/}  from 'd3-format'

export const DISASTER_ATTRIBUTES= [
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


export function fnum(x, withDollar=true, roundUnder10K=true) {
    if(isNaN(x)) return x;

    if(x < 9999 && !roundUnder10K) {
        const frmt = format(withDollar ? "$,.0f" : ",.0f")
        return frmt(x);
    }
    if (x > 999 && x < 9999 && roundUnder10K) {
        const frmt = format(withDollar ? "$,.0f" : ",.0f")
        return frmt(x/1000) + "K";
    }

    if(x < 1000000) {
        const frmt = format(withDollar ? "$,.0f" : ",.0f")
        return frmt(x/1000) + "K";
    }
    if( x < 10000000) {
        const frmt = format(withDollar ? "$,.0f" : ",.0f")
        return frmt(x/1000000) + "M";
    }

    if(x < 1000000000) {
        const frmt = format(withDollar ? "$,.1f" : ",.1f")
        return frmt(x/1000000) + "M";
    }

    if(x < 1000000000000) {
        const frmt = format(withDollar ? "$,.1f" : ",.1f")
        return frmt(x/1000000000) + "B";    
    }

    return "$1T+";
}