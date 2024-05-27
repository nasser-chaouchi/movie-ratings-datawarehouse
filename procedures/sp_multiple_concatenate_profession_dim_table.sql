CREATE OR REPLACE PROCEDURE public.sp_multiple_concatenate_profession_dim_table(
	)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    CREATE TEMP TABLE people_profession AS
    	SELECT nconst, 
			LOWER(UNNEST(STRING_TO_ARRAY(REPLACE(COALESCE(primaryProfession_split, NULL), '_', ' '), ','))) AS profession_name
		FROM (
			SELECT nconst, STRING_AGG(primaryProfession, ',') AS primaryProfession_split
			FROM public.name_basics
			GROUP BY nconst
			UNION
			SELECT nconst,
				NULL as primaryProfession_split
			FROM public.name_basics
			WHERE primaryProfession IS NULL
		);

    MERGE INTO multiple_concatenate_profession_dim_table AS target
    USING (
        -- Subquery to aggregate profession keys for each person
        SELECT DISTINCT
            STRING_AGG(DISTINCT CAST(pdt.profession_key AS VARCHAR), '|') AS concatenated_profession
        FROM
            people_profession AS pp
        JOIN
            public.profession_dim_table AS pdt ON pdt.profession_name = pp.profession_name
        GROUP BY
            pp.nconst
    ) AS source
    ON (target.multiple_concatenate_profession_name = source.concatenated_profession)
    WHEN NOT MATCHED THEN
        INSERT (multiple_concatenate_profession_name)
        VALUES (source.concatenated_profession);

    -- Drop temporary table
    DROP TABLE IF EXISTS people_profession;
END;
$BODY$;
ALTER PROCEDURE public.sp_multiple_concatenate_profession_dim_table()
    OWNER TO postgres;