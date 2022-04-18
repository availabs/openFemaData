with national as (select nri_category,
                         count(1),
                         avg(Least(COALESCE(building_loss_ratio_per_basis, 0), 1))           b_av_n,
                         avg(Least(COALESCE(crop_loss_ratio_per_basis, 0), 1))               c_av_n,
                         avg(Least(COALESCE(population_loss_ratio_per_basis, 0), 1))         p_av_n,
                         avg(Least(COALESCE(fema_building_loss_ratio_per_basis, 0), 1))      f_av_n,

                         variance(Least(COALESCE(building_loss_ratio_per_basis, 0), 1))      b_va_n,
                         variance(Least(COALESCE(crop_loss_ratio_per_basis, 0), 1))          c_va_n,
                         variance(Least(COALESCE(population_loss_ratio_per_basis, 0), 1))    p_va_n,
                         variance(Least(COALESCE(fema_building_loss_ratio_per_basis, 0), 1)) f_va_n

                  from severe_weather_new.details_fema_per_day_basis as a
                           join severe_weather_new.fips_to_regions_and_surrounding_counties as b
                                on b.fips = a.geoid
                  WHERE nri_category is not null
                  group by 1
                  order by 1),
     regional as (select region,
                         nri_category,
                         count(1),
                         avg(Least(COALESCE(building_loss_ratio_per_basis, 0), 1))           b_av_r,
                         avg(Least(COALESCE(crop_loss_ratio_per_basis, 0), 1))               c_av_r,
                         avg(Least(COALESCE(population_loss_ratio_per_basis, 0), 1))         p_av_r,
                         avg(Least(COALESCE(fema_building_loss_ratio_per_basis, 0), 1))      f_av_r,

                         variance(Least(COALESCE(building_loss_ratio_per_basis, 0), 1))      b_va_r,
                         variance(Least(COALESCE(crop_loss_ratio_per_basis, 0), 1))          c_va_r,
                         variance(Least(COALESCE(population_loss_ratio_per_basis, 0), 1))    p_va_r,
                         variance(Least(COALESCE(fema_building_loss_ratio_per_basis, 0), 1)) f_va_r

                  from severe_weather_new.details_fema_per_day_basis as a
                           join severe_weather_new.fips_to_regions_and_surrounding_counties as b
                                on b.fips = a.geoid
                  WHERE nri_category is not null
                  group by 1, 2
                  order by 1, 2),
     county as (select LEFT(b.fips, 5)                                                     fips,
                       nri_category,
                       count(1),
                       avg(Least(COALESCE(building_loss_ratio_per_basis, 0), 1))           b_av_c,
                       avg(Least(COALESCE(crop_loss_ratio_per_basis, 0), 1))               c_av_c,
                       avg(Least(COALESCE(population_loss_ratio_per_basis, 0), 1))         p_av_c,
                       avg(Least(COALESCE(fema_building_loss_ratio_per_basis, 0), 1))      f_av_c,

                       variance(Least(COALESCE(building_loss_ratio_per_basis, 0), 1))      b_va_c,
                       variance(Least(COALESCE(crop_loss_ratio_per_basis, 0), 1))          c_va_c,
                       variance(Least(COALESCE(population_loss_ratio_per_basis, 0), 1))    p_va_c,
                       variance(Least(COALESCE(fema_building_loss_ratio_per_basis, 0), 1)) f_va_c

                from severe_weather_new.details_fema_per_day_basis as a
                         join severe_weather_new.fips_to_regions_and_surrounding_counties as b
                              on b.fips = a.geoid
                WHERE nri_category is not null
                group by 1, 2
                order by 1, 2),

     surrounding as (select surrounding_counties                                                fips,
                            nri_category,
                            count(1),
                            avg(Least(COALESCE(building_loss_ratio_per_basis, 0), 1))           b_av_s,
                            avg(Least(COALESCE(crop_loss_ratio_per_basis, 0), 1))               c_av_s,
                            avg(Least(COALESCE(population_loss_ratio_per_basis, 0), 1))         p_av_s,
                            avg(Least(COALESCE(fema_building_loss_ratio_per_basis, 0), 1))      f_av_s,

                            variance(Least(COALESCE(building_loss_ratio_per_basis, 0), 1))      b_va_s,
                            variance(Least(COALESCE(crop_loss_ratio_per_basis, 0), 1))          c_va_s,
                            variance(Least(COALESCE(population_loss_ratio_per_basis, 0), 1))    p_va_s,
                            variance(Least(COALESCE(fema_building_loss_ratio_per_basis, 0), 1)) f_va_s

                     from severe_weather_new.details_fema_per_day_basis as a
                              join severe_weather_new.fips_to_regions_and_surrounding_counties as b
                                   on b.fips = a.geoid
                     WHERE nri_category is not null
                     group by 1, 2
                     order by 1, 2)

