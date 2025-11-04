#!/bin/bash

# Windsurf 设备号重置工具
# 自动关闭 Windsurf 并重置设备标识符

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 日志函数
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 路径配置
WINDSURF_PATH="${1:-/Applications/Windsurf.app}"
HOME_DIR="$HOME"
DB_PATH="$HOME_DIR/Library/Application Support/Windsurf/User/globalStorage/state.vscdb"
JSON_PATH="$HOME_DIR/Library/Application Support/Windsurf/User/globalStorage/storage.json"
MACHINE_ID_PATH="$HOME_DIR/Library/Application Support/Windsurf/machineId"
BACKUP_DIR="$HOME_DIR/Library/Application Support/Windsurf/Backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo ""
echo "=========================================="
echo "  Windsurf 设备号重置工具"
echo "=========================================="
echo ""

# 检查并关闭 Windsurf
if pgrep -f "Windsurf" > /dev/null 2>&1; then
    log_info "检测到 Windsurf 正在运行，正在关闭..."
    
    osascript -e 'quit app "Windsurf"' 2>/dev/null || true
    
    local count=0
    while pgrep -f "Windsurf" > /dev/null 2>&1 && [ $count -lt 10 ]; do
        sleep 1
        ((count++))
    done
    
    if pgrep -f "Windsurf" > /dev/null 2>&1; then
        pkill -TERM -f "Windsurf" 2>/dev/null || true
        sleep 2
    fi
    
    if pgrep -f "Windsurf" > /dev/null 2>&1; then
        log_error "无法关闭 Windsurf，请手动关闭后重试"
        exit 1
    fi
    
    log_success "Windsurf 已关闭"
else
    log_success "Windsurf 未运行"
fi

# 创建备份
log_info "正在创建备份..."
mkdir -p "$BACKUP_DIR"

if [ -f "$DB_PATH" ]; then
    cp "$DB_PATH" "$BACKUP_DIR/state.vscdb.backup.$TIMESTAMP"
    log_success "数据库已备份"
fi

# 生成新的设备ID
log_info "正在生成新的设备ID..."

DEV_DEVICE_ID=$(uuidgen | tr '[:upper:]' '[:lower:]')
MACHINE_ID=$(uuidgen | tr '[:upper:]' '[:lower:]')
MAC_MACHINE_ID=$(uuidgen | tr '[:upper:]' '[:lower:]')
SQM_ID=$(uuidgen | tr '[:upper:]' '[:lower:]')
SERVICE_MACHINE_ID=$(uuidgen | tr '[:upper:]' '[:lower:]')

# 更新数据库
log_info "正在更新数据库..."

sqlite3 "$DB_PATH" <<EOF
CREATE TABLE IF NOT EXISTS ItemTable (key TEXT PRIMARY KEY, value TEXT);
INSERT OR REPLACE INTO ItemTable (key, value) VALUES ('telemetry.devDeviceId', '$DEV_DEVICE_ID');
INSERT OR REPLACE INTO ItemTable (key, value) VALUES ('telemetry.machineId', '$MACHINE_ID');
INSERT OR REPLACE INTO ItemTable (key, value) VALUES ('telemetry.macMachineId', '$MAC_MACHINE_ID');
INSERT OR REPLACE INTO ItemTable (key, value) VALUES ('telemetry.sqmId', '$SQM_ID');
INSERT OR REPLACE INTO ItemTable (key, value) VALUES ('storage.serviceMachineId', '$SERVICE_MACHINE_ID');
EOF

log_success "数据库更新完成"

# 更新 machineId 文件
log_info "正在更新 machineId 文件..."
mkdir -p "$(dirname "$MACHINE_ID_PATH")"
echo "$MACHINE_ID" > "$MACHINE_ID_PATH"
log_success "machineId 文件更新完成"

# 更新 JSON 配置
if [ -f "$JSON_PATH" ]; then
    log_info "正在更新 JSON 配置..."
    if command -v jq &> /dev/null; then
        jq ".machineId = \"$MACHINE_ID\"" "$JSON_PATH" > "$JSON_PATH.tmp"
        mv "$JSON_PATH.tmp" "$JSON_PATH"
    else
        sed -i.bak "s/\"machineId\"[[:space:]]*:[[:space:]]*\"[^\"]*\"/\"machineId\": \"$MACHINE_ID\"/" "$JSON_PATH"
        rm -f "$JSON_PATH.bak"
    fi
    log_success "JSON 配置更新完成"
fi

echo ""
echo "=========================================="
log_success "设备号重置成功"
echo "=========================================="
echo ""

echo "新的设备标识符："
echo "----------------------------------------"
echo "devDeviceId:        $DEV_DEVICE_ID"
echo "machineId:          $MACHINE_ID"
echo "macMachineId:       $MAC_MACHINE_ID"
echo "sqmId:              $SQM_ID"
echo "serviceMachineId:   $SERVICE_MACHINE_ID"
echo "----------------------------------------"
echo ""
echo "备份位置: $BACKUP_DIR"
echo ""
log_info "请重启 Windsurf 使更改生效"
echo ""
