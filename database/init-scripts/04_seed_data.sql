DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'authenticator') THEN
        CREATE ROLE authenticator NOINHERIT LOGIN PASSWORD 'secretpassword';
    END IF;
END
$$;

GRANT web_anon, authenticated TO authenticator;

INSERT INTO public.users (user_id) VALUES ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11') ON CONFLICT DO NOTHING;
INSERT INTO public.profiles (user_id, student_code, full_name, email, faculty, major) 
VALUES ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'SV001', 'Nguyen Van A', 'anv@student.edu.vn', 'CNTT', 'KTPM') ON CONFLICT DO NOTHING;

INSERT INTO public.users (user_id) VALUES ('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22') ON CONFLICT DO NOTHING;
INSERT INTO public.profiles (user_id, student_code, full_name, email, faculty, major) 
VALUES ('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'SV002', 'Tran Thi B', 'btt@student.edu.vn', 'CNTT', 'KHMT') ON CONFLICT DO NOTHING;