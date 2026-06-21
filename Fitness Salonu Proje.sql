CREATE DATABASE IF NOT EXISTS fitness_salonu
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_turkish_ci;

USE fitness_salonu;

CREATE TABLE uyelik_paketleri (
    paket_id         INT           NOT NULL AUTO_INCREMENT,
    paket_adi        VARCHAR(100)  NOT NULL,
    sure_gun         INT           NOT NULL,
    ucret            DECIMAL(10,2) NOT NULL,
    max_giris_gun    INT           DEFAULT NULL,
    antrenor_dahil   TINYINT(1)    NOT NULL DEFAULT 0,
    aciklama         TEXT          DEFAULT NULL,
    aktif            TINYINT(1)    NOT NULL DEFAULT 1,
    olusturma_tarihi DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (paket_id)
) ENGINE=InnoDB COMMENT='Salon üyelik paket tanımları';

CREATE TABLE antrenorler (
    antrenor_id    INT           NOT NULL AUTO_INCREMENT,
    ad             VARCHAR(50)   NOT NULL,
    soyad          VARCHAR(50)   NOT NULL,
    telefon        VARCHAR(15)   NOT NULL,
    email          VARCHAR(100)  NOT NULL,
    uzmanlik_alani VARCHAR(100)  DEFAULT NULL,
    sertifika_no   VARCHAR(50)   DEFAULT NULL,
    maas           DECIMAL(10,2) NOT NULL,
    ise_baslama    DATE          NOT NULL,
    calisma_durumu ENUM('aktif','izinli','ayrildi') NOT NULL DEFAULT 'aktif',
    PRIMARY KEY (antrenor_id),
    UNIQUE KEY uq_antrenor_email (email)
) ENGINE=InnoDB COMMENT='Salon antrenörleri';

