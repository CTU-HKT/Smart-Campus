-- DEV ONLY: mật khẩu mặc định cho môi trường thử nghiệm. Đổi trước khi triển khai.
GRANT web_anon, authenticated TO authenticator;

INSERT INTO public.users (user_id) VALUES ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11') ON CONFLICT DO NOTHING;
INSERT INTO public.profiles (user_id, student_code, full_name, email, faculty, major) 
VALUES ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'SV001', 'Nguyen Van A', 'anv@student.edu.vn', 'CNTT', 'KTPM') ON CONFLICT DO NOTHING;

INSERT INTO public.users (user_id) VALUES ('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22') ON CONFLICT DO NOTHING;
INSERT INTO public.profiles (user_id, student_code, full_name, email, faculty, major) 
VALUES ('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'SV002', 'Tran Thi B', 'btt@student.edu.vn', 'CNTT', 'KHMT') ON CONFLICT DO NOTHING;