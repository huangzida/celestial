<script setup lang="ts">
import { ref, computed } from 'vue'
import { Slider, ColorPicker, Toggle, SubTabs } from '@bg-effects/shared'
import zhCN from '../locales/zh-CN.json'
import en from '../locales/en.json'
import type { CelestialProps } from '../types'

const props = defineProps<{
  lang?: 'zh-CN' | 'en'
}>()

const config = defineModel<CelestialProps>('config', { required: true })

const activeTab = ref<'mode' | 'appearance' | 'environment'>('mode')

defineExpose({
  activeTab,
})

const i18n: Record<string, any> = {
  'zh-CN': zhCN,
  'en': en,
}

const t = (path: string) => {
  const dict = i18n[props.lang || 'zh-CN']
  return path.split('.').reduce((obj: any, key) => obj?.[key], dict) || path
}

interface SubTabItem {
  id: string
  label: string
}

const subTabs = computed((): SubTabItem[] => [
  { id: 'mode', label: t('tabs.mode') },
  { id: 'appearance', label: t('tabs.appearance') },
  { id: 'environment', label: t('tabs.environment') },
])
</script>

<template>
  <div class="flex flex-col gap-6 text-white/90">
    <SubTabs v-model="activeTab" :tabs="subTabs" />

    <div class="flex flex-col gap-6 p-1 pointer-events-auto overflow-y-auto max-h-[400px] custom-scrollbar pr-2">
      <!-- Mode Tab -->
      <div v-if="activeTab === 'mode'" class="flex flex-col gap-6">
        <div class="flex flex-col gap-3">
          <div class="flex justify-between text-xs text-white/50 uppercase tracking-wider">
            <span>{{ t('labels.mode') }}</span>
          </div>
          <div class="grid grid-cols-2 bg-black/80 rounded-xl p-1 gap-1 border border-white/10">
            <button
              v-for="mode in ['auto', 'sun', 'moon', 'solar_eclipse', 'lunar_eclipse']"
              :key="mode"
              class="py-2 text-[10px] uppercase font-black rounded-lg transition-all active:scale-95 border-none cursor-pointer"
              :class="
                config.cycleMode === mode
                  ? 'bg-blue-600 text-white shadow-md'
                  : 'bg-white/5 text-white/40 hover:bg-white/10 hover:text-white/60'
              "
              @click="config.cycleMode = mode as any"
            >
              {{ t(`modes.${mode}`) }}
            </button>
          </div>
        </div>
        
        <Slider
          v-model="config.timeSpeed"
          :label="t('labels.speed')"
          :min="0.1"
          :max="5.0"
          :step="0.1"
          suffix="x"
        />
        
        <Toggle
          v-model="config.autoCycle"
          :label="t('labels.auto_cycle')"
        />
      </div>

      <!-- Appearance Tab -->
      <div v-if="activeTab === 'appearance'" class="flex flex-col gap-6">
        <Slider
          v-model="config.objectSize"
          :label="t('labels.size')"
          :min="0.5"
          :max="8.0"
          :step="0.1"
        />
        <Slider
          v-model="config.orbitRadius"
          :label="t('labels.radius')"
          :min="0.5"
          :max="2.0"
          :step="0.1"
        />
        <Slider
          v-model="config.bloomIntensity"
          :label="t('labels.bloom')"
          :min="0.0"
          :max="3.0"
          :step="0.1"
        />
        
        <div v-if="config.cycleMode === 'auto' || config.cycleMode === 'moon'" class="flex flex-col gap-6">
          <Slider
            v-model="config.moonPhase"
            :label="t('labels.moon_phase')"
            :min="0.0"
            :max="1.0"
            :step="0.01"
            :format="(v) => (v * 100).toFixed(0) + '%'"
          />
          <ColorPicker
            v-model="config.moonGlowColor"
            :label="t('labels.moon_glow')"
          />
        </div>
      </div>

      <!-- Environment Tab -->
      <div v-if="activeTab === 'environment'" class="flex flex-col gap-6">
        <Slider
          v-model="config.horizonHeight"
          :label="t('labels.horizon')"
          :min="0.1"
          :max="0.6"
          :step="0.01"
        />
        <Slider
          v-model="config.starIntensity"
          :label="t('labels.stars')"
          :min="0.0"
          :max="1.0"
          :step="0.01"
        />
        <Toggle
          v-model="config.seaEnabled"
          :label="t('labels.sea')"
        />
        <Toggle
          v-model="config.interactive"
          :label="t('labels.interactive')"
        />
      </div>
    </div>
  </div>
</template>

<style scoped>
.custom-scrollbar::-webkit-scrollbar {
  width: 6px;
}

.custom-scrollbar::-webkit-scrollbar-track {
  background: transparent;
}

.custom-scrollbar::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.1);
  border-radius: 3px;
}

.custom-scrollbar::-webkit-scrollbar-thumb:hover {
  background: rgba(255, 255, 255, 0.2);
}
</style>
