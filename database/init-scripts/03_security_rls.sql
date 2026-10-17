CREATE OR REPLACE FUNCTION current_user_id() RETURNS UUID AS $$
BEGIN
    RETURN NULLIF(current_setting('request.jwt.claims', true)::json->>'sub', '')::UUID;
EXCEPTION
    WHEN OTHERS THEN RETURN NULL;
END;
$$ LANGUAGE plpgsql STABLE;

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.applications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS profile_select_policy ON public.profiles;
CREATE POLICY profile_select_policy ON public.profiles
    FOR SELECT USING (user_id = current_user_id());

DROP POLICY IF EXISTS profile_insert_policy ON public.profiles;
CREATE POLICY profile_insert_policy ON public.profiles
    FOR INSERT WITH CHECK (user_id = current_user_id());

DROP POLICY IF EXISTS profile_update_policy ON public.profiles;
CREATE POLICY profile_update_policy ON public.profiles
    FOR UPDATE USING (user_id = current_user_id());

DROP POLICY IF EXISTS app_select_policy ON public.applications;
CREATE POLICY app_select_policy ON public.applications
    FOR SELECT USING (user_id = current_user_id());

DROP POLICY IF EXISTS app_insert_policy ON public.applications;
CREATE POLICY app_insert_policy ON public.applications
    FOR INSERT WITH CHECK (user_id = current_user_id());