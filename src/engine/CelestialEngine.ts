import { Geometry, Mesh, Program, Renderer, Vec2 } from 'ogl'
import type { CelestialEngineConfig } from '../types'
import { defu } from 'defu'
import { meta } from '../meta'
import { hexToRgbNormalized } from '@bg-effects/shared'
import vertexShader from './shaders/vertex.glsl?raw'
import fragmentShader from './shaders/fragment.glsl?raw'

export class CelestialEngine {
  renderer: Renderer
  gl: any
  program: Program
  mesh: Mesh
  raf: number = 0
  container: HTMLElement
  private ro?: ResizeObserver
  private t0: number = performance.now()
  private _isPaused = false
  private pausedTime = 0
  private pauseStartTime = 0
  private config: CelestialEngineConfig
  private mouse = new Vec2(0.5, 0.5)
  private targetMouse = new Vec2(0.5, 0.5)
  private internalTime = 0

  constructor(container: HTMLElement, config: CelestialEngineConfig) {
    this.container = container
    this.config = defu(config, meta.defaultConfig)

    this.renderer = new Renderer({
      alpha: true,
      antialias: true,
      dpr: Math.min(window.devicePixelRatio, 2),
    })
    this.gl = this.renderer.gl
    this.gl.clearColor(0, 0, 0, 0)
    this.container.appendChild(this.gl.canvas)

    const geometry = new Geometry(this.gl, {
      position: { size: 2, data: new Float32Array([-1, -1, 3, -1, -1, 3]) },
      uv: { size: 2, data: new Float32Array([0, 0, 2, 0, 0, 2]) },
    })

    const modeMap: Record<string, number> = {
      auto: 0, sun: 1, moon: 2, solar_eclipse: 3, lunar_eclipse: 4
    }

    this.program = new Program(this.gl, {
      vertex: vertexShader,
      fragment: fragmentShader,
      uniforms: {
        uTime: { value: 0 },
        uResolution: { value: new Vec2(this.gl.canvas.width, this.gl.canvas.height) },
        uMouse: { value: this.mouse },
        uTimeProgress: { value: 0.5 },
        uCycleMode: { value: modeMap[this.config.cycleMode] || 0 },
        uBloom: { value: this.config.bloomIntensity },
        uSize: { value: this.config.objectSize },
        uRadius: { value: this.config.orbitRadius },
        uHorizonProp: { value: this.config.horizonHeight },
        uMoonPhase: { value: this.config.moonPhase },
        uMoonGlowColor: { value: hexToRgbNormalized(this.config.moonGlowColor) },
        uStarIntensity: { value: this.config.starIntensity },
        uSeaEnabled: { value: this.config.seaEnabled },
      },
    })

    this.mesh = new Mesh(this.gl, { geometry, program: this.program })

    this.ro = new ResizeObserver(() => this.resize())
    this.ro.observe(this.container)
    this.resize()

    this.container.addEventListener('mousemove', this.handleMouseMove)

    this.loop(this.t0)
  }

  private handleMouseMove = (e: MouseEvent) => {
    if (!this.config.interactive) return
    const rect = this.container.getBoundingClientRect()
    const x = e.clientX - rect.left
    const y = e.clientY - rect.top
    this.targetMouse.set(x / rect.width, 1.0 - y / rect.height)
  }

  private loop = (time: number) => {
    this.raf = requestAnimationFrame(this.loop)
    if (this._isPaused) return

    const currentTime = (time - this.t0 - this.pausedTime) * 0.001
    
    if (this.config.autoCycle) {
      this.internalTime += 0.0005 * this.config.timeSpeed
    }

    if (this.config.interactive) {
      this.mouse.lerp(this.targetMouse, 0.05)
    }

    if (this.program) {
      this.program.uniforms.uTime.value = currentTime
      this.program.uniforms.uTimeProgress.value = this.internalTime % 1.0
    }

    this.renderer.render({ scene: this.mesh })
  }

  resize() {
    const width = this.container.offsetWidth
    const height = this.container.offsetHeight
    this.renderer.setSize(width, height)
    this.program.uniforms.uResolution.value.set(width, height)
  }

  updateConfig(config: Partial<CelestialEngineConfig>) {
    this.config = { ...this.config, ...config }
    
    const modeMap: Record<string, number> = {
      auto: 0, sun: 1, moon: 2, solar_eclipse: 3, lunar_eclipse: 4
    }

    if (this.program) {
      this.program.uniforms.uCycleMode.value = modeMap[this.config.cycleMode] || 0
      this.program.uniforms.uBloom.value = this.config.bloomIntensity
      this.program.uniforms.uSize.value = this.config.objectSize
      this.program.uniforms.uRadius.value = this.config.orbitRadius
      this.program.uniforms.uHorizonProp.value = this.config.horizonHeight
      this.program.uniforms.uMoonPhase.value = this.config.moonPhase
      this.program.uniforms.uMoonGlowColor.value = hexToRgbNormalized(this.config.moonGlowColor)
      this.program.uniforms.uStarIntensity.value = this.config.starIntensity
      this.program.uniforms.uSeaEnabled.value = this.config.seaEnabled
    }
  }

  pause() {
    if (!this._isPaused) {
      this._isPaused = true
      this.pauseStartTime = performance.now()
    }
  }

  resume() {
    if (this._isPaused) {
      this._isPaused = false
      this.pausedTime += performance.now() - this.pauseStartTime
    }
  }

  restart() {
    this.pausedTime = 0
    this.pauseStartTime = 0
    this.t0 = performance.now()
    this.internalTime = 0
  }

  destroy() {
    if (this.raf) cancelAnimationFrame(this.raf)
    if (this.ro) this.ro.disconnect()
    this.container.removeEventListener('mousemove', this.handleMouseMove)
    if (this.container.contains(this.gl.canvas)) {
      this.container.removeChild(this.gl.canvas)
    }
    this.gl.getExtension('WEBGL_lose_context')?.loseContext()
  }
}
