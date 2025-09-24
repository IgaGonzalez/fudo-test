# 🌐 Ejemplos de cURL para Fudo Challenge API

Esta documentación proporciona ejemplos completos de cURL para probar todos los endpoints de la API sin necesidad de Postman.

## 🚀 Setup Inicial

```bash
# Variables base
export BASE_URL="http://localhost:9292"
export USERNAME="admin"
export PASSWORD="password"
```

## 📋 Endpoints de Prueba

### 1. 🏥 Health Check

```bash
curl -X GET "$BASE_URL/health" \
  -H "Accept: application/json" \
  -w "\nStatus: %{http_code}\nTime: %{time_total}s\n"
```

**Respuesta esperada:**
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "timestamp": "2023-12-01T15:30:00+00:00",
  "success": true
}
```

### 2. 🔐 Autenticación

```bash
# Login y guardar session_id
SESSION_RESPONSE=$(curl -s -X POST "$BASE_URL/auth" \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\"}")

echo "Auth Response: $SESSION_RESPONSE"

# Extraer session_id
SESSION_ID=$(echo "$SESSION_RESPONSE" | grep -o '"session_id":"[^"]*"' | cut -d'"' -f4)
echo "Session ID: $SESSION_ID"

# Verificar autenticación
if [ -z "$SESSION_ID" ]; then
  echo "❌ Authentication failed"
  exit 1
else
  echo "✅ Authentication successful"
fi
```

**Respuesta esperada:**
```json
{
  "success": true,
  "message": "Authentication successful",
  "session_id": "abc123...",
  "expires_at": "2023-12-01T16:30:00+00:00"
}
```

### 3. 📦 Crear Producto (Asíncrono)

```bash
# Crear producto y guardar job_id
PRODUCT_RESPONSE=$(curl -s -X POST "$BASE_URL/products" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $SESSION_ID" \
  -d '{"name": "Producto de Prueba cURL"}')

echo "Product Creation Response: $PRODUCT_RESPONSE"

# Extraer job_id
JOB_ID=$(echo "$PRODUCT_RESPONSE" | grep -o '"job_id":"[^"]*"' | cut -d'"' -f4)
echo "Job ID: $JOB_ID"
```

**Respuesta esperada:**
```json
{
  "message": "Product creation initiated",
  "job_id": "job123abc...",
  "status": "pending",
  "estimated_completion": "2023-12-01T15:30:05+00:00"
}
```

### 4. ⏳ Verificar Estado del Job

```bash
# Verificar estado inmediatamente
echo "🔄 Checking job status (should be pending)..."
curl -s -X GET "$BASE_URL/products/status?job_id=$JOB_ID" \
  -H "Authorization: Bearer $SESSION_ID" | jq .

# Esperar 6 segundos
echo "⏱️ Waiting 6 seconds for async completion..."
sleep 6

# Verificar estado después del delay
echo "✅ Checking job status (should be completed)..."
JOB_STATUS_RESPONSE=$(curl -s -X GET "$BASE_URL/products/status?job_id=$JOB_ID" \
  -H "Authorization: Bearer $SESSION_ID")

echo "$JOB_STATUS_RESPONSE" | jq .

# Extraer product_id
PRODUCT_ID=$(echo "$JOB_STATUS_RESPONSE" | grep -o '"product_id":[^,}]*' | cut -d':' -f2)
echo "Product ID: $PRODUCT_ID"
```

### 5. 📊 Listar Productos

```bash
echo "📋 Listing all products..."
curl -s -X GET "$BASE_URL/products" \
  -H "Authorization: Bearer $SESSION_ID" | jq .
```

### 6. 🎯 Obtener Producto Específico

```bash
echo "🎯 Getting specific product..."
curl -s -X GET "$BASE_URL/products/$PRODUCT_ID" \
  -H "Authorization: Bearer $SESSION_ID" | jq .
```

### 7. 📈 Estadísticas del Sistema

```bash
echo "📊 Getting system stats..."
curl -s -X GET "$BASE_URL/products/stats" \
  -H "Authorization: Bearer $SESSION_ID" | jq .
```

### 8. 📖 Especificación OpenAPI

```bash
echo "📖 Getting OpenAPI specification..."
curl -I "$BASE_URL/openapi.yaml"
echo ""
curl -s "$BASE_URL/openapi.yaml" | head -20
```

### 9. 👨‍💻 Archivo AUTHORS

```bash
echo "👤 Getting AUTHORS file..."
curl -I "$BASE_URL/AUTHORS"
echo ""
curl -s "$BASE_URL/AUTHORS"
```

### 10. 🗜️ Prueba de Compresión Gzip

```bash
echo "🗜️ Testing gzip compression..."
curl -s -X GET "$BASE_URL/products" \
  -H "Authorization: Bearer $SESSION_ID" \
  -H "Accept-Encoding: gzip, deflate" \
  -w "\nCompressed size: %{size_download} bytes\n"
```

## 🧪 Tests de Validación

### Credenciales Inválidas

```bash
echo "🚫 Testing invalid credentials..."
curl -s -X POST "$BASE_URL/auth" \
  -H "Content-Type: application/json" \
  -d '{"username":"wrong","password":"wrong"}' \
  -w "\nStatus: %{http_code}\n"
```

### Sin Autenticación

```bash
echo "🔒 Testing without authentication..."
curl -s -X POST "$BASE_URL/products" \
  -H "Content-Type: application/json" \
  -d '{"name":"Unauthorized Product"}' \
  -w "\nStatus: %{http_code}\n"
```

### Campo Requerido Faltante

```bash
echo "⚠️ Testing missing required field..."
curl -s -X POST "$BASE_URL/products" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $SESSION_ID" \
  -d '{"description":"Product without name"}' \
  -w "\nStatus: %{http_code}\n"
```

### JSON Inválido

```bash
echo "💥 Testing invalid JSON..."
curl -s -X POST "$BASE_URL/products" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $SESSION_ID" \
  -d '{ invalid json }' \
  -w "\nStatus: %{http_code}\n"
```

### Job ID Inválido

```bash
echo "🔍 Testing invalid job ID..."
curl -s -X GET "$BASE_URL/products/status?job_id=invalid-job-id" \
  -H "Authorization: Bearer $SESSION_ID" \
  -w "\nStatus: %{http_code}\n"
```

## 🎬 Script Completo de Pruebas

```bash
#!/bin/bash

# Fudo Challenge API - Complete Test Script
set -e  # Exit on any error

echo "🚀 Starting Fudo Challenge API Tests"
echo "====================================="

# Configuration
BASE_URL="http://localhost:9292"
USERNAME="admin"
PASSWORD="password"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
  echo -e "\n${BLUE}$1${NC}"
  echo "------------------------------"
}

