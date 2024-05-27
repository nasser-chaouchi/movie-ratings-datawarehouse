CREATE OR REPLACE PROCEDURE public.sp_multiple_genre_dim_table(
	)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    -- Utilisation d'un CTE pour préparer les données source
    WITH source AS (
        SELECT
            multiple_concatenate_genre_key,
            (regexp_split_to_table(multiple_concatenate_genre_name, '\|'))::int AS genre_key
        FROM
            public.multiple_concatenate_genre_dim_table
    )
    MERGE INTO public.multiple_genre_dim_table AS target
    USING source
    ON (target.multiple_concatenate_genre_key = source.multiple_concatenate_genre_key AND target.genre_key = source.genre_key)
    WHEN NOT MATCHED THEN
        INSERT (multiple_concatenate_genre_key, genre_key)
        VALUES (source.multiple_concatenate_genre_key, source.genre_key);
END;
$BODY$;
ALTER PROCEDURE public.sp_multiple_genre_dim_table()
    OWNER TO postgres;