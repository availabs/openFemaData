-- SELECT *
--  FROM public.tmp_per_basis_data_zero_loss_detailed
--  where geoid = '48201' and nri_category='coastal';
with nri_normal as
(select 
           stcofips,
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
    sum(CFLD_hlrb), 
    sum(CWAV_hlrb), 
    sum(HRCN_hlrb),
    sum(HWAV_hlrb),
    sum(HAIL_hlrb), 
    sum(TRND_hlrb ), 
    sum(RFLD_hlrb),
    sum(LTNG_hlrb ), 
    sum(LNDS_hlrb), 
    sum(ISTM_hlrb ),
    sum(SWND_hlrb),
    sum(WFIR_hlrb ), 
    sum(WNTW_hlrb ), 
    sum(TSUN_hlrb ), 
    sum(AVLN_hlrb), 
    sum(VLCN_hlrb)
]) as nri_hlr_b,
    unnest(array[
    sum( CFLD_EXPB ), 
    sum( CWAV_EXPB ), 
    sum( HRCN_EXPB ),
    sum(HWAV_EXPB),
    sum(HAIL_EXPB  ), 
    sum( TRND_EXPB ), 
    sum( RFLD_EXPB ),
    sum(LTNG_EXPB  ), 
    sum(LNDS_EXPB ), 
    sum( ISTM_EXPB ),
    sum( SWND_EXPB  ),
    sum( WFIR_EXPB  ), 
    sum( WNTW_EXPB ), 
    sum( TSUN_EXPB), 
    sum( AVLN_EXPB ), 
    sum(VLCN_EXPB  )
]) as nri_exp_b,
           unnest(array[
    sum( CFLD_AFREQ),
    sum( CWAV_AFREQ), 
    sum( HRCN_AFREQ),
    sum( HWAV_AFREQ),
    sum( HAIL_AFREQ), 
    sum( TRND_AFREQ), 
    sum( RFLD_AFREQ),
    sum( LTNG_AFREQ), 
    sum( LNDS_AFREQ), 
    sum(ISTM_AFREQ),
    sum( SWND_AFREQ),
    sum( WFIR_AFREQ), 
    sum( WNTW_AFREQ), 
    sum(TSUN_AFREQ), 
    sum(AVLN_AFREQ), 
    sum( VLCN_AFREQ)
]) as nri_freq
FROM national_risk_index.nri_counties_november_2021 nri
group by stcofips
),
lr_by_county as
(SELECT a.nri_category,geoid,event_day_date, event_ids, disaster_number, num_events, swd_property_damage, nri_exp_b,  coalesce(swd_property_damage,0) / nri_exp_b as b_loss_ratio, swd_crop_damage
    FROM public.tmp_per_basis_data_zero_loss_detailed as a
    join nri_normal as b on a.geoid = b.stcofips and a.nri_category = b.nri_category
    where geoid = '48201' and a.nri_category='coastal')

select * from lr_by_county


--select geoid, avg(b_loss_ratio) from lr_by_county group by geoid


-- select * 
--  FROM public.tmp_per_basis_data_zero_loss_detailed_witout_event_type_mapping
--  where '1791,3294' = ANY(disaster_number)