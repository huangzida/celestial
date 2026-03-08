<script setup lang="ts">
import { ref, onMounted, onUnmounted, watch, computed } from 'vue'
import { DebugShell } from '@bg-effects/debug-ui'
import { defu } from 'defu'
import { meta } from './meta'
import type { CelestialProps, CelestialEngineConfig } from './types'
import { CelestialEngine } from './engine/CelestialEngine'
import ConfigPanel from './ui/ConfigPanel.vue'

const props = withDefaults(defineProps<CelestialProps>(), {
  debug: undefined,
  autoCycle: undefined,
  seaEnabled: undefined,
  interactive: undefined,
})

const config = ref<CelestialProps>(defu(props, meta.defaultConfig) as CelestialProps)
const internalLang = ref<'zh-CN' | 'en'>(config.value.lang || 'zh-CN')

watch(() => props, (newProps) => {
  if (!props.debug) {
    config.value = defu(newProps, meta.defaultConfig) as CelestialProps
  }
}, { deep: true })

const configPanelRef = ref<any>(null)
const containerRef = ref<HTMLElement | null>(null)
let engine: CelestialEngine | null = null

const engineInterface = computed(() => ({
  pause: () => engine?.pause(),
  resume: () => engine?.resume(),
  restart: () => engine?.restart(),
}))

const handleRandomize = () => {
  if (meta.randomize) {
    const currentTab = configPanelRef.value?.activeTab
    const tabValue = typeof currentTab === 'object' && currentTab?.value ? currentTab.value : currentTab
    const randomized = meta.randomize(config.value, tabValue)
    config.value = {
      ...randomized,
      debug: config.value.debug,
      lang: config.value.lang,
    }
  }
}

const effectiveConfig = computed(() => (props.debug ? config.value : props))

const resolveEngineConfig = (source: CelestialProps): CelestialEngineConfig => ({
  timeSpeed: source.timeSpeed ?? meta.defaultConfig.timeSpeed,
  cycleMode: source.cycleMode ?? meta.defaultConfig.cycleMode,
  autoCycle: source.autoCycle ?? meta.defaultConfig.autoCycle,
  objectSize: source.objectSize ?? meta.defaultConfig.objectSize,
  orbitRadius: source.orbitRadius ?? meta.defaultConfig.orbitRadius,
  horizonHeight: source.horizonHeight ?? meta.defaultConfig.horizonHeight,
  starIntensity: source.starIntensity ?? meta.defaultConfig.starIntensity,
  seaEnabled: source.seaEnabled ?? meta.defaultConfig.seaEnabled,
  bloomIntensity: source.bloomIntensity ?? meta.defaultConfig.bloomIntensity,
  moonPhase: source.moonPhase ?? meta.defaultConfig.moonPhase,
  moonGlowColor: source.moonGlowColor ?? meta.defaultConfig.moonGlowColor,
  coronaStyle: source.coronaStyle ?? meta.defaultConfig.coronaStyle,
  interactive: source.interactive ?? meta.defaultConfig.interactive,
  cloudOpacity: source.cloudOpacity ?? meta.defaultConfig.cloudOpacity,
})

watch(effectiveConfig, (newConfig) => {
  if (!engine) return
  engine.updateConfig(resolveEngineConfig(defu(newConfig, meta.defaultConfig) as CelestialProps))
}, { deep: true })

onMounted(() => {
  if (!containerRef.value) return
  const resolved = defu(effectiveConfig.value, meta.defaultConfig) as CelestialProps
  engine = new CelestialEngine(containerRef.value, resolveEngineConfig(resolved))
})

onUnmounted(() => {
  engine?.destroy()
  engine = null
})
</script>

<template>
  <div ref="containerRef" :class="['relative w-full h-full overflow-hidden', className]">
    <DebugShell
      v-if="debug"
      v-model:config="config"
      v-model:lang="internalLang"
      :meta="meta"
      :engine="engineInterface"
      @randomize="handleRandomize"
    >
      <template #settings>
        <ConfigPanel
          ref="configPanelRef"
          v-model:config="config"
          :lang="internalLang"
        />
      </template>
    </DebugShell>
  </div>
</template>
