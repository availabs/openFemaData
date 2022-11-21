with per_basis_summary as (
	select nri_category, 
		sum(case when ctype = 'buildings' then 1 else 0 end) as num_b,
		sum(case when ctype = 'buildings' and damage > 0 then 1 else 0 end) as num_b_nonzero,	
		sum(case when ctype = 'population' then 1 else 0 end) as num_p,
		sum(case when ctype = 'population' and damage > 0 then 1 else 0 end) as num_p_nonzero,
		sum(case when ctype = 'crop' then 1 else 0 end) as num_c,
	    sum(case when ctype = 'crop' and damage > 0 then 1 else 0 end) as num_c_nonzero,
		sum(case when ctype = 'buildings' then damage else 0 end) as loss_b,
		sum(case when ctype = 'population' then damage else 0 end) as loss_pe,
		sum(case when ctype = 'crop' then damage else 0 end) as loss_c,
		round((sum(case when ctype = 'population' then damage else 0 end)/7600000)::numeric,1) as loss_p
	from public.tmp_pb_normalised_pop_v2
	group by 1
),
swd_summary as (
SELECT  nri_category, count(1),  
    sum(
        case 
            when coalesce(property_damage,0) + coalesce(crop_damage,0) + coalesce(injuries_direct,0) + coalesce(injuries_indirect,0) + coalesce(deaths_direct,0) + coalesce(deaths_indirect,0) > 0 then 1
            else 0
        end
    ) as swd_events,
    
    sum(property_damage) as property_damage,
    sum(crop_damage) as crop_damage
    FROM severe_weather_new.details
    where (year >= 1996 and year <=2019)
    and event_type_formatted not in ('OTHER','Marine Dense Fog', 'Dense Fog', 'Astronomical Low Tide','Dust Devil','Dense Smoke','Dust Storm', 'Northern Lights')
    and geoid is not null
    group by 1
), nri_summary as (
    select 
unnest(array['coastal', 'coldwave', 'hurricane',  'heatwave', 'hail','tornado', 'riverine', 'lightning','landslide',  'icestorm', 
 'wind', 'wildfire',  'winterweat', 'tsunami','avalanche',  'volcano'
                ]) as nri_category,
unnest(array[
    sum(CFLD_hlrb * CFLD_EXPB  * CFLD_AFREQ), 
    sum(CWAV_hlrb * CWAV_EXPB  * CWAV_AFREQ), 
    sum(HRCN_hlrb * HRCN_EXPB  * HRCN_AFREQ),
    sum(HWAV_hlrb * HWAV_EXPB  * HWAV_AFREQ),
    sum(HAIL_hlrb * HAIL_EXPB  * HAIL_AFREQ), 
    sum(TRND_hlrb * TRND_EXPB  * TRND_AFREQ), 
    sum(RFLD_hlrb * RFLD_EXPB  * RFLD_AFREQ),
    sum(LTNG_hlrb * LTNG_EXPB  * LTNG_AFREQ), 
    sum(LNDS_hlrb * LNDS_EXPB  * LNDS_AFREQ), 
    sum(ISTM_hlrb * ISTM_EXPB  * ISTM_AFREQ),
    sum(SWND_hlrb * SWND_EXPB  * SWND_AFREQ),
    sum(WFIR_hlrb * WFIR_EXPB  * WFIR_AFREQ), 
    sum(WNTW_hlrb * WNTW_EXPB  * WNTW_AFREQ), 
    sum(TSUN_hlrb * TSUN_EXPB  * TSUN_AFREQ), 
    sum(AVLN_hlrb * AVLN_EXPB  * AVLN_AFREQ), 
    sum(VLCN_hlrb * VLCN_EXPB  * VLCN_AFREQ)
]) as nri_property,
unnest(array[
    sum(0), 
    sum(CWAV_hlra * CWAV_EXPA  * CWAV_AFREQ), 
    sum(HRCN_hlra * HRCN_EXPA  * HRCN_AFREQ),
    sum(HWAV_hlra * HWAV_EXPA  * HWAV_AFREQ),
    sum(HAIL_hlra * HAIL_EXPA  * HAIL_AFREQ), 
    sum(TRND_hlra * TRND_EXPA  * TRND_AFREQ), 
    sum(RFLD_hlra * RFLD_EXPA  * RFLD_AFREQ),
    sum(0), 
    sum(0), 
    sum(0),
    sum(SWND_hlra * SWND_EXPA  * SWND_AFREQ),
    sum(WFIR_hlra * WFIR_EXPA  * WFIR_AFREQ), 
    sum(WNTW_hlra * WNTW_EXPA  * WNTW_AFREQ), 
    sum(0), 
    sum(0), 
    sum(0)
]) as nri_crop,
    unnest(array[
    sum(CFLD_hlrp * CFLD_EXPPE  * CFLD_AFREQ), 
    sum(CWAV_hlrp * CWAV_EXPPE * CWAV_AFREQ), 
    sum(HRCN_hlrp * HRCN_EXPPE  * HRCN_AFREQ),
    sum(HWAV_hlrp * HWAV_EXPPE  * HWAV_AFREQ),
    sum(HAIL_hlrp * HAIL_EXPPE  * HAIL_AFREQ), 
    sum(TRND_hlrp * TRND_EXPPE  * TRND_AFREQ), 
    sum(RFLD_hlrp * RFLD_EXPPE  * RFLD_AFREQ),
    sum(LTNG_hlrp * LTNG_EXPPE  * LTNG_AFREQ), 
    sum(LNDS_hlrp * LNDS_EXPPE  * LNDS_AFREQ), 
    sum(ISTM_hlrp * ISTM_EXPPE  * ISTM_AFREQ),
    sum(SWND_hlrp * SWND_EXPPE  * SWND_AFREQ),
    sum(WFIR_hlrp * WFIR_EXPPE  * WFIR_AFREQ), 
    sum(WNTW_hlrp * WNTW_EXPPE  * WNTW_AFREQ), 
    sum(TSUN_hlrp * TSUN_EXPPE  * TSUN_AFREQ), 
    sum(AVLN_hlrp * AVLN_EXPPE  * AVLN_AFREQ), 
    sum(VLCN_hlrp * VLCN_EXPPE  * VLCN_AFREQ)
]) as nri_pop
FROM national_risk_index.nri_counties_november_2021 nri
),
hlr_summary as (
    SELECT nri_category,
       sum(CASE
               WHEN nri_category IN ('coastal') and ctype = 'buildings'
                   THEN hlr * CFLD_EXPB  * CFLD_AFREQ
               WHEN nri_category IN ('coldwave') and ctype = 'buildings'
                   THEN hlr * CWAV_EXPB  * CWAV_AFREQ
               WHEN nri_category IN ('drought') and ctype = 'buildings'
                   THEN hlr * CWAV_EXPB  * CWAV_AFREQ
               WHEN nri_category IN ('hurricane') and ctype = 'buildings'
                   THEN hlr * HRCN_EXPB  * HRCN_AFREQ
               WHEN nri_category IN ('heatwave') and ctype = 'buildings'
                   THEN hlr * HWAV_EXPB  * HWAV_AFREQ
               WHEN nri_category IN ('hail') and ctype = 'buildings'
                   THEN hlr * HAIL_EXPB  * HAIL_AFREQ
               WHEN nri_category IN ('tornado') and ctype = 'buildings'
                   THEN hlr * TRND_EXPB  * TRND_AFREQ
               WHEN nri_category IN ('riverine') and ctype = 'buildings'
                   THEN hlr * RFLD_EXPB  * RFLD_AFREQ
               WHEN nri_category IN ('lightning') and ctype = 'buildings'
                   THEN hlr * LTNG_EXPB  * LTNG_AFREQ
               WHEN nri_category IN ('landslide') and ctype = 'buildings'
                   THEN hlr * LNDS_EXPB  * LNDS_AFREQ
               WHEN nri_category IN ('icestorm') and ctype = 'buildings'
                   THEN hlr * ISTM_EXPB  * ISTM_AFREQ
               WHEN nri_category IN ('wind') and ctype = 'buildings'
                   THEN hlr * SWND_EXPB  * SWND_AFREQ
               WHEN nri_category IN ('wildfire') and ctype = 'buildings'
                   THEN hlr * WFIR_EXPB  * WFIR_AFREQ
               WHEN nri_category IN ('winterweat') and ctype = 'buildings'
                   THEN hlr * WNTW_EXPB  * WNTW_AFREQ
               WHEN nri_category IN ('tsunami') and ctype = 'buildings'
                   THEN hlr * TSUN_EXPB  * TSUN_AFREQ
               WHEN nri_category IN ('avalanche') and ctype = 'buildings'
                   THEN hlr * AVLN_EXPB  * AVLN_AFREQ
               WHEN nri_category IN ('volcano') and ctype = 'buildings'
                   THEN hlr * VLCN_EXPB  * VLCN_AFREQ
           END) swd_building,

       sum(CASE
               WHEN nri_category IN ('coldwave') and ctype = 'crop'
                   THEN hlr * CWAV_EXPA  * CWAV_AFREQ
               WHEN nri_category IN ('drought') and ctype = 'crop'
                   THEN hlr * CWAV_EXPA  * CWAV_AFREQ
               WHEN nri_category IN ('hurricane') and ctype = 'crop'
                   THEN hlr * HRCN_EXPA  * HRCN_AFREQ
               WHEN nri_category IN ('heatwave') and ctype = 'crop'
                   THEN hlr * HWAV_EXPA  * HWAV_AFREQ
               WHEN nri_category IN ('hail') and ctype = 'crop'
                   THEN hlr * HAIL_EXPA  * HAIL_AFREQ
               WHEN nri_category IN ('tornado') and ctype = 'crop'
                   THEN hlr * TRND_EXPA  * TRND_AFREQ
               WHEN nri_category IN ('riverine') and ctype = 'crop'
                   THEN hlr * RFLD_EXPA  * RFLD_AFREQ
               WHEN nri_category IN ('wind') and ctype = 'crop'
                   THEN hlr * SWND_EXPA  * SWND_AFREQ
               WHEN nri_category IN ('wildfire') and ctype = 'crop'
                   THEN hlr * WFIR_EXPA  * WFIR_AFREQ
               WHEN nri_category IN ('winterweat') and ctype = 'crop'
                   THEN hlr * WNTW_EXPA  * WNTW_AFREQ
           END) swd_crop,
           sum(CASE
                      WHEN nri_category IN ('coastal') and ctype = 'population'
                          THEN hlr * CFLD_EXPPE  * CFLD_AFREQ
                      WHEN nri_category IN ('coldwave') and ctype = 'population'
                          THEN hlr * CWAV_EXPPE  * CWAV_AFREQ 
                      WHEN nri_category IN ('drought') and ctype = 'population'
                          THEN hlr * CWAV_EXPPE  * CWAV_AFREQ
                      WHEN nri_category IN ('hurricane') and ctype = 'population'
                          THEN hlr * HRCN_EXPPE  * HRCN_AFREQ
                      WHEN nri_category IN ('heatwave') and ctype = 'population'
                          THEN hlr * HWAV_EXPPE  * HWAV_AFREQ
                      WHEN nri_category IN ('hail') and ctype = 'population'
                          THEN hlr * HAIL_EXPPE  * HAIL_AFREQ
                      WHEN nri_category IN ('tornado') and ctype = 'population'
                          THEN hlr * TRND_EXPPE  * TRND_AFREQ
                      WHEN nri_category IN ('riverine') and ctype = 'population'
                          THEN hlr * RFLD_EXPPE  * RFLD_AFREQ
                      WHEN nri_category IN ('lightning') and ctype = 'population'
                          THEN hlr * LTNG_EXPPE  * LTNG_AFREQ
                      WHEN nri_category IN ('landslide') and ctype = 'population'
                          THEN hlr * LNDS_EXPPE  * LNDS_AFREQ
                      WHEN nri_category IN ('icestorm') and ctype = 'population'
                          THEN hlr * ISTM_EXPPE  * ISTM_AFREQ
                      WHEN nri_category IN ('wind') and ctype = 'population'
                          THEN hlr * SWND_EXPPE  * SWND_AFREQ
                      WHEN nri_category IN ('wildfire') and ctype = 'population'
                          THEN hlr * WFIR_EXPPE  * WFIR_AFREQ
                      WHEN nri_category IN ('winterweat') and ctype = 'population'
                          THEN hlr * WNTW_EXPPE  * WNTW_AFREQ
                      WHEN nri_category IN ('tsunami') and ctype = 'population'
                          THEN hlr * TSUN_EXPPE  * TSUN_AFREQ
                      WHEN nri_category IN ('avalanche') and ctype = 'population'
                          THEN hlr * AVLN_EXPPE  * AVLN_AFREQ
                      WHEN nri_category IN ('volcano') and ctype = 'population'
                          THEN hlr * VLCN_EXPPE  * VLCN_AFREQ
                  END) swd_pop
FROM public.tmp_hlr_normalised_pop_v2
         JOIN national_risk_index.nri_counties_november_2021
              ON geoid = stcofips
GROUP BY nri_category

ORDER BY nri_category
)

