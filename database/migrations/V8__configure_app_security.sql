-- Requires existing PostgREST roles: authenticated, web_anon.
-- Secure defaults: only explicitly listed reads/writes; no direct student INSERT into approval tables.
GRANT USAGE ON SCHEMA app TO authenticated;
GRANT SELECT ON app.loai_ho_so, app.mon_hoc TO authenticated;
GRANT SELECT ON app.sinh_vien, app.can_bo, app.dang_ky_mon, app.ho_so,
 app.buoc_duyet, app.quyet_dinh_duyet, app.tep_dinh_kem, app.thong_bao TO authenticated;
GRANT INSERT ON app.ho_so TO authenticated;
GRANT UPDATE (trang_thai_doc) ON app.thong_bao TO authenticated;
GRANT USAGE ON SEQUENCE app.ho_so_id_seq TO authenticated;
CREATE FUNCTION app.jwt_sub() RETURNS UUID LANGUAGE plpgsql STABLE
SET search_path = pg_catalog, app AS $$
DECLARE v TEXT;
BEGIN
 v := NULLIF(current_setting('request.jwt.claims',true),'');
 IF v IS NULL THEN RETURN NULL; END IF;
 RETURN NULLIF(v::jsonb->>'sub','')::uuid;
EXCEPTION WHEN invalid_text_representation OR invalid_parameter_value THEN RETURN NULL;
END $$;

CREATE FUNCTION app.jwt_ma_sv() RETURNS VARCHAR(20) LANGUAGE sql STABLE
SET search_path = pg_catalog, app AS $$
 SELECT s.ma_sv FROM app.sinh_vien s WHERE s.keycloak_sub=app.jwt_sub() LIMIT 1
$$;
CREATE FUNCTION app.jwt_ma_cb() RETURNS VARCHAR(20) LANGUAGE sql STABLE
SET search_path = pg_catalog, app AS $$
 SELECT c.ma_cb FROM app.can_bo c WHERE c.keycloak_sub=app.jwt_sub() LIMIT 1
$$;
-- Helpers run with table-owner privileges to avoid cyclic RLS evaluation.
ALTER FUNCTION app.jwt_ma_sv() SECURITY DEFINER;
ALTER FUNCTION app.jwt_ma_cb() SECURITY DEFINER;
REVOKE ALL ON FUNCTION app.jwt_ma_sv() FROM PUBLIC;
REVOKE ALL ON FUNCTION app.jwt_ma_cb() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.jwt_ma_sv(), app.jwt_ma_cb(), app.jwt_sub() TO authenticated;

ALTER TABLE app.sinh_vien ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.can_bo ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.mon_hoc ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.loai_ho_so ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.dang_ky_mon ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.ho_so ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.buoc_duyet ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.quyet_dinh_duyet ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.tep_dinh_kem ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.thong_bao ENABLE ROW LEVEL SECURITY;

CREATE POLICY sv_read_self ON app.sinh_vien FOR SELECT TO authenticated USING (ma_sv=app.jwt_ma_sv());
CREATE POLICY cb_read_self ON app.can_bo FOR SELECT TO authenticated USING (ma_cb=app.jwt_ma_cb());
CREATE POLICY read_courses ON app.mon_hoc FOR SELECT TO authenticated USING (true);
CREATE POLICY read_types ON app.loai_ho_so FOR SELECT TO authenticated USING (true);
CREATE POLICY read_enrollments ON app.dang_ky_mon FOR SELECT TO authenticated USING (ma_sv=app.jwt_ma_sv());
CREATE POLICY read_own_applications ON app.ho_so FOR SELECT TO authenticated USING (ma_sv=app.jwt_ma_sv());
CREATE POLICY insert_own_applications ON app.ho_so FOR INSERT TO authenticated WITH CHECK (ma_sv=app.jwt_ma_sv() AND trang_thai='Mới');
CREATE POLICY read_own_notifications ON app.thong_bao FOR SELECT TO authenticated USING (ma_sv=app.jwt_ma_sv() OR ma_cb=app.jwt_ma_cb());
CREATE POLICY mark_own_notifications ON app.thong_bao FOR UPDATE TO authenticated
 USING (ma_sv=app.jwt_ma_sv() OR ma_cb=app.jwt_ma_cb())
 WITH CHECK (ma_sv=app.jwt_ma_sv() OR ma_cb=app.jwt_ma_cb());
-- Approval and attachment visibility is handled by trusted backend until
-- audited SECURITY DEFINER authorization helpers are implemented.
