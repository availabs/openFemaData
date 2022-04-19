with t as (SELECT a.fips, geo.geom
           FROM severe_weather_new.fips_to_regions_and_surrounding_counties a
                    JOIN geo.tl_2017_tract geo
                         ON a.fips = geo.geoid
           WHERE length(fips) = 11)

UPDATE severe_weather_new.fips_to_regions_and_surrounding_counties dst
SET geom = t.geom
FROM t
WHERE dst.fips = t.fips