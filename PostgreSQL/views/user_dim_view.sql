CREATE VIEW public.user_dim_view
 AS
 SELECT user_key,
    useridml,
    user_count
   FROM user_dim_table;