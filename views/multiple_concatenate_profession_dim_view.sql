CREATE VIEW public.multiple_concatenate_profession_dim_view AS
SELECT
    multiple_concatenate_profession_key,
    multiple_concatenate_profession_name
FROM
    public.multiple_concatenate_profession_dim_table;