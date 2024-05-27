CREATE TABLE IF NOT EXISTS public.user_dim_table
(
    user_key serial PRIMARY KEY,
    useridml integer NOT NULL,
    user_count integer
);
