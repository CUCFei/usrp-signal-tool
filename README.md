# USRP Signal Manager

USRP Signal Manager 是一个基于Web的USRP设备控制与信号管理工具，提供直观的界面用于USRP设备的信号录制、传输、实时频谱采集及文件管理等操作，适用于需要快速配置和控制USRP设备的场景。


## 功能概述

- **设备管理**：自动发现并显示连接的USRP设备，支持设备选择与状态监控
- **信号录制**：配置频率、采样率、增益等参数，录制信号到本地文件
- **信号传输**：选择本地IQ文件，配置传输参数并发送信号
- **实时频谱采集**：实时采集并显示频谱数据，直观观察信号特征
- **频谱分析**：从录制或上传的IQ文件生成频谱图，支持保存分析结果
- **文件管理**：上传、下载、删除录制或上传的IQ文件，方便数据管理


## 安装与部署

### 前置依赖

- Python 3.6+
- UHD (Universal Software Radio Peripheral) 库及工具（用于USRP设备通信）
- 必要的Python包：`flask`, `numpy`, `scipy`（可通过`pip`安装）


### 部署步骤

1. **克隆仓库**（假设仓库地址）：
   ```bash
   git clone https://github.com/CUCFEI/usrp-signal-tool
   cd usrp-signal-tool
   ```

2. **安装Python依赖**：
   ```bash
   pip install flask numpy scipy
   ```

3. **（可选）配置网络**：
   若部署主机无键盘鼠标，可使用`configure_network.sh`脚本配置网络（支持DHCP优先，失败时自动使用静态IP 192.168.100.100）：
   ```bash
   sudo ./configure_network.sh
   ```
   脚本会自动检测有线网络接口并应用配置。

4. **启动应用**：
   ```bash
   python app.py
   ```

5. **访问界面**：
   在浏览器中输入 `http://<主机IP>:5000` 即可访问控制界面（默认端口为Flask默认端口5000，可在代码中修改）。


## 使用指南

### 1. 设备管理

- 页面顶部"Connected Devices"区域会自动发现并显示连接的USRP设备
- 点击设备列表项选择需要使用的设备
- 可通过"Refresh Devices"按钮手动刷新设备列表
- 设备状态指示灯（绿色：正常；红色闪烁：异常）实时显示USRP连接状态


### 2. 信号录制（Record Signal Tab）

- 配置录制参数：
  - 文件名（自动生成时间戳文件名，可自定义）
  - 频率（Hz）、采样率（samples/sec）、增益（dB）、通道
  - 录制时长（秒）
- 点击"Start Recording"开始录制，"Stop Recording"停止录制
- 录制前会自动检查存储空间，确保有足够空间（至少保留1GB空闲空间）


### 3. 信号传输（Transmit Signal Tab）

- 选择需要传输的IQ文件（支持上传或录制的文件）
- 配置传输参数：频率（Hz）、采样率（samples/sec）、增益（dB）、通道
- 点击"Start Transmission"开始传输，"Stop Transmission"停止传输
- 传输进度条实时显示传输进度及时间信息


### 4. 实时频谱采集（Realtime Capture Tab）

- 配置采集参数：频率（Hz）、采样率（Sa/s）、增益（dB）、带宽（Hz）、通道
- 点击"Start Capturing"开始实时采集，"Stop Capturing"停止采集
- 采集过程中，频谱图实时更新，直观展示信号频谱特征


### 5. 频谱分析（Spectrum Analyzer Tab）

- 选择需要分析的IQ文件（支持上传或录制的文件）
- 配置采样率参数
- 点击"Generate"生成频谱图，"Refresh"刷新分析结果，"Save Image"保存频谱图
- 频谱图展示信号的频率-幅度特性


### 6. 文件管理（File Management Tab）

- **上传文件**：通过文件选择框选择IQ文件（.iq/.bin/.dat），点击"Upload"上传
- **文件列表**：展示所有上传文件和录制文件，支持：
  - 下载文件（点击下载按钮）
  - 删除文件（点击删除按钮，需确认）


## 注意事项

- 确保USRP设备已正确连接并供电，且主机已安装UHD驱动
- 录制/传输大文件时，确保主机有足够的存储空间
- 实时频谱采集和信号传输可能受网络带宽或主机性能影响，建议使用高性能主机
- 网络配置脚本`configure_network.sh`仅适用于Linux系统，且需要root权限运行


## 故障排除

- **设备未发现**：检查USRP设备连接、供电，确保UHD工具可识别设备（可通过`uhd_find_devices`命令验证）
- **操作失败**：查看页面提示信息，可能是参数不完整或设备正忙（同一时间只能进行录制/传输/采集中的一项操作）
- **存储空间不足**：在"File Management"中删除不需要的文件释放空间
- **网络问题**：若使用网络配置脚本后仍无法联网，可手动检查`/etc/netplan/01-ethernet-config.yaml`配置