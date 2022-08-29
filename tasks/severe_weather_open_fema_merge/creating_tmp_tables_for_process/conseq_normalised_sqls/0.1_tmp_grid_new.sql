DROP FUNCTION makegrid_2d(geometry,integer,integer);
CREATE OR REPLACE FUNCTION public.makegrid_2d (
    bound_polygon public.geometry,
    width_step integer,
    height_step integer
)
    RETURNS public.geometry AS
$body$
DECLARE
    Xmin DOUBLE PRECISION;
    Xmax DOUBLE PRECISION;
    Ymax DOUBLE PRECISION;
    X DOUBLE PRECISION;
    Y DOUBLE PRECISION;
    NextX DOUBLE PRECISION;
    NextY DOUBLE PRECISION;
    CPoint public.geometry;
    sectors public.geometry[];
    i INTEGER;
    SRID INTEGER;
BEGIN
    Xmin := ST_XMin(bound_polygon);
    Xmax := ST_XMax(bound_polygon);
    Ymax := ST_YMax(bound_polygon);
    SRID := ST_SRID(bound_polygon);

    Y := ST_YMin(bound_polygon); --current sector's corner coordinate
    i := -1;
    <<yloop>>
    LOOP
        IF (Y > Ymax) THEN
            EXIT;
        END IF;

        X := Xmin;
        <<xloop>>
        LOOP
            IF (X > Xmax) THEN
                EXIT;
            END IF;

            CPoint := ST_SetSRID(ST_MakePoint(X, Y), SRID);
            NextX := ST_X(ST_Project(CPoint, $2, radians(90))::geometry);
            NextY := ST_Y(ST_Project(CPoint, $3, radians(0))::geometry);

            i := i + 1;
            sectors[i] := ST_MakeEnvelope(X, Y, NextX, NextY, SRID);

            X := NextX;
        END LOOP xloop;
        CPoint := ST_SetSRID(ST_MakePoint(X, Y), SRID);
        NextY := ST_Y(ST_Project(CPoint, $3, radians(0))::geometry);
        Y := NextY;
    END LOOP yloop;

    RETURN ST_Collect(sectors);
END;
$body$
    LANGUAGE 'plpgsql';



-- SELECT row_number() OVER() id, cell FROM
-- (SELECT (
-- ST_Dump(makegrid_2d(
-- 	, -- WGS84 SRID
--  196000) -- cell step in meters
-- )).geom AS cell) AS q_grid

with grid as (
    SELECT cell
    FROM (
             SELECT (
                        ST_Dump(
                                makegrid_2d(
                                        (
                                            SELECT ST_Collect(ST_Simplify(st_setsrid(geom, 4326), 0.1)) FROM geo.tl_2017_us_state
                                            where geoid not in ('11', '99', '72', '69', '60', '66', '78')
                                              and geoid not in ('02', '15')
                                        ),
                                        196000, -- width step in meters
                                        196000  -- height step in meters
                                    )
                            )
                        ) .geom AS cell
         ) grid
             JOIN (
        SELECT ST_Collect(ST_Simplify(st_setsrid(geom, 4326), 0.1)) geom FROM geo.tl_2017_us_state
        where geoid not in ('11', '99', '72', '69', '60', '66', '78')
          and geoid not in ('02', '15')
    ) area
                  ON st_intersects(grid.cell, area.geom)

    union

    SELECT cell
    FROM (
             SELECT (
                        ST_Dump(
                                makegrid_2d(
                                        (
                                            SELECT st_setsrid(geom, 4326) FROM geo.tl_2017_us_state
                                            WHERE geoid in ('02')
                                        ),
                                        196000, -- width step in meters
                                        196000  -- height step in meters
                                    )
                            )
                        ) .geom AS cell
         ) grid
             JOIN (
        SELECT st_setsrid(geom, 4326) geom FROM geo.tl_2017_us_state
        where geoid in ('02')
    ) area
                  ON st_intersects(grid.cell, area.geom)



    union

    SELECT cell
    FROM (
             SELECT (
                        ST_Dump(
                                makegrid_2d(
                                        (
                                            SELECT ST_Collect(ST_Simplify(st_setsrid(geom, 4326), 0.1)) FROM geo.tl_2017_us_state
                                            WHERE geoid in ('15')
                                        ),
                                        196000, -- width step in meters
                                        196000  -- height step in meters
                                    )
                            )
                        ) .geom AS cell
         ) grid
             JOIN (
        SELECT ST_Collect(ST_Simplify(st_setsrid(geom, 4326), 0.1)) geom FROM geo.tl_2017_us_state
        where geoid in ('15')
    ) area
                  ON st_intersects(grid.cell, area.geom)
)

select row_number() OVER() id, cell
into tmp_grid_new
from grid
