with
    county_geo as (
        select st_setsrid(geom, 4326) geom, geoid
        from geo.tl_2017_us_county
    ),
    t as (
        SELECT fips, grid.id, ST_Area(ST_INTERSECTION(grid.cell, county_geo.geom)) covered_area,
               rank() over (partition by fips order by ST_Area(ST_INTERSECTION(grid.cell, county_geo.geom)) desc)
        FROM severe_weather_new.fips_to_regions_and_surrounding_counties  county
                 JOIN county_geo
                      ON fips = county_geo.geoid
                 JOIN tmp_grid_new grid
                      ON NOT st_disjoint(county_geo.geom, grid.cell)
        order by 1, 3 desc)

select * into tmp_fips_to_grid_mapping_196_newer from t