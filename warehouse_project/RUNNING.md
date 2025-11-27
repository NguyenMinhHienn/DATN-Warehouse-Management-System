# Chạy dự án Warehouse (nhanh)

Hướng dẫn này giúp bạn khởi động frontend (React TS) và backend (Node/Express) cùng lúc bằng một lệnh `npm run dev` từ thư mục `warehouse_project`.

Yêu cầu trước khi chạy:
- MySQL (XAMPP) đã được cài và `warehouse_db` đã import.
- Node.js và npm đã được cài.

1) Cài dependencies

Mở PowerShell ở thư mục `warehouse_project` và chạy:

```powershell
# Cài các gói dùng để chạy cả hai project cùng lúc
npm install

# Cài dependencies backend (express, mysql2, cors, body-parser, nodemon)
cd backend
npm install
cd ..

# Cài dependencies frontend (CRA đã tạo project, cài node modules)
cd frontend
npm install
cd ..
```

2) Chạy đồng thời frontend + backend

Từ thư mục `warehouse_project` chạy:

```powershell
# Lệnh 'dev' dùng concurrently để chạy backend (nodemon) và frontend (CRA) cùng lúc
npm run dev
```

- Backend: sẽ chạy `backend/npm run dev` → dùng `nodemon index.js` (tự reload khi thay đổi).
- Frontend: sẽ chạy `frontend/npm start` → CRA dev server (http://localhost:3000).
- Backend mặc định lắng nghe trên cổng `3001`.

3) Nếu cần chạy riêng

- Chỉ backend:
```powershell
cd backend
npm run dev      # hoặc npm start
```

- Chỉ frontend:
```powershell
cd frontend
npm start
```

4) Biến môi trường (nếu MySQL có cấu hình khác)

Trước khi chạy backend, đặt biến môi trường trong PowerShell:

```powershell
$env:DB_HOST='127.0.0.1'
$env:DB_PORT='3306'
$env:DB_USER='root'
$env:DB_PASSWORD='your_mysql_password'
$env:DB_NAME='warehouse_db'
# rồi chạy backend
cd backend
npm run dev
```

5) Troubleshooting
- Nếu backend báo `ECONNREFUSED 127.0.0.1:3306`: đảm bảo MySQL chạy trong XAMPP Control Panel.
- Nếu frontend báo lỗi thiếu module `react` hoặc types: đảm bảo bạn đã chạy `npm install` trong `frontend`.
- Nếu `npm run dev` báo lệnh `concurrently` không tồn tại: chạy `npm install` trong `warehouse_project` để cài devDependency `concurrently`.

---

Nếu muốn, tôi có thể thêm một file `.env.example` và tích hợp `dotenv` cho backend để dễ quản lý biến môi trường.