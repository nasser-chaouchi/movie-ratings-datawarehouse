CREATE OR REPLACE PROCEDURE public.sp_movie_dim_table(
	)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	CREATE TEMP TABLE t_movies AS
		SELECT DISTINCT
			CASE
				WHEN LENGTH(m.title) < 7 THEN m.title
				ELSE SUBSTR(m.title, 1, LENGTH(m.title) - 7)
			END AS title,
			m.movieid as movieid,
			CASE
				WHEN LENGTH(m.title) < 7 THEN null
				ELSE SUBSTR(m.title, LENGTH(m.title) - 4, 4)
			END AS releaseDate
		FROM 
			public.movies AS m 
		LEFT JOIN
			public.links AS l 
				ON 
					m.movieid = l.movieid
		LEFT JOIN public.title_basics AS tb 
			ON 
				l.imdbid = SUBSTRING(tb.tconst, 3)::int
		WHERE 
			tb.tconst IS NULL;
	
	CREATE TABLE t_movies_good_date AS
		SELECT *
		from t_movies
		where releaseDate ~ '^\d{4}$';
		
	MERGE INTO movie_dim_table AS target
    USING (
        SELECT
            *
        FROM
            t_movies_good_date AS tm
    ) AS source
    ON (target.movieid = source.movieid)
    WHEN NOT MATCHED THEN
        INSERT (title, movieid, releasedate)
        VALUES (source.title, source.movieid, source.releasedate::int);
	
	DROP TABLE IF EXISTS t_movies;
	DROP TABLE IF EXISTS t_movies_good_date;

	
	CREATE TEMP TABLE t_movies_basics AS
		SELECT distinct
			primaryTitle as title,
			tb.tconst,
			m.movieid,
			startyear as releaseDate,
			tr.averagerating AS averageRating,
			tr.numvotes AS num_votes
		FROM
			public.movies AS m
		JOIN
			public.links AS l 
				ON 
					m.movieid = l.movieid
		JOIN
			public.title_basics AS tb 
				ON 
					l.imdbid = SUBSTRING(tb.tconst, 3)::int
		INNER JOIN
			public.title_ratings AS tr
				ON
					tb.tconst = tr.tconst;

	CREATE TEMP TABLE t_basics AS
		SELECT 
			primaryTitle as title,
			tb.tconst,
			startyear as releaseDate,
			tr.averagerating AS averageRating,
			tr.numvotes AS num_votes
		FROM 
		   public.title_basics AS tb
		LEFT JOIN
			public.links AS l 
				ON 
					l.imdbid = SUBSTRING(tb.tconst, 3)::int
		LEFT JOIN 
			public.movies AS m 
				ON
					m.movieid = l.movieid
		INNER JOIN
			public.title_ratings AS tr
				ON
					tb.tconst = tr.tconst
		WHERE 
			m.movieid IS NULL;

	CREATE TEMP TABLE t_sep_movieid	AS
		SELECT DISTINCT
			nconst,
			unnest(string_to_array(COALESCE(knownfortitles, 'null'), ',')) AS movie_id
		from name_basics;

	CREATE TEMP TABLE t_cast_mb AS
		select 
			tconst,
			STRING_AGG(DISTINCT CAST(tsm.nconst AS VARCHAR), '|') AS concatenated_professional
		from t_movies_basics as tmb
		inner join t_sep_movieid as tsm
			on tsm.movie_id = tmb.tconst
		group by tmb.tconst;

	CREATE TEMP TABLE t_cast_b AS
		select
			tconst,
			STRING_AGG(DISTINCT CAST(tsm.nconst AS VARCHAR), '|') AS concatenated_professional
		from t_basics as tb
		inner join t_sep_movieid as tsm
			on tsm.movie_id = tb.tconst
		group by tb.tconst;
	
	CREATE TEMP TABLE t_key_mb AS
		select 
			tconst,
			multiple_concatenate_professional_key
		from t_cast_mb as tcmb
		inner join multiple_concatenate_professional_dim_table as mcpdt on
			mcpdt.multiple_concatenate_professional_name = tcmb.concatenated_professional;
	
	CREATE TEMP TABLE t_key_b AS
		select 
			tconst,
			multiple_concatenate_professional_key
		from t_cast_b as tcb
		inner join multiple_concatenate_professional_dim_table as mcpdt on
			mcpdt.multiple_concatenate_professional_name = tcb.concatenated_professional;
	
	CREATE TEMP TABLE t_mb_pf AS
		select title,
			tmb.tconst,
			movieid,
			multiple_concatenate_professional_key,
			releaseDate,
			averageRating,
			num_votes
		from t_movies_basics tmb
		inner join t_key_mb as tkmb
			on tmb.tconst = tkmb.tconst;
			
	MERGE INTO movie_dim_table AS target
    USING (
        SELECT
            *,
			CASE 
            	WHEN releasedate = '\N' THEN NULL  
            	ELSE releasedate::int  
        	END AS cleaned_releasedate
        FROM
            t_mb_pf AS tm
    ) AS source
    ON (target.movieid = source.movieid)
    WHEN NOT MATCHED THEN
        INSERT (title, movieid, tconst, multiple_concatenate_professional_key, releasedate, averageRating, num_votes)
        VALUES (source.title, source.movieid,source.tconst, source.multiple_concatenate_professional_key,
				cleaned_releasedate, source.averageRating, source.num_votes);
			
	CREATE TEMP TABLE t_b_pf AS
		select title,
			tb.tconst,
			multiple_concatenate_professional_key,
			releaseDate,
			averageRating,
			num_votes
		from t_basics tb
		inner join t_key_b as tkb
			on tb.tconst = tkb.tconst;
			
	MERGE INTO movie_dim_table AS target
    USING (
        SELECT
            *,
			CASE 
            	WHEN releasedate = '\N' THEN NULL  
            	ELSE releasedate::int  
        	END AS cleaned_releasedate
        FROM
            t_b_pf AS tm
    ) AS source
    ON (target.tconst = source.tconst)
    WHEN NOT MATCHED THEN
        INSERT (title, tconst, multiple_concatenate_professional_key, releasedate, averageRating, num_votes)
        VALUES (source.title,source.tconst, source.multiple_concatenate_professional_key,
				cleaned_releasedate, source.averageRating, source.num_votes);
	
    		
	CREATE TEMP TABLE movie_genres AS
    SELECT
        movieid,
        LOWER(UNNEST(STRING_TO_ARRAY(genres, '|'))) AS genre_split
    FROM
        public.movies;
					
	CREATE TEMP TABLE tconst_genres AS
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
	
	CREATE TEMP TABLE movie_genres_key AS
	SELECT distinct
            movieid,
            STRING_AGG(DISTINCT CAST(gdt.genre_key AS VARCHAR), '|') AS concatenated_genres
        FROM
            movie_genres AS mg
        JOIN
            public.genre_dim_table AS gdt ON gdt.genre_name = mg.genre_split
        GROUP BY
            movieid;			
			
	CREATE TEMP TABLE tconst_genres_key AS
		SELECT distinct
            tconst,
            STRING_AGG(DISTINCT CAST(gdt.genre_key AS VARCHAR), '|') AS concatenated_genres
        FROM
            tconst_genres AS tg
        JOIN
            public.genre_dim_table AS gdt ON gdt.genre_name = tg.genre_split
        GROUP BY
            tconst;
	
	CREATE TEMP TABLE movie_genres_mkey AS
		SELECT distinct
			movieid,
			multiple_concatenate_genre_key
		from movie_genres_key as mgk
		Inner JOIN multiple_concatenate_genre_dim_table as mcgt
			on mgk.concatenated_genres = mcgt.multiple_concatenate_genre_name;
	
	MERGE INTO movie_dim_table AS target
    USING (
        SELECT
            *
        FROM
            movie_genres_mkey
    ) AS source
    ON (target.movieid = source.movieid)
    WHEN MATCHED THEN
        UPDATE SET multiple_concatenate_genre_key =  source.multiple_concatenate_genre_key;
	
	drop table if exists movie_genres;
	drop table if exists movie_genres_key;
	drop table if exists movie_genres_mkey;
	
	CREATE TEMP TABLE tconst_genres_mkey AS
		SELECT distinct
			tconst,
			multiple_concatenate_genre_key
		from tconst_genres_key as tgk
		INNER JOIN multiple_concatenate_genre_dim_table as mcgt
			on tgk.concatenated_genres = mcgt.multiple_concatenate_genre_name;
	
	MERGE INTO movie_dim_table AS target
    USING (
        SELECT
            *
        FROM
            tconst_genres_mkey
    ) AS source
    ON (target.tconst = source.tconst)
    WHEN MATCHED THEN
        UPDATE SET multiple_concatenate_genre_key =  source.multiple_concatenate_genre_key;
		
	DROP TABLE IF EXISTS t_movies_basics;
	DROP TABLE IF EXISTS t_basics;
	DROP TABLE IF EXISTS t_sep_movieid;
	DROP TABLE IF EXISTS t_cast_b;
	DROP TABLE IF EXISTS t_cast_mb;
	DROP TABLE IF EXISTS t_key_b;
	drop table if exists t_key_mb;
	drop table if exists t_mb_pf;
	drop table if exists t_b_pf;
	
	drop table if exists tconst_genres;
	drop table if exists tconst_genres_key;
	drop table if exists tconst_genres_mkey;

END;
$BODY$;
ALTER PROCEDURE public.sp_movie_dim_table()
    OWNER TO postgres;