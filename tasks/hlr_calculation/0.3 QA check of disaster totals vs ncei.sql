SELECT a.disaster_number,
	string_agg(distinct b.declaration_title || '-' || b.state, ',' ) as declaration_title,
	to_char(sum(fema_property_damage), 'FM9,999,999,999,999') as fema,
	to_char(sum(swd_property_damage), 'FM9,999,999,999,999') as swd,
	to_char(coalesce(sum(fema_property_damage),0) - coalesce(sum(swd_property_damage),0), 'FM999,999,999,999') as diff,
	coalesce(sum(fema_property_damage) - sum(swd_property_damage),0)
	FROM severe_weather_new.tmp_merged_data_updated_fema_data as a
	join open_fema_data.disaster_declarations_summaries_v2 as b
	on a.disaster_number = b.disaster_number::text
	and a.geoid = b.fips_state_code || b.fips_county_code
	group by 1
	order by 6 desc;