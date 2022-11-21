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
SELECT  nri_category, count(1) swd_total_events,  
    sum(
        case 
            when coalesce(property_damage,0) + coalesce(crop_damage,0) + coalesce(injuries_direct,0) + coalesce(injuries_indirect,0) + coalesce(deaths_direct,0) + coalesce(deaths_indirect,0) > 0 then 1
            else 0
        end
    ) as swd_nonzero_events,
    
    sum(property_damage) as loss_b,
    sum(crop_damage) as loss_c,
	sum(
                   coalesce(deaths_direct::float,0) +
                   coalesce(deaths_indirect::float,0) +
                   (
                       (
                           coalesce(injuries_direct::float,0) +
                           coalesce(injuries_indirect::float,0)
                           ) / 10
                       )
    ) as loss_p,
	sum(
                   coalesce(deaths_direct::float,0) +
                   coalesce(deaths_indirect::float,0) +
                   (
                       (
                           coalesce(injuries_direct::float,0) +
                           coalesce(injuries_indirect::float,0)
                           ) / 10
                       )
    ) * 7600000 as loss_pe
	FROM severe_weather_new.details
    where (year >= 1996 and year <=2019)
    and event_type_formatted not in ('OTHER','Marine Dense Fog', 'Dense Fog', 'Astronomical Low Tide','Dust Devil','Dense Smoke','Dust Storm', 'Northern Lights')
    and geoid is not null
    group by 1
),
pb_swd_loss_comp as (
select a.nri_category, 
		--a.loss_p as swd_loss_p, b.loss_p as pb_loss_p,
		a.loss_b - b.loss_b as b_diff,
		a.loss_c - b.loss_c as c_diff,
		a.loss_p - b.loss_p as p_diff,
		a.loss_pe - b.loss_pe as pe_diff
	from swd_summary as a
	join per_basis_summary as b 
	on a.nri_category = b.nri_category 
) 
-- select nri_category, 
-- 	num_b, num_b_nonzero,
-- 	num_c, num_c_nonzero,
-- 	num_p, num_p_nonzero
-- 	from per_basis_summary

select * from public.tmp_pb_normalised_pop_v2 limit 10