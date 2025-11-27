-- ============================================================================
-- QUẢN LÝ KHO HÀNG - WAREHOUSE MANAGEMENT SYSTEM
-- Database: warehouse_db
-- Version: 1.0
-- Mô tả: Hệ thống quản lý kho hàng
-- ============================================================================

-- ============================================================================
-- 1. TẠO DATABASE
-- ============================================================================
DROP DATABASE IF EXISTS warehouse_db;
CREATE DATABASE warehouse_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE warehouse_db;

-- ============================================================================
-- 2. TẠO BẢNG: ROLES (QUYỀN HẠN CƠ BẢN)
-- ============================================================================
CREATE TABLE roles (
    role_id INT PRIMARY KEY AUTO_INCREMENT,
    role_name VARCHAR(50) NOT NULL UNIQUE COMMENT 'Tên quyền: Admin, Manager, Warehouse Staff, Accountant',
    description TEXT COMMENT 'Mô tả chi tiết về quyền',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_role_name (role_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng quyền hạn người dùng';

-- ============================================================================
-- 3. TẠO BẢNG: PERMISSIONS (QUYỀN HẠN CHI TIẾT)
-- ============================================================================
CREATE TABLE permissions (
    permission_id INT PRIMARY KEY AUTO_INCREMENT,
    permission_code VARCHAR(100) NOT NULL UNIQUE COMMENT 'Mã quyền: import.create, export.view, report.view',
    permission_name VARCHAR(100) NOT NULL COMMENT 'Tên quyền dễ đọc',
    description TEXT COMMENT 'Mô tả chi tiết',
    module VARCHAR(50) COMMENT 'Module liên quan: import, export, product, report, system',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_permission_code (permission_code),
    INDEX idx_module (module)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng quyền hạn chi tiết';

-- ============================================================================
-- 4. TẠO BẢNG: ROLE_PERMISSIONS (LIÊN KẾT ROLE - PERMISSION)
-- ============================================================================
CREATE TABLE role_permissions (
    role_permission_id INT PRIMARY KEY AUTO_INCREMENT,
    role_id INT NOT NULL,
    permission_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permissions(permission_id) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE KEY unique_role_permission (role_id, permission_id),
    INDEX idx_role_id (role_id),
    INDEX idx_permission_id (permission_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng liên kết Role với Permissions';

-- ============================================================================
-- 5. TẠO BẢNG: USERS (TÀI KHOẢN NGƯỜI DÙNG)
-- ============================================================================
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE COMMENT 'Tên đăng nhập',
    email VARCHAR(100) NOT NULL UNIQUE COMMENT 'Email',
    password_hash VARCHAR(255) NOT NULL COMMENT 'Mật khẩu (hash)',
    full_name VARCHAR(100) NOT NULL COMMENT 'Họ và tên',
    phone VARCHAR(20) COMMENT 'Số điện thoại',
    role_id INT NOT NULL,
    status ENUM('active', 'inactive', 'locked') DEFAULT 'active' COMMENT 'Trạng thái: active, inactive, locked',
    last_login DATETIME COMMENT 'Lần đăng nhập cuối',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_role_id (role_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng tài khoản người dùng';

-- ============================================================================
-- 6. TẠO BẢNG: CATEGORIES (LOẠI SẢN PHẨM)
-- ============================================================================
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL UNIQUE COMMENT 'Tên loại sản phẩm',
    description TEXT COMMENT 'Mô tả',
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_category_name (category_name),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng loại sản phẩm';

-- ============================================================================
-- 7. TẠO BẢNG: SUPPLIERS (NHÀ CUNG CẤP)
-- ============================================================================
CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_name VARCHAR(100) NOT NULL UNIQUE COMMENT 'Tên nhà cung cấp',
    contact_person VARCHAR(100) COMMENT 'Người liên hệ',
    email VARCHAR(100) COMMENT 'Email',
    phone VARCHAR(20) COMMENT 'Số điện thoại',
    address TEXT COMMENT 'Địa chỉ',
    city VARCHAR(50) COMMENT 'Thành phố',
    country VARCHAR(50) COMMENT 'Quốc gia',
    tax_code VARCHAR(20) COMMENT 'Mã số thuế',
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_supplier_name (supplier_name),
    INDEX idx_email (email),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng nhà cung cấp';

-- ============================================================================
-- 8. TẠO BẢNG: CUSTOMERS (KHÁCH HÀNG)
-- ============================================================================
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL COMMENT 'Tên khách hàng',
    email VARCHAR(100) COMMENT 'Email',
    phone VARCHAR(20) COMMENT 'Số điện thoại',
    address TEXT COMMENT 'Địa chỉ',
    city VARCHAR(50) COMMENT 'Thành phố',
    country VARCHAR(50) COMMENT 'Quốc gia',
    tax_code VARCHAR(20) COMMENT 'Mã số thuế (nếu là công ty)',
    customer_type ENUM('individual', 'business') DEFAULT 'individual' COMMENT 'Loại khách hàng: cá nhân hoặc công ty',
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_customer_name (customer_name),
    INDEX idx_email (email),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng khách hàng';

-- ============================================================================
-- 9. TẠO BẢNG: PRODUCTS (SẢN PHẨM)
-- ============================================================================
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    sku VARCHAR(50) NOT NULL UNIQUE COMMENT 'Mã SKU (Stock Keeping Unit) - duy nhất',
    product_name VARCHAR(100) NOT NULL COMMENT 'Tên sản phẩm',
    category_id INT NOT NULL,
    description TEXT COMMENT 'Mô tả chi tiết',
    unit VARCHAR(20) COMMENT 'Đơn vị tính: cái, bộ, thùng, ...',
    purchase_price DECIMAL(12, 2) NOT NULL COMMENT 'Giá nhập',
    selling_price DECIMAL(12, 2) NOT NULL COMMENT 'Giá bán',
    reorder_level INT DEFAULT 10 COMMENT 'Mức tồn kho tối thiểu cảnh báo',
    current_stock INT DEFAULT 0 COMMENT 'Số lượng tồn kho hiện tại',
    status ENUM('active', 'inactive', 'discontinued') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_sku (sku),
    INDEX idx_product_name (product_name),
    INDEX idx_category_id (category_id),
    INDEX idx_current_stock (current_stock),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng sản phẩm';

-- ============================================================================
-- 10. TẠO BẢNG: IMPORT_RECEIPTS (PHIẾU NHẬP HÀNG)
-- ============================================================================
CREATE TABLE import_receipts (
    receipt_id INT PRIMARY KEY AUTO_INCREMENT,
    receipt_number VARCHAR(50) NOT NULL UNIQUE COMMENT 'Số phiếu nhập',
    supplier_id INT NOT NULL,
    warehouse_staff_id INT NOT NULL COMMENT 'Nhân viên kho nhập hàng',
    receipt_date DATE NOT NULL,
    total_amount DECIMAL(15, 2) DEFAULT 0 COMMENT 'Tổng tiền nhập hàng',
    notes TEXT COMMENT 'Ghi chú',
    status ENUM('pending', 'received', 'rejected', 'completed') DEFAULT 'pending' COMMENT 'Trạng thái: chưa nhận, đã nhận, bị từ chối, hoàn thành',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (warehouse_staff_id) REFERENCES users(user_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_receipt_number (receipt_number),
    INDEX idx_supplier_id (supplier_id),
    INDEX idx_receipt_date (receipt_date),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng phiếu nhập hàng';

-- ============================================================================
-- 11. TẠO BẢNG: IMPORT_RECEIPT_DETAILS (CHI TIẾT NHẬP HÀNG)
-- ============================================================================
CREATE TABLE import_receipt_details (
    detail_id INT PRIMARY KEY AUTO_INCREMENT,
    receipt_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL COMMENT 'Số lượng nhập',
    unit_price DECIMAL(12, 2) NOT NULL COMMENT 'Giá đơn vị tại thời điểm nhập',
    total_price DECIMAL(15, 2) COMMENT 'Thành tiền = quantity * unit_price',
    
    FOREIGN KEY (receipt_id) REFERENCES import_receipts(receipt_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_receipt_id (receipt_id),
    INDEX idx_product_id (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng chi tiết từng sản phẩm trong phiếu nhập';

-- ============================================================================
-- 12. TẠO BẢNG: EXPORT_RECEIPTS (PHIẾU XUẤT HÀNG)
-- ============================================================================
CREATE TABLE export_receipts (
    receipt_id INT PRIMARY KEY AUTO_INCREMENT,
    receipt_number VARCHAR(50) NOT NULL UNIQUE COMMENT 'Số phiếu xuất',
    customer_id INT NOT NULL,
    warehouse_staff_id INT NOT NULL COMMENT 'Nhân viên kho xuất hàng',
    receipt_date DATE NOT NULL,
    total_amount DECIMAL(15, 2) DEFAULT 0 COMMENT 'Tổng tiền xuất hàng',
    notes TEXT COMMENT 'Ghi chú',
    status ENUM('pending', 'picked', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending' COMMENT 'Trạng thái: chờ xử lý, đã lấy hàng, đã giao',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (warehouse_staff_id) REFERENCES users(user_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_receipt_number (receipt_number),
    INDEX idx_customer_id (customer_id),
    INDEX idx_receipt_date (receipt_date),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng phiếu xuất hàng';

-- ============================================================================
-- 13. TẠO BẢNG: EXPORT_RECEIPT_DETAILS (CHI TIẾT XUẤT HÀNG)
-- ============================================================================
CREATE TABLE export_receipt_details (
    detail_id INT PRIMARY KEY AUTO_INCREMENT,
    receipt_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL COMMENT 'Số lượng xuất',
    unit_price DECIMAL(12, 2) NOT NULL COMMENT 'Giá bán tại thời điểm xuất',
    total_price DECIMAL(15, 2) COMMENT 'Thành tiền = quantity * unit_price',
    
    FOREIGN KEY (receipt_id) REFERENCES export_receipts(receipt_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_receipt_id (receipt_id),
    INDEX idx_product_id (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng chi tiết từng sản phẩm trong phiếu xuất';

-- ============================================================================
-- 14. TẠO BẢNG: STOCKTAKE (ĐỢT KIỂM KHO)
-- ============================================================================
CREATE TABLE stocktake (
    stocktake_id INT PRIMARY KEY AUTO_INCREMENT,
    stocktake_code VARCHAR(50) NOT NULL UNIQUE COMMENT 'Mã kiểm kho',
    stocktake_date DATE NOT NULL COMMENT 'Ngày kiểm kho',
    staff_id INT NOT NULL COMMENT 'Nhân viên thực hiện kiểm kho',
    notes TEXT COMMENT 'Ghi chú',
    status ENUM('pending', 'in_progress', 'completed') DEFAULT 'pending' COMMENT 'Trạng thái kiểm kho',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (staff_id) REFERENCES users(user_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_stocktake_code (stocktake_code),
    INDEX idx_stocktake_date (stocktake_date),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng đợt kiểm kho';

-- ============================================================================
-- 15. TẠO BẢNG: STOCKTAKE_DETAILS (CHI TIẾT KIỂM KHO)
-- ============================================================================
CREATE TABLE stocktake_details (
    detail_id INT PRIMARY KEY AUTO_INCREMENT,
    stocktake_id INT NOT NULL,
    product_id INT NOT NULL,
    system_quantity INT COMMENT 'Số lượng tồn kho theo hệ thống',
    physical_quantity INT COMMENT 'Số lượng tồn kho thực tế',
    difference INT COMMENT 'Chênh lệch = physical_quantity - system_quantity (âm = thiếu, dương = thừa)',
    notes TEXT COMMENT 'Ghi chú về chênh lệch',
    
    FOREIGN KEY (stocktake_id) REFERENCES stocktake(stocktake_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_stocktake_id (stocktake_id),
    INDEX idx_product_id (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng chi tiết kiểm kho từng sản phẩm';

-- ============================================================================
-- 16. TẠO BẢNG: NOTIFICATIONS (CẢNH BÁO HỆ THỐNG)
-- ============================================================================
CREATE TABLE notifications (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    notification_type ENUM('low_stock', 'overstock', 'expired', 'system') DEFAULT 'low_stock' COMMENT 'Loại cảnh báo',
    message TEXT COMMENT 'Nội dung cảnh báo',
    is_read BOOLEAN DEFAULT FALSE COMMENT 'Đã đọc hay chưa',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_product_id (product_id),
    INDEX idx_notification_type (notification_type),
    INDEX idx_is_read (is_read),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng cảnh báo hệ thống (tồn kho thấp, hết hàng, ...)';

-- ============================================================================
-- 17. TẠO BẢNG: ACTIVITY_LOGS (NHẬT KÝ HOẠT ĐỘNG)
-- ============================================================================
CREATE TABLE activity_logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    action VARCHAR(100) NOT NULL COMMENT 'Hành động: CREATE, UPDATE, DELETE, IMPORT, EXPORT, LOGIN, ...',
    entity_type VARCHAR(50) COMMENT 'Loại entity: Product, ImportReceipt, ExportReceipt, Stocktake, ...',
    entity_id INT COMMENT 'ID của entity bị tác động',
    old_value TEXT COMMENT 'Giá trị cũ (nếu có)',
    new_value TEXT COMMENT 'Giá trị mới (nếu có)',
    ip_address VARCHAR(50) COMMENT 'Địa chỉ IP',
    description TEXT COMMENT 'Mô tả chi tiết hành động',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_action (action),
    INDEX idx_entity_type (entity_type),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng nhật ký hoạt động của người dùng';

-- ============================================================================
-- 3. THÊM QUYỀN HẠN (PERMISSIONS)
-- ============================================================================
INSERT INTO permissions (permission_code, permission_name, description, module) VALUES
-- Module: Quản lý sản phẩm
('product.view', 'Xem sản phẩm', 'Có quyền xem danh sách và chi tiết sản phẩm', 'product'),
('product.create', 'Tạo sản phẩm', 'Có quyền tạo sản phẩm mới', 'product'),
('product.edit', 'Sửa sản phẩm', 'Có quyền chỉnh sửa thông tin sản phẩm', 'product'),
('product.delete', 'Xóa sản phẩm', 'Có quyền xóa sản phẩm', 'product'),

-- Module: Nhập hàng
('import.view', 'Xem phiếu nhập', 'Có quyền xem danh sách phiếu nhập hàng', 'import'),
('import.create', 'Tạo phiếu nhập', 'Có quyền tạo phiếu nhập hàng mới', 'import'),
('import.approve', 'Duyệt phiếu nhập', 'Có quyền duyệt phiếu nhập hàng', 'import'),

-- Module: Xuất hàng
('export.view', 'Xem phiếu xuất', 'Có quyền xem danh sách phiếu xuất hàng', 'export'),
('export.create', 'Tạo phiếu xuất', 'Có quyền tạo phiếu xuất hàng mới', 'export'),
('export.approve', 'Duyệt phiếu xuất', 'Có quyền duyệt phiếu xuất hàng', 'export'),

-- Module: Kiểm kho
('stocktake.view', 'Xem kiểm kho', 'Có quyền xem danh sách kiểm kho', 'stocktake'),
('stocktake.create', 'Tạo kiểm kho', 'Có quyền tạo đợt kiểm kho mới', 'stocktake'),

-- Module: Báo cáo
('report.view', 'Xem báo cáo', 'Có quyền xem báo cáo hệ thống', 'report'),
('report.export', 'Xuất báo cáo', 'Có quyền xuất file báo cáo', 'report'),

-- Module: Quản lý người dùng
('user.view', 'Xem người dùng', 'Có quyền xem danh sách người dùng', 'system'),
('user.create', 'Tạo người dùng', 'Có quyền tạo tài khoản người dùng mới', 'system'),
('user.edit', 'Sửa người dùng', 'Có quyền chỉnh sửa thông tin người dùng', 'system'),
('user.delete', 'Xóa người dùng', 'Có quyền xóa tài khoản người dùng', 'system'),

-- Module: Nhật ký
('log.view', 'Xem nhật ký', 'Có quyền xem nhật ký hoạt động', 'system'),
('notification.view', 'Xem cảnh báo', 'Có quyền xem cảnh báo hệ thống', 'system');

-- ============================================================================
-- 4. THÊM ROLES (QUYỀN - VAI TRÒ)
-- ============================================================================
INSERT INTO roles (role_name, description) VALUES
('Admin', 'Quản trị viên - Có đầy đủ quyền hạn trên hệ thống'),
('Manager', 'Quản lý - Quản lý chung các hoạt động kho hàng'),
('Warehouse Staff', 'Nhân viên kho - Xử lý nhập xuất hàng'),
('Accountant', 'Kế toán - Xem báo cáo tài chính');

-- ============================================================================
-- 5. LIÊN KẾT ROLES VỚI PERMISSIONS
-- ============================================================================
-- Admin: Có tất cả quyền
INSERT INTO role_permissions (role_id, permission_id)
SELECT 1, permission_id FROM permissions;

-- Manager: Có quyền xem, tạo, duyệt nhập/xuất, quản lý sản phẩm, xem báo cáo
INSERT INTO role_permissions (role_id, permission_id)
SELECT 2, permission_id FROM permissions 
WHERE permission_code IN (
    'product.view', 'product.create', 'product.edit',
    'import.view', 'import.create', 'import.approve',
    'export.view', 'export.create', 'export.approve',
    'stocktake.view', 'stocktake.create',
    'report.view', 'report.export',
    'user.view', 'notification.view', 'log.view'
);

-- Warehouse Staff: Chỉ xem, tạo nhập/xuất, xem sản phẩm, xem cảnh báo
INSERT INTO role_permissions (role_id, permission_id)
SELECT 3, permission_id FROM permissions 
WHERE permission_code IN (
    'product.view',
    'import.view', 'import.create',
    'export.view', 'export.create',
    'stocktake.view', 'stocktake.create',
    'notification.view'
);

-- Accountant: Chỉ xem sản phẩm, xem nhập/xuất, xem báo cáo, xem nhật ký
INSERT INTO role_permissions (role_id, permission_id)
SELECT 4, permission_id FROM permissions 
WHERE permission_code IN (
    'product.view',
    'import.view',
    'export.view',
    'report.view', 'report.export',
    'log.view', 'notification.view'
);

-- ============================================================================
-- 6. THÊM DỮ LIỆU MẪU: USERS (NGƯỜI DÙNG)
-- ============================================================================
INSERT INTO users (username, email, password_hash, full_name, phone, role_id, status) VALUES
-- Password hash giả lập (trong thực tế sử dụng bcrypt hoặc password_hash)
('admin001', 'admin@warehouse.com', '$2y$10$abcdefghijklmnopqrstuvwx', 'Nguyễn Văn Admin', '0901234567', 1, 'active'),
('manager001', 'manager@warehouse.com', '$2y$10$abcdefghijklmnopqrstuvwx', 'Trần Thị Manager', '0901234568', 2, 'active'),
('warehouse_staff_01', 'staff1@warehouse.com', '$2y$10$abcdefghijklmnopqrstuvwx', 'Lê Văn A', '0901234569', 3, 'active'),
('warehouse_staff_02', 'staff2@warehouse.com', '$2y$10$abcdefghijklmnopqrstuvwx', 'Phạm Văn B', '0901234570', 3, 'active'),
('accountant001', 'accountant@warehouse.com', '$2y$10$abcdefghijklmnopqrstuvwx', 'Hoàng Thị C', '0901234571', 4, 'active');

-- ============================================================================
-- 7. THÊM DỮ LIỆU MẪU: CATEGORIES (LOẠI SẢN PHẨM)
-- ============================================================================
INSERT INTO categories (category_name, description, status) VALUES
('Điện tử', 'Các sản phẩm điện tử tiêu dùng', 'active'),
('Quần áo', 'Quần áo thời trang', 'active'),
('Thực phẩm', 'Thực phẩm tươi sống', 'active'),
('Đồ gia dụng', 'Các dụng cụ và đồ gia dụng', 'active'),
('Sách báo', 'Sách, báo và tạp chí', 'active'),
('Mỹ phẩm', 'Mỹ phẩm và chăm sóc cá nhân', 'active');

-- ============================================================================
-- 8. THÊM DỮ LIỆU MẪU: SUPPLIERS (NHÀ CUNG CẤP)
-- ============================================================================
INSERT INTO suppliers (supplier_name, contact_person, email, phone, address, city, country, tax_code, status) VALUES
('Công ty TNHH ABC', 'Nguyễn Văn X', 'contact@abc.com', '0901111111', '123 Đường A, Quận 1', 'Hồ Chí Minh', 'Việt Nam', '0101234567', 'active'),
('Nhà nhập khẩu XYZ', 'Trần Thị Y', 'contact@xyz.com', '0901111112', '456 Đường B, Quận 3', 'Hồ Chí Minh', 'Việt Nam', '0102345678', 'active'),
('Công ty TNHH DEF', 'Lê Văn Z', 'contact@def.com', '0901111113', '789 Đường C, Quận 5', 'Hồ Chí Minh', 'Việt Nam', '0103456789', 'active'),
('Nhà sản xuất GHI', 'Phạm Thị W', 'contact@ghi.com', '0901111114', '321 Đường D, Quận 7', 'Hồ Chí Minh', 'Việt Nam', '0104567890', 'active');

-- ============================================================================
-- 9. THÊM DỮ LIỆU MẪU: CUSTOMERS (KHÁCH HÀNG)
-- ============================================================================
INSERT INTO customers (customer_name, email, phone, address, city, country, customer_type, status) VALUES
('Cửa hàng Minh Anh', 'minhanh@shop.com', '0902222221', '111 Đường E, Quận 2', 'Hồ Chí Minh', 'Việt Nam', 'business', 'active'),
('Công ty TNHH Mộc Như', 'mocnhu@company.com', '0902222222', '222 Đường F, Quận 4', 'Hồ Chí Minh', 'Việt Nam', 'business', 'active'),
('Nguyễn Thanh Hải', 'thanhhaistore@gmail.com', '0902222223', '333 Đường G, Quận 6', 'Hồ Chí Minh', 'Việt Nam', 'individual', 'active'),
('Bạch Hồng Shop', 'bachhong@gmail.com', '0902222224', '444 Đường H, Quận 8', 'Hồ Chí Minh', 'Việt Nam', 'individual', 'active'),
('Tập đoàn Thương mại QT', 'thuongmai@global.com', '0902222225', '555 Đường I, Quận 10', 'Hồ Chí Minh', 'Việt Nam', 'business', 'active');

-- ============================================================================
-- 10. THÊM DỮ LIỆU MẪU: PRODUCTS (SẢN PHẨM)
-- ============================================================================
INSERT INTO products (sku, product_name, category_id, description, unit, purchase_price, selling_price, reorder_level, current_stock, status) VALUES
-- Điện tử
('SKU001', 'Tai nghe Bluetooth Sony WF-1000', 1, 'Tai nghe không dây chức năng khử tiếng ồn', 'cái', 1500000, 2500000, 5, 8, 'active'),
('SKU002', 'Sạc pin dự phòng Anker 20000mAh', 1, 'Pin dự phòng công suất cao, sạc nhanh', 'cái', 300000, 650000, 10, 3, 'active'),
('SKU003', 'Cáp USB Type-C 2m', 1, 'Cáp sạc nhanh tương thích USB-C', 'bộ', 50000, 150000, 20, 45, 'active'),

-- Quần áo
('SKU004', 'Áo thun unisex Cotton', 2, 'Áo thun 100% cotton, thoải mái', 'cái', 80000, 250000, 15, 5, 'active'),
('SKU005', 'Quần jeans nam đen', 2, 'Quần jeans chất lượng cao', 'cái', 200000, 500000, 10, 12, 'active'),

-- Thực phẩm
('SKU006', 'Cà phê hạt Trung Nguyên', 3, 'Cà phê rang xay Trung Nguyên đậm đà', 'gói', 60000, 150000, 30, 8, 'active'),
('SKU007', 'Dầu ăn Plant 1L', 3, 'Dầu ăn cao cấp nhập khẩu', 'chai', 80000, 180000, 20, 15, 'active'),

-- Đồ gia dụng
('SKU008', 'Chảo chống dính Happycook', 4, 'Chảo chống dính kích thước 28cm', 'cái', 250000, 600000, 8, 6, 'active'),
('SKU009', 'Nước rửa chén Sunlight 500ml', 4, 'Nước rửa chén đậm đặc bảo vệ tay', 'chai', 25000, 60000, 50, 120, 'active'),

-- Sách báo
('SKU010', 'Sách Lập trình Python cơ bản', 5, 'Giáo trình lập trình Python', 'cuốn', 80000, 220000, 5, 4, 'active'),

-- Mỹ phẩm
('SKU011', 'Mặt nạ dưỡng da sheet mask', 6, 'Mặt nạ giấy dưỡng ẩm', 'hộp', 150000, 400000, 10, 8, 'active'),
('SKU012', 'Kem dưỡng da ban đêm', 6, 'Kem dưỡng da chuyên biệt', 'hộp', 200000, 550000, 8, 2, 'active');

-- ============================================================================
-- 11. THÊM DỮ LIỆU MẪU: IMPORT_RECEIPTS (PHIẾU NHẬP)
-- ============================================================================
INSERT INTO import_receipts (receipt_number, supplier_id, warehouse_staff_id, receipt_date, total_amount, status) VALUES
('IMP-2025-001', 1, 3, '2025-01-10', 5000000, 'completed'),
('IMP-2025-002', 2, 4, '2025-01-15', 3500000, 'completed'),
('IMP-2025-003', 3, 3, '2025-01-20', 2000000, 'pending');

-- ============================================================================
-- 12. THÊM DỮ LIỆU MẪU: IMPORT_RECEIPT_DETAILS (CHI TIẾT NHẬP)
-- ============================================================================
INSERT INTO import_receipt_details (receipt_id, product_id, quantity, unit_price, total_price) VALUES
(1, 1, 5, 1500000, 7500000),
(1, 2, 10, 300000, 3000000),
(2, 4, 20, 80000, 1600000),
(2, 5, 15, 200000, 3000000),
(3, 6, 50, 60000, 3000000),
(3, 7, 30, 80000, 2400000);

-- ============================================================================
-- 13. THÊM DỮ LIỆU MẪU: EXPORT_RECEIPTS (PHIẾU XUẤT)
-- ============================================================================
INSERT INTO export_receipts (receipt_number, customer_id, warehouse_staff_id, receipt_date, total_amount, status) VALUES
('EXP-2025-001', 1, 3, '2025-01-12', 2000000, 'delivered'),
('EXP-2025-002', 2, 4, '2025-01-18', 1500000, 'delivered'),
('EXP-2025-003', 3, 3, '2025-01-25', 800000, 'shipped');

-- ============================================================================
-- 14. THÊM DỮ LIỆU MẫU: EXPORT_RECEIPT_DETAILS (CHI TIẾT XUẤT)
-- ============================================================================
INSERT INTO export_receipt_details (receipt_id, product_id, quantity, unit_price, total_price) VALUES
(1, 1, 2, 2500000, 5000000),
(1, 2, 3, 650000, 1950000),
(2, 4, 5, 250000, 1250000),
(2, 5, 3, 500000, 1500000),
(3, 3, 10, 150000, 1500000);

-- ============================================================================
-- 15. THÊM DỮ LIỆU MẪU: STOCKTAKE (KIỂM KHO)
-- ============================================================================
INSERT INTO stocktake (stocktake_code, stocktake_date, staff_id, status) VALUES
('ST-2025-001', '2025-01-20', 3, 'completed'),
('ST-2025-002', '2025-01-25', 4, 'in_progress');

-- ============================================================================
-- 16. THÊM DỮ LIỆU MẪU: STOCKTAKE_DETAILS (CHI TIẾT KIỂM KHO)
-- ============================================================================
INSERT INTO stocktake_details (stocktake_id, product_id, system_quantity, physical_quantity, difference) VALUES
(1, 1, 8, 8, 0),
(1, 2, 3, 3, 0),
(1, 3, 45, 45, 0),
(1, 4, 5, 5, 0),
(1, 5, 12, 12, 0),
(2, 6, 8, 7, -1),
(2, 7, 15, 16, 1),
(2, 8, 6, 6, 0),
(2, 9, 120, 120, 0);

-- ============================================================================
-- 17. THÊM DỮ LIỆU MẪU: ACTIVITY_LOGS (NHẬT KÝ HOẠT ĐỘNG)
-- ============================================================================
INSERT INTO activity_logs (user_id, action, entity_type, entity_id, description) VALUES
(1, 'LOGIN', 'User', 1, 'Admin001 đăng nhập vào hệ thống'),
(2, 'LOGIN', 'User', 2, 'Manager001 đăng nhập vào hệ thống'),
(3, 'CREATE', 'ImportReceipt', 1, 'Tạo phiếu nhập IMP-2025-001'),
(3, 'CREATE', 'ExportReceipt', 1, 'Tạo phiếu xuất EXP-2025-001'),
(4, 'CREATE', 'Stocktake', 1, 'Tạo đợt kiểm kho ST-2025-001');

-- ============================================================================
-- ============================================================================
-- PHẦN II: VIEWS, TRIGGERS & STORED PROCEDURES
-- ============================================================================
-- ============================================================================

-- ============================================================================
-- 1. TẠO VIEW: view_inventory_status
-- ============================================================================
CREATE VIEW view_inventory_status AS
SELECT 
    p.product_id,
    p.sku,
    p.product_name,
    c.category_name,
    p.unit,
    p.purchase_price,
    p.selling_price,
    p.current_stock,
    p.reorder_level,
    CASE 
        WHEN p.current_stock < p.reorder_level THEN 'Cảnh báo - Tồn kho thấp'
        WHEN p.current_stock >= (p.reorder_level * 2) THEN 'Bình thường'
        ELSE 'Cần theo dõi'
    END AS stock_status,
    (p.current_stock * p.selling_price) AS inventory_value,
    p.status,
    p.updated_at
FROM products p
INNER JOIN categories c ON p.category_id = c.category_id
WHERE p.status = 'active'
ORDER BY p.current_stock ASC;

-- ============================================================================
-- 2. TẠO TRIGGER: Cảnh báo tồn kho thấp sau khi cập nhật products
-- ============================================================================
DELIMITER $$

CREATE TRIGGER trg_low_stock_alert_after_update
AFTER UPDATE ON products
FOR EACH ROW
BEGIN
    -- Nếu số lượng tồn kho mới < mức tối thiểu và tồn kho cũ >= mức tối thiểu
    -- thì tạo cảnh báo mới
    IF NEW.current_stock < NEW.reorder_level AND OLD.current_stock >= OLD.reorder_level THEN
        INSERT INTO notifications (product_id, notification_type, message, is_read)
        VALUES (
            NEW.product_id,
            'low_stock',
            CONCAT('Sản phẩm "', NEW.product_name, '" (SKU: ', NEW.sku, ') có tồn kho thấp: ', NEW.current_stock, ' ', NEW.unit),
            FALSE
        );
    END IF;
    
    -- Nếu tồn kho về bình thường (>= mức tối thiểu) thì cập nhật các cảnh báo chưa đọc
    IF NEW.current_stock >= NEW.reorder_level AND OLD.current_stock < OLD.reorder_level THEN
        UPDATE notifications
        SET is_read = TRUE
        WHERE product_id = NEW.product_id 
        AND notification_type = 'low_stock' 
        AND is_read = FALSE;
    END IF;
END$$

DELIMITER ;

-- ============================================================================
-- 3. TẠO TRIGGER: Ghi log khi sản phẩm bị cập nhật
-- ============================================================================
DELIMITER $$

CREATE TRIGGER trg_log_product_update
AFTER UPDATE ON products
FOR EACH ROW
BEGIN
    -- Ghi log chỉ khi có sự thay đổi trong current_stock hoặc selling_price
    IF NEW.current_stock != OLD.current_stock OR NEW.selling_price != OLD.selling_price THEN
        INSERT INTO activity_logs (
            user_id, 
            action, 
            entity_type, 
            entity_id, 
            old_value, 
            new_value, 
            description
        ) VALUES (
            1, -- Giả sử user_id = 1 (Admin) - trong thực tế cần lấy từ context
            'UPDATE',
            'Product',
            NEW.product_id,
            CONCAT('Tồn kho: ', OLD.current_stock, ', Giá: ', OLD.selling_price),
            CONCAT('Tồn kho: ', NEW.current_stock, ', Giá: ', NEW.selling_price),
            CONCAT('Cập nhật sản phẩm ', NEW.product_name, ' (SKU: ', NEW.sku, ')')
        );
    END IF;
END$$

DELIMITER ;

-- ============================================================================
-- 4. TẠO TRIGGER: Tự động cập nhật total_price trong import_receipt_details
-- ============================================================================
DELIMITER $$

CREATE TRIGGER trg_calc_import_detail_total
BEFORE INSERT ON import_receipt_details
FOR EACH ROW
BEGIN
    SET NEW.total_price = NEW.quantity * NEW.unit_price;
END$$

DELIMITER ;

-- ============================================================================
-- 5. TẠO TRIGGER: Tự động cập nhật total_price trong export_receipt_details
-- ============================================================================
DELIMITER $$

CREATE TRIGGER trg_calc_export_detail_total
BEFORE INSERT ON export_receipt_details
FOR EACH ROW
BEGIN
    SET NEW.total_price = NEW.quantity * NEW.unit_price;
END$$

DELIMITER ;

-- ============================================================================
-- 6. TẠO TRIGGER: Tự động cập nhật total_amount trong import_receipts
-- ============================================================================
DELIMITER $$

CREATE TRIGGER trg_calc_import_receipt_total
AFTER INSERT ON import_receipt_details
FOR EACH ROW
BEGIN
    UPDATE import_receipts
    SET total_amount = (
        SELECT COALESCE(SUM(total_price), 0)
        FROM import_receipt_details
        WHERE receipt_id = NEW.receipt_id
    )
    WHERE receipt_id = NEW.receipt_id;
END$$

DELIMITER ;

-- ============================================================================
-- 7. TẠO TRIGGER: Tự động cập nhật total_amount trong export_receipts
-- ============================================================================
DELIMITER $$

CREATE TRIGGER trg_calc_export_receipt_total
AFTER INSERT ON export_receipt_details
FOR EACH ROW
BEGIN
    UPDATE export_receipts
    SET total_amount = (
        SELECT COALESCE(SUM(total_price), 0)
        FROM export_receipt_details
        WHERE receipt_id = NEW.receipt_id
    )
    WHERE receipt_id = NEW.receipt_id;
END$$

DELIMITER ;

-- ============================================================================
-- ============================================================================
-- PHẦN III: QUERIES THƯỜNG DÙNG
-- ============================================================================
-- ============================================================================

-- ============================================================================
-- QUERY 1: Top 10 sản phẩm tồn kho thấp nhất
-- ============================================================================
-- Mục đích: Giúp quản lý nhanh chóng xác định những sản phẩm cần nhập thêm
SELECT 
    p.product_id,
    p.sku,
    p.product_name,
    c.category_name,
    p.current_stock,
    p.reorder_level,
    p.unit,
    (p.reorder_level - p.current_stock) AS quantity_to_order,
    p.purchase_price,
    ((p.reorder_level - p.current_stock) * p.purchase_price) AS estimated_cost
FROM products p
INNER JOIN categories c ON p.category_id = c.category_id
WHERE p.status = 'active' AND p.current_stock < p.reorder_level
ORDER BY p.current_stock ASC
LIMIT 10;

-- ============================================================================
-- QUERY 2: Thống kê tổng tồn kho theo từng loại hàng
-- ============================================================================
-- Mục đích: Xem tổng quát tồn kho của từng danh mục sản phẩm
SELECT 
    c.category_id,
    c.category_name,
    COUNT(p.product_id) AS total_products,
    COALESCE(SUM(p.current_stock), 0) AS total_quantity,
    COALESCE(SUM(p.current_stock * p.selling_price), 0) AS inventory_value,
    ROUND(COALESCE(SUM(p.current_stock * p.selling_price), 0) / 
        NULLIF(COALESCE(SUM(p.current_stock * p.purchase_price), 0), 0) * 100, 2) AS profit_margin_percent
FROM categories c
LEFT JOIN products p ON c.category_id = p.category_id AND p.status = 'active'
WHERE c.status = 'active'
GROUP BY c.category_id, c.category_name
ORDER BY inventory_value DESC;

-- ============================================================================
-- QUERY 3: Lịch sử nhập xuất gần nhất (20 giao dịch cuối cùng)
-- ============================================================================
-- Mục đích: Theo dõi hoạt động nhập xuất kho gần đây
SELECT 
    'Nhập hàng' AS transaction_type,
    ir.receipt_number AS receipt_no,
    s.supplier_name AS partner_name,
    ir.receipt_date,
    u.full_name AS created_by,
    COUNT(ird.detail_id) AS total_items,
    ir.total_amount,
    ir.status
FROM import_receipts ir
INNER JOIN suppliers s ON ir.supplier_id = s.supplier_id
INNER JOIN users u ON ir.warehouse_staff_id = u.user_id
LEFT JOIN import_receipt_details ird ON ir.receipt_id = ird.receipt_id
GROUP BY ir.receipt_id
UNION ALL
SELECT 
    'Xuất hàng' AS transaction_type,
    er.receipt_number AS receipt_no,
    c.customer_name AS partner_name,
    er.receipt_date,
    u.full_name AS created_by,
    COUNT(erd.detail_id) AS total_items,
    er.total_amount,
    er.status
FROM export_receipts er
INNER JOIN customers c ON er.customer_id = c.customer_id
INNER JOIN users u ON er.warehouse_staff_id = u.user_id
LEFT JOIN export_receipt_details erd ON er.receipt_id = erd.receipt_id
GROUP BY er.receipt_id
ORDER BY receipt_date DESC
LIMIT 20;

-- ============================================================================
-- QUERY 4: Doanh thu theo tháng (6 tháng gần nhất)
-- ============================================================================
-- Mục đích: Phân tích doanh số bán hàng theo từng tháng
SELECT 
    DATE_FORMAT(er.receipt_date, '%Y-%m') AS month,
    DATE_FORMAT(er.receipt_date, '%b %Y') AS month_display,
    COUNT(DISTINCT er.receipt_id) AS total_orders,
    COUNT(DISTINCT er.customer_id) AS unique_customers,
    COALESCE(SUM(er.total_amount), 0) AS total_revenue,
    ROUND(COALESCE(AVG(er.total_amount), 0), 2) AS avg_order_value
FROM export_receipts er
WHERE er.status IN ('delivered', 'shipped', 'completed')
AND er.receipt_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY DATE_FORMAT(er.receipt_date, '%Y-%m')
ORDER BY month DESC;

-- ============================================================================
-- QUERY 5: Chênh lệch kiểm kho (Thực tế vs Hệ thống)
-- ============================================================================
-- Mục đích: Phát hiện sai sót về tồn kho, hàng mất, hoặc thừa
SELECT 
    st.stocktake_id,
    st.stocktake_code,
    st.stocktake_date,
    u.full_name AS staff_name,
    p.product_id,
    p.sku,
    p.product_name,
    c.category_name,
    std.system_quantity,
    std.physical_quantity,
    std.difference,
    CASE 
        WHEN std.difference < 0 THEN CONCAT('Thiếu: ', ABS(std.difference), ' ', p.unit)
        WHEN std.difference > 0 THEN CONCAT('Thừa: ', std.difference, ' ', p.unit)
        ELSE 'Chính xác'
    END AS discrepancy_status,
    std.notes
FROM stocktake st
INNER JOIN stocktake_details std ON st.stocktake_id = std.stocktake_id
INNER JOIN products p ON std.product_id = p.product_id
INNER JOIN categories c ON p.category_id = c.category_id
INNER JOIN users u ON st.staff_id = u.user_id
WHERE std.difference != 0
ORDER BY st.stocktake_date DESC, ABS(std.difference) DESC;

-- ============================================================================
-- QUERY 6 (THÊM): Danh sách sản phẩm sắp hết hàng
-- ============================================================================
-- Mục đích: Cảnh báo sản phẩm sắp hết và cần nhập khẩn cấp
SELECT 
    p.product_id,
    p.sku,
    p.product_name,
    c.category_name,
    p.current_stock,
    p.reorder_level,
    CASE 
        WHEN p.current_stock = 0 THEN 'HẾT HÀNG'
        WHEN p.current_stock < (p.reorder_level * 0.5) THEN 'NGUY HIỂM'
        WHEN p.current_stock < p.reorder_level THEN 'CẢNH BÁO'
        ELSE 'BÌNH THƯỜNG'
    END AS status_alert,
    p.updated_at
FROM products p
INNER JOIN categories c ON p.category_id = c.category_id
WHERE p.status = 'active'
ORDER BY p.current_stock ASC;

-- ============================================================================
-- ============================================================================
-- CHÚ THÍCH VÀ HƯỚNG DẪN SỬ DỤNG
-- ============================================================================
-- ============================================================================

/*
HƯỚNG DẪN IMPORT:
1. Mở MySQL Workbench hoặc phpMyAdmin
2. Chọn Import từ menu (hoặc chạy trực tiếp file SQL này)
3. File này sẽ tự động:
   - Xóa database cũ nếu tồn tại (DROP DATABASE)
   - Tạo database mới: warehouse_db
   - Tạo 17 bảng với quan hệ và ràng buộc
   - Tạo 3 bảng quan hệ phức tạp (Permissions, Roles, Role_Permissions)
   - Thêm 7 TRIGGER tự động
   - Tạo 1 VIEW giám sát tồn kho
   - Thêm dữ liệu mẫu cho thử nghiệm

CÁCH TRUY VẤN DỮ LIỆU:
- Sử dụng 6 query đã viết sẵn ở cuối file
- Hoặc truy vấn trực tiếp từ VIEW: SELECT * FROM view_inventory_status;

GHI CHÚ QUAN TRỌNG:
1. Password hash trong bảng users chỉ là giả lập
   - Trong production, sử dụng PHP bcrypt hoặc tương tự
2. TRIGGERS tự động cập nhật:
   - Tính toán total_price cho chi tiết hóa đơn
   - Cảnh báo khi tồn kho thấp
   - Ghi nhật ký hoạt động
3. FOREIGN KEY constraints đảm bảo tính toàn vẹn dữ liệu
4. INDEXES được tạo trên các cột tìm kiếm thường xuyên

QUẢN LÝ QUYỀN HẠN:
- 4 ROLES được cấu hình: Admin, Manager, Warehouse Staff, Accountant
- 16 PERMISSIONS chi tiết cho từng module
- Có thể thêm user và gán role/permission tùy theo nhu cầu

BẢNG CHÍNH:
1. products: Lưu thông tin sản phẩm với current_stock
2. import_receipts / import_receipt_details: Quản lý hàng nhập
3. export_receipts / export_receipt_details: Quản lý hàng xuất
4. stocktake / stocktake_details: Quản lý kiểm kho
5. notifications: Cảnh báo tự động từ TRIGGER
6. activity_logs: Ghi lại mọi hoạt động
7. users / roles / permissions: Quản lý quyền hạn

PHÁT TRIỂN TIẾP:
- Thêm Stored Procedures cho các tác vụ phức tạp
- Thêm more TRIGGERS nếu cần
- Tối ưu hóa INDEXES dựa trên pattern truy vấn thực tế
- Thêm CHECK constraints nếu cần validation cấp DB
*/

-- ============================================================================
-- KẾT THÚC FILE SQL - DATABASE WAREHOUSE_DB
-- ============================================================================
