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

---------

with merged as (
    select to_char(sum(swd_property_damage), '$ 999,999,999,999') swd_property_damage,
           to_char(sum(swd_crop_damage), '$ 999,999,999,999') swd_crop_damage,
           to_char(sum(fema_property_damage), '$ 999,999,999,999') fema_property_damage,
           to_char(sum(fema_crop_damage), '$ 999,999,999,999') fema_crop_damage,
           to_char(sum(fusion_property_damage), '$ 999,999,999,999') fusion_property_damage,
           to_char(sum(fusion_crop_damage), '$ 999,999,999,999') fusion_crop_damage,
           sum(
                       coalesce(deaths_direct::float,0) +
                       coalesce(deaths_indirect::float,0) +
                       (
                               (
                                       coalesce(injuries_direct::float,0) +
                                       coalesce(injuries_indirect::float,0)
                                   ) / 10
                           )
               ) * 7600000 population_merge
    from severe_weather_new.tmp_merged_data_v3
),
     swd_raw as (
         select to_char(sum(property_damage), '$ 999,999,999,999') raw_swd_property_damage,
                to_char(sum(crop_damage), '$ 999,999,999,999') raw_swd_crop_damage,
                sum(
                            coalesce(deaths_direct::float,0) +
                            coalesce(deaths_indirect::float,0) +
                            (
                                    (
                                            coalesce(injuries_direct::float,0) +
                                            coalesce(injuries_indirect::float,0)
                                        ) / 10
                                )
                    ) * 7600000 population_swd
         from severe_weather_new.details
         WHERE year >= 1996 and year <= 2019
           AND nri_category not in ('Dense Fog', 'Marine Dense Fog', 'Dense Smoke', 'Dust Devil', 'Dust Storm', 'Astronomical Low Tide', 'Northern Lights', 'OTHER')
           AND geoid is not null
     ),
     fema_raw as (
         SELECT to_char(sum(fema_property_damage), '$ 999,999,999,999') raw_fema_property_damage,
                to_char(sum(fema_crop_damage), '$ 999,999,999,999') raw_fema_crop_damage
         FROM open_fema_data.tmp_disaster_loss_summary_v2
     )

select *
from merged, swd_raw, fema_raw



------


with fusion as (select nri_category, ctype, count(1) num_records_fusion_pb, to_char(avg(damage), '$ 999,999,999,999') avg_damage_fusion_pb
                from tmp_pb_fusion
                where event_day_date is not null
                group by 1, 2
                order by 1, 2),
     swd_pb as (select nri_category, ctype, count(1) num_records_swd_pb, to_char(avg(damage), '$ 999,999,999,999') avg_damage_swd_pb
                from tmp_pb_for_doc
                where event_day_date is not null
                group by 1, 2
                order by 1, 2)

select *
from fusion
         join swd_pb
              using (nri_category, ctype)
