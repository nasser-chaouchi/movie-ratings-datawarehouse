CREATE VIEW public.multiple_professional_dim_view AS
SELECT
    multiple_concatenate_professional_key,
    professional_key
FROM
    public.multiple_professional_dim_table;
