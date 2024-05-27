CREATE OR REPLACE PROCEDURE public.sp_rating_fact_table(
	)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	CREATE TEMP TABLE ratings_time AS
		SELECT userid,
			movieid,
			rating,
			TO_TIMESTAMP(timestamp::bigint)
		from ratings;

	CREATE TEMP TABLE rating_modify_time AS
		SELECT userid,
			movieid,
			rating,
			TO_CHAR(to_timestamp, 'YYYY-MM-DD') AS date_only,
			TO_CHAR(to_timestamp, 'HH24:MI:SS') AS time_only
		FROM ratings_time;

	CREATE TEMP TABLE rating_modify_time_key as
		SELECT userid,
			movieid, 
			rating,
			date_key,
			time_key
		from rating_modify_time as rmt
		inner join date_dim_table as ddt
			on rmt.date_only = TO_CHAR(ddt.full_date, 'YYYY-MM-DD')
		inner join time_dim_table as tdt
			on rmt.time_only = tdt.time_value;
	
	CREATE TEMP TABLE rating_time_user_key as
		select udt.user_key,
			mdt.movie_key, 
			rating,
			date_key,
			time_key
		from rating_modify_time_key as rmtk
			inner join user_dim_table as udt
				on udt.useridml = rmtk.userid
			inner join movie_dim_table as mdt
				on mdt.movieid = rmtk.movieid;

	MERGE INTO rating_fact_table AS target
		USING (
			-- Subquery to aggregate genre keys for each movie
			SELECT
				*
			FROM
				rating_time_user_key
		) AS source
		ON (target.user_key = source.user_key and target.movie_key = source.movie_key)
		WHEN NOT MATCHED THEN
			INSERT (user_key, movie_key, date_key, time_key, rating)
			VALUES (source.user_key, source.movie_key, source.date_key, source.time_key, rating)
		WHEN MATCHED THEN
			UPDATE SET
				date_key = source.date_key,
				time_key = source.time_key,
				rating = source.rating;
			
	DROP TABLE IF EXISTS ratings_time;
    DROP TABLE IF EXISTS rating_modify_time;
    DROP TABLE IF EXISTS rating_modify_time_key;
	DROP TABLE IF EXISTS rating_time_user_key;
	
END;
$BODY$;
ALTER PROCEDURE public.sp_rating_fact_table()
    OWNER TO postgres;