CREATE OR REPLACE PROCEDURE public.sp_multiple_profession_dim_table(
	)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    -- Utilisation d'un CTE pour préparer les données source
    WITH source AS (
        SELECT
            multiple_concatenate_profession_key,
            (regexp_split_to_table(multiple_concatenate_profession_name, '\|'))::int AS profession_key
        FROM
            public.multiple_concatenate_profession_dim_table
    )
    MERGE INTO public.multiple_profession_dim_table AS target
    USING source
    ON (target.multiple_concatenate_profession_key = source.multiple_concatenate_profession_key AND target.profession_key = source.profession_key)
    WHEN NOT MATCHED THEN
        INSERT (multiple_concatenate_profession_key, profession_key)
        VALUES (source.multiple_concatenate_profession_key, source.profession_key);
END;
$BODY$;
ALTER PROCEDURE public.sp_multiple_profession_dim_table()
    OWNER TO postgres;