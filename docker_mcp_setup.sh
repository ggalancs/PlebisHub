#!/bin/bash

# Script para configurar Docker Desktop MCP con Claude Code en macOS
# Ejecutar con: bash setup-docker-mcp-claude-code.sh

set -e

echo "🐳 Configurando Docker Desktop MCP para Claude Code en macOS..."

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verificar que Docker Desktop está instalado
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}❌ Docker Desktop no está instalado${NC}"
    echo "Instálalo desde: https://www.docker.com/products/docker-desktop"
    exit 1
fi

echo -e "${GREEN}✓ Docker Desktop encontrado${NC}"

# Verificar que Docker Desktop está corriendo
if ! docker info &> /dev/null; then
    echo -e "${YELLOW}❌ Docker Desktop no está corriendo${NC}"
    echo "Por favor, inicia Docker Desktop y vuelve a ejecutar este script"
    exit 1
fi

echo -e "${GREEN}✓ Docker Desktop está corriendo${NC}"

# Directorio de configuración de Claude Code
CLAUDE_CONFIG_DIR="$HOME/.config/claude"
CLAUDE_CONFIG_FILE="$CLAUDE_CONFIG_DIR/claude_desktop_config.json"

# Crear directorio si no existe
mkdir -p "$CLAUDE_CONFIG_DIR"

# Verificar si npx está disponible
if ! command -v npx &> /dev/null; then
    echo -e "${YELLOW}❌ npx no está instalado${NC}"
    echo "Instala Node.js desde: https://nodejs.org/"
    exit 1
fi

echo -e "${GREEN}✓ npx encontrado${NC}"

# Crear o actualizar la configuración
echo -e "${BLUE}📝 Configurando claude_desktop_config.json...${NC}"

# Backup del archivo existente si existe
if [ -f "$CLAUDE_CONFIG_FILE" ]; then
    BACKUP_FILE="$CLAUDE_CONFIG_FILE.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$CLAUDE_CONFIG_FILE" "$BACKUP_FILE"
    echo -e "${GREEN}✓ Backup creado: $BACKUP_FILE${NC}"
fi

# Crear la configuración del MCP de Docker
cat > "$CLAUDE_CONFIG_FILE" << 'EOF'
{
  "mcpServers": {
    "docker": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-docker"
      ]
    }
  }
}
EOF

echo -e "${GREEN}✓ Configuración creada en: $CLAUDE_CONFIG_FILE${NC}"

# Mostrar la configuración
echo -e "\n${BLUE}📄 Configuración actual:${NC}"
cat "$CLAUDE_CONFIG_FILE"

# Verificar que el servidor MCP se puede ejecutar
echo -e "\n${BLUE}🧪 Verificando servidor MCP de Docker...${NC}"
if npx -y @modelcontextprotocol/server-docker --version &> /dev/null; then
    echo -e "${GREEN}✓ Servidor MCP de Docker verificado${NC}"
else
    echo -e "${YELLOW}⚠️  No se pudo verificar el servidor MCP${NC}"
    echo "Pero debería funcionar al ejecutar Claude Code"
fi

# Instrucciones finales
echo -e "\n${GREEN}✅ Configuración completada${NC}"
echo -e "\n${BLUE}Próximos pasos:${NC}"
echo "1. Reinicia Claude Code si está abierto"
echo "2. Ejecuta: claude-code"
echo "3. El MCP de Docker estará disponible automáticamente"
echo ""
echo -e "${BLUE}Capacidades disponibles:${NC}"
echo "  • Listar contenedores, imágenes, volúmenes y redes"
echo "  • Inspeccionar y gestionar contenedores"
echo "  • Ver logs de contenedores"
echo "  • Ejecutar comandos en contenedores"
echo "  • Gestionar imágenes Docker"
echo ""
echo -e "${YELLOW}Nota:${NC} Asegúrate de que Docker Desktop tenga permisos en"
echo "Configuración del Sistema → Privacidad y Seguridad → Automatización"
