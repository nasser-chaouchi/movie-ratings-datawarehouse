CREATE VIEW public.professional_dim_view AS
SELECT
    professional_key,
    nconst,
    name,
    multiple_concatenate_profession_key,
    birthyear,
    deathyear
FROM
    public.professional_dim_table;