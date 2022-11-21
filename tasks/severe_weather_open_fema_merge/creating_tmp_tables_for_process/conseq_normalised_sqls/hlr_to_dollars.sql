SELECT nri_category,
       ctype,
       CASE
           WHEN ctype = 'buildings'
               THEN sum(CASE
                            WHEN nri_category IN ('coastal')
                                THEN hlr * CFLD_EXPB  * CFLD_AFREQ
                            WHEN nri_category IN ('coldwave')
                                THEN hlr * CWAV_EXPB  * CWAV_AFREQ
                            WHEN nri_category IN ('hurricane')
                                THEN hlr * HRCN_EXPB  * HRCN_AFREQ
                            WHEN nri_category IN ('heatwave')
                                THEN hlr * HWAV_EXPB  * HWAV_AFREQ
                            WHEN nri_category IN ('hail')
                                THEN hlr * HAIL_EXPB  * HAIL_AFREQ
                            WHEN nri_category IN ('tornado')
                                THEN hlr * TRND_EXPB  * TRND_AFREQ
                            WHEN nri_category IN ('riverine')
                                THEN hlr * RFLD_EXPB  * RFLD_AFREQ
                            WHEN nri_category IN ('lightning')
                                THEN hlr * LTNG_EXPB  * LTNG_AFREQ
                            WHEN nri_category IN ('landslide')
                                THEN hlr * LNDS_EXPB  * LNDS_AFREQ
                            WHEN nri_category IN ('icestorm')
                                THEN hlr * ISTM_EXPB  * ISTM_AFREQ
                            WHEN nri_category IN ('wind')
                                THEN hlr * SWND_EXPB  * SWND_AFREQ
                            WHEN nri_category IN ('wildfire')
                                THEN (
                                      CASE WHEN geoid IN (select stcofips
                                                          FROM national_risk_index.nri_counties_november_2021
                                                          where wfir_hlrb = 0.4)
                                               THEN 0.4
                                           ELSE hlr
                                          END
                                      ) * WFIR_EXPB  * WFIR_AFREQ
                            WHEN nri_category IN ('winterweat')
                                THEN hlr * WNTW_EXPB  * WNTW_AFREQ
                            WHEN nri_category IN ('tsunami')
                                THEN hlr * TSUN_EXPB  * TSUN_AFREQ
                            WHEN nri_category IN ('avalanche')
                                THEN hlr * AVLN_EXPB  * AVLN_AFREQ
                            WHEN nri_category IN ('volcano')
                                THEN hlr * VLCN_EXPB  * VLCN_AFREQ
               END)
           WHEN ctype = 'crop'
               THEN sum(CASE
                            WHEN nri_category IN ('coldwave')
                                THEN hlr * CWAV_EXPA  * CWAV_AFREQ
                            WHEN nri_category IN ('drought')
                                THEN hlr * DRGT_EXPA  * DRGT_AFREQ
                            WHEN nri_category IN ('hurricane')
                                THEN hlr * HRCN_EXPA  * HRCN_AFREQ
                            WHEN nri_category IN ('heatwave')
                                THEN hlr * HWAV_EXPA  * HWAV_AFREQ
                            WHEN nri_category IN ('hail')
                                THEN hlr * HAIL_EXPA  * HAIL_AFREQ
                            WHEN nri_category IN ('tornado')
                                THEN hlr * TRND_EXPA  * TRND_AFREQ
                            WHEN nri_category IN ('riverine')
                                THEN hlr * RFLD_EXPA  * RFLD_AFREQ
                            WHEN nri_category IN ('wind')
                                THEN hlr * SWND_EXPA  * SWND_AFREQ
                            WHEN nri_category IN ('wildfire')
                                THEN hlr * WFIR_EXPA  * WFIR_AFREQ
                            WHEN nri_category IN ('winterweat')
                                THEN hlr * WNTW_EXPA  * WNTW_AFREQ
               END)
           WHEN ctype = 'population'
               THEN sum(CASE
                            WHEN nri_category IN ('coastal')
                                THEN hlr * CFLD_EXPPE  * CFLD_AFREQ
                            WHEN nri_category IN ('coldwave')
                                THEN hlr * CWAV_EXPPE  * CWAV_AFREQ
                            WHEN nri_category IN ('hurricane')
                                THEN hlr * HRCN_EXPPE  * HRCN_AFREQ
                            WHEN nri_category IN ('heatwave')
                                THEN hlr * HWAV_EXPPE  * HWAV_AFREQ
                            WHEN nri_category IN ('hail')
                                THEN hlr * HAIL_EXPPE  * HAIL_AFREQ
                            WHEN nri_category IN ('tornado')
                                THEN hlr * TRND_EXPPE  * TRND_AFREQ
                            WHEN nri_category IN ('riverine')
                                THEN hlr * RFLD_EXPPE  * RFLD_AFREQ
                            WHEN nri_category IN ('lightning')
                                THEN hlr * LTNG_EXPPE  * LTNG_AFREQ
                            WHEN nri_category IN ('landslide')
                                THEN hlr * LNDS_EXPPE  * LNDS_AFREQ
                            WHEN nri_category IN ('icestorm')
                                THEN hlr * ISTM_EXPPE  * ISTM_AFREQ
                            WHEN nri_category IN ('wind')
                                THEN hlr * SWND_EXPPE  * SWND_AFREQ
                            WHEN nri_category IN ('wildfire')
                                THEN hlr * WFIR_EXPPE  * WFIR_AFREQ
                            WHEN nri_category IN ('winterweat')
                                THEN hlr * WNTW_EXPPE  * WNTW_AFREQ
                            WHEN nri_category IN ('tsunami')
                                THEN hlr * TSUN_EXPPE  * TSUN_AFREQ
                            WHEN nri_category IN ('avalanche')
                                THEN hlr * AVLN_EXPPE  * AVLN_AFREQ
                            WHEN nri_category IN ('volcano')
                                THEN hlr * VLCN_EXPPE  * VLCN_AFREQ
               END)
           END avail,

       CASE
           WHEN ctype = 'buildings'
               THEN sum(CASE
                            WHEN nri_category IN ('coastal')
                                THEN cfld_hlrb * CFLD_EXPB  * CFLD_AFREQ
                            WHEN nri_category IN ('coldwave')
                                THEN cwav_hlrb * CWAV_EXPB  * CWAV_AFREQ
                            WHEN nri_category IN ('hurricane')
                                THEN hrcn_hlrb * HRCN_EXPB  * HRCN_AFREQ
                            WHEN nri_category IN ('heatwave')
                                THEN hwav_hlrb * HWAV_EXPB  * HWAV_AFREQ
                            WHEN nri_category IN ('hail')
                                THEN hail_hlrb * HAIL_EXPB  * HAIL_AFREQ
                            WHEN nri_category IN ('tornado')
                                THEN trnd_hlrb * TRND_EXPB  * TRND_AFREQ
                            WHEN nri_category IN ('riverine')
                                THEN rfld_hlrb * RFLD_EXPB  * RFLD_AFREQ
                            WHEN nri_category IN ('lightning')
                                THEN ltng_hlrb * LTNG_EXPB  * LTNG_AFREQ
                            WHEN nri_category IN ('landslide')
                                THEN lnds_hlrb * LNDS_EXPB  * LNDS_AFREQ
                            WHEN nri_category IN ('icestorm')
                                THEN istm_hlrb * ISTM_EXPB  * ISTM_AFREQ
                            WHEN nri_category IN ('wind')
                                THEN swnd_hlrb * SWND_EXPB  * SWND_AFREQ
                            WHEN nri_category IN ('wildfire')
                                THEN wfir_hlrb * WFIR_EXPB  * WFIR_AFREQ
                            WHEN nri_category IN ('winterweat')
                                THEN wntw_hlrb * WNTW_EXPB  * WNTW_AFREQ
                            WHEN nri_category IN ('tsunami')
                                THEN tsun_hlrb * TSUN_EXPB  * TSUN_AFREQ
                            WHEN nri_category IN ('avalanche')
                                THEN avln_hlrb * AVLN_EXPB  * AVLN_AFREQ
                            WHEN nri_category IN ('volcano')
                                THEN vlcn_hlrb * VLCN_EXPB  * VLCN_AFREQ
               END)
           WHEN ctype = 'crop'
               THEN sum(CASE
                            WHEN nri_category IN ('coldwave')
                                THEN cwav_hlra * CWAV_EXPA  * CWAV_AFREQ
                            WHEN nri_category IN ('drought')
                                THEN drgt_hlra * DRGT_EXPA  * DRGT_AFREQ
                            WHEN nri_category IN ('hurricane')
                                THEN hrcn_hlra * HRCN_EXPA  * HRCN_AFREQ
                            WHEN nri_category IN ('heatwave')
                                THEN hwav_hlra * HWAV_EXPA  * HWAV_AFREQ
                            WHEN nri_category IN ('hail')
                                THEN hail_hlra * HAIL_EXPA  * HAIL_AFREQ
                            WHEN nri_category IN ('tornado')
                                THEN trnd_hlra * TRND_EXPA  * TRND_AFREQ
                            WHEN nri_category IN ('riverine')
                                THEN rfld_hlra * RFLD_EXPA  * RFLD_AFREQ
                            WHEN nri_category IN ('wind')
                                THEN swnd_hlra * SWND_EXPA  * SWND_AFREQ
                            WHEN nri_category IN ('wildfire')
                                THEN wfir_hlra * WFIR_EXPA  * WFIR_AFREQ
                            WHEN nri_category IN ('winterweat')
                                THEN wntw_hlra * WNTW_EXPA  * WNTW_AFREQ
               END)
           WHEN ctype = 'population'
               THEN sum(CASE
                            WHEN nri_category IN ('coastal')
                                THEN cfld_hlrp * CFLD_EXPPE  * CFLD_AFREQ
                            WHEN nri_category IN ('coldwave')
                                THEN cwav_hlrp * CWAV_EXPPE  * CWAV_AFREQ
                            WHEN nri_category IN ('hurricane')
                                THEN hrcn_hlrp * HRCN_EXPPE  * HRCN_AFREQ
                            WHEN nri_category IN ('heatwave')
                                THEN hwav_hlrp * HWAV_EXPPE  * HWAV_AFREQ
                            WHEN nri_category IN ('hail')
                                THEN hail_hlrp * HAIL_EXPPE  * HAIL_AFREQ
                            WHEN nri_category IN ('tornado')
                                THEN trnd_hlrp * TRND_EXPPE  * TRND_AFREQ
                            WHEN nri_category IN ('riverine')
                                THEN rfld_hlrp * RFLD_EXPPE  * RFLD_AFREQ
                            WHEN nri_category IN ('lightning')
                                THEN ltng_hlrp * LTNG_EXPPE  * LTNG_AFREQ
                            WHEN nri_category IN ('landslide')
                                THEN lnds_hlrp * LNDS_EXPPE  * LNDS_AFREQ
                            WHEN nri_category IN ('icestorm')
                                THEN istm_hlrp * ISTM_EXPPE  * ISTM_AFREQ
                            WHEN nri_category IN ('wind')
                                THEN swnd_hlrp * SWND_EXPPE  * SWND_AFREQ
                            WHEN nri_category IN ('wildfire')
                                THEN wfir_hlrp * WFIR_EXPPE  * WFIR_AFREQ
                            WHEN nri_category IN ('winterweat')
                                THEN wntw_hlrp * WNTW_EXPPE  * WNTW_AFREQ
                            WHEN nri_category IN ('tsunami')
                                THEN tsun_hlrp * TSUN_EXPPE  * TSUN_AFREQ
                            WHEN nri_category IN ('avalanche')
                                THEN avln_hlrp * AVLN_EXPPE  * AVLN_AFREQ
                            WHEN nri_category IN ('volcano')
                                THEN vlcn_hlrp * VLCN_EXPPE  * VLCN_AFREQ
               END)
           END nri


FROM tmp_hlr
         JOIN national_risk_index.nri_counties_november_2021
              ON geoid = stcofips
GROUP BY 1, 2

ORDER BY 1, 2