-- select * from hlr_summary

select a.nri_category, 
--     ((per_basis_property-property_damage) / nullif(property_damage,0)) * 100 as property_damage_ratio,
--     ((per_basis_crop - crop_damage) / nullif(crop_damage,0)) * 100 as crop_damage_ratio,
    round(((property_damage / 24)/1000000000),4) as swd_annual,
    --per_basis_property / 24 as per_basis_year,
    round(((d.swd_building/1000000000)::numeric),4) as avail_b,
    round(((c.nri_property/1000000000)::numeric),4) as nri_b,
    round(((coalesce(d.swd_crop,0)/1000000000)::numeric),4) as avail_c,
    round(((c.nri_crop/1000000000)::numeric),4) as nri_c,
    round(((coalesce(d.swd_pop,0)/1000000000)::numeric),4) as avail_p,
    round(((c.nri_pop/1000000000)::numeric),4) as nri_p,
    ((( (property_damage / 24) - nri_property) / nullif((c.nri_property),0)) * 100)::int as nri_swd_ratio,
    ((( (d.swd_building) - nri_property) / nullif((c.nri_property),0)) * 100)::int as nri_hlr_ratio
from swd_summary as a
join per_basis_summary as b on a.nri_category = b.nri_category
join nri_summary  as c on a.nri_category = c.nri_category
join hlr_summary as d on a.nri_category = d.nri_category
order by nri_category asc