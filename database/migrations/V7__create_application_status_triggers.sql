-- Compute cached status; zero steps must remain 'Mới'.
CREATE FUNCTION app.compute_ho_so_trang_thai(p_ma_hs BIGINT) RETURNS VOID
LANGUAGE plpgsql SET search_path = pg_catalog, app AS $$
BEGIN
 UPDATE app.ho_so h SET trang_thai = CASE
  WHEN EXISTS (SELECT 1 FROM app.buoc_duyet b JOIN app.quyet_dinh_duyet q ON q.ma_buoc=b.id WHERE b.ma_hs=p_ma_hs AND q.ket_qua='Từ chối') THEN 'Từ chối'
  WHEN EXISTS (SELECT 1 FROM app.buoc_duyet b WHERE b.ma_hs=p_ma_hs)
   AND NOT EXISTS (SELECT 1 FROM app.buoc_duyet b WHERE b.ma_hs=p_ma_hs AND b.trang_thai_buoc <> 'Hoàn thành')
   AND NOT EXISTS (SELECT 1 FROM app.buoc_duyet b LEFT JOIN app.quyet_dinh_duyet q ON q.ma_buoc=b.id WHERE b.ma_hs=p_ma_hs AND (q.id IS NULL OR q.ket_qua <> 'Đồng ý')) THEN 'Đã duyệt'
  WHEN EXISTS (SELECT 1 FROM app.buoc_duyet b WHERE b.ma_hs=p_ma_hs AND b.trang_thai_buoc IN ('Đang xử lý','Hoàn thành')) THEN 'Đang duyệt'
  ELSE 'Mới' END
 WHERE h.id=p_ma_hs;
END $$;
CREATE FUNCTION app.trg_refresh_ho_so_from_step() RETURNS trigger
LANGUAGE plpgsql SET search_path = pg_catalog, app AS $$
BEGIN
 IF TG_OP = 'DELETE' THEN
  PERFORM app.compute_ho_so_trang_thai(OLD.ma_hs);
  RETURN OLD;
 END IF;
 PERFORM app.compute_ho_so_trang_thai(NEW.ma_hs);
 IF TG_OP = 'UPDATE' AND OLD.ma_hs IS DISTINCT FROM NEW.ma_hs THEN
  PERFORM app.compute_ho_so_trang_thai(OLD.ma_hs);
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER trg_step_status AFTER INSERT OR UPDATE OR DELETE ON app.buoc_duyet
FOR EACH ROW EXECUTE FUNCTION app.trg_refresh_ho_so_from_step();
CREATE FUNCTION app.trg_refresh_ho_so_from_decision() RETURNS trigger
LANGUAGE plpgsql SET search_path = pg_catalog, app AS $$
DECLARE v_hs BIGINT;
BEGIN
 IF TG_OP = 'DELETE' THEN
  SELECT b.ma_hs INTO v_hs FROM app.buoc_duyet b WHERE b.id=OLD.ma_buoc;
 ELSE
  SELECT b.ma_hs INTO v_hs FROM app.buoc_duyet b WHERE b.id=NEW.ma_buoc;
 END IF;
 IF v_hs IS NOT NULL THEN PERFORM app.compute_ho_so_trang_thai(v_hs); END IF;
 IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER trg_decision_status AFTER INSERT OR UPDATE OR DELETE ON app.quyet_dinh_duyet
FOR EACH ROW EXECUTE FUNCTION app.trg_refresh_ho_so_from_decision();
