CREATE VIEW public.time_dim_view AS
SELECT
    time_key,
    time_value,
    hours_24,
    hours_12,
    hour_minutes,
    day_minutes,
    seconds
FROM
    public.time_dim_table;