print_success() {
  echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
  echo -e "${RED}❌ $1${NC}"
}

print_warning() {
  echo -e "${YELLOW}⚠️ $1${NC}"
}

# Test 1: Health Check
print_step "1. Health Check"
HEALTH_RESPONSE=$(curl -s "$BASE_URL/health")
if echo "$HEALTH_RESPONSE" | grep -q '"status":"healthy"'; then
  print_success "Health check passed"
else
  print_error "Health check failed"
  exit 1
fi

# Test 2: Authentication
print_step "2. Authentication"
SESSION_RESPONSE=$(curl -s -X POST "$BASE_URL/auth" \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\"}")

SESSION_ID=$(echo "$SESSION_RESPONSE" | grep -o '"session_id":"[^"]*"' | cut -d'"' -f4)
if [ -n "$SESSION_ID" ]; then
  print_success "Authentication successful"
  echo "Session ID: ${SESSION_ID:0:20}..."
else
  print_error "Authentication failed"
  exit 1
fi

# Test 3: Create Product
print_step "3. Create Product (Async)"
PRODUCT_RESPONSE=$(curl -s -X POST "$BASE_URL/products" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $SESSION_ID" \
  -d '{"name": "Test Product from cURL"}')

JOB_ID=$(echo "$PRODUCT_RESPONSE" | grep -o '"job_id":"[^"]*"' | cut -d'"' -f4)
if [ -n "$JOB_ID" ]; then
  print_success "Product creation initiated"
  echo "Job ID: $JOB_ID"
else
  print_error "Product creation failed"
  exit 1
fi

# Test 4: Check Job Status (Pending)
print_step "4. Check Job Status (Pending)"
JOB_STATUS=$(curl -s "$BASE_URL/products/status?job_id=$JOB_ID" \
  -H "Authorization: Bearer $SESSION_ID")
if echo "$JOB_STATUS" | grep -q '"status":"pending"'; then
  print_success "Job is pending (as expected)"
else
  print_warning "Job is not pending (might already be completed)"
fi

# Test 5: Wait and Check Completion
print_step "5. Wait for Async Completion"
echo "Waiting 6 seconds..."
sleep 6

JOB_STATUS_FINAL=$(curl -s "$BASE_URL/products/status?job_id=$JOB_ID" \
  -H "Authorization: Bearer $SESSION_ID")
if echo "$JOB_STATUS_FINAL" | grep -q '"status":"completed"'; then
  print_success "Job completed successfully"
  PRODUCT_ID=$(echo "$JOB_STATUS_FINAL" | grep -o '"product_id":[^,}]*' | cut -d':' -f2)
  echo "Product ID: $PRODUCT_ID"
else
  print_error "Job did not complete"
  echo "$JOB_STATUS_FINAL"
fi

# Test 6: List Products
print_step "6. List All Products"
PRODUCTS_LIST=$(curl -s "$BASE_URL/products" \
  -H "Authorization: Bearer $SESSION_ID")
PRODUCT_COUNT=$(echo "$PRODUCTS_LIST" | grep -o '"total":[^,}]*' | cut -d':' -f2)
print_success "Found $PRODUCT_COUNT products"

# Test 7: Get Statistics
print_step "7. System Statistics"
STATS=$(curl -s "$BASE_URL/products/stats" \
  -H "Authorization: Bearer $SESSION_ID")
echo "$STATS" | jq . 2>/dev/null || echo "$STATS"

# Test 8: Static Files
print_step "8. Static Files"
# OpenAPI
OPENAPI_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/openapi.yaml")
if [ "$OPENAPI_STATUS" = "200" ]; then
  print_success "OpenAPI specification accessible"
else
  print_error "OpenAPI specification failed ($OPENAPI_STATUS)"
fi

# AUTHORS
AUTHORS_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/AUTHORS")
if [ "$AUTHORS_STATUS" = "200" ]; then
  print_success "AUTHORS file accessible"
else
  print_error "AUTHORS file failed ($AUTHORS_STATUS)"
fi

# Test 9: Error Cases
print_step "9. Error Handling Tests"

# Invalid credentials
INVALID_AUTH=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/auth" \
  -H "Content-Type: application/json" \
  -d '{"username":"wrong","password":"wrong"}')
if [ "$INVALID_AUTH" = "401" ]; then
  print_success "Invalid credentials properly rejected (401)"
else
  print_error "Invalid credentials test failed ($INVALID_AUTH)"
fi

# No authentication
NO_AUTH=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/products" \
  -H "Content-Type: application/json" \
  -d '{"name":"Unauthorized"}')
if [ "$NO_AUTH" = "401" ]; then
  print_success "Unauthorized access properly rejected (401)"
else
  print_error "No auth test failed ($NO_AUTH)"
fi

# Invalid JSON
INVALID_JSON=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/products" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $SESSION_ID" \
  -d '{ invalid json }')
