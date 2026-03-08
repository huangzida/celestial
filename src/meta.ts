import { rand, sample } from '@bg-effects/shared'
import type { EffectMeta } from '@bg-effects/core'
import type { CelestialProps } from './types'

export const meta: EffectMeta<CelestialProps> = {
  id: 'celestial',
  name: {
    en: 'Celestial',
    'zh-CN': '日月交替',
  },
  category: 'nature',
  version: '1.0.0',
  defaultConfig: {
    debug: false,
    lang: 'zh-CN',
    timeSpeed: 1.0,
    cycleMode: 'auto',
    autoCycle: true,
    objectSize: 2.0,
    orbitRadius: 0.8,
    starIntensity: 0.5,
    seaEnabled: true,
    horizonHeight: 0.3,
    bloomIntensity: 1.0,
    moonPhase: 0.5,
    moonGlowColor: '#6e8db0',
    coronaStyle: 'organic',
    interactive: true,
    cloudOpacity: 0.3,
  },
  randomize: (current, tab?) => {
    const result = { ...current }
    
    if (!tab) {
      result.timeSpeed = rand(0.5, 2.0)
      result.cycleMode = sample(['auto', 'sun', 'moon', 'solar_eclipse', 'lunar_eclipse'])
      result.autoCycle = Math.random() > 0.2
      result.objectSize = rand(1.0, 5.0)
      result.orbitRadius = rand(0.8, 1.3)
      result.horizonHeight = rand(0.2, 0.5)
      result.starIntensity = rand(0.3, 0.8)
      result.seaEnabled = Math.random() > 0.2
      result.bloomIntensity = rand(0.8, 1.5)
      result.cloudOpacity = rand(0.1, 0.5)
      return result
    }

    if (tab === 'mode') {
      result.timeSpeed = rand(0.5, 2.0)
      result.cycleMode = sample(['auto', 'sun', 'moon', 'solar_eclipse', 'lunar_eclipse'])
      result.autoCycle = Math.random() > 0.2
      return result
    }

    if (tab === 'appearance') {
      result.objectSize = rand(1.0, 5.0)
      result.orbitRadius = rand(0.8, 1.3)
      result.bloomIntensity = rand(0.8, 1.5)
      result.moonPhase = rand(0, 1)
      return result
    }

    if (tab === 'environment') {
      result.horizonHeight = rand(0.2, 0.5)
      result.starIntensity = rand(0.3, 0.8)
      result.seaEnabled = Math.random() > 0.2
      result.interactive = Math.random() > 0.5
      return result
    }

    return result
  },
  presets: [
    {
      id: 'celestial-eternal-sun',
      name: { en: 'Eternal Sun', 'zh-CN': '永恒之日' },
      config: {
        cycleMode: 'sun',
        timeSpeed: 0.5,
        seaEnabled: true,
        objectSize: 1.5,
        orbitRadius: 1.0,
        bloomIntensity: 1.2,
      },
    },
    {
      id: 'celestial-solar-eclipse',
      name: { en: 'Solar Eclipse', 'zh-CN': '日全食' },
      config: {
        cycleMode: 'solar_eclipse',
        timeSpeed: 0.2,
        coronaStyle: 'organic',
        bloomIntensity: 2.0,
        objectSize: 2.5,
        orbitRadius: 1.0,
      },
    },
    {
      id: 'celestial-lunar-eclipse',
      name: { en: 'Lunar Eclipse', 'zh-CN': '月全食' },
      config: {
        cycleMode: 'lunar_eclipse',
        timeSpeed: 0.2,
        bloomIntensity: 1.5,
        objectSize: 2.0,
        orbitRadius: 1.0,
        moonPhase: 1.0,
        moonGlowColor: '#ff2200',
      },
    }
  ],
}
