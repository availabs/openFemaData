with t as (SELECT fips, grid.id, ST_Area(ST_INTERSECTION(grid.geom, county.geom)) covered_area,
                  rank() over (partition by fips order by ST_Area(ST_INTERSECTION(grid.geom, county.geom)) desc)
           FROM severe_weather_new.fips_to_regions_and_surrounding_counties county
                    JOIN severe_weather_new.grid
                         ON NOT st_disjoint(county.geom, grid.geom)
                             and length(county.fips) = 5
           order by 1, 3 desc)

UPDATE severe_weather_new.fips_to_regions_and_surrounding_counties dst
SET surrounding_counties = t.id
FROM t
WHERE dst.fips = t.fips
  and t.rank = 1



-- SELECT UpdateGeometrySRID('severe_weather_new', 'fips_to_regions_and_surrounding_counties', 'geom', 4326);