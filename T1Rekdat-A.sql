CREATE DATABASE universitas;
USE universitas;

SELECT * FROM mahasiswa;
SELECT * FROM mata_kuliah;
SELECT * FROM krs;
SELECT * FROM dosen;

-- NO 2
SELECT * FROM mahasiswa WHERE NPM IS NULL 
   OR Nama IS NULL 
   OR Angkatan IS NULL 
   OR Prodi IS NULL 
   OR IPK IS NULL;

SELECT * FROM dosen WHERE NIDN IS NULL 
   OR NamaDosen IS NULL 
   OR Prodi IS NULL;

SELECT * FROM mata_kuliah WHERE KodeMK IS NULL 
   OR NamaMK IS NULL 
   OR SKS IS NULL 
   OR Prodi IS NULL;

SELECT * FROM krs WHERE NPM IS NULL 
   OR KodeMK IS NULL 
   OR Semester IS NULL 
   OR Nilai IS NULL;

-- NO 3
-- Cek apakah ada duplikasi di tabel krs
SELECT 
    NPM, 
    KodeMK, 
    Semester, 
    COUNT(*) AS jumlah_data
FROM krs
GROUP BY NPM, KodeMK, Semester
HAVING COUNT(*) > 1;

-- NO 6
SELECT table_name, column_name
FROM information_schema.columns
WHERE table_schema = 'universitas'
  AND table_name IN ('dosen', 'krs', 'mahasiswa', 'mata_kuliah')
  AND numeric_precision IS NOT NULL;

SELECT 'mahasiswa' AS tabel, 'IPK' AS kolom, MIN(IPK) AS nilai_min, MAX(IPK) AS nilai_max, AVG(IPK) AS rata_rata, STDDEV(IPK) AS standar_deviasi FROM universitas.mahasiswa
UNION ALL
SELECT 'mahasiswa', 'Angkatan', MIN(Angkatan), MAX(Angkatan), AVG(Angkatan), STDDEV(Angkatan) FROM universitas.mahasiswa
UNION ALL
SELECT 'mata_kuliah', 'SKS', MIN(SKS), MAX(SKS), AVG(SKS), STDDEV(SKS) FROM universitas.mata_kuliah
UNION ALL
SELECT 'krs', 'Semester', MIN(Semester), MAX(Semester), AVG(Semester), STDDEV(Semester) FROM universitas.krs;
SELECT 'krs', 'Semester', MIN(Semester), MAX(Semester), AVG(Semester), STDDEV(Semester) FROM universitas.krs;


-- NO 7 
-- Mahasiswa: Prodi
SELECT Prodi, COUNT(*) AS frekuensi
FROM universitas.mahasiswa
GROUP BY Prodi;

-- Dosen: Prodi
SELECT Prodi, COUNT(*) AS frekuensi
FROM universitas.dosen
GROUP BY Prodi;

-- Mata Kuliah: Prodi
SELECT Prodi, COUNT(*) AS frekuensi
FROM universitas.mata_kuliah
GROUP BY Prodi;

-- KRS: KodeMK (frekuensi pengambilan mata kuliah)
SELECT KodeMK, COUNT(*) AS frekuensi
FROM universitas.krs
GROUP BY KodeMK;

-- KRS: Nilai
SELECT Nilai, COUNT(*) AS frekuensi
FROM universitas.krs
GROUP BY Nilai;

-- NO 8
SELECT Nama, IPK
FROM universitas.mahasiswa
WHERE IPK > (SELECT AVG(IPK) FROM universitas.mahasiswa)
ORDER BY IPK DESC;

-- NO 9
SELECT 
    m.Nama AS Nama_Mahasiswa, 
    m.Prodi AS Prodi_Mahasiswa, 
    mk.NamaMK AS Mata_Kuliah_Diambil, 
    mk.Prodi AS Prodi_Penyelenggara
FROM universitas.mahasiswa m
JOIN universitas.krs k ON m.NPM = k.NPM
JOIN universitas.mata_kuliah mk ON k.KodeMK = mk.KodeMK
WHERE m.NPM IN (
    -- Subquery: Mencari NPM yang mengambil MK dengan Prodi berbeda
    SELECT k2.NPM 
    FROM universitas.krs k2
    JOIN universitas.mata_kuliah mk2 ON k2.KodeMK = mk2.KodeMK
    JOIN universitas.mahasiswa m2 ON k2.NPM = m2.NPM
    WHERE m2.Prodi <> mk2.Prodi
)
ORDER BY m.Nama, mk.NamaMK;

-- NO 10
SELECT 
    m.NPM, 
    m.Nama, 
    COUNT(k.KodeMK) AS Jumlah_Mata_Kuliah
FROM universitas.mahasiswa m
LEFT JOIN universitas.krs k ON m.NPM = k.NPM
GROUP BY m.NPM, m.Nama
ORDER BY Jumlah_Mata_Kuliah DESC;
-- 	NO 11
SELECT KodeMK, COUNT(NPM) AS Jumlah_Mhs
FROM krs
GROUP BY KodeMK
HAVING COUNT(NPM) >= 3;

-- 	NO 11
SELECT KodeMK, COUNT(NPM) AS Jumlah_Mhs
FROM krs
GROUP BY KodeMK
HAVING COUNT(NPM) >= 3;

--   NO 12
SELECT DISTINCT m.Nama 
FROM mahasiswa m
JOIN krs k ON m.NPM = k.NPM
JOIN mata_kuliah mk ON k.KodeMK = mk.KodeMK
WHERE mk.SKS = (SELECT MAX(SKS) FROM mata_kuliah);

--   NO 13
SELECT Nama FROM mahasiswa 
WHERE NPM NOT IN (SELECT NPM FROM krs WHERE KodeMK = 'IF101');

--   NO 14
SELECT Nama FROM mahasiswa 
WHERE NPM IN (SELECT NPM FROM krs) 
AND NPM NOT IN (
    SELECT k.NPM FROM krs k 
    JOIN mata_kuliah mk ON k.KodeMK = mk.KodeMK 
    WHERE mk.SKS <> 3
);

--   NO 15
SELECT m.Nama, m.IPK, COUNT(k.KodeMK) AS Total_MK
FROM mahasiswa m
LEFT JOIN krs k ON m.NPM = k.NPM
GROUP BY m.NPM, m.Nama, m.IPK
ORDER BY m.IPK DESC;

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
    ROUND(AVG(IPK), 2)  AS rata_rata_ipk
FROM mahasiswa
GROUP BY Angkatan
ORDER BY Angkatan;
