# Warehouse Project (Minimal scaffold)

This repository contains a minimal scaffold for a Warehouse Management System split into backend and frontend.

Structure:

```
warehouse_project/
  backend/
    index.js        # Express + MySQL backend
  frontend/
    src/
      App.tsx
      components/
        Navbar.tsx
        ProductList.tsx
        ProductForm.tsx
```

# Backend

Requirements:
- Node.js
- MySQL database `warehouse_db` imported (use XAMPP / phpMyAdmin)

Install and run:

```powershell
cd warehouse_project/backend
npm install express mysql2 cors body-parser
node index.js
```

By default backend runs on http://localhost:3001 and expects DB at 127.0.0.1:3306 with user `root` and empty password. You can set environment variables:
- DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, DB_NAME, PORT

API examples:
- GET http://localhost:3001/api/products
- GET http://localhost:3001/api/products/:id
- POST http://localhost:3001/api/products
- PUT http://localhost:3001/api/products/:id
- DELETE http://localhost:3001/api/products/:id

# Frontend

Create React app with TypeScript (recommended):

```bash
npx create-react-app frontend --template typescript
```

Then replace `src/App.tsx` and `src/components/*` with the files in this scaffold.

Start frontend:

```powershell
cd frontend
npm install
npm start
```

Frontend expects backend at http://localhost:3001.

# Notes
- The frontend files provided are minimal and meant to be used inside a CRA TypeScript project.
- The backend implements full CRUD for `products` and simple GET endpoints for other tables; extend as needed.

If you want, I can:
- Create a full `package.json` for backend and frontend,
- Add dotenv support,
- Add more CRUD routes for other tables,
- Provide a Postman collection.

Reply which you want next and I will add it.
