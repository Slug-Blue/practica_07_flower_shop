\set ON_ERROR_STOP on
SELECT version(), current_user, current_database();
SELECT 'clients' AS table_name, COUNT(*) AS row_count, SUM(id) AS id_sum, SUM(amount) AS amount_sum FROM public.clients
UNION ALL SELECT 'masters', COUNT(*), SUM(id), SUM(amount) FROM public.masters
UNION ALL SELECT 'appointments', COUNT(*), SUM(id), SUM(amount) FROM public.appointments
ORDER BY table_name;
SELECT * FROM public.clients WHERE id=1;
SELECT * FROM public.masters WHERE id=1;
SELECT * FROM public.appointments WHERE id=1;
SELECT * FROM public.access_probe ORDER BY id;
