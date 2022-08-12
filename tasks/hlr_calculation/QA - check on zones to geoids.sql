with states as (
            SELECT id, geoid, stusps, name
            FROM geo.tl_2017_us_state
        ),
        zone_to_county_enriched as (
            select zone, state, state_zone, stusps, states.geoid, county, lpad(fips::text, 5, '0') fips
            from severe_weather.zone_to_county
            JOIN states
            ON states.stusps = state
            order by 1, 2, 3
        ),
		cz_zone_events as 
        (
		select
        cz_fips d_cz_fips, d.state d_state, state_fips d_state_fips, cz_name d_zone_name,
        zone ztc_zone, ztc.state ztc_state, county ztc_county, lpad(fips::text, 5, '0') ztc_fips, d.geoid, d.tmp_geoid,
		event_type_formatted, coalesce(property_damage,0) as property_damage,
        case when lpad(fips::text, 5, '0') = d.geoid then 1 else 0 end
        from severe_weather_new.details d
        	JOIN zone_to_county_enriched ztc
        	on d.cz_fips = ztc.zone
        	AND LPAD(state_fips::TEXT, 2, '0') = ztc.geoid
        	AND lower(cz_name) like '%' || lower(county) || '%'
        	where cz_type = 'Z' and begin_lat = '0' -- and lpad(fips::text, 5, '0') != d.geoid
        	order by 1, 2
		),
	details_sample as (
select * from  severe_weather_new.details
where event_id = ANY('{648138,922726,922726,111052,929486,858288,898392,648138,858288,929486,922725,111052,929484,922725,788675,929484,111033,922726,111052,929486,858288,648138,111015,923443,898392,111015,111033,922725,929484,788675,923443,788675,898392,923443,111033,111015}'::integer[])
),

-- select event_id, d.geoid,  lpad(z.fips::text, 5, '0') from details_sample  as d
--         join zone_to_county_enriched z
--         on z.zone = d.cz_fips
-- 		and LPAD(state_fips::TEXT, 2, '0') = z.geoid
--         AND begin_lat = '0'
--         AND cz_type = 'Z'
		
-- select * from cz_zone_events limit 100
zone_matching as (
select state_zone, event_type_formatted, array_agg(distinct fips) as fips_list, sum(coalesce(d.property_damage,0)),  array_agg(distinct d.geoid) as geoids,  count(1)
 from zone_to_county_enriched as ztc
 join severe_weather_new.details as d
 on d.cz_fips = ztc.zone and LPAD(state_fips::TEXT, 2, '0') = ztc.geoid
 where d.cz_type = 'Z' and d.begin_lat = '0'
 
 group by 1,2
 order by 4 desc
)

select array_length(fips_list,1), * from zone_matching
where array_length(fips_list,1) > 1 
order by 5 desc

 
 

	
	
	
--  select d_state || d_cz_fips, event_type_formatted, sum(property_damage), count(1)
--  	from cz_zone_events
-- 	group by 1,2
-- 	order by 3 desc




