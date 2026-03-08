import Celestial from './Celestial.vue'
import { meta } from './meta'
import en from './locales/en.json'
import zhCN from './locales/zh-CN.json'

export { Celestial, meta }
export type { CelestialProps, CelestialEngineConfig } from './types'

export const locales = {
  en,
  'zh-CN': zhCN,
}
