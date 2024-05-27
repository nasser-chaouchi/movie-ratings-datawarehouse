CREATE OR REPLACE PROCEDURE public.sp_time_dim_table(
	)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    INSERT INTO time_dim_table (time_key, time_value, hours_24, hours_12, hour_minutes, seconds, day_minutes)
    SELECT
        CAST(TO_CHAR(time, 'HH24MISS') AS INTEGER) AS time_key,
        TO_CHAR(time, 'HH24:MI:SS') AS time_value,
        TO_CHAR(time, 'HH24') AS hours_24,
        TO_CHAR(time, 'HH12') AS hours_12,
        TO_CHAR(time, 'MI') AS hour_minutes,
        TO_CHAR(time, 'SS') AS seconds,
        EXTRACT(HOUR FROM time) * 60 + EXTRACT(MINUTE FROM time) AS day_minutes
    FROM (
        SELECT '00:00:00'::TIME + (m.minute || ' minutes')::INTERVAL + (s.second || ' seconds')::INTERVAL AS time
        FROM generate_series(0, 1439) AS m(minute) -- Generates minutes from 00 to 1439
        CROSS JOIN generate_series(0, 59) AS s(second) -- Generates seconds from 00 to 59
    ) dq
    ON CONFLICT (time_key) DO NOTHING; -- Assumes 'time_key' is a unique column in 'time_dim_table'
END;
$BODY$;
ALTER PROCEDURE public.sp_time_dim_table()
    OWNER TO postgres;
