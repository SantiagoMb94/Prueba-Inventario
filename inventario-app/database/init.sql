-- Inicialización de la base de datos de inventario
-- Este archivo se ejecuta automáticamente al crear el contenedor PostgreSQL

-- Crear extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tabla de usuarios
CREATE TABLE IF NOT EXISTS usuarios (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    rol VARCHAR(20) DEFAULT 'usuario',
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de categorías de equipos
CREATE TABLE IF NOT EXISTS categorias (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de equipos
CREATE TABLE IF NOT EXISTS equipos (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    categoria_id INTEGER REFERENCES categorias(id),
    marca VARCHAR(100),
    modelo VARCHAR(100),
    serial VARCHAR(100),
    ubicacion VARCHAR(200),
    estado VARCHAR(50) DEFAULT 'activo',
    fecha_adquisicion DATE,
    valor_adquisicion DECIMAL(10,2),
    responsable_id INTEGER REFERENCES usuarios(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de inventario
CREATE TABLE IF NOT EXISTS inventario (
    id SERIAL PRIMARY KEY,
    equipo_id INTEGER REFERENCES equipos(id),
    cantidad INTEGER DEFAULT 1,
    stock_minimo INTEGER DEFAULT 0,
    stock_maximo INTEGER DEFAULT 100,
    ubicacion_almacen VARCHAR(200),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de movimientos de inventario
CREATE TABLE IF NOT EXISTS movimientos_inventario (
    id SERIAL PRIMARY KEY,
    inventario_id INTEGER REFERENCES inventario(id),
    tipo_movimiento VARCHAR(20) NOT NULL, -- 'entrada', 'salida', 'ajuste'
    cantidad INTEGER NOT NULL,
    motivo TEXT,
    usuario_id INTEGER REFERENCES usuarios(id),
    fecha_movimiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar datos de ejemplo

-- Usuario administrador por defecto
INSERT INTO usuarios (username, email, password_hash, nombre, apellido, rol) 
VALUES ('admin', 'admin@inventario.com', '$2b$10$rQZ8K9mN2pL1vX3yW4uJ5t', 'Administrador', 'Sistema', 'admin')
ON CONFLICT (username) DO NOTHING;

-- Categorías básicas
INSERT INTO categorias (nombre, descripcion) VALUES
('Computadoras', 'Equipos de cómputo y laptops'),
('Periféricos', 'Teclados, mouse, monitores, etc.'),
('Redes', 'Switches, routers, cables de red'),
('Mobiliario', 'Escritorios, sillas, estantes'),
('Herramientas', 'Herramientas de trabajo')
ON CONFLICT DO NOTHING;

-- Crear índices para mejorar rendimiento
CREATE INDEX IF NOT EXISTS idx_equipos_categoria ON equipos(categoria_id);
CREATE INDEX IF NOT EXISTS idx_equipos_responsable ON equipos(responsable_id);
CREATE INDEX IF NOT EXISTS idx_inventario_equipo ON inventario(equipo_id);
CREATE INDEX IF NOT EXISTS idx_movimientos_inventario ON movimientos_inventario(inventario_id);

-- Función para actualizar timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para actualizar timestamps
CREATE TRIGGER update_usuarios_updated_at BEFORE UPDATE ON usuarios FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_equipos_updated_at BEFORE UPDATE ON equipos FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_inventario_updated_at BEFORE UPDATE ON inventario FOR EACH ROW EXECUTE FUNCTION update_updated_at_column(); 