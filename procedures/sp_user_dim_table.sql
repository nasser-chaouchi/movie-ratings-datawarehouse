CREATE OR REPLACE PROCEDURE public.sp_user_dim_table(
	)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    INSERT INTO user_dim_table (useridml, user_count)
    SELECT userid AS useridml, COUNT(*) AS user_count
    FROM ratings
    GROUP BY userid
    ON CONFLICT (useridml) DO UPDATE
    SET user_count = EXCLUDED.user_count;
END;
$BODY$;
ALTER PROCEDURE public.sp_user_dim_table()
    OWNER TO postgres;