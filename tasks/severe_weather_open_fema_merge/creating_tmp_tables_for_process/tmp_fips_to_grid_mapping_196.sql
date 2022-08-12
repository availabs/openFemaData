CREATE OR replace FUNCTION generate_grid(bound_polygon geometry, grid_step numeric, srid integer default 4326)
    RETURNS table(id bigint, geom geometry)
    LANGUAGE plpgsql
AS $function$
DECLARE
    Xmin int;
    Xmax int;
    Ymax int;
    Ymin int;
    query_text text;
BEGIN
    Xmin := floor(ST_XMin(bound_polygon));
    Xmax := ceil(ST_XMax(bound_polygon));
    Ymin := floor(ST_YMin(bound_polygon));
    Ymax := ceil(ST_YMax(bound_polygon));

    query_text := 'select row_number() over() id, st_makeenvelope(s1, s2, s1+$5, s2+$5, $6) geom
    from generate_series($1, $2+$5, $5) s1, generate_series ($3, $4+$5, $5) s2';

    RETURN QUERY EXECUTE query_text using Xmin, Xmax, Ymin, Ymax, grid_step, srid;
END;
$function$
;

create table severe_weather_new.grid_196_new as
SELECT id, grid.geom
FROM (
         select id, geom from generate_grid(
                 (SELECT ST_Collect(ST_Simplify(geom, 0.1)) FROM geo.tl_2017_us_state where geoid not in ('11', '99', '72', '69', '60', '66', '78')),
                 2,
                 4326)
     ) grid
         JOIN (SELECT st_setsrid(ST_Collect(ST_Simplify(geom, 0.1)), 4326) geom FROM geo.tl_2017_us_state where geoid not in ('11', '99', '72', '69', '60', '66', '78')) area
              ON st_intersects(grid.geom, area.geom)

