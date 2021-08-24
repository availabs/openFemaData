const db = require('../open-fema-dataloader/db.js');

const updateCoords = async () => {
    let query = `
                update severe_weather_new.details dst
                set begin_coords_geom = st_setsrid(st_point(src.begin_lon, src.begin_lat), 4326),
                    end_coords_geom   = st_setsrid(st_point(src.end_lon, src.end_lat), 4326) 
                from severe_weather_new.details src
                where src.event_id = dst.event_id
                  and src.episode_id = dst.episode_id
                and src.begin_lon != 0
                and src.begin_lat != 0
                and src.end_lon != 0
                and src.end_lat != 0
`
    return db.query(query);
}

const updateDamage = async () => {
    let query = `
        update severe_weather_new.details 
        set property_damage = 
            CASE 
                WHEN char_length(damage_property) > 1
                THEN
                    CASE 
                          WHEN RIGHT(damage_property,1) = 'B' THEN cast(cast(LEFT(damage_property,-1) as float) * 1000000000 as bigint)
                          WHEN RIGHT(damage_property,1) = 'M' THEN cast(cast(LEFT(damage_property,-1) as float) * 1000000 as bigint)
                          WHEN RIGHT(damage_property,1) = 'K' THEN cast(cast(LEFT(damage_property,-1) as float) * 1000 as bigint)
                          WHEN RIGHT(damage_property,1) = 'H' or RIGHT(damage_property,1) = 'h' THEN cast(cast(LEFT(damage_property,-1) as float) * 100 as bigint)  
                          ELSE cast(cast(damage_property as float) as bigint)
                    END
            END,
            crop_damage = 
            CASE 
                WHEN char_length(damage_crops) > 1
                THEN
                    CASE 
                          WHEN RIGHT(damage_crops,1) = 'B' THEN cast(cast(LEFT(damage_crops,-1) as float) * 1000000000 as bigint)
                          WHEN RIGHT(damage_crops,1) = 'M' THEN cast(cast(LEFT(damage_crops,-1) as float) * 1000000 as bigint)
                          WHEN RIGHT(damage_crops,1) = 'K' or RIGHT(damage_crops,1) = 'k' or RIGHT(damage_crops,1) = 'T' THEN cast(cast(LEFT(damage_crops,-1) as float) * 1000 as bigint)
                          WHEN RIGHT(damage_crops,1) = 'H' or RIGHT(damage_crops,1) = 'h' THEN cast(cast(LEFT(damage_crops,-1) as float) * 100 as bigint)
                          WHEN RIGHT(damage_crops,1) = '?' THEN 0
                          ELSE cast(cast(damage_crops as float) as bigint)
                    END
            END
    `
    return db.query(query);
}

const updateGeoTracts = async () => {
    // some of the geoids from geo.tl_2017_tract mismatch severe_weather_new.details. priority given to geo.tl_2017_tract
    let query = `
        with t as (
            select b.geoid, st_setsrid(geom, 4326) geom
            from geo.tl_2017_tract b
        ),
             s as (
                 select event_id, begin_coords_geom
                 from severe_weather_new.details
                 where geoid is null
                   and begin_coords_geom is not null
             ),
             a as (
                 select s.event_id, begin_coords_geom, t.geoid geoid
                 from s
                          join t
                               on st_contains(t.geom, begin_coords_geom)
             )

        update severe_weather_new.details dst
        set geoid = a.geoid from a
        where dst.event_id = a.event_id


    `
    return db.query(query);
}

const updateGeoCounties = async () => {
    let query = `
        UPDATE severe_weather_new.details
        SET geoid = LPAD(state_fips::TEXT, 2, '0') || LPAD(cz_fips::TEXT, 3, '0')
        WHERE geoid IS NULL
    `
    return db.query(query);
}

const updateGeoCousubs = async () => {
    let query = `
        with t as (
            select event_id, st_transform(begin_coords_geom, 4269) geom
            from severe_weather_new.details
            where cousub_geoid is null
              and begin_coords_geom is not null
        ),
             s as (
                 SELECT event_id, geoid
                 FROM geo.tl_2017_cousub a
                          join t
                               on st_contains(a.geom, t.geom)
             )

        update severe_weather_new.details dst
        set cousub_geoid = s.geoid from s
        where dst.event_id = s.event_id
    `
    return db.query(query);
}

const postProcess = async () => {
    // await updateCoords();
    // await updateDamage();
    // await updateGeoTracts();
    // await updateGeoCounties();
    await updateGeoCousubs();
}

postProcess()