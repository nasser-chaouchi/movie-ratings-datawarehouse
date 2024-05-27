CREATE OR REPLACE PROCEDURE public.sp_genre_dim_table(
	)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    MERGE INTO genre_dim_table AS target
    USING (
        SELECT DISTINCT LOWER(UNNEST(STRING_TO_ARRAY(m.genres, '|'))) AS genre_name
        FROM (
            SELECT movieid, STRING_AGG(genres, '|') AS genres
            FROM public.movies
            GROUP BY movieid
        ) AS m
    UNION
        SELECT DISTINCT LOWER(UNNEST(STRING_TO_ARRAY(t.genres, ','))) AS genre_name
        FROM (
            SELECT tconst, STRING_AGG(genres, ',') AS genres
            FROM public.title_basics
            GROUP BY tconst
        ) AS t
    ) AS source
    ON (LOWER(target.genre_name) = source.genre_name)
    WHEN NOT MATCHED THEN
        INSERT (genre_name)
        VALUES (source.genre_name);
END;
$BODY$;
ALTER PROCEDURE public.sp_genre_dim_table()
    OWNER TO postgres;