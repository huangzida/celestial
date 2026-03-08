# @bg-effects/celestial

[English](./README.md) | [简体中文](./README_CN.md)

Celestial cycle background effect with day/night transitions, sun, moon, and eclipses.

[Live Demo](https://huangzida.github.io/celestial/)

---

### Features

- 🚀 **High Performance**: Built with OGL (a lightweight WebGL library) for smooth rendering.
- ☀️ **Day/Night Cycle**: Realistic solar and lunar cycles with transitions.
- 🌙 **Special Events**: Support for solar and lunar eclipses, plus moon phases.
- 🌊 **Sea Reflection**: Atmospheric sea reflections and horizon effects.
- 🛠️ **Debug Mode**: Built-in visual debug panel for real-time adjustments.
- 📦 **Ready to Use**: Easy-to-use Vue component with simple configuration.

### Installation

```bash
pnpm add @bg-effects/celestial ogl
```

> **Note**: `ogl` is a peer dependency and needs to be installed manually.

### Usage

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

### Props

| Prop | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `timeSpeed` | `number` | `1.0` | Cycle animation speed |
| `cycleMode` | `'auto' \| 'sun' \| 'moon' \| 'solar_eclipse' \| 'lunar_eclipse'` | `'auto'` | Display mode |
| `autoCycle` | `boolean` | `true` | Enable automatic day/night cycle |
| `objectSize` | `number` | `1.0` | Size of sun/moon |
| `orbitRadius` | `number` | `1.0` | Orbit radius |
| `horizonHeight` | `number` | `0.3` | Height of the horizon |
| `starIntensity` | `number` | `1.0` | Intensity of stars |
| `seaEnabled` | `boolean` | `true` | Enable sea reflection |
| `bloomIntensity` | `number` | `1.0` | Bloom effect intensity |
| `moonPhase` | `number` | `0.0` | Moon phase (-1.0 to 1.0) |
| `moonGlowColor` | `string` | `'#ffffff'` | Color of moon glow |
| `coronaStyle` | `'sharp' \| 'organic'` | `'organic'` | Style of solar corona |
| `interactive` | `boolean` | `true` | Enable mouse interaction |
| `cloudOpacity` | `number` | `0.5` | Cloud opacity |
| `debug` | `boolean` | `false` | Enable debug panel |
| `lang` | `'zh-CN' \| 'en'` | `'zh-CN'` | UI language |

### Local Development

```bash
# Install dependencies
pnpm install

# Start development server
pnpm dev
```

### License

MIT
