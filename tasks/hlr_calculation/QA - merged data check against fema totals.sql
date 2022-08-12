-- select disaster_number, sum(fema_property_damage) 
-- from severe_weather_new.tmp_merged_data
-- where disaster_number = '4085'
-- group by 1


-- select 
--  disaster_number,  count(1),
--  to_char(sum(fema_property_damage), 'FM9,999,999,999,999') as fema,
--  sum(fema_property_damage)
-- from open_fema_data.tmp_disaster_loss_summary  
-- group by 1
-- order by 4 desc
-- limit 100


with fusion_summary_by_disaster as (
   SELECT
	a.disaster_number,
	a.geoid,
	count(1) as count,
	sum(a.fema_property_damage) as fema,
	sum(swd_property_damage) as swd
	-- sum(b.property_damage) / count(1) as swd_raw
	FROM  severe_weather_new.tmp_merged_data  as a
	-- join severe_weather_new.details as b
	-- on a.event_id = b.event_id
	group by 1,2
	order by 3 desc
)

-- select * from fusion_summary_by_disaster
-- limit 100

select a.disaster_number,
	sum(a.count),
	sum(a.fema),
	sum(b.fema_property_damage),
	sum(a.swd)
	
	from fusion_summary_by_disaster as a
  	join open_fema_data.disaster_declarations_summaries_v2
  		on a.disaster_number = disaster_declarations_summaries_v2.disaster_number::text
	 	and a.geoid = disaster_declarations_summaries_v2.fips_state_code || disaster_declarations_summaries_v2.fips_county_code
	
 	join open_fema_data.tmp_disaster_loss_summary as b
 		on a.disaster_number = b.disaster_number
		and a.geoid = b.geoid
	group by 1
	order by 3 desc