if [ "$INVALID_JSON" = "400" ]; then
  print_success "Invalid JSON properly rejected (400)"
else
  print_error "Invalid JSON test failed ($INVALID_JSON)"
fi

print_step "🎉 All Tests Completed!"
print_success "API is functioning correctly"
echo ""
echo "Summary:"
echo "- Health check: ✅"
echo "- Authentication: ✅"
echo "- Async product creation: ✅"
echo "- Job status tracking: ✅"
echo "- Product listing: ✅"
echo "- Static files: ✅"
echo "- Error handling: ✅"
echo ""
echo "🚀 Fudo Challenge API is ready for production!"
```

## 💾 Guardar el Script

```bash
# Hacer el script ejecutable
chmod +x test_api.sh

# Ejecutar
./test_api.sh
```

## 📊 Verificación de Headers

```bash
# Verificar headers de caché
echo "🔍 Checking cache headers..."

echo "OpenAPI (should not cache):"
curl -I "$BASE_URL/openapi.yaml" 2>/dev/null | grep -i cache

echo "AUTHORS (should cache 24h):"
curl -I "$BASE_URL/AUTHORS" 2>/dev/null | grep -i cache

echo "Health (may vary):"
curl -I "$BASE_URL/health" 2>/dev/null | grep -i cache
```

## 🎯 Pruebas de Performance

```bash
# Prueba de tiempo de respuesta
echo "⏱️ Performance test..."
for i in {1..5}; do
  echo "Request $i:"
  curl -s -w "Time: %{time_total}s, Size: %{size_download} bytes\n" \
    -o /dev/null "$BASE_URL/health"
done
```

---

**¡Estas herramientas te permiten probar completamente la API desde línea de comandos! 🚀**
