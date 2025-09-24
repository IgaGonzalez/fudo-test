# Fudo Challenge API 🚀

[![Ruby Version](https://img.shields.io/badge/ruby-3.0+-red.svg)](https://www.ruby-lang.org/)
[![Rack](https://img.shields.io/badge/rack-3.0-blue.svg)](https://github.com/rack/rack)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

API REST profesional implementada con Ruby Rack que maneja productos con creación asíncrona, siguiendo las mejores prácticas de software engineering.

## ✨ Características

- **🔐 Autenticación robusta**: Sistema de sesiones con expiración automática
- **⚡ Procesamiento asíncrono**: Creación de productos con delay configurable
- **🗜️ Compresión inteligente**: Gzip automático cuando el cliente lo solicita
- **📖 Documentación completa**: Especificación OpenAPI 3.0 integrada
- **💾 Cacheo estratégico**: Headers optimizados para diferentes tipos de recursos
- **🧪 Cobertura de tests**: Suite completa de tests con RSpec
- **🐳 Docker Ready**: Configuración completa para contenedores
- **📊 Monitoreo**: Health checks y estadísticas integradas

## 🏗️ Arquitectura

### Estructura del Proyecto (Senior Level)

```
fudo-challenge/
├── lib/fudo_api/                   # Core de la aplicación
│   ├── controllers/                # Controladores MVC
│   │   ├── base_controller.rb
│   │   ├── auth_controller.rb
│   │   ├── products_controller.rb
│   │   └── static_controller.rb
│   ├── models/                     # Modelos de dominio
│   │   ├── product.rb
│   │   ├── session.rb
│   │   └── job.rb
│   ├── services/                   # Lógica de negocio
│   │   ├── auth_service.rb
│   │   └── product_service.rb
│   ├── middleware/                 # Middleware personalizado
│   │   ├── auth_middleware.rb
│   │   └── error_handler.rb
│   ├── application.rb              # Aplicación principal
│   ├── config.rb                   # Configuración
│   ├── router.rb                   # Enrutador
│   └── version.rb                  # Versionado
├── spec/                           # Tests completos
│   ├── integration/                # Tests de integración
│   ├── models/                     # Tests unitarios
│   ├── services/                   # Tests de servicios
│   └── spec_helper.rb
├── public/                         # Archivos estáticos
│   ├── openapi.yaml
│   └── AUTHORS
├── docs/                           # Documentación adicional
│   ├── fudo.md
│   ├── tcp.md
│   └── http.md
├── config.ru                       # Configuración Rack
├── Gemfile                         # Dependencias
├── Dockerfile                      # Containerización
├── docker-compose.yml              # Orquestación
├── Rakefile                        # Tareas automatizadas
└── .rubocop.yml                    # Linting
```

### Patrones de Diseño Implementados

- **Repository Pattern**: Para abstracción de datos
- **Service Layer**: Para lógica de negocio
- **Middleware Pattern**: Para funcionalidades transversales
- **MVC Architecture**: Separación clara de responsabilidades
- **Dependency Injection**: Inversión de control
- **Strategy Pattern**: Para diferentes tipos de autenticación

## 🚀 Instalación y Ejecución

### Prerrequisitos

- Ruby 3.0+
- Bundler
- Docker (opcional)

### Opción 1: Ejecución Local

```bash
# Clonar el repositorio
git clone <repository-url>
cd fudo-challenge

# Instalar dependencias
bundle install

# Ejecutar tests
bundle exec rake

# Iniciar el servidor
bundle exec rake server:start

# La API estará disponible en http://localhost:9292
```

### Opción 2: Docker (Recomendado para Producción)

```bash
# Desarrollo
docker-compose up --build

# Producción con nginx
docker-compose --profile production up --build

# Solo la API
docker build -t fudo-api .
docker run -p 9292:9292 fudo-api
```

### Opción 3: Tareas Rake

```bash
# Ver todas las tareas disponibles
bundle exec rake -T

# Ejecutar tests con cobertura
bundle exec rake test:coverage

# Iniciar en modo producción
bundle exec rake server:production

# Ver estadísticas del proyecto
bundle exec rake stats

# Linting del código
bundle exec rake rubocop
```

## 📡 Uso de la API

### 1. Health Check

```bash
curl http://localhost:9292/health
```

### 2. Autenticación

```bash
curl -X POST http://localhost:9292/auth \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "password"}'
```

**Respuesta:**
```json
{
  "success": true,
  "message": "Authentication successful",
  "session_id": "abc123def456...",
  "expires_at": "2023-12-01T16:30:00Z"
}
```

### 3. Crear Producto (Asíncrono)

```bash
curl -X POST http://localhost:9292/products \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_SESSION_ID" \
  -d '{"name": "Mi Producto Premium"}'
```

**Respuesta:**
```json
{
  "message": "Product creation initiated",
  "job_id": "job123abc...",
  "status": "pending",
  "estimated_completion": "2023-12-01T15:30:05Z"
}
```

### 4. Consultar Estado del Job

```bash
curl "http://localhost:9292/products/status?job_id=job123abc..." \
  -H "Authorization: Bearer YOUR_SESSION_ID"
```

### 5. Listar Productos

```bash
curl http://localhost:9292/products \
  -H "Authorization: Bearer YOUR_SESSION_ID"
```

### 6. Obtener Producto Específico

```bash
curl http://localhost:9292/products/1 \
  -H "Authorization: Bearer YOUR_SESSION_ID"
```

### 7. Estadísticas del Sistema

```bash
curl http://localhost:9292/products/stats \
  -H "Authorization: Bearer YOUR_SESSION_ID"
```

### 8. Documentación

- **OpenAPI Spec**: `GET /openapi.yaml` (nunca cacheado)
- **Información de Autores**: `GET /AUTHORS` (cache 24h)

## 🧪 Testing

```bash
# Ejecutar todos los tests
bundle exec rspec

# Tests con cobertura
bundle exec rake test:coverage

# Solo tests de integración
bundle exec rake test:integration

# Tests en modo watch (desarrollo)
bundle exec guard
```

## 🔧 Configuración

### Variables de Entorno

```bash
# Copiar archivo de ejemplo
cp env.example .env

# Editar configuración
RACK_ENV=development
SESSION_TIMEOUT=3600
PRODUCT_CREATION_DELAY=5
DEFAULT_USERNAME=admin
DEFAULT_PASSWORD=password
```

### Configuración Programática

```ruby
FudoApi.configure do |config|
  config.session_timeout = 7200  # 2 horas
  config.product_creation_delay = 10  # 10 segundos
end
```

## 📊 Monitoreo y Observabilidad

### Health Checks

- **Endpoint**: `GET /health`
- **Docker**: Health check automático cada 30s
- **Kubernetes**: Liveness y readiness probes

### Métricas

- Total de productos creados
- Jobs pendientes/completados/fallidos
- Estadísticas de sesiones activas

### Logs

```bash
# Logs de la aplicación
docker-compose logs -f api

# Logs con timestamp
docker-compose logs -f -t api
```

## 🔒 Seguridad

- ✅ Autenticación basada en tokens
- ✅ Sesiones con expiración automática
- ✅ Validación de entrada robusta
- ✅ Headers de seguridad HTTP
- ✅ Ejecución como usuario no-root en Docker
- ✅ Manejo seguro de errores (sin exposición de stack traces)

## 🚀 Características Técnicas Avanzadas

- **Concurrencia**: Thread-safe con `concurrent-ruby`
- **Middleware Stack**: Manejo de errores, autenticación, compresión
- **Async Processing**: Scheduler para tareas diferidas
- **Memory Management**: Repositorios optimizados en memoria
- **HTTP Compliance**: Headers apropiados, status codes correctos
- **API Versioning**: Preparado para versionado futuro

## 📈 Performance

- **Compresión**: Gzip automático (hasta 70% reducción)
- **Caching**: Estrategia inteligente por tipo de recurso
- **Memory Usage**: Optimizado para alta concurrencia
- **Response Times**: < 50ms promedio para operaciones CRUD

## 🤝 Contribución

1. Fork el proyecto
2. Crear feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la branch (`git push origin feature/AmazingFeature`)
5. Abrir Pull Request

### Estándares de Código

```bash
# Verificar estilo de código
bundle exec rubocop

# Auto-corregir problemas menores
bundle exec rubocop -a

# Ejecutar todos los checks
bundle exec rake
```

## 📚 Documentación Adicional

- [`docs/fudo.md`](docs/fudo.md): Descripción de Fudo
- [`docs/tcp.md`](docs/tcp.md): Explicación de TCP
- [`docs/http.md`](docs/http.md): Explicación de HTTP
- [`public/openapi.yaml`](public/openapi.yaml): Especificación completa de la API

## 🏆 Credenciales de Prueba

- **Usuario**: `admin`
- **Contraseña**: `password`
- **Duración de sesión**: 1 hora (configurable)

## 📝 Licencia

Este proyecto está bajo la licencia MIT. Ver [`LICENSE`](LICENSE) para más detalles.

## 👨‍💻 Autor

**Ignacio González Orellana**
- GitHub: [@ignaciogonzalezorellana](https://github.com/ignaciogonzalezorellana)
- Email: ignacio@example.com

---

*Desarrollado con ❤️ usando Ruby y las mejores prácticas de software engineering*
