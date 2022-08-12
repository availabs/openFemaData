SELECT geoid, region, surrounding, nri_category, wt_n_original, wt_n, wt_r, wt_c, wt_s, hlr_b,
       to_char(swd_raw_total, 'FM9,999,999,999') swd_raw_total,
       to_char(swd_raw_num_events, 'FM9,999,999,999') swd_raw_num_events,
       to_char(our_total, 'FM9,999,999,999') our_total,
       to_char(nri_total, 'FM9,999,999,999') nri_total,
       round(percent_diff_total::numeric, 2) percent_diff_total
FROM public.tmp_full_data_table
where swd_raw_total = 0 and percent_diff_total is not null
order by percent_diff_total desc