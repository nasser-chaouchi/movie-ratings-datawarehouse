CREATE OR REPLACE PROCEDURE public.sp_multiple_concatenate_genre_dim_table(
	)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    -- Subquery to generate movie genres
    CREATE TEMP TABLE movie_genres AS
    SELECT
        movieid,
        LOWER(UNNEST(STRING_TO_ARRAY(genres, '|'))) AS genre_split
    FROM
        public.movies;
		
	create TEMP TABLE movie_concat_distinct AS
	SELECT
        movieid,
       	STRING_AGG(DISTINCT CAST(gdt.genre_key AS VARCHAR), '|') AS concatenated_genres
    FROM
        movie_genres AS mg
    JOIN
        public.genre_dim_table AS gdt ON gdt.genre_name = mg.genre_split
    GROUP BY
        movieid;
    
    -- Merge into multiple_concatenate_genre_table
    MERGE INTO multiple_concatenate_genre_dim_table AS target
    USING (
        -- Subquery to aggregate genre keys for each movie
        SELECT
            distinct concatenated_genres
        FROM
            movie_concat_distinct AS mg
    ) AS source
    ON (target.multiple_concatenate_genre_name = source.concatenated_genres)
    WHEN NOT MATCHED THEN
        INSERT (multiple_concatenate_genre_name)
        VALUES (source.concatenated_genres);

    -- Drop temporary table
    DROP TABLE IF EXISTS movie_genres;
	DROP TABLE IF EXISTS movie_concat_distinct;

    -- Create temporary table for movies not present in public.movies
    CREATE TEMP TABLE movie_genres AS
    SELECT
        tconst,
        LOWER(UNNEST(STRING_TO_ARRAY(genres, ','))) AS genre_split
    FROM (
        SELECT tb.tconst, tb.genres
        FROM public.title_basics AS tb
        LEFT JOIN public.links AS l ON l.imdbid = SUBSTRING(tb.tconst, 3)::int
        LEFT JOIN public.movies AS m ON m.movieid = l.movieid
        WHERE m.movieid IS NULL
    );
	
	create TEMP TABLE movie_concat_distinct AS
	SELECT
        tconst,
       	STRING_AGG(DISTINCT CAST(gdt.genre_key AS VARCHAR), '|') AS concatenated_genres
    FROM
        movie_genres AS mg
    JOIN
        public.genre_dim_table AS gdt ON gdt.genre_name = mg.genre_split
    GROUP BY
        tconst;

    -- Merge into multiple_concatenate_genre_table for movies not present in public.movies
    MERGE INTO multiple_concatenate_genre_dim_table AS target
    USING (
        -- Subquery to aggregate genre keys for each movie
        SELECT
            distinct concatenated_genres
        FROM
            movie_concat_distinct AS mg
    ) AS source
    ON (target.multiple_concatenate_genre_name = source.concatenated_genres)
    WHEN NOT MATCHED THEN
        INSERT (multiple_concatenate_genre_name)
        VALUES (source.concatenated_genres);

    -- Drop temporary table
    DROP TABLE IF EXISTS movie_genres;
	DROP TABLE IF EXISTS movie_concat_distinct;
END;
$BODY$;
ALTER PROCEDURE public.sp_multiple_concatenate_genre_dim_table()
    OWNER TO postgres;