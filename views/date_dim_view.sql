CREATE VIEW public.date_dim_view AS
SELECT
    date_key,
    full_date,
    year,
    month,
    day
FROM
    public.date_dim_table;
