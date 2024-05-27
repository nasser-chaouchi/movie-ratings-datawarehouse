CREATE OR REPLACE PROCEDURE public.sp_multiple_concatenate_professional_dim_table(
	)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	CREATE TEMP TABLE t_movies_basics AS
		SELECT distinct
			tb.tconst,
			m.movieid
		FROM
			public.movies AS m
		JOIN
			public.links AS l 
				ON 
					m.movieid = l.movieid
		JOIN
			public.title_basics AS tb 
				ON 
					l.imdbid = SUBSTRING(tb.tconst, 3)::int;

	CREATE TEMP TABLE t_basics AS
		SELECT 
			tb.tconst
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
		WHERE 
			m.movieid IS NULL;

	CREATE TEMP TABLE t_sep_movieid	AS
		SELECT DISTINCT
			nconst,
			unnest(string_to_array(COALESCE(knownfortitles, 'null'), ',')) AS movie_id
		from name_basics;

	CREATE TEMP TABLE t_cast_mb AS
		select 
			STRING_AGG(DISTINCT CAST(tsm.nconst AS VARCHAR), '|') AS concatenated_professional
		from t_movies_basics as tmb
		inner join t_sep_movieid as tsm
			on tsm.movie_id = tmb.tconst
		group by tmb.tconst;

	CREATE TEMP TABLE t_cast_b AS
		select STRING_AGG(DISTINCT CAST(tsm.nconst AS VARCHAR), '|') AS concatenated_professional
		from t_basics as tb
		inner join t_sep_movieid as tsm
			on tsm.movie_id = tb.tconst
		group by tb.tconst;

	MERGE INTO multiple_concatenate_professional_dim_table AS target
	USING (
		SELECT DISTINCT concatenated_professional
		FROM t_cast_b
	) AS source
	ON (target.multiple_concatenate_professional_name = source.concatenated_professional)
	WHEN NOT MATCHED THEN
		INSERT (multiple_concatenate_professional_name)
		VALUES (source.concatenated_professional);

	MERGE INTO multiple_concatenate_professional_dim_table AS target
	USING (
		SELECT DISTINCT concatenated_professional
		FROM t_cast_mb
	) AS source
	ON (target.multiple_concatenate_professional_name = source.concatenated_professional)
	WHEN NOT MATCHED THEN
		INSERT (multiple_concatenate_professional_name)
		VALUES (source.concatenated_professional);

	DROP TABLE IF EXISTS t_movies_basics;
	DROP TABLE IF EXISTS t_basics;
	DROP TABLE IF EXISTS t_sep_movieid;
	DROP TABLE IF EXISTS t_cast_b;
	DROP TABLE IF EXISTS t_cast_mb;

END;
$BODY$;
ALTER PROCEDURE public.sp_multiple_concatenate_professional_dim_table()
    OWNER TO postgres;