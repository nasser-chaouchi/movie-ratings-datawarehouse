CREATE OR REPLACE PROCEDURE public.sp_date_dim_table(
	)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    INSERT INTO date_dim_table (date_key, full_date, year, month, day)
    SELECT
        year * 10000 + month * 100 + day AS date_key,
        TO_DATE(year || '-' || month || '-' || day, 'YYYY-MM-DD') AS full_date,
        year,
        month,
        day
    FROM (
        SELECT
            year,
            month,
            day
        FROM
            generate_series(1700, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER) AS years(year),
            generate_series(1, 12) AS months(month),
            generate_series(1, 31) AS days(day)
        WHERE
            days.day <= (EXTRACT(DAY FROM (DATE_TRUNC('MONTH', DATE(year || '-' || month || '-01')) + INTERVAL '1 MONTH - 1 day')::DATE))
    ) AS valid_dates
    ON CONFLICT (date_key) DO NOTHING;
END;
$BODY$;
ALTER PROCEDURE public.sp_date_dim_table()
    OWNER TO postgres;