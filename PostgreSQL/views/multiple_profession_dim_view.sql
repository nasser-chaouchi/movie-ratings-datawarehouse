CREATE VIEW public.multiple_profession_dim_view AS
SELECT
    multiple_concatenate_profession_key,
    profession_key
FROM
    public.multiple_profession_dim_table;