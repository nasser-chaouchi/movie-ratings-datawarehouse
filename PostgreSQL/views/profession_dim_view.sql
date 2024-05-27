CREATE VIEW public.profession_dim_view AS
SELECT
    profession_key,
    profession_name
FROM
    public.profession_dim_table;