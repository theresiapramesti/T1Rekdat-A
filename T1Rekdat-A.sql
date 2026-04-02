CREATE DATABASE universitas;
USE universitas;

SELECT * FROM mahasiswa;
SELECT * FROM mata_kuliah;
SELECT * FROM krs;
SELECT * FROM dosen;

-- 	NO 16
SELECT
    mk.SKS,
    ROUND(AVG(
        CASE k.Nilai
            WHEN 'A'  THEN 4.0
            WHEN 'A-' THEN 3.7
            WHEN 'B+' THEN 3.3
            WHEN 'B'  THEN 3.0
            WHEN 'B-' THEN 2.7
            WHEN 'C+' THEN 2.3
            WHEN 'C'  THEN 2.0
            ELSE 1.0
        END
    ), 2) AS rata_rata_nilai,
    COUNT(*) AS jumlah_pengambilan
FROM krs k
JOIN mata_kuliah mk ON k.KodeMK = mk.KodeMK
GROUP BY mk.SKS
ORDER BY mk.SKS;

-- NO 17
WITH

-- Langkah 1: Hitung jumlah MK tiap mahasiswa
jml_mk AS (
    SELECT NPM, COUNT(*) AS jumlah
    FROM krs
    GROUP BY NPM
),

-- Langkah 2: Jumlah MK mahasiswa dengan IPK tertinggi
jml_top AS (
    SELECT j.jumlah
    FROM jml_mk j
    JOIN mahasiswa m ON j.NPM = m.NPM
    WHERE m.IPK = (SELECT MAX(IPK) FROM mahasiswa)
    LIMIT 1
)

-- Langkah 3: Hitung persentase mahasiswa yang lebih aktif
SELECT
    COUNT(*) AS mahasiswa_lebih_aktif,
    (SELECT COUNT(*) FROM mahasiswa) AS total_mahasiswa,
    ROUND(
        100.0 * COUNT(*) / (SELECT COUNT(*) FROM mahasiswa),
        2
    ) AS persentase
FROM jml_mk
WHERE jumlah > (SELECT jumlah FROM jml_top);

-- NO 18
SELECT
    COUNT(DISTINCT k.NPM) AS mahasiswa_lintas,
    (SELECT COUNT(*) FROM mahasiswa) AS total_mahasiswa,
    ROUND(
        100.0 * COUNT(DISTINCT k.NPM)
               / (SELECT COUNT(*) FROM mahasiswa),
        2
    ) AS proporsi_persen
FROM krs k
JOIN mahasiswa m      ON k.NPM    = m.NPM
JOIN mata_kuliah mk   ON k.KodeMK = mk.KodeMK
WHERE mk.Prodi != m.Prodi;	

-- NO 19
SELECT
    SUM(CASE WHEN mk.Prodi  = m.Prodi THEN 1 ELSE 0 END) AS dari_prodi_sendiri,
    SUM(CASE WHEN mk.Prodi != m.Prodi THEN 1 ELSE 0 END) AS dari_prodi_lain,
    COUNT(*) AS total_pengambilan,
    ROUND(
        100.0 * SUM(CASE WHEN mk.Prodi = m.Prodi THEN 1 ELSE 0 END)
               / COUNT(*),
        2
    ) AS persen_dari_prodi_sendiri
FROM krs k
JOIN mahasiswa m      ON k.NPM    = m.NPM
JOIN mata_kuliah mk   ON k.KodeMK = mk.KodeMK;
    
-- NO 20
SELECT
    Angkatan,
    COUNT(*)          AS jumlah_mahasiswa,
    ROUND(AVG(IPK), 2)  AS rata_rata_ipk,
    ROUND(MIN(IPK), 2)  AS ipk_terendah,
    ROUND(MAX(IPK), 2)  AS ipk_tertinggi
FROM mahasiswa
GROUP BY Angkatan
ORDER BY Angkatan;