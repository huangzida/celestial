# @bg-effects/celestial

[English](./README.md) | [简体中文](./README_CN.md)

具有昼夜交替、太阳、月亮和食现象的星空背景特效。

[在线演示](https://huangzida.github.io/celestial/)

---

### 特性

- 🚀 **高性能**: 基于 OGL (轻量级 WebGL 库) 构建，运行流畅。
- ☀️ **昼夜交替**: 逼真的太阳和月亮运行周期及过渡效果。
- 🌙 **特殊事件**: 支持日食、月食以及月相变化。
- 🌊 **海面反射**: 大气感十足的海面反射和地平线效果。
- 🛠️ **调试模式**: 内置可视化调试面板，方便实时调整效果。
- 📦 **开箱即用**: 作为 Vue 组件，简单配置即可使用。

### 安装

```bash
pnpm add @bg-effects/celestial ogl
```

> **注意**: `ogl` 是 peer dependency，需要手动安装。

### 使用

```vue
<script setup>
import { Celestial } from '@bg-effects/celestial'
</script>

<template>
  <div style="width: 100vw; height: 100vh; background: #000;">
    <Celestial 
      :time-speed="1.0"
      cycle-mode="auto"
      :sea-enabled="true"
    />
  </div>
</template>
```

### 属性 (Props)

| 属性名 | 类型 | 默认值 | 说明 |
| :--- | :--- | :--- | :--- |
| `timeSpeed` | `number` | `1.0` | 周期动画速度 |
| `cycleMode` | `'auto' \| 'sun' \| 'moon' \| 'solar_eclipse' \| 'lunar_eclipse'` | `'auto'` | 显示模式 |
| `autoCycle` | `boolean` | `true` | 是否开启自动昼夜循环 |
| `objectSize` | `number` | `1.0` | 太阳/月亮大小 |
| `orbitRadius` | `number` | `1.0` | 轨道半径 |
| `horizonHeight` | `number` | `0.3` | 地平线高度 |
| `starIntensity` | `number` | `1.0` | 星光强度 |
| `seaEnabled` | `boolean` | `true` | 是否开启海面反射 |
| `bloomIntensity` | `number` | `1.0` | 辉光强度 |
| `moonPhase` | `number` | `0.0` | 月相 (-1.0 到 1.0) |
| `moonGlowColor` | `string` | `'#ffffff'` | 月晕颜色 |
| `coronaStyle` | `'sharp' \| 'organic'` | `'organic'` | 日冕样式 |
| `interactive` | `boolean` | `true` | 是否开启鼠标交互 |
| `cloudOpacity` | `number` | `0.5` | 云层透明度 |
| `debug` | `boolean` | `false` | 是否开启调试面板 |
| `lang` | `'zh-CN' \| 'en'` | `'zh-CN'` | 界面语言 |

### 本地开发

```bash
# 安装依赖
pnpm install

# 启动开发环境
pnpm dev
```

### 许可

MIT
