/*
Backend cho Warehouse Project
- Express + mysql2 (promise) + cors + body-parser
- Kết nối tới database `warehouse_db` (XAMPP / phpMyAdmin)

Chạy:
  npm install express mysql2 cors body-parser
  node index.js

Cấu hình môi trường (tuỳ chọn):
  DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, DB_NAME, PORT

Mặc định:
  host: 127.0.0.1
  port: 3306
  user: root
  password: ''
  database: warehouse_db
  server PORT: 3001
*/

const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const mysql = require('mysql2/promise');

const app = express();
const PORT = process.env.PORT ? parseInt(process.env.PORT) : 3001;

// CORS: cho phép react frontend ở localhost:3000 gọi API
app.use(cors({ origin: 'http://localhost:3000' }));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// cấu hình DB từ env hoặc mặc định
const dbConfig = {
  host: process.env.DB_HOST || '127.0.0.1',
  port: process.env.DB_PORT ? parseInt(process.env.DB_PORT) : 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'warehouse_db',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
};

let pool;

async function initDb() {
  try {
    pool = mysql.createPool(dbConfig);
    // quick test
    const [rows] = await pool.query('SELECT 1');
    console.log('DB connected:', dbConfig.database);
  } catch (err) {
    console.error('Lỗi kết nối DB:', err.message);
    console.error('Kiểm tra MySQL đang chạy, thông tin kết nối và port (XAMPP).');
    process.exit(1);
  }
}

// -------------------------
// API cho products (CRUD)
// -------------------------
// GET /api/products -> trả về tất cả sản phẩm
app.get('/api/products', async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT p.*, c.category_name
       FROM products p
       LEFT JOIN categories c ON p.category_id = c.category_id
       ORDER BY p.product_name ASC`
    );
    res.json({ success: true, data: rows });
  } catch (err) {
    console.error('GET /api/products error', err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// GET /api/products/:id
app.get('/api/products/:id', async (req, res) => {
  const id = parseInt(req.params.id);
  if (isNaN(id)) return res.status(400).json({ success: false, message: 'Invalid id' });
  try {
    const [rows] = await pool.query('SELECT * FROM products WHERE product_id = ? LIMIT 1', [id]);
    if (rows.length === 0) return res.status(404).json({ success: false, message: 'Product not found' });
    res.json({ success: true, data: rows[0] });
  } catch (err) {
    console.error('GET /api/products/:id error', err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// POST /api/products
app.post('/api/products', async (req, res) => {
  const { sku, product_name, category_id, description, unit, purchase_price, selling_price, reorder_level, current_stock, status } = req.body;
  try {
    const [result] = await pool.query(
      `INSERT INTO products (sku, product_name, category_id, description, unit, purchase_price, selling_price, reorder_level, current_stock, status)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [sku, product_name, category_id || null, description || null, unit || null, purchase_price || 0, selling_price || 0, reorder_level || 0, current_stock || 0, status || 'active']
    );
    const insertId = result.insertId;
    const [newRows] = await pool.query('SELECT * FROM products WHERE product_id = ?', [insertId]);
    res.status(201).json({ success: true, data: newRows[0] });
  } catch (err) {
    console.error('POST /api/products error', err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// PUT /api/products/:id
app.put('/api/products/:id', async (req, res) => {
  const id = parseInt(req.params.id);
  if (isNaN(id)) return res.status(400).json({ success: false, message: 'Invalid id' });
  const fields = req.body || {};
  // build dynamic set clause but whitelist columns
  const allowed = ['sku','product_name','category_id','description','unit','purchase_price','selling_price','reorder_level','current_stock','status'];
  const sets = [];
  const values = [];
  for (const key of allowed) {
    if (Object.prototype.hasOwnProperty.call(fields, key)) {
      // use template literal to create `column = ?`
      sets.push(`${key} = ?`);
      values.push(fields[key]);
    }
  }
  if (sets.length === 0) return res.status(400).json({ success: false, message: 'No valid fields to update' });
  values.push(id);
  const sql = `UPDATE products SET ${sets.join(', ')} WHERE product_id = ?`;
  try {
    const [result] = await pool.query(sql, values);
    const [rows] = await pool.query('SELECT * FROM products WHERE product_id = ?', [id]);
    if (rows.length === 0) return res.status(404).json({ success: false, message: 'Product not found' });
    res.json({ success: true, data: rows[0], affectedRows: result.affectedRows });
  } catch (err) {
    console.error('PUT /api/products/:id error', err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// DELETE /api/products/:id
app.delete('/api/products/:id', async (req, res) => {
  const id = parseInt(req.params.id);
  if (isNaN(id)) return res.status(400).json({ success: false, message: 'Invalid id' });
  try {
    const [result] = await pool.query('DELETE FROM products WHERE product_id = ?', [id]);
    res.json({ success: true, affectedRows: result.affectedRows });
  } catch (err) {
    console.error('DELETE /api/products/:id error', err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// -------------------------
// GENERIC CRUD placeholder for other tables (minimal)
// For brevity we implement simple GET all endpoints for other tables
// You can extend these patterns to full CRUD as needed
// -------------------------
const otherTables = ['users','roles','categories','suppliers','customers','import_receipts','import_receipt_details','export_receipts','export_receipt_details','activity_logs','stocktake','stocktake_details','notifications'];
for (const t of otherTables) {
  app.get(`/api/${t}`, async (req, res) => {
    try {
      const [rows] = await pool.query(`SELECT * FROM \`${t}\` LIMIT 1000`);
      res.json({ success: true, data: rows });
    } catch (err) {
      res.status(500).json({ success: false, error: err.message });
    }
  });
}

// Root
app.get('/', (req, res) => {
  res.send('Warehouse backend is running. Use /api/products for product endpoints.');
});

// Start server after DB init
initDb().then(() => {
  app.listen(PORT, () => {
    console.log(`Server listening on http://localhost:${PORT}`);
  });
});
