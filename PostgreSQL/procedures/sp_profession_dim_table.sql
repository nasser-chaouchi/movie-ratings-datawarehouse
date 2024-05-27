CREATE OR REPLACE PROCEDURE public.sp_profession_dim_table(
	)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    -- Merge into profession_dim_table
    MERGE INTO profession_dim_table AS target
    USING (
        -- Subquery to extract distinct profession names
        SELECT DISTINCT LOWER(UNNEST(STRING_TO_ARRAY(REPLACE(m.primaryProfession, '_', ' '), ','))) AS profession_name
        FROM (
            SELECT nconst, STRING_AGG(primaryProfession, ',') AS primaryProfession
            FROM public.name_basics
            GROUP BY nconst
        ) AS m
    ) AS source
    ON (target.profession_name = source.profession_name)
    WHEN NOT MATCHED THEN
        INSERT (profession_name)
        VALUES (source.profession_name);
END;
$BODY$;
ALTER PROCEDURE public.sp_profession_dim_table()
    OWNER TO postgres;