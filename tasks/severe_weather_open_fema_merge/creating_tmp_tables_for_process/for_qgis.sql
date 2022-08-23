select a.*,
       CASE
           WHEN nri_category IN ('coastal')
               THEN hlr_b * CFLD_EXPB  * CFLD_AFREQ
           WHEN nri_category IN ('coldwave')
               THEN hlr_b * CWAV_EXPB  * CWAV_AFREQ
           WHEN nri_category IN ('hurricane')
               THEN hlr_b * HRCN_EXPB  * HRCN_AFREQ
           WHEN nri_category IN ('heatwave')
               THEN hlr_b * HWAV_EXPB  * HWAV_AFREQ
           WHEN nri_category IN ('hail')
               THEN hlr_b * HAIL_EXPB  * HAIL_AFREQ
           WHEN nri_category IN ('tornado')
               THEN hlr_b * TRND_EXPB  * TRND_AFREQ
           WHEN nri_category IN ('riverine')
               THEN hlr_b * RFLD_EXPB  * RFLD_AFREQ
           WHEN nri_category IN ('lightning')
               THEN hlr_b * LTNG_EXPB  * LTNG_AFREQ
           WHEN nri_category IN ('landslide')
               THEN hlr_b * LNDS_EXPB  * LNDS_AFREQ
           WHEN nri_category IN ('icestorm')
               THEN hlr_b * ISTM_EXPB  * ISTM_AFREQ
           WHEN nri_category IN ('wind')
               THEN hlr_b * SWND_EXPB  * SWND_AFREQ
           WHEN nri_category IN ('wildfire')
               THEN hlr_b * WFIR_EXPB  * WFIR_AFREQ
           WHEN nri_category IN ('winterweat')
               THEN hlr_b * WNTW_EXPB  * WNTW_AFREQ
           WHEN nri_category IN ('tsunami')
               THEN hlr_b * TSUN_EXPB  * TSUN_AFREQ
           WHEN nri_category IN ('avalanche')
               THEN hlr_b * AVLN_EXPB  * AVLN_AFREQ
           WHEN nri_category IN ('volcano')
               THEN hlr_b * VLCN_EXPB  * VLCN_AFREQ
           END swd_building,
       CASE
           WHEN nri_category IN ('coastal')
               THEN CFLD_HLRB * CFLD_EXPB  * CFLD_AFREQ
           WHEN nri_category IN ('coldwave')
               THEN CWAV_HLRB * CWAV_EXPB  * CWAV_AFREQ
           WHEN nri_category IN ('hurricane')
               THEN HRCN_HLRB * HRCN_EXPB  * HRCN_AFREQ
           WHEN nri_category IN ('heatwave')
               THEN HWAV_HLRB * HWAV_EXPB  * HWAV_AFREQ
           WHEN nri_category IN ('hail')
               THEN HAIL_HLRB * HAIL_EXPB  * HAIL_AFREQ
           WHEN nri_category IN ('tornado')
               THEN TRND_HLRB * TRND_EXPB  * TRND_AFREQ
           WHEN nri_category IN ('riverine')
               THEN RFLD_HLRB * RFLD_EXPB  * RFLD_AFREQ
           WHEN nri_category IN ('lightning')
               THEN LTNG_HLRB * LTNG_EXPB  * LTNG_AFREQ
           WHEN nri_category IN ('landslide')
               THEN LNDS_HLRB * LNDS_EXPB  * LNDS_AFREQ
           WHEN nri_category IN ('icestorm')
               THEN ISTM_HLRB * ISTM_EXPB  * ISTM_AFREQ
           WHEN nri_category IN ('wind')
               THEN SWND_HLRB * SWND_EXPB  * SWND_AFREQ
           WHEN nri_category IN ('wildfire')
               THEN WFIR_HLRB * WFIR_EXPB  * WFIR_AFREQ
           WHEN nri_category IN ('winterweat')
               THEN WNTW_HLRB * WNTW_EXPB  * WNTW_AFREQ
           WHEN nri_category IN ('tsunami')
               THEN TSUN_HLRB * TSUN_EXPB  * TSUN_AFREQ
           WHEN nri_category IN ('avalanche')
               THEN AVLN_HLRB * AVLN_EXPB  * AVLN_AFREQ
           WHEN nri_category IN ('volcano')
               THEN VLCN_HLRB * VLCN_EXPB  * VLCN_AFREQ
           END nri_building,
       b.geom
into tmp_hlr_geom_for_qgis
from tmp_hlr_swd_wt a
         join geo.tl_2017_us_county_4326 b
              on a.geoid = b.geoid
         join national_risk_index.nri_counties_november_2021 nri
              on a.geoid = nri.stcofips