SELECT mapping.fips,
       mapping.region,
       mapping.surrounding_counties,
       county.*,
       national.*,
       regional.*,
       surrounding.*,

       COALESCE(((
                         (1.0 / NULLIF(b_va_n, 0)) /
                         (
                                 COALESCE(1.0 / NULLIF(b_va_n, 0), 0) +
                                 COALESCE(1.0 / NULLIF(b_va_r, 0), 0) +
                                 COALESCE(1.0 / NULLIF(b_va_c, 0), 0) +
                                 COALESCE(1.0 / NULLIF(b_va_s, 0), 0)
                             )
                     ) *
                 b_av_n), 0) +
       COALESCE(((
                         (1.0 / NULLIF(b_va_r, 0)) /
                         (
                                 COALESCE(1.0 / NULLIF(b_va_n, 0), 0) +
                                 COALESCE(1.0 / NULLIF(b_va_r, 0), 0) +
                                 COALESCE(1.0 / NULLIF(b_va_c, 0), 0) +
                                 COALESCE(1.0 / NULLIF(b_va_s, 0), 0)
                             )
                     ) *
                 b_av_r), 0) +
       COALESCE(((
                         (1.0 / NULLIF(b_va_c, 0)) /
                         (
                                 COALESCE(1.0 / NULLIF(b_va_n, 0), 0) +
                                 COALESCE(1.0 / NULLIF(b_va_r, 0), 0) +
                                 COALESCE(1.0 / NULLIF(b_va_c, 0), 0) +
                                 COALESCE(1.0 / NULLIF(b_va_s, 0), 0)
                             )
                     ) *
                 b_av_c), 0) +
       COALESCE(((
                         (1.0 / NULLIF(b_va_s, 0)) /
                         (
                                 COALESCE(1.0 / NULLIF(b_va_n, 0), 0) +
                                 COALESCE(1.0 / NULLIF(b_va_r, 0), 0) +
                                 COALESCE(1.0 / NULLIF(b_va_c, 0), 0) +
                                 COALESCE(1.0 / NULLIF(b_va_s, 0), 0)
                             )
                     ) *
                 b_av_s), 0) AS hlr_b,

       COALESCE(((
                         (1.0 / NULLIF(c_va_n, 0)) /
                         (
                                 COALESCE(1.0 / NULLIF(c_va_n, 0), 0) +
                                 COALESCE(1.0 / NULLIF(c_va_r, 0), 0) +
                                 COALESCE(1.0 / NULLIF(c_va_c, 0), 0) +
                                 COALESCE(1.0 / NULLIF(c_va_s, 0), 0)
                             )
                     ) *
                 c_av_n), 0) +
       COALESCE(((
                         (1.0 / NULLIF(c_va_r, 0)) /
                         (
                                 COALESCE(1.0 / NULLIF(c_va_n, 0), 0) +
                                 COALESCE(1.0 / NULLIF(c_va_r, 0), 0) +
                                 COALESCE(1.0 / NULLIF(c_va_c, 0), 0) +
                                 COALESCE(1.0 / NULLIF(c_va_s, 0), 0)
                             )
                     ) *
                 c_av_r), 0) +
       COALESCE(((
                         (1.0 / NULLIF(c_va_c, 0)) /
                         (
                                 COALESCE(1.0 / NULLIF(c_va_n, 0), 0) +
                                 COALESCE(1.0 / NULLIF(c_va_r, 0), 0) +
                                 COALESCE(1.0 / NULLIF(c_va_c, 0), 0) +
                                 COALESCE(1.0 / NULLIF(c_va_s, 0), 0)
                             )
                     ) *
                 c_av_c), 0) +
       COALESCE(((
                         (1.0 / NULLIF(c_va_s, 0)) /
                         (
                                 COALESCE(1.0 / NULLIF(c_va_n, 0), 0) +
                                 COALESCE(1.0 / NULLIF(c_va_r, 0), 0) +
                                 COALESCE(1.0 / NULLIF(c_va_c, 0), 0) +
                                 COALESCE(1.0 / NULLIF(c_va_s, 0), 0)
                             )
                     ) *
                 c_av_s), 0) AS hlr_c,

       COALESCE(((
                         (1.0 / NULLIF(p_va_n, 0)) /
                         (
                                 COALESCE(1.0 / NULLIF(p_va_n, 0), 0) +
                                 COALESCE(1.0 / NULLIF(p_va_r, 0), 0) +
                                 COALESCE(1.0 / NULLIF(p_va_c, 0), 0) +
                                 COALESCE(1.0 / NULLIF(p_va_s, 0), 0)
                             )
                     ) *
                 p_av_n), 0) +
       COALESCE(((
                         (1.0 / NULLIF(p_va_r, 0)) /
                         (
                                 COALESCE(1.0 / NULLIF(p_va_n, 0), 0) +
                                 COALESCE(1.0 / NULLIF(p_va_r, 0), 0) +
                                 COALESCE(1.0 / NULLIF(p_va_c, 0), 0) +
                                 COALESCE(1.0 / NULLIF(p_va_s, 0), 0)
                             )
                     ) *
                 p_av_r), 0) +
       COALESCE(((
                         (1.0 / NULLIF(p_va_c, 0)) /
                         (
                                 COALESCE(1.0 / NULLIF(p_va_n, 0), 0) +
                                 COALESCE(1.0 / NULLIF(p_va_r, 0), 0) +
                                 COALESCE(1.0 / NULLIF(p_va_c, 0), 0) +
                                 COALESCE(1.0 / NULLIF(p_va_s, 0), 0)
                             )
                     ) *
                 p_av_c), 0) +
       COALESCE(((
                         (1.0 / NULLIF(p_va_s, 0)) /
                         (
                                 COALESCE(1.0 / NULLIF(p_va_n, 0), 0) +
                                 COALESCE(1.0 / NULLIF(p_va_r, 0), 0) +
                                 COALESCE(1.0 / NULLIF(p_va_c, 0), 0) +
                                 COALESCE(1.0 / NULLIF(p_va_s, 0), 0)
                             )
                     ) *
                 p_av_s), 0) AS hlr_p,

       COALESCE(((
                         (1.0 / NULLIF(f_va_n, 0)) /
                         (
                                 COALESCE(1.0 / NULLIF(f_va_n, 0), 0) +
                                 COALESCE(1.0 / NULLIF(f_va_r, 0), 0) +
                                 COALESCE(1.0 / NULLIF(f_va_c, 0), 0) +
                                 COALESCE(1.0 / NULLIF(f_va_s, 0), 0)
                             )
                     ) *
                 f_av_n), 0) +
       COALESCE(((
                         (1.0 / NULLIF(f_va_r, 0)) /
                         (
                                 COALESCE(1.0 / NULLIF(f_va_n, 0), 0) +
                                 COALESCE(1.0 / NULLIF(f_va_r, 0), 0) +
                                 COALESCE(1.0 / NULLIF(f_va_c, 0), 0) +
                                 COALESCE(1.0 / NULLIF(f_va_s, 0), 0)
                             )
                     ) *
                 f_av_r), 0) +
       COALESCE(((
                         (1.0 / NULLIF(f_va_c, 0)) /
                         (
                                 COALESCE(1.0 / NULLIF(f_va_n, 0), 0) +
                                 COALESCE(1.0 / NULLIF(f_va_r, 0), 0) +
                                 COALESCE(1.0 / NULLIF(f_va_c, 0), 0) +
                                 COALESCE(1.0 / NULLIF(f_va_s, 0), 0)
                             )
                     ) *
                 f_av_c), 0) +
       COALESCE(((
                         (1.0 / NULLIF(f_va_s, 0)) /
                         (
                                 COALESCE(1.0 / NULLIF(f_va_n, 0), 0) +
                                 COALESCE(1.0 / NULLIF(f_va_r, 0), 0) +
                                 COALESCE(1.0 / NULLIF(f_va_c, 0), 0) +
                                 COALESCE(1.0 / NULLIF(f_va_s, 0), 0)
                             )
                     ) *
                 f_av_s), 0) AS hlr_f

FROM severe_weather_new.fips_to_regions_and_surrounding_counties mapping
         JOIN county
              on county.fips = mapping.fips
         JOIN national
              ON county.nri_category = national.nri_category
         JOIN regional
              ON mapping.region = regional.region AND county.nri_category = regional.nri_category
         JOIN surrounding
              ON mapping.surrounding_counties = surrounding.fips