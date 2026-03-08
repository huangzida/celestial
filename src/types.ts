export interface CelestialProps {
  debug?: boolean
  lang?: 'zh-CN' | 'en'
  className?: string
  timeSpeed?: number
  cycleMode?: 'auto' | 'sun' | 'moon' | 'solar_eclipse' | 'lunar_eclipse'
  autoCycle?: boolean
  objectSize?: number
  orbitRadius?: number
  horizonHeight?: number
  starIntensity?: number
  seaEnabled?: boolean
  bloomIntensity?: number
  moonPhase?: number
  moonGlowColor?: string
  coronaStyle?: 'sharp' | 'organic'
  interactive?: boolean
  cloudOpacity?: number
}

export interface CelestialEngineConfig {
  timeSpeed: number
  cycleMode: 'auto' | 'sun' | 'moon' | 'solar_eclipse' | 'lunar_eclipse'
  autoCycle: boolean
  objectSize: number
  orbitRadius: number
  horizonHeight: number
  starIntensity: number
  seaEnabled: boolean
  bloomIntensity: number
  moonPhase: number
  moonGlowColor: string
  coronaStyle: 'sharp' | 'organic'
  interactive: boolean
  cloudOpacity: number
}
