--TASK 1

--Create Tabel
CREATE TABLE employees(id INT NOT NULL, nama VARCHAR(100) NOT NULL, gaji INT NOT NULL, manager_id INT);

--Insert Values
INSERT INTO employees VALUES(1,'Steven',9000,3);
INSERT INTO employees VALUES(2,'Sakura',10000),(3,'Jennifer',8500);
INSERT INTO employees VALUES(4,'Jung',8500,2),(5,'Nayeon',12000,6);
INSERT INTO employees VALUES(5,'Romanov',8500);

--1
SELECT id,nama FROM employees WHERE id % 2 <> 0;

--2
SELECT gaji, COUNT(*) sama FROM employees GROUP BY gaji HAVING gaji > 1;
SELECT nama,gaji AS salary FROM employees WHERE gaji = 8500;

--3
SELECT nama,gaji FROM employees WHERE gaji > (SELECT MAX(gaji) FROM employees WHERE manager_id = 3) ORDER BY gaji;

--4
CREATE INDEX nama_employee ON employees(nama);
-- Untuk menjaga performa database bisa melakukan indexing kepada tabel pegawai yang bertujuan untuk mempercepat pencarian data berdasarkan kolom tertentu.
-- Index membuat pencarian data menjadi lebih optimal karena lebih cepat dan tidak banyak menghabiskan resource CPU.
-- Dari beberapa tipe index, saya memberikan rekomendasi menggunakan B-Tree indexing. 
-- CREATE INDEX index_employees ON employees(nama);
-- Kelebihan B-Tree index adalah :
-- Index-organized tables, baris dimasukkan kedalam index yang di definisikan pada promary key table.
-- Reverse key indexes, index yang digunakan untuk data yang sangat beragam atau increment. 
-- Descending indexes, index yang memasukkan data ke dalam kolom tertentu dalam urutan menurutn.
-- B-Tree cluster indexes, digunakan untuk mengindeks table cluster key



--TASK 2
--Create table dan pembuatan relasi antar table seperti yang sudah di gambarkan di ERD dan Class Diagram
--Create table obat dengan FOREIGN KEY id_suplier yang terhubung dengan tabel suplier
CREATE TABLE obat(
    barcode__obat INT NOT NULL,
    nama_obat VARCHAR(45) NOT NULL,
    jenis_obat VARCHAR(45) NOT NULL,
    stok INT NOT NULL,
    id_suplier INT,
    PRIMARY KEY (barcode__obat),
    FOREIGN KEY suplier REFERENCES suplier(id_suplier)
)

--Create table suplier dengan PRIMARY KEY id_suplier
CREATE TABLE suplier(
    id_suplier INT NOT NULL,
    nama VARCHAR(45) NOT NULL,
    alamat TEXT NOT NULL,
    no_telp INT NOT NULL,
    PRIMARY KEY (id_suplier)
)

--Create table transaksi_masuk yang menyimpan data transaksi masuk obat(purchasing). Dengan FOREIGN KEY barcode_obat yang
--terhubung dengan tabel obat, dan FOREIGN KEY id_suplier yang terhubung dengan tabel suplier
CREATE TABLE transaksi_masuk(
    id_trans_masuk INT NOT NULL,
    tanggal DATE NOT NULL,
    jumlah INT NOT NULL,
    barcode__obat INT NOT NULL,
    id_suplier INT NOT NULL,
    PRIMARY KEY (id_trans_masuk),
    FOREIGN KEY (barcode__obat) REFERENCES obat(barcode__obat),
    FOREIGN KEY (id_suplier) REFERENCES suplier(id_suplier)
)

--Create table transaksi_keluar yang menyimpan data transaksi keluar obat(selling). Dengan FOREIGN KEY barcode_obat
-- yang terhubung dengan tabel obat, dan FOREIGN KEY rekam_medis yang terhubung dengan tabel pasien.
CREATE TABLE transaksi_keluar(
    id_trans_keluar INT NOT NULL,
    no_resep INT NOT NULL,
    barcode__obat INT NOT NULL,
    jumlah INT NOT NULL,
    rekam_medis INT NOT NULL,
    PRIMARY KEY (id_trans_keluar),
    FOREIGN KEY (barcode__obat) REFERENCES obat(barcode__obat),
    FOREIGN KEY (rekam_medis) REFERENCES pasien(rekam_medis)
)

--Create tabel pasien dengan PRIMARY KEY rekam_medis
CREATE TABLE pasien(
    rekam_medis INT NOT NULL,
    nama VARCHAR(45) NOT NULL,
    alamat TEXT NOT NULL,
    no_telp INT NOT NULL,
    PRIMARY KEY (rekam_medis)
)

--Create tabel tracing_obat yang menyimpan data masuk(purchasing) dan keluar(selling) obat. Tabel ini nantinya yang akan di akses oleh supervisor
--jika ingin mengecek ketersediaan obat dan tracing keluar masuknya obat. 
--Memiliki FOREIGN KEY barcode_obat yang terhubung dengan tabel obat, FOREIGN KEY id_trans_masuk yang terhubung dengan tabel transaksi_masuk
--FOREIGN KEY id_trans_keluar yang terhubung dengan tabel transaksi_keluar
CREATE TABLE tracing_obat(
    id_tracing INT NOT NULL,
    barcode__obat INT NOT NULL,
    id_trans_masuk INT NOT NULL,
    id_trans_keluar INT NOT NULL,
    PRIMARY KEY (id_tracing),
    FOREIGN KEY (barcode__obat) REFERENCES obat(barcode__obat),
    FOREIGN KEY (id_trans_masuk) REFERENCES transaksi_masuk(id_trans_masuk),
    FOREIGN KEY (id_trans_keluar) REFERENCES transaksi_keluar(id_trans_keluar)
)

--Create tabel supervisor dengan PRIMARY KEY id_supervisor 
CREATE TABLE supervisor(
    id_supervisor INT NOT NULL,
    nama VARCHAR(45) NOT NULL,
    PRIMARY KEY (id_supervisor)
)

--QUERY SUPERVISOR UNTUK MENGECEK KETERSEDIAAN OBAT
SELECT obat.nama,obat.jumlah,id_trans_masuk,id_trans_keluar FROM tracing_obat 
INNER JOIN tracing_obat ON obat.barcode__obat=tracing_obat.barcode__obat;

--4
--Solusi permasalah filter nama obat menurut saya dengan melakukan indexing pada kolom nama obat tabel detail adjustment keluar. 
--Karena query sudah terasa lambat saat dieksekusi, dan jumlah data sudah sangat banyak. 
--Kenapa indexing, karena query sql secara default bekerja dengan cara table scan. Yaitu menscan data satu persatu
--mulai dari record 1 (pertama) sampai ke record trakhir. Jika terdapat 1000 transaksi maka sql akan menscan table 
--dari record 1 hingga record 1000. Itulah kenapa query sql akan berjalan lambat seiring bertambahnya data. 
--Dengan membuat index, maka sql tidak perlu menscan data satu persatu dari awal hingga terakhir. 

--Query pembuatan index
CREATE INDEX index_nama_obat ON detail_adjusment_keluar(nama_obat) NOLOGGING COMPUTE STATISTICS;