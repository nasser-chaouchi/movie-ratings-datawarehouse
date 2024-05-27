CREATE OR REPLACE PROCEDURE public.sp_professional_dim_table(
	)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	CREATE TEMP TABLE people_profession AS
			SELECT nconst, 
				LOWER(UNNEST(STRING_TO_ARRAY(REPLACE(COALESCE(primaryProfession_split, 'NULL'), '_', ' '), ','))) AS profession_name
			FROM (
				SELECT nconst, STRING_AGG(primaryProfession, ',') AS primaryProfession_split
				FROM public.name_basics
				GROUP BY nconst
				UNION
				SELECT nconst,
					NULL as primaryProfession_split
				FROM public.name_basics
				WHERE primaryProfession IS NULL);

	CREATE TEMP TABLE people_profession_key AS
		SELECT
			agg_result.nconst,
			mcpt.multiple_concatenate_profession_key as multiple_concatenate_profession_key
		FROM
			(
				SELECT
					pp.nconst AS nconst,
					STRING_AGG(DISTINCT CAST(pdt.profession_key AS VARCHAR), '|') AS concatenated_profession
				FROM
					people_profession AS pp
				JOIN
					public.profession_dim_table AS pdt ON pdt.profession_name = pp.profession_name
				GROUP BY
					pp.nconst
			) AS agg_result
		JOIN
			public.multiple_concatenate_profession_dim_table AS mcpt ON mcpt.multiple_concatenate_profession_name = agg_result.concatenated_profession;

		MERGE INTO professional_dim_table AS target
		USING (
			-- Subquery to aggregate profession keys for each person
			SELECT primaryName as name, 
				nb.nconst as nconst,
				CASE
					WHEN pcp.multiple_concatenate_profession_key = NULL THEN NULL
					ELSE pcp.multiple_concatenate_profession_key
				END as multiple_concatenate_profession_key,
				CASE 
					WHEN nb.birthyear = '\N' THEN NULL 
					ELSE nb.birthyear::int
				END as birthyear,
				CASE 
					WHEN nb.deathyear = '\N' THEN NULL 
					ELSE nb.deathyear::int 
				END as deathyear
			FROM
				public.name_basics as nb
			JOIN
				people_profession_key as pcp
			ON nb.nconst = pcp.nconst
		) AS source
		ON (target.nconst = source.nconst)
		WHEN NOT MATCHED THEN
			INSERT (nconst, name, multiple_concatenate_profession_key, birthyear, deathyear)
			VALUES (source.nconst, source.name, source.multiple_concatenate_profession_key, source.birthyear, source.deathyear);	
	
	DROP TABLE IF EXISTS people_profession;	
	DROP TABLE IF EXISTS people_profession_key;
	
END;
$BODY$;
ALTER PROCEDURE public.sp_professional_dim_table()
    OWNER TO postgres;