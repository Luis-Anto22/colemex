CREATE TABLE profesionales (
  id INT AUTO_INCREMENT PRIMARY KEY,
  rol VARCHAR(40) NOT NULL,                -- investigador, valuador, abogado, etc.
  nombre VARCHAR(120) NOT NULL,
  telefono VARCHAR(30) DEFAULT '',
  email VARCHAR(120) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,     -- nunca guardes password plano
  foto_url TEXT,
  verificado TINYINT(1) NOT NULL DEFAULT 0,
  estado VARCHAR(30) NOT NULL DEFAULT 'Disponible', -- Disponible/Ocupado/Fuera de servicio
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

);
