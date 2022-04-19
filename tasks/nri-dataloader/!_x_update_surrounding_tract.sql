with t as (SELECT fips, geom FROM severe_weather_new.fips_to_regions_and_surrounding_counties where length(fips) = 11),
     s as (
         SELECT src.fips, array_agg(dst.fips) sc
         FROM t src
                  JOIN t dst
                       ON NOT ST_Disjoint(src.geom, dst.geom)
                           AND src.fips != dst.fips
         GROUP BY 1
     )
UPDATE severe_weather_new.fips_to_regions_and_surrounding_counties dst
SET surrounding_counties = s.sc
FROM s
WHERE s.fips = dst.fips;

-- psql -U postgres -h mars.availabs.org -d hazard_mitigation -f 7_update_surrounding_tract.sql