CREATE TABLE uyeler (
    uye_id              INT          NOT NULL AUTO_INCREMENT,
    tc_kimlik           CHAR(11)     NOT NULL,
    ad                  VARCHAR(50)  NOT NULL,
    soyad               VARCHAR(50)  NOT NULL,
    dogum_tarihi        DATE         NOT NULL,
    cinsiyet            ENUM('E','K') NOT NULL,
    telefon             VARCHAR(15)  NOT NULL,
    email               VARCHAR(100) DEFAULT NULL,
    adres               TEXT         DEFAULT NULL,
    acil_iletisim_ad    VARCHAR(100) DEFAULT NULL,
    acil_iletisim_tel   VARCHAR(15)  DEFAULT NULL,
    kayit_tarihi        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    uye_durumu          ENUM('aktif','pasif','donduruldu') NOT NULL DEFAULT 'aktif',
    kisisel_antrenor_id INT          DEFAULT NULL,
    PRIMARY KEY (uye_id),
    UNIQUE KEY uq_uye_tc    (tc_kimlik),
    UNIQUE KEY uq_uye_email (email),
    CONSTRAINT fk_uye_antrenor FOREIGN KEY (kisisel_antrenor_id)
        REFERENCES antrenorler(antrenor_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Salonun kayıtlı üyeleri';

CREATE TABLE uyelikler (
    uyelik_id        INT           NOT NULL AUTO_INCREMENT,
    uye_id           INT           NOT NULL,
    paket_id         INT           NOT NULL,
    baslangic_tarihi DATE          NOT NULL,
    bitis_tarihi     DATE          NOT NULL,
    ucret_odendi     DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    odeme_durumu     ENUM('odendi','bekliyor','iptal') NOT NULL DEFAULT 'bekliyor',
    notlar           TEXT          DEFAULT NULL,
    PRIMARY KEY (uyelik_id),
    CONSTRAINT fk_uyelik_uye   FOREIGN KEY (uye_id)   REFERENCES uyeler(uye_id)             ON DELETE CASCADE  ON UPDATE CASCADE,
    CONSTRAINT fk_uyelik_paket FOREIGN KEY (paket_id) REFERENCES uyelik_paketleri(paket_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Üye abonelik dönemleri';

CREATE TABLE odeme_kayitlari (
    odeme_id      INT           NOT NULL AUTO_INCREMENT,
    uyelik_id     INT           NOT NULL,
    uye_id        INT           NOT NULL,
    odeme_tarihi  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    tutar         DECIMAL(10,2) NOT NULL,
    odeme_yontemi ENUM('nakit','kredi_karti','banka_havalesi','mobil_odeme') NOT NULL,
    islem_no      VARCHAR(50)   DEFAULT NULL,
    kasiyer_id    INT           DEFAULT NULL,
    notlar        TEXT          DEFAULT NULL,
    PRIMARY KEY (odeme_id),
    CONSTRAINT fk_odeme_uyelik  FOREIGN KEY (uyelik_id)  REFERENCES uyelikler(uyelik_id)      ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_odeme_uye     FOREIGN KEY (uye_id)     REFERENCES uyeler(uye_id)             ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_odeme_kasiyer FOREIGN KEY (kasiyer_id) REFERENCES antrenorler(antrenor_id)   ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Üyelik ödeme işlemleri';

CREATE TABLE saglik_bilgileri (
    saglik_id            INT        NOT NULL AUTO_INCREMENT,
    uye_id               INT        NOT NULL,
    kayit_tarihi         DATE       NOT NULL DEFAULT (CURRENT_DATE),
    kronik_hastalik      TEXT       DEFAULT NULL,
    ameliyat_gecmisi     TEXT       DEFAULT NULL,
    kullanilan_ilaclar   TEXT       DEFAULT NULL,
    alerji               TEXT       DEFAULT NULL,
    doktor_onayi         TINYINT(1) NOT NULL DEFAULT 0,
    doktor_adi           VARCHAR(100) DEFAULT NULL,
    sigara               TINYINT(1) NOT NULL DEFAULT 0,
    alkol                ENUM('yok','az','orta','fazla') DEFAULT 'yok',
    egzersiz_kisitlamasi TEXT       DEFAULT NULL,
    guncelleme_tarihi    DATETIME   DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (saglik_id),
    CONSTRAINT fk_saglik_uye FOREIGN KEY (uye_id) REFERENCES uyeler(uye_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Üyelerin sağlık bilgileri ve kısıtlamaları';

CREATE TABLE fiziksel_olcumler (
    olcum_id        INT           NOT NULL AUTO_INCREMENT,
    uye_id          INT           NOT NULL,
    olcum_tarihi    DATE          NOT NULL DEFAULT (CURRENT_DATE),
    boy_cm          DECIMAL(5,1)  DEFAULT NULL,
    kilo_kg         DECIMAL(5,2)  DEFAULT NULL,
    bmi             DECIMAL(4,2)  DEFAULT NULL,
    vucut_yag_orani DECIMAL(5,2)  DEFAULT NULL,
    kas_kitlesi_kg  DECIMAL(5,2)  DEFAULT NULL,
    gogus_cm        DECIMAL(5,1)  DEFAULT NULL,
    bel_cm          DECIMAL(5,1)  DEFAULT NULL,
    kalca_cm        DECIMAL(5,1)  DEFAULT NULL,
    ust_kol_sag_cm  DECIMAL(5,1)  DEFAULT NULL,
    ust_kol_sol_cm  DECIMAL(5,1)  DEFAULT NULL,
    bacak_sag_cm    DECIMAL(5,1)  DEFAULT NULL,
    bacak_sol_cm    DECIMAL(5,1)  DEFAULT NULL,
    omuz_cm         DECIMAL(5,1)  DEFAULT NULL,
    nabiz_istirahat INT           DEFAULT NULL,
    kan_basinci     VARCHAR(10)   DEFAULT NULL,
    olcumu_yapan_id INT           DEFAULT NULL,
    notlar          TEXT          DEFAULT NULL,
    PRIMARY KEY (olcum_id),
    CONSTRAINT fk_olcum_uye      FOREIGN KEY (uye_id)          REFERENCES uyeler(uye_id)            ON DELETE CASCADE  ON UPDATE CASCADE,
    CONSTRAINT fk_olcum_antrenor FOREIGN KEY (olcumu_yapan_id) REFERENCES antrenorler(antrenor_id)  ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Üye fiziksel ölçüm takibi (zaman serisi)';

CREATE TABLE spor_dallari (
    dal_id   INT          NOT NULL AUTO_INCREMENT,
    dal_adi  VARCHAR(100) NOT NULL,
    kategori ENUM('kuvvet','kardiyo','esneklik','denge','takim','karisik','diger') NOT NULL DEFAULT 'diger',
    aciklama TEXT         DEFAULT NULL,
    PRIMARY KEY (dal_id),
    UNIQUE KEY uq_dal_adi (dal_adi)
) ENGINE=InnoDB COMMENT='Spor dalları referans tablosu';

CREATE TABLE uye_spor_dallari (
    uye_id         INT        NOT NULL,
    dal_id         INT        NOT NULL,
    ilgi_seviyesi  ENUM('baslangic','orta','ileri') NOT NULL DEFAULT 'baslangic',
    katilim_tarihi DATE       DEFAULT (CURRENT_DATE),
    aktif          TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (uye_id, dal_id),
    CONSTRAINT fk_usd_uye FOREIGN KEY (uye_id) REFERENCES uyeler(uye_id)       ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_usd_dal FOREIGN KEY (dal_id) REFERENCES spor_dallari(dal_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Üye - spor dalı ilgi ilişkisi (N:M)';

CREATE TABLE giris_cikis_kayitlari (
    kayit_id          INT        NOT NULL AUTO_INCREMENT,
    uye_id            INT        NOT NULL,
    giris_zamani      DATETIME   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    cikis_zamani      DATETIME   DEFAULT NULL,
    kalinma_suresi_dk INT        DEFAULT NULL,
    giris_yontemi     ENUM('kart','qr_kod','manuel') NOT NULL DEFAULT 'kart',
    PRIMARY KEY (kayit_id),
    CONSTRAINT fk_gc_uye FOREIGN KEY (uye_id) REFERENCES uyeler(uye_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Üye giriş-çıkış saati takibi';

CREATE TABLE egzersizler (
    egzersiz_id     INT          NOT NULL AUTO_INCREMENT,
    egzersiz_adi    VARCHAR(100) NOT NULL,
    kas_grubu       VARCHAR(100) DEFAULT NULL,
    ekipman_gerekli TINYINT(1)   NOT NULL DEFAULT 0,
    zorluk_seviyesi ENUM('kolay','orta','zor') NOT NULL DEFAULT 'orta',
    aciklama        TEXT         DEFAULT NULL,
    video_url       VARCHAR(255) DEFAULT NULL,
    PRIMARY KEY (egzersiz_id),
    UNIQUE KEY uq_egzersiz_adi (egzersiz_adi)
) ENGINE=InnoDB COMMENT='Egzersiz hareketi kütüphanesi';

CREATE TABLE antrenman_programlari (
    program_id          INT          NOT NULL AUTO_INCREMENT,
    uye_id              INT          NOT NULL,
    antrenor_id         INT          NOT NULL,
    program_adi         VARCHAR(150) NOT NULL,
    amac                ENUM('kilo_verme','kas_kazanma','dayaniklilik','esneklik','genel_saglik') NOT NULL DEFAULT 'genel_saglik',
    baslangic_tarihi    DATE         NOT NULL,
    bitis_tarihi        DATE         DEFAULT NULL,
    haftalik_gun_sayisi TINYINT      NOT NULL DEFAULT 3,
    aktif               TINYINT(1)   NOT NULL DEFAULT 1,
    olusturma_tarihi    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (program_id),
    CONSTRAINT fk_program_uye      FOREIGN KEY (uye_id)      REFERENCES uyeler(uye_id)            ON DELETE CASCADE  ON UPDATE CASCADE,
    CONSTRAINT fk_program_antrenor FOREIGN KEY (antrenor_id) REFERENCES antrenorler(antrenor_id)  ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Kişiselleştirilmiş antrenman programları';

CREATE TABLE program_egzersiz_detaylari (
    detay_id      INT          NOT NULL AUTO_INCREMENT,
    program_id    INT          NOT NULL,
    egzersiz_id   INT          NOT NULL,
    gun_no        TINYINT      NOT NULL,
    set_sayisi    TINYINT      NOT NULL DEFAULT 3,
    tekrar_sayisi TINYINT      NOT NULL DEFAULT 10,
    agirlik_kg    DECIMAL(6,2) DEFAULT NULL,
    dinlenme_sn   INT          DEFAULT 60,
    sira          TINYINT      NOT NULL DEFAULT 1,
    PRIMARY KEY (detay_id),
    CONSTRAINT fk_ped_program  FOREIGN KEY (program_id)  REFERENCES antrenman_programlari(program_id) ON DELETE CASCADE  ON UPDATE CASCADE,
    CONSTRAINT fk_ped_egzersiz FOREIGN KEY (egzersiz_id) REFERENCES egzersizler(egzersiz_id)          ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Programa bağlı egzersiz detayları (N:M)';

CREATE TABLE gunluk_antrenman_kayitlari (
    antrenman_id   INT        NOT NULL AUTO_INCREMENT,
    uye_id         INT        NOT NULL,
    program_id     INT        DEFAULT NULL,
    tarih          DATE       NOT NULL DEFAULT (CURRENT_DATE),
    baslangic_saat TIME       DEFAULT NULL,
    bitis_saat     TIME       DEFAULT NULL,
    toplam_sure_dk INT        DEFAULT NULL,
    antrenman_tipi ENUM('kuvvet','kardiyo','esneklik','karisik','grup_dersi') NOT NULL DEFAULT 'karisik',
    yogunluk       ENUM('dusuk','orta','yuksek') NOT NULL DEFAULT 'orta',
    kalori_yakilan INT        DEFAULT NULL,
    nabiz_ort      INT        DEFAULT NULL,
    antrenor_id    INT        DEFAULT NULL,
    uye_notu       TEXT       DEFAULT NULL,
    antrenor_notu  TEXT       DEFAULT NULL,
    PRIMARY KEY (antrenman_id),
    CONSTRAINT fk_gak_uye      FOREIGN KEY (uye_id)     REFERENCES uyeler(uye_id)                    ON DELETE CASCADE  ON UPDATE CASCADE,
    CONSTRAINT fk_gak_program  FOREIGN KEY (program_id) REFERENCES antrenman_programlari(program_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_gak_antrenor FOREIGN KEY (antrenor_id) REFERENCES antrenorler(antrenor_id)          ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Üyenin günlük antrenman performans kaydı';

CREATE TABLE degisiklik_loglari (
    log_id         INT      NOT NULL AUTO_INCREMENT,
    tablo_adi      VARCHAR(64) NOT NULL,
    kayit_id       INT      NOT NULL,
    islem_tipi     ENUM('INSERT','UPDATE','DELETE') NOT NULL,
    degistiren_uye INT      DEFAULT NULL,
    eski_deger     TEXT     DEFAULT NULL,
    yeni_deger     TEXT     DEFAULT NULL,
    islem_zamani   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (log_id)
) ENGINE=InnoDB COMMENT='Otomatik denetim günlüğü (trigger tarafından doldurulur)';

CREATE INDEX idx_uye_ad_soyad    ON uyeler(soyad, ad);
CREATE INDEX idx_uye_durum       ON uyeler(uye_durumu);
CREATE INDEX idx_gc_giris_zamani ON giris_cikis_kayitlari(giris_zamani);
CREATE INDEX idx_gc_uye_tarih    ON giris_cikis_kayitlari(uye_id, giris_zamani);
CREATE INDEX idx_olcum_uye_tarih ON fiziksel_olcumler(uye_id, olcum_tarihi);
CREATE INDEX idx_gak_uye_tarih   ON gunluk_antrenman_kayitlari(uye_id, tarih);
CREATE INDEX idx_gak_tarih       ON gunluk_antrenman_kayitlari(tarih);
CREATE INDEX idx_uyelik_bitis    ON uyelikler(bitis_tarihi);
CREATE INDEX idx_uyelik_uye_aktif ON uyelikler(uye_id, odeme_durumu);
CREATE INDEX idx_odeme_tarih     ON odeme_kayitlari(odeme_tarihi);

CREATE VIEW v_aktif_uyeler AS
SELECT
    u.uye_id,
    u.ad,
    u.soyad,
    u.cinsiyet,
    TIMESTAMPDIFF(YEAR, u.dogum_tarihi, CURDATE()) AS yas,
    u.telefon,
    u.email,
    up.paket_adi,
    ul.bitis_tarihi,
    DATEDIFF(ul.bitis_tarihi, CURDATE())           AS kalan_gun,
    CONCAT(a.ad, ' ', a.soyad)                    AS antrenor_adi
FROM uyeler u
JOIN uyelikler ul        ON u.uye_id    = ul.uye_id   AND ul.odeme_durumu = 'odendi'
JOIN uyelik_paketleri up ON ul.paket_id = up.paket_id
LEFT JOIN antrenorler a  ON u.kisisel_antrenor_id = a.antrenor_id
WHERE u.uye_durumu = 'aktif'
  AND ul.bitis_tarihi >= CURDATE();

CREATE VIEW v_son_olcumler AS
SELECT
    u.uye_id,
    u.ad,
    u.soyad,
    fo.olcum_tarihi,
    fo.boy_cm,
    fo.kilo_kg,
    fo.bmi,
    fo.vucut_yag_orani,
    fo.kas_kitlesi_kg,
    fo.bel_cm,
    fo.kan_basinci,
    CONCAT(a.ad, ' ', a.soyad) AS olcumu_yapan
FROM uyeler u
JOIN fiziksel_olcumler fo ON u.uye_id = fo.uye_id
LEFT JOIN antrenorler a   ON fo.olcumu_yapan_id = a.antrenor_id
WHERE fo.olcum_tarihi = (
    SELECT MAX(olcum_tarihi)
    FROM fiziksel_olcumler
    WHERE uye_id = u.uye_id  
);

CREATE VIEW v_bugun_aktif_girisler AS
SELECT
    u.uye_id,
    u.ad,
    u.soyad,
    gc.giris_zamani,
    gc.cikis_zamani,
    gc.kalinma_suresi_dk,
    gc.giris_yontemi
FROM giris_cikis_kayitlari gc
JOIN uyeler u ON gc.uye_id = u.uye_id
WHERE DATE(gc.giris_zamani) = CURDATE();

CREATE VIEW v_antrenor_is_yuku AS
SELECT
    a.antrenor_id,
    CONCAT(a.ad, ' ', a.soyad)      AS antrenor,
    a.uzmanlik_alani,
    COUNT(DISTINCT u.uye_id)        AS kisisel_uye_sayisi,
    COUNT(DISTINCT gak.antrenman_id) AS bu_ay_seans_sayisi
FROM antrenorler a
LEFT JOIN uyeler u
       ON a.antrenor_id = u.kisisel_antrenor_id AND u.uye_durumu = 'aktif'
LEFT JOIN gunluk_antrenman_kayitlari gak
       ON a.antrenor_id = gak.antrenor_id
      AND MONTH(gak.tarih) = MONTH(CURDATE())
      AND YEAR(gak.tarih)  = YEAR(CURDATE())
WHERE a.calisma_durumu = 'aktif'
GROUP BY a.antrenor_id, a.ad, a.soyad, a.uzmanlik_alani;

CREATE VIEW v_aylik_gelir_ozet AS
SELECT
    YEAR(ok.odeme_tarihi)  AS yil,
    MONTH(ok.odeme_tarihi) AS ay,
    up.paket_adi,
    COUNT(ok.odeme_id)     AS islem_sayisi,
    SUM(ok.tutar)          AS toplam_gelir,
    AVG(ok.tutar)          AS ortalama_odeme
FROM odeme_kayitlari ok
JOIN uyelikler ul        ON ok.uyelik_id  = ul.uyelik_id
JOIN uyelik_paketleri up ON ul.paket_id   = up.paket_id
GROUP BY YEAR(ok.odeme_tarihi), MONTH(ok.odeme_tarihi), up.paket_adi;

DELIMITER //
CREATE PROCEDURE sp_uye_raporu(IN p_uye_id INT)
BEGIN
    -- Temel üye bilgileri
    SELECT
        u.uye_id, u.ad, u.soyad, u.tc_kimlik,
        TIMESTAMPDIFF(YEAR, u.dogum_tarihi, CURDATE()) AS yas,
        u.telefon, u.email, u.uye_durumu,
        CONCAT(a.ad, ' ', a.soyad) AS antrenor
    FROM uyeler u
    LEFT JOIN antrenorler a ON u.kisisel_antrenor_id = a.antrenor_id
    WHERE u.uye_id = p_uye_id;

    -- Aktif üyelik paketi
    SELECT up.paket_adi, ul.baslangic_tarihi, ul.bitis_tarihi,
           DATEDIFF(ul.bitis_tarihi, CURDATE()) AS kalan_gun,
           ul.odeme_durumu
    FROM uyelikler ul
    JOIN uyelik_paketleri up ON ul.paket_id = up.paket_id
    WHERE ul.uye_id = p_uye_id
      AND ul.bitis_tarihi >= CURDATE()
    ORDER BY ul.bitis_tarihi DESC
    LIMIT 1;

    -- Son fiziksel ölçüm
    SELECT olcum_tarihi, boy_cm, kilo_kg, bmi, vucut_yag_orani, bel_cm
    FROM fiziksel_olcumler
    WHERE uye_id = p_uye_id
    ORDER BY olcum_tarihi DESC
    LIMIT 1;

    -- Bu ayki antrenman istatistiği
    SELECT
        COUNT(*)                    AS bu_ay_antrenman_sayisi,
        SUM(toplam_sure_dk)         AS toplam_antrenman_suresi_dk,
        ROUND(AVG(toplam_sure_dk))  AS ortalama_sure_dk,
        SUM(kalori_yakilan)         AS toplam_kalori
    FROM gunluk_antrenman_kayitlari
    WHERE uye_id     = p_uye_id
      AND MONTH(tarih) = MONTH(CURDATE())
      AND YEAR(tarih)  = YEAR(CURDATE());
END //

CREATE PROCEDURE sp_yeni_uyelik_kaydi(
    IN  p_tc          CHAR(11),
    IN  p_ad          VARCHAR(50),
    IN  p_soyad       VARCHAR(50),
    IN  p_dogum       DATE,
    IN  p_cinsiyet    CHAR(1),
    IN  p_telefon     VARCHAR(15),
    IN  p_email       VARCHAR(100),
    IN  p_paket_id    INT,
    IN  p_odeme_yont  VARCHAR(30),
    OUT p_yeni_uye_id INT,
    OUT p_sonuc_mesaj VARCHAR(200)
)
BEGIN
    DECLARE v_paket_ucret DECIMAL(10,2);
    DECLARE v_uyelik_id   INT;

    SELECT ucret INTO v_paket_ucret
    FROM uyelik_paketleri
    WHERE paket_id = p_paket_id AND aktif = 1;

    IF v_paket_ucret IS NULL THEN
        SET p_yeni_uye_id = NULL;
        SET p_sonuc_mesaj = 'HATA: Geçersiz veya pasif paket seçildi.';
    ELSE
        INSERT INTO uyeler(tc_kimlik, ad, soyad, dogum_tarihi, cinsiyet, telefon, email)
        VALUES(p_tc, p_ad, p_soyad, p_dogum, p_cinsiyet, p_telefon, p_email);

        SET p_yeni_uye_id = LAST_INSERT_ID();

        INSERT INTO uyelikler(uye_id, paket_id, baslangic_tarihi, bitis_tarihi, ucret_odendi, odeme_durumu)
        SELECT p_yeni_uye_id, p_paket_id,
               CURDATE(),
               DATE_ADD(CURDATE(), INTERVAL sure_gun DAY),
               ucret, 'odendi'
        FROM uyelik_paketleri
        WHERE paket_id = p_paket_id;

        SET v_uyelik_id = LAST_INSERT_ID();

        INSERT INTO odeme_kayitlari(uyelik_id, uye_id, tutar, odeme_yontemi)
        VALUES(v_uyelik_id, p_yeni_uye_id, v_paket_ucret, p_odeme_yont);

        SET p_sonuc_mesaj = CONCAT('Başarılı. Yeni üye ID: ', p_yeni_uye_id);
    END IF;
END //

CREATE PROCEDURE sp_aylik_aktivite_raporu(IN p_yil INT, IN p_ay INT)
BEGIN
    DECLARE v_baslangic DATE;
    DECLARE v_bitis     DATE;

    SET v_baslangic = STR_TO_DATE(CONCAT(p_yil, '-', LPAD(p_ay, 2, '0'), '-01'), '%Y-%m-%d');
    SET v_bitis     = LAST_DAY(v_baslangic);

    SELECT
        u.uye_id,
        CONCAT(u.ad, ' ', u.soyad)               AS uye_adi,
        up.paket_adi,
        COUNT(DISTINCT gak.antrenman_id)          AS antrenman_sayisi,
        COALESCE(SUM(gak.toplam_sure_dk), 0)      AS toplam_dakika,
        COALESCE(SUM(gak.kalori_yakilan), 0)      AS toplam_kalori,
        COALESCE(COUNT(DISTINCT gc.kayit_id), 0)  AS salon_giris_sayisi
    FROM uyeler u
    JOIN uyelikler ul        ON u.uye_id    = ul.uye_id
    JOIN uyelik_paketleri up ON ul.paket_id = up.paket_id
    LEFT JOIN gunluk_antrenman_kayitlari gak
           ON u.uye_id = gak.uye_id
          AND gak.tarih BETWEEN v_baslangic AND v_bitis
    LEFT JOIN giris_cikis_kayitlari gc
           ON u.uye_id = gc.uye_id
          AND DATE(gc.giris_zamani) BETWEEN v_baslangic AND v_bitis
    WHERE u.uye_durumu = 'aktif'
    GROUP BY u.uye_id, u.ad, u.soyad, up.paket_adi
    ORDER BY antrenman_sayisi DESC;
END //

DELIMITER ;

DELIMITER //
CREATE TRIGGER tr_giris_cikis_sure_hesapla
    BEFORE UPDATE ON giris_cikis_kayitlari
    FOR EACH ROW
BEGIN
    IF NEW.cikis_zamani IS NOT NULL AND OLD.cikis_zamani IS NULL THEN
        SET NEW.kalinma_suresi_dk =
            TIMESTAMPDIFF(MINUTE, NEW.giris_zamani, NEW.cikis_zamani);
    END IF;
END //


CREATE TRIGGER tr_olcum_bmi_hesapla
    BEFORE INSERT ON fiziksel_olcumler
    FOR EACH ROW
BEGIN
    IF NEW.kilo_kg IS NOT NULL AND NEW.boy_cm IS NOT NULL AND NEW.boy_cm > 0 THEN
        SET NEW.bmi = NEW.kilo_kg / POW(NEW.boy_cm / 100, 2);
    END IF;
END //

CREATE TRIGGER tr_uye_durum_log
    AFTER UPDATE ON uyeler
    FOR EACH ROW
BEGIN
    IF OLD.uye_durumu != NEW.uye_durumu THEN
        INSERT INTO degisiklik_loglari(tablo_adi, kayit_id, islem_tipi, eski_deger, yeni_deger)
        VALUES(
            'uyeler', NEW.uye_id, 'UPDATE',
            JSON_OBJECT('uye_durumu', OLD.uye_durumu),
            JSON_OBJECT('uye_durumu', NEW.uye_durumu)
        );
    END IF;
END //

CREATE TRIGGER tr_antrenman_silindi_log
    AFTER DELETE ON gunluk_antrenman_kayitlari
    FOR EACH ROW
BEGIN
    INSERT INTO degisiklik_loglari(tablo_adi, kayit_id, islem_tipi, eski_deger)
    VALUES(
        'gunluk_antrenman_kayitlari', OLD.antrenman_id, 'DELETE',
        JSON_OBJECT(
            'uye_id',  OLD.uye_id,
            'tarih',   OLD.tarih,
            'sure_dk', OLD.toplam_sure_dk,
            'kalori',  OLD.kalori_yakilan
        )
    );
END //

DELIMITER ;

DELIMITER //
CREATE FUNCTION fn_bmi_kategori(p_bmi DECIMAL(5,2))
RETURNS VARCHAR(30)
DETERMINISTIC
BEGIN
    DECLARE v_kategori VARCHAR(30);
    IF    p_bmi < 18.5 THEN SET v_kategori = 'Zayıf';
    ELSEIF p_bmi < 25.0 THEN SET v_kategori = 'Normal';
    ELSEIF p_bmi < 30.0 THEN SET v_kategori = 'Fazla Kilolu';
    ELSEIF p_bmi < 35.0 THEN SET v_kategori = 'Obez (Sınıf 1)';
    ELSEIF p_bmi < 40.0 THEN SET v_kategori = 'Obez (Sınıf 2)';
    ELSE                      SET v_kategori = 'Morbid Obez';
    END IF;
    RETURN v_kategori;
END //

CREATE FUNCTION fn_uyelik_durum_etiketi(p_bitis_tarihi DATE)
RETURNS VARCHAR(30)
DETERMINISTIC
BEGIN
    DECLARE v_kalan INT;
    SET v_kalan = DATEDIFF(p_bitis_tarihi, CURDATE());
    IF    v_kalan < 0  THEN RETURN 'Süresi Dolmuş';
    ELSEIF v_kalan = 0 THEN RETURN 'Bugün Bitiyor!';
    ELSEIF v_kalan <= 7 THEN RETURN CONCAT(v_kalan, ' gün kaldı ⚠');
    ELSE                     RETURN CONCAT(v_kalan, ' gün kaldı');
    END IF;
END //

DELIMITER ;
INSERT INTO uyelik_paketleri(paket_adi, sure_gun, ucret, antrenor_dahil, aciklama) VALUES
('Aylık Basic',        30,   399.00, 0, 'Temel salon erişimi'),
('Aylık Premium',      30,   699.00, 1, 'Kişisel antrenör dahil'),
('3 Aylık Avantajlı', 90,   999.00, 0, '3 ay süre avantajı'),
('Yıllık Üyelik',     365, 2999.00, 1, 'Yıllık en iyi fiyat + antrenör');

INSERT INTO antrenorler(ad, soyad, telefon, email, uzmanlik_alani, maas, ise_baslama) VALUES
('Kerem', 'Yıldız', '05301112233', 'kerem@salon.com', 'Kuvvet & Crossfit', 25000.00, '2021-03-01'),
('Selin', 'Arslan', '05302223344', 'selin@salon.com', 'Yoga & Pilates',    22000.00, '2022-01-15'),
('Burak', 'Çelik',  '05303334455', 'burak@salon.com', 'Kardiyovasküler',   23000.00, '2020-09-10'),
('Merve', 'Kaya',   '05304445566', 'merve@salon.com', 'Beslenme & Diyet',  24000.00, '2023-02-20');

INSERT INTO spor_dallari(dal_adi, kategori, aciklama) VALUES
('Crossfit',     'kuvvet',   'Yoğun fonksiyonel antrenman'),
('Yoga',         'esneklik', 'Zihin-beden dengesi'),
('Pilates',      'denge',    'Core güçlendirme'),
('Spinning',     'kardiyo',  'Sabit bisiklet grubu'),
('Zumba',        'kardiyo',  'Dans bazlı kardiyo'),
('Powerlifting', 'kuvvet',   'Maksimum kuvvet'),
('Yüzme',        'kardiyo',  'Su sporları'),
('Boks',         'karisik',  'Dövüş sanatı / kondisyon');

INSERT INTO uyeler(tc_kimlik, ad, soyad, dogum_tarihi, cinsiyet, telefon, email, kisisel_antrenor_id) VALUES
('12345678901', 'Ali',    'Yılmaz', '1990-05-15', 'E', '05311234567', 'ali@email.com',    1),
('23456789012', 'Ayşe',   'Demir',  '1995-08-22', 'K', '05322345678', 'ayse@email.com',   2),
('34567890123', 'Mehmet', 'Şahin',  '1988-12-01', 'E', '05333456789', 'mehmet@email.com', 1),
('45678901234', 'Fatma',  'Koç',    '2000-03-30', 'K', '05344567890', 'fatma@email.com',  3),
('56789012345', 'Emre',   'Kurt',   '1993-07-11', 'E', '05355678901', 'emre@email.com',   NULL);

INSERT INTO egzersizler(egzersiz_adi, kas_grubu, ekipman_gerekli, zorluk_seviyesi) VALUES
('Bench Press',    'Göğüs, Triceps', 1, 'orta'),
('Squat',          'Bacak, Kalça',   1, 'orta'),
('Deadlift',       'Sırt, Bacak',    1, 'zor'),
('Pull-up',        'Sırt, Biceps',   1, 'orta'),
('Plank',          'Karın',          0, 'kolay'),
('Burpee',         'Tüm vücut',      0, 'zor'),
('Lunges',         'Bacak, Kalça',   0, 'kolay'),
('Shoulder Press', 'Omuz, Triceps',  1, 'orta');

INSERT INTO uyelikler(uye_id, paket_id, baslangic_tarihi, bitis_tarihi, ucret_odendi, odeme_durumu) VALUES
(1, 2, DATE_SUB(CURDATE(), INTERVAL 15 DAY), DATE_ADD(CURDATE(), INTERVAL 5  DAY),  699.00,  'odendi'),
(2, 4, DATE_SUB(CURDATE(), INTERVAL 15 DAY), DATE_ADD(CURDATE(), INTERVAL 15 DAY), 2999.00, 'odendi'),
(3, 3, DATE_SUB(CURDATE(), INTERVAL 10 DAY), DATE_ADD(CURDATE(), INTERVAL 340 DAY), 999.00, 'odendi'),
(4, 1, DATE_SUB(CURDATE(), INTERVAL 15 DAY), DATE_ADD(CURDATE(), INTERVAL 3  DAY),  399.00,  'odendi'),
(5, 1, DATE_SUB(CURDATE(), INTERVAL 15 DAY), DATE_ADD(CURDATE(), INTERVAL 7  DAY),  399.00,  'odendi');

INSERT INTO odeme_kayitlari(uyelik_id, uye_id, tutar, odeme_yontemi) VALUES
(1, 1,  699.00, 'kredi_karti'),
(2, 2, 2999.00, 'banka_havalesi'),
(3, 3,  999.00, 'nakit'),
(4, 4,  399.00, 'nakit'),
(5, 5,  399.00, 'mobil_odeme');

INSERT INTO saglik_bilgileri(uye_id, kronik_hastalik, doktor_onayi, egzersiz_kisitlamasi) VALUES
(1, NULL,             1, NULL),
(2, 'Hafif skolyoz', 1, 'Ağır deadlift yasak'),
(3, 'Hipertansiyon', 1, 'Maksimum yoğunluktan kaçın'),
(4, NULL,             1, NULL),
(5, NULL,             0, NULL);

INSERT INTO fiziksel_olcumler(uye_id, olcum_tarihi, boy_cm, kilo_kg, vucut_yag_orani, bel_cm, olcumu_yapan_id) VALUES
(1, DATE_SUB(CURDATE(), INTERVAL 50 DAY), 178.0, 82.5, 22.0, 88.0, 1),
(1, DATE_SUB(CURDATE(), INTERVAL 20 DAY), 178.0, 80.2, 20.5, 86.0, 1),
(2, DATE_SUB(CURDATE(), INTERVAL 50 DAY), 165.0, 62.0, 24.0, 70.0, 2),
(3, DATE_SUB(CURDATE(), INTERVAL 45 DAY), 175.0, 95.0, 28.5, 99.0, 3),
(4, DATE_SUB(CURDATE(), INTERVAL 40 DAY), 160.0, 58.0, 21.0, 65.0, 2);

INSERT INTO uye_spor_dallari(uye_id, dal_id, ilgi_seviyesi) VALUES
(1, 1, 'ileri'),      -- Ali → Crossfit
(1, 6, 'orta'),       -- Ali → Powerlifting
(2, 2, 'ileri'),      -- Ayşe → Yoga
(2, 3, 'orta'),       -- Ayşe → Pilates
(3, 6, 'ileri'),      -- Mehmet → Powerlifting
(4, 4, 'baslangic'),  -- Fatma → Spinning
(4, 5, 'baslangic'),  -- Fatma → Zumba
(5, 8, 'orta');       -- Emre → Boks

INSERT INTO giris_cikis_kayitlari(uye_id, giris_zamani, cikis_zamani) VALUES
(1, DATE_ADD(CURDATE(), INTERVAL  9 HOUR),  DATE_ADD(CURDATE(), INTERVAL 10.5  HOUR)),
(2, DATE_ADD(CURDATE(), INTERVAL 10 HOUR),  DATE_ADD(CURDATE(), INTERVAL 11    HOUR)),
(3, DATE_ADD(CURDATE(), INTERVAL 17 HOUR),  DATE_ADD(CURDATE(), INTERVAL 18.5  HOUR)),
(1, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL  9 HOUR), INTERVAL 1 DAY),
   DATE_SUB(DATE_ADD(CURDATE(), INTERVAL 10 HOUR), INTERVAL 1 DAY)),
(5, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL 18 HOUR), INTERVAL 1 DAY),
   DATE_SUB(DATE_ADD(CURDATE(), INTERVAL 19 HOUR), INTERVAL 1 DAY));

INSERT INTO antrenman_programlari(uye_id, antrenor_id, program_adi, amac, baslangic_tarihi, bitis_tarihi, haftalik_gun_sayisi) VALUES
(1, 1, '8 Haftalık Kas Kazanma Programı', 'kas_kazanma', DATE_SUB(CURDATE(), INTERVAL 20 DAY), DATE_ADD(CURDATE(), INTERVAL 40 DAY), 4),
(2, 2, '12 Haftalık Yoga & Esneklik',     'esneklik',    DATE_SUB(CURDATE(), INTERVAL 20 DAY), DATE_ADD(CURDATE(), INTERVAL 60 DAY), 3),
(3, 1, 'Kilo Verme Programı',             'kilo_verme',  DATE_SUB(CURDATE(), INTERVAL 15 DAY), DATE_ADD(CURDATE(), INTERVAL 75 DAY), 5);

INSERT INTO gunluk_antrenman_kayitlari(uye_id, program_id, tarih, baslangic_saat, bitis_saat, toplam_sure_dk, antrenman_tipi, yogunluk, kalori_yakilan, antrenor_id) VALUES
(1, 1, CURDATE(),                                  '09:05:00', '10:25:00', 80, 'kuvvet',   'yuksek', 520, 1),
(1, 1, DATE_SUB(CURDATE(), INTERVAL 2 DAY),        '09:00:00', '10:20:00', 80, 'kuvvet',   'yuksek', 510, 1),
(2, 2, CURDATE(),                                  '10:05:00', '10:55:00', 50, 'esneklik', 'orta',   200, 2),
(3, 3, DATE_SUB(CURDATE(), INTERVAL 1 DAY),        '17:35:00', '18:55:00', 80, 'karisik',  'yuksek', 650, 1),
(5, NULL, DATE_SUB(CURDATE(), INTERVAL 1 DAY),     '18:05:00', '19:25:00', 80, 'kardiyo',  'orta',   400, NULL);


--  ÖRNEK SORGULAR
SELECT
    CONCAT(u.ad, ' ', u.soyad)              AS uye_adi,
    up.paket_adi,
    ul.bitis_tarihi,
    CONCAT(a.ad, ' ', a.soyad)              AS antrenor_adi,
    fn_uyelik_durum_etiketi(ul.bitis_tarihi) AS uyelik_durumu
FROM uyeler u
INNER JOIN uyelikler ul        ON u.uye_id    = ul.uye_id AND ul.odeme_durumu = 'odendi'
INNER JOIN uyelik_paketleri up ON ul.paket_id = up.paket_id
LEFT  JOIN antrenorler a       ON u.kisisel_antrenor_id = a.antrenor_id
WHERE u.uye_durumu = 'aktif';

-- ─── Sağlık kısıtlaması olan üyeler ──────────
SELECT
    CONCAT(u.ad, ' ', u.soyad)                           AS uye,
    COALESCE(sb.egzersiz_kisitlamasi, 'Kısıtlama yok')   AS kisitlama,
    COALESCE(sb.kronik_hastalik,      'Yok')             AS hastalik,
    sb.doktor_onayi
FROM uyeler u
LEFT JOIN saglik_bilgileri sb ON u.uye_id = sb.uye_id
ORDER BY sb.egzersiz_kisitlamasi IS NULL, u.soyad;

-- ─── Bu ay yapılan antrenman seanslarının detayı ─────────
SELECT
    CONCAT(u.ad, ' ', u.soyad)  AS uye,
    gak.tarih,
    gak.toplam_sure_dk           AS sure_dk,
    gak.kalori_yakilan,
    gak.yogunluk,
    ap.program_adi,
    CONCAT(a.ad, ' ', a.soyad)  AS antrenor
FROM gunluk_antrenman_kayitlari gak
JOIN  uyeler u                       ON gak.uye_id     = u.uye_id
LEFT JOIN antrenman_programlari ap   ON gak.program_id = ap.program_id
LEFT JOIN antrenorler a              ON gak.antrenor_id = a.antrenor_id
WHERE MONTH(gak.tarih) = MONTH(CURDATE())
  AND YEAR(gak.tarih)  = YEAR(CURDATE())
ORDER BY gak.tarih DESC;

-- ─── Bu ay ortalama kalori yakımının üzerindekiler ───
SELECT
    CONCAT(u.ad, ' ', u.soyad) AS uye,
    SUM(gak.kalori_yakilan)    AS toplam_kalori
FROM gunluk_antrenman_kayitlari gak
JOIN uyeler u ON gak.uye_id = u.uye_id
WHERE MONTH(gak.tarih) = MONTH(CURDATE())
  AND YEAR(gak.tarih)  = YEAR(CURDATE())
GROUP BY u.uye_id, u.ad, u.soyad
HAVING SUM(gak.kalori_yakilan) > (
    SELECT AVG(toplam)
    FROM (
        SELECT SUM(kalori_yakilan) AS toplam
        FROM gunluk_antrenman_kayitlari
        WHERE MONTH(tarih) = MONTH(CURDATE())
          AND YEAR(tarih)  = YEAR(CURDATE())
        GROUP BY uye_id
    ) AS uye_kalori
);

-- ───Fiziksel ölçümü olmayan üyeler ─────────────
SELECT u.uye_id, CONCAT(u.ad, ' ', u.soyad) AS uye, u.kayit_tarihi
FROM uyeler u
WHERE NOT EXISTS (
    SELECT 1 FROM fiziksel_olcumler fo
    WHERE fo.uye_id = u.uye_id  
);

-- ─── Son ölçüm + BMI kategorisi ───────
SELECT
    v.ad, v.soyad, v.olcum_tarihi,
    v.kilo_kg, v.boy_cm, v.bmi,
    fn_bmi_kategori(v.bmi) AS bmi_kategori,
    v.olcumu_yapan
FROM v_son_olcumler v
ORDER BY v.bmi DESC;

-- ─── Üye spor dalları ───────────────
SELECT
    CONCAT(u.ad, ' ', u.soyad)                                  AS uye,
    GROUP_CONCAT(sd.dal_adi ORDER BY sd.dal_adi SEPARATOR ', ') AS spor_dallari,
    COUNT(usd.dal_id)                                           AS dal_sayisi
FROM uyeler u
JOIN uye_spor_dallari usd ON u.uye_id   = usd.uye_id AND usd.aktif = 1
JOIN spor_dallari sd       ON usd.dal_id = sd.dal_id
GROUP BY u.uye_id, u.ad, u.soyad
ORDER BY dal_sayisi DESC;

-- ─── STORED PROCEDURE çağırmaları ───────────────────────
CALL sp_uye_raporu(1);
CALL sp_aylik_aktivite_raporu(YEAR(CURDATE()), MONTH(CURDATE()));  

-- ─── Üyelik bitmek üzere olanlar (7 gün içinde) ─────────
SELECT
    CONCAT(u.ad, ' ', u.soyad)              AS uye,
    u.telefon,
    up.paket_adi,
    ul.bitis_tarihi,
    DATEDIFF(ul.bitis_tarihi, CURDATE())    AS kalan_gun
FROM uyelikler ul
JOIN uyeler u           ON ul.uye_id   = u.uye_id
JOIN uyelik_paketleri up ON ul.paket_id = up.paket_id
WHERE ul.odeme_durumu = 'odendi'
  AND ul.bitis_tarihi BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)
  AND u.uye_durumu    = 'aktif'
ORDER BY ul.bitis_tarihi;

-- ───Kilo değişim trendi ─────────────
SELECT
    uye_id,
    olcum_tarihi,
    kilo_kg,
    kilo_kg - LAG(kilo_kg) OVER (PARTITION BY uye_id ORDER BY olcum_tarihi) AS kilo_farki_kg
FROM fiziksel_olcumler
ORDER BY uye_id, olcum_tarihi;