with t as (SELECT
               distinct geoid fips,
                        CASE
                            WHEN substring(geoid, 1, 2) IN ('23', '33', '25', '50', '44', '09', '34', '10', '24', '42', '36', '51', '54', '10')
                                THEN 'A'

                            WHEN substring(geoid, 1, 2) IN ('37', '45', '13', '12', '01', '28', '47', '21')
                                THEN 'B'

                            WHEN substring(geoid, 1, 2) IN ('27', '55', '26', '17', '18', '39')
                                THEN 'C'

                            WHEN substring(geoid, 1, 2) IN ('30', '38', '56', '46', '49', '08')
                                THEN 'D'

                            WHEN substring(geoid, 1, 2) IN ('19', '29', '20', '31')
                                THEN 'E'

                            WHEN substring(geoid, 1, 2) IN ('48', '22', '35', '40', '05')
                                THEN 'F'

                            WHEN substring(geoid, 1, 2) IN ('06', '04', '32', '15')
                                THEN 'G'

                            WHEN substring(geoid, 1, 2) IN ('53', '16', '41', '02')
                                THEN 'H'

                            ELSE null
                            END region
           FROM severe_weather_new.details_fema_per_day_basis
           where geoid is not null)

INSERT INTO severe_weather_new.fips_to_regions_and_surrounding_counties(
    fips, region)
SELECT * FROM t
