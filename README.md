# Windsurf 设备号重置工具

一个用于重置 Windsurf 编辑器设备标识符的简单工具。

## 功能

- 自动关闭正在运行的 Windsurf
- 备份原有配置
- 生成新的设备标识符
- 更新所有相关配置文件

## 使用方法

### 1. 下载脚本

```bash
git clone https://github.com/jiliaoyo/reset_windsurf_device-for-mac.git
cd reset_windsurf_device-for-mac
```

### 2. 运行脚本

**需要使用 sudo 权限运行：**

```bash
sudo ./reset.sh
```

> **注意**：必须使用 `sudo` 运行，否则可能因为权限不足导致修改失败。

### 3. 重启 Windsurf

脚本执行完成后，重新打开 Windsurf 即可。

## 系统要求

- macOS 系统
- Windsurf 已安装在 `/Applications/Windsurf.app`
- 系统自带的 `sqlite3` 和 `uuidgen` 工具

## 注意事项

- 脚本会自动创建备份，位于 `~/Library/Application Support/Windsurf/Backups/`
- 重置后可能需要重新登录账户
- 本地配置和扩展不受影响

## 工作原理

脚本会重置以下设备标识符：

- `telemetry.devDeviceId`
- `telemetry.machineId`
- `telemetry.macMachineId`
- `telemetry.sqmId`
- `storage.serviceMachineId`

## 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

## 免责声明

本工具仅供学习和研究使用，请遵守相关软件的使用条款。
