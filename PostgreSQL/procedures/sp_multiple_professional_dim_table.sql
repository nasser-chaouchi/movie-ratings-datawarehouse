CREATE OR REPLACE PROCEDURE public.sp_multiple_professional_dim_table(
	)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    -- Insert into multiple_professional_dim_table with conflict handling
    INSERT INTO multiple_professional_dim_table (multiple_concatenate_professional_key, professional_key)
    SELECT DISTINCT
        multiple_concatenate_professional_key,
        LOWER(UNNEST(STRING_TO_ARRAY(multiple_concatenate_professional_name, '|'))) AS professional_key
    FROM public.multiple_concatenate_professional_dim_table
    ON CONFLICT (multiple_concatenate_professional_key, professional_key) DO NOTHING;
END;
$BODY$;
ALTER PROCEDURE public.sp_multiple_professional_dim_table()
    OWNER TO postgres;
