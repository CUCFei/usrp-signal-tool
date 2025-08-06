# USRP Signal Tool

USRP Signal Tool 是一个基于 Flask 和 UHD 驱动的信号管理工具，用于控制 USRP 设备进行信号录制、传输和实时频谱分析。通过直观的 Web 界面，用户可以轻松配置设备参数、管理 IQ 数据文件，并可视化频谱信息。


## 功能概述

- **设备管理**：自动发现并选择连接的 USRP 设备，显示设备详细信息（序列号、型号、最大增益等）
- **信号录制**：配置频率、采样率、增益等参数，将 USRP 接收的信号保存为 IQ 数据文件
- **信号传输**：选择本地 IQ 数据文件，通过 USRP 设备发送出去
- **实时频谱分析**：实时采集信号并绘制频谱图，支持频率、采样率等参数动态调整
- **文件管理**：上传、下载、删除 IQ 数据文件（包括录制文件和上传文件）
- **系统监控**：显示 USRP 设备状态（是否存在溢出/欠载）、存储空间状态等


## 环境要求

- **操作系统**：Linux（推荐 Ubuntu 20.04/22.04）
- **依赖软件**：
  - UHD 驱动（`uhd-host`、`libuhd-dev`）
  - Python 3.8+
  - Python 库：`flask`、`flask-cors`、`numpy`、`scipy`
  - 网络管理工具：`netplan`


## 快速安装

### 1. 克隆仓库（假设项目仓库地址）

```bash
git clone https://github.com/CUCFei/usrp-signal-tool.git
cd usrp-signal-tool
```

### 2. 运行环境配置脚本

项目提供自动化配置脚本，可快速安装依赖并初始化环境：

```bash
# 赋予脚本执行权限
chmod +x utils/configure_env.sh

# 以 root 权限运行（需要安装系统依赖）
sudo ./utils/configure_env.sh
```

脚本功能：
- 安装系统依赖（UHD 驱动、Python 及相关工具）
- 创建必要目录（`uploads`、`records`、`utils`）并配置权限
- 安装 Python 依赖库
- 可选创建 Python 虚拟环境


### 3. 网络配置（可选）

若需要配置 USRP 网络环境（优先 DHCP，失败时使用静态 IP），可运行网络配置脚本：

```bash
chmod +x utils/configure_env.sh

# 以 root 权限运行
sudo ./utils/configure_network.sh
```

配置说明：
- 自动检测有线网络接口
- 优先通过 DHCP 获取 IP 地址
- DHCP 失败时自动使用静态 IP：`192.168.100.100/24`
- DNS 服务器：`8.8.8.8`、`8.8.4.4`


## 使用方法

### 1. 启动应用

```bash
# 若使用虚拟环境，先激活
source venv/bin/activate  # 仅当配置时选择了虚拟环境

# 启动 Flask 应用
python app.py
```

默认情况下，应用会在 `http://0.0.0.0:5000` 运行，可通过浏览器访问 Web 界面。


### 2. Web 界面操作

#### 设备选择

- 页面顶部会自动发现并列出连接的 USRP 设备
- 点击设备旁的 `Select` 按钮选择要使用的设备
- 设备状态灯显示设备是否正常（绿色：正常；红色闪烁：溢出/欠载）


#### 信号录制（Record Signal 标签页）

- 配置参数：
  - 文件名：自定义录制文件名称（默认自动生成时间戳）
  - 频率：接收信号的中心频率（Hz）
  - 时长：录制时间（秒）
  - 采样率：信号采样率（samples/sec）
  - 增益：接收增益（dB，不超过设备最大增益）
  - 通道：选择接收通道（0 或 1）
- 点击 `Start Recording` 开始录制，`Stop Recording` 停止


#### 信号传输（Transmit Signal 标签页）

- 配置参数：
  - 选择文件：从上传文件或录制文件中选择要发送的 IQ 数据
  - 频率：发送信号的中心频率（Hz）
  - 采样率：信号采样率（需与文件匹配）
  - 增益：发送增益（dB，不超过设备最大增益）
  - 通道：选择发送通道（0 或 1）
- 点击 `Start Transmission` 开始发送，`Stop Transmission` 停止


#### 实时频谱采集（Realtime Capture 标签页）

- 配置参数：
  - 频率：采集的中心频率（Hz）
  - 采样率：采集采样率（Sa/s）
  - 增益：接收增益（dB）
  - 带宽：信号带宽（Hz）
  - 通道：采集通道（0 或 1）
- 点击 `Start Capturing` 开始实时采集，页面会动态绘制频谱图


#### 频谱分析（Spectrum Analyzer 标签页）

- 选择本地 IQ 数据文件（上传或录制的文件）
- 配置采样率，点击 `Generate` 生成频谱图
- 可通过 `Save Image` 保存频谱图为 PNG 文件


#### 文件管理（File Management 标签页）

- 上传文件：点击 `Choose File` 选择本地 IQ 数据文件（.iq、.bin、.dat），点击 `Upload` 上传
- 下载文件：点击文件旁的下载按钮保存到本地
- 删除文件：点击文件旁的删除按钮移除文件


## 开机自启动配置

为方便部署，可将应用配置为系统服务，实现开机自启动，可在utils中提供的模板基础上修改或直接创建到目标路径：

### 1. 创建系统服务文件

```bash
sudo nano /etc/systemd/system/usrp-signal-tool.service
```

### 2. 写入服务配置（根据实际路径修改）

```ini
[Unit]
Description=USRP Signal Tool Service
After=network.target uhd-host.service
Wants=network-online.target

[Service]
 # 替换为你的用户名
User=[your_username]
#  替换为项目根目录
WorkingDirectory=[/your_path_to/usrp-signal-tool]
 # 替换为 Python 路径（虚拟环境路径或系统 Python）
ExecStart=[/your_path_to/python3] app.py
Environment="PYTHONUNBUFFERED=1"
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

### 3. 启用并启动服务

```bash
# 重新加载服务配置
sudo systemctl daemon-reload

# 启用开机自启动
sudo systemctl enable usrp-signal-tool.service

# 启动服务
sudo systemctl start usrp-signal-tool.service

# 查看服务状态
sudo systemctl status usrp-signal-tool.service
```


## 目录结构

```
usrp-signal-tool/
├── app.py               # 主应用程序（Flask 后端）
├── index.html           # Web 前端界面
├── uploads/             # 上传的 IQ 数据文件
├── records/             # 录制的 IQ 数据文件
├── utils/
│   ├── configure_env.sh # 环境配置脚本
│   └── configure_network.sh # 网络配置脚本
│   └── usrp-signal-tool.serviceh # 服务模板
├── static/              # 静态资源（CSS、JS、图标等）
└── README.md            # 项目说明文档
```


## 常见问题

1. **设备无法发现**：
   - 检查 USRP 设备是否正确连接电源和网线
   - 确认 UHD 驱动已正确安装：`uhd_find_devices` 命令是否能找到设备
   - 检查用户权限（是否加入 `sudo` 组或对 USRP 设备有访问权限）

2. **存储空间不足**：
   - 录制前会自动检查存储空间，确保至少保留 1GB 空闲空间
   - 可在 `File Management` 标签页删除不需要的文件释放空间

3. **服务启动失败**：
   - 查看日志排查问题：`journalctl -u usrp-signal-tool.service -f`
   - 检查服务文件中的路径是否正确，用户是否有项目目录的读写权限


## 许可证

[MIT](LICENSE)