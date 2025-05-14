-Langkah persiapan
-- untuk merubah format date di kolom date
UPDATE `rakamin-kf-analytics-459013.KimiaFarma.Transaction`
SET date = FORMAT_DATE('%Y-%m-%d', PARSE_DATE('%m/%d/%Y', date))
WHERE date IS NOT NULL;

-- untuk pengecekan apakah ada duplikasi di kolom transaction ID
SELECT transaction_id, COUNT(*) AS jumlah_duplikat 
FROM `rakamin-kf-analytics-459013.KimiaFarma.Transaction` 
GROUP BY transaction_id HAVING jumlah_duplikat > 1;

-- Untuk mengecek apakah ada missing value di masing-masing kolom pada tabel Final Transaction
SELECT 
  COUNTIF (transaction_id IS NULL) AS null_transaction_id,
  COUNTIF (date IS NULL) AS null_date,
  COUNTIF (branch_id IS NULL) AS null_branch_id,
  COUNTIF (customer_name IS NULL) AS null_customer_name,
  COUNTIF (product_id IS NULL) AS null_product_id,
  COUNTIF (price IS NULL) AS null_price,
  COUNTIF (discount_percentage IS NULL) AS null_discount_percentage,
  COUNTIF (rating IS NULL) AS null_rating
FROM `rakamin-kf-analytics-459013.KimiaFarma.Transaction`;

-- untuk mengecek apakah ada spasi kosong (Whitespaces). Contoh di Kolom Customer Name
SELECT *
FROM `rakamin-kf-analytics-459013.KimiaFarma.Transaction`;
WHERE customer_name != TRIM(customer_name);

-Langkah analisa
-- membuat tabel analisa
CREATE TABLE `rakamin-kf-analytics-459013.KimiaFarma.Analisa` AS 
SELECT
 t.transaction_id,
 t.date,
 b.branch_id,
 b.branch_name,
 b.branch_category,
 b.kota,
 b.provinsi,
 b.rating AS rating_cabang,
 t.customer_name,
 p.product_id,
 p.product_name,
 p.price AS actual_price,
 t.discount_percentage,
 CASE
    WHEN p.price <= 50000 THEN 0.1
    WHEN p.price > 50000 AND p.price <= 100000 THEN 0.15
    WHEN p.price > 100000 AND p.price <= 300000 THEN 0.20
    WHEN p.price > 300000 AND p.price <= 500000 THEN 0.25
    ELSE 0.30
 END AS persentase_gross_laba, 
 
 t.price * (1 - t.discount_percentage) AS net_sales,

 -- Asumsi Net Profit = persentase_goss_laba
 t.price * (1 - t.discount_percentage) *
 CASE
    WHEN p.price <= 50000 THEN 0.1
    WHEN p.price > 50000 AND p.price <= 100000 THEN 0.15
    WHEN p.price > 100000 AND p.price <= 300000 THEN 0.20
    WHEN p.price > 300000 AND p.price <= 500000 THEN 0.25
    ELSE 0.30
  END AS net_profit,

  t.rating AS rating_transaksi

  FROM `rakamin-kf-analytics-459013.KimiaFarma.Transaction` t
  JOIN `rakamin-kf-analytics-459013.KimiaFarma.Product` p ON t.product_id = p.product_id
  JOIN `rakamin-kf-analytics-459013.KimiaFarma.Branch` b ON t.branch_id = b.branch_id;

-- untuk mengecek apakah dari proses join diatas ada baris yang tertinggal
-- dari tabel produk
SELECT *
FROM `rakamin-kf-analytics-459013.KimiaFarma.Transaction` t
LEFT JOIN `rakamin-kf-analytics-459013.KimiaFarma.Product` p
  ON t.product_id = p.product_id
WHERE p.product_id IS NULL;

-- dari tabel branch
SELECT *
FROM `rakamin-kf-analytics-459013.KimiaFarma.Transaction` t
LEFT JOIN `rakamin-kf-analytics-459013.KimiaFarma.Branch` b
  ON t.branch_id = b.branch_id
WHERE b.branch_id IS NULL;
