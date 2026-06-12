<template>
  <div class="love-page">
    <canvas ref="canvasRef" class="heart-canvas"></canvas>
    <div class="overlay">
      <h1 class="title">Love</h1>
      <p class="subtitle">爱与花随风流动，自上而下凝成一颗心</p>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'

const canvasRef = ref(null)
let animationId = null

const CONFIG = {
  particleCount: 1200,
  heartHeightRatio: 0.48,
  heartYOffset: -0.04,
  baseY: 0.78,
  scanSpeed: 0.05,
  holdFrames: 280,
  rows: 60,
  trailLength: 6,
}

const FLOWERS = [
  { name: 'rose', hue: 345 },
  { name: 'tulip', hue: 325 },
  { name: 'sakura', hue: 340 },
  { name: 'peach', hue: 330 },
  { name: 'carnation', hue: 335 },
  { name: 'violet', hue: 270 },
]

function heartPoint(t, r, cx, cy, scale) {
  const hx = 16 * Math.pow(Math.sin(t), 3)
  const hy = -(13 * Math.cos(t) - 5 * Math.cos(2 * t) - 2 * Math.cos(3 * t) - Math.cos(4 * t))
  const s = scale * r
  return { x: cx + hx * s, y: cy + hy * s }
}

class Particle {
  constructor(target, bounds, index) {
    this.bounds = bounds
    this.index = index
    this.targetX = target.x
    this.targetY = target.y
    this.triggerOrder = target.triggerOrder
    this.reset(true)
  }

  reset(initial = false) {
    this.x = this.bounds.w / 2 + (Math.random() - 0.5) * this.bounds.w * 0.7
    this.y = this.bounds.h * CONFIG.baseY + Math.random() * this.bounds.h * 0.14

    this.vx = 0
    this.vy = 0

    this.size = Math.random() * 4 + 3

    const flower = FLOWERS[Math.floor(Math.random() * FLOWERS.length)]
    this.flowerType = flower.name
    this.hue = flower.hue + (Math.random() - 0.5) * 15
    this.sat = 85 + Math.random() * 10
    this.light = 70 + Math.random() * 10
    this.alpha = initial ? 0.2 + Math.random() * 0.15 : 0.4 + Math.random() * 0.2
    this.maxAlpha = 0.75 + Math.random() * 0.25

    this.state = 'idle'
    this.twinklePhase = Math.random() * Math.PI * 2
    this.twinkleSpeed = 0.03 + Math.random() * 0.05
    this.arrivedTimer = 0

    this.rotation = Math.random() * Math.PI * 2
    this.rotationSpeed = (Math.random() - 0.5) * 0.06

    this.flowOffset = Math.random() * Math.PI * 2
    this.flowSpeed = 0.012 + Math.random() * 0.008
    this.curveAmp = 20 + Math.random() * 35
    this.curvePhase = Math.random() * Math.PI * 2
    this.progress = 0

    this.history = []
  }

  curvePoint(p) {
    const startX = this.bounds.w / 2 + (this.targetX - this.bounds.w / 2) * 0.1
    const startY = this.bounds.h * CONFIG.baseY
    const endX = this.targetX
    const endY = this.targetY

    const lx = startX + (endX - startX) * p
    const ly = startY + (endY - startY) * p

    const bend = Math.sin(p * Math.PI) * (1 - p * 0.3)
    const wx = Math.sin(this.curvePhase + p * Math.PI * 2 + this.flowOffset) * this.curveAmp * bend
    const wy = Math.cos(this.curvePhase + p * Math.PI * 1.5) * this.curveAmp * 0.3 * bend

    return { x: lx + wx, y: ly + wy }
  }

  update(scanProgress, currentPhase, globalTime) {
    this.twinklePhase += this.twinkleSpeed
    this.rotation += this.rotationSpeed

    if (this.state === 'idle') {
      const driftX = Math.sin(globalTime * 0.012 + this.index * 0.05) * 0.3
      const driftY = Math.cos(globalTime * 0.015 + this.index * 0.1) * 0.1
      this.x += driftX
      this.y += driftY

      if (this.y < this.bounds.h * (CONFIG.baseY - 0.02)) this.y += 0.15
      if (this.y > this.bounds.h * (CONFIG.baseY + 0.16)) this.y -= 0.15

      if (scanProgress >= this.triggerOrder) {
        this.state = 'rising'
        this.progress = 0
      }
    }

    if (this.state === 'rising') {
      this.progress += this.flowSpeed
      if (this.progress > 1) this.progress = 1

      const target = this.curvePoint(this.progress)
      const dx = target.x - this.x
      const dy = target.y - this.y
      this.x += dx * 0.12
      this.y += dy * 0.12

      this.history.push({ x: this.x, y: this.y, r: this.rotation })
      if (this.history.length > CONFIG.trailLength) this.history.shift()

      if (this.alpha < this.maxAlpha) this.alpha += 0.02

      if (this.progress >= 0.98 && Math.hypot(dx, dy) < 4) {
        this.state = 'arrived'
      }
    }

    if (this.state === 'arrived') {
      this.arrivedTimer++
      const breathe = Math.sin(this.arrivedTimer * 0.06 + this.twinklePhase) * 2.5
      const driftX = Math.sin(this.arrivedTimer * 0.028 + this.curvePhase) * 1.8
      const driftY = Math.cos(this.arrivedTimer * 0.032 + this.curvePhase) * 1.5

      const dx = this.targetX - this.x + driftX + breathe * 0.5
      const dy = this.targetY - this.y + driftY + breathe * 0.4
      this.x += dx * 0.035
      this.y += dy * 0.035

      this.history.push({ x: this.x, y: this.y, r: this.rotation })
      if (this.history.length > 4) this.history.shift()

      if (this.alpha < this.maxAlpha) this.alpha += 0.008
    }

    if (currentPhase === 'dissolving') {
      this.vy += 0.1
      this.vx *= 0.985
      this.x += this.vx + Math.sin(this.y * 0.015 + this.twinklePhase) * 0.25
      this.y += this.vy
      this.alpha -= 0.006

      this.history.push({ x: this.x, y: this.y, r: this.rotation })
      if (this.history.length > CONFIG.trailLength) this.history.shift()

      if (this.y > this.bounds.h + 30 || this.alpha <= 0) {
        this.reset(false)
      }
    }
  }

  // 轻量花朵绘制：五个椭圆花瓣 + 花蕊
  drawFlower(ctx, x, y, size, rotation, alpha) {
    const cos = Math.cos(rotation)
    const sin = Math.sin(rotation)

    const rotate = (px, py) => ({
      x: x + px * cos - py * sin,
      y: y + px * sin + py * cos
    })

    const c = `hsla(${this.hue}, ${this.sat}%, ${this.light}%, ${alpha})`
    ctx.fillStyle = c

    // 5 个花瓣
    for (let i = 0; i < 5; i++) {
      const angle = (i / 5) * Math.PI * 2
      const px = Math.cos(angle) * size * 0.6
      const py = Math.sin(angle) * size * 0.5
      const p1 = rotate(px, py)

      ctx.beginPath()
      ctx.ellipse(p1.x, p1.y, size * 0.45, size * 0.25, rotation + angle, 0, Math.PI * 2)
      ctx.fill()
    }

    // 花蕊
    ctx.fillStyle = `hsla(45, 90%, 70%, ${alpha})`
    ctx.beginPath()
    ctx.arc(x, y, size * 0.12, 0, Math.PI * 2)
    ctx.fill()
  }

  draw(ctx) {
    if (this.alpha <= 0.001) return

    const twinkle = 0.8 + 0.2 * Math.sin(this.twinklePhase)
    const headAlpha = Math.max(0, Math.min(1, this.alpha * twinkle))

    // 只给头部花朵绘制短拖尾（虚影）
    if (this.history.length > 1 && this.state !== 'idle') {
      for (let i = 0; i < this.history.length - 1; i += 2) {
        const p = this.history[i]
        const ratio = i / (this.history.length - 1)
        const a = headAlpha * ratio * 0.5
        const size = this.size * ratio * 0.5

        this.drawFlower(ctx, p.x, p.y, size, p.r, a)
      }
    }

    this.drawFlower(ctx, this.x, this.y, this.size, this.rotation, headAlpha)
  }
}

function buildHeartPoints(w, h) {
  const points = []
  const cx = w / 2
  const cy = h / 2 + h * CONFIG.heartYOffset
  const scale = (h * CONFIG.heartHeightRatio) / 18

  for (let i = 0; i < CONFIG.particleCount; i++) {
    const t = Math.random() * Math.PI * 2
    const r = Math.pow(Math.random(), 0.5)
    const p = heartPoint(t, r, cx, cy, scale)
    points.push({ x: p.x, y: p.y })
  }

  points.sort((a, b) => a.y - b.y)

  const rows = CONFIG.rows
  const perRow = Math.ceil(points.length / rows)

  return points.map((p, i) => ({
    x: p.x,
    y: p.y,
    triggerOrder: Math.floor(i / perRow)
  }))
}

function initCanvas() {
  const canvas = canvasRef.value
  if (!canvas) return () => {}

  const ctx = canvas.getContext('2d')
  let particles = []
  let totalRows = CONFIG.rows
  let scanProgress = 0
  let phase = 'forming'
  let phaseTimer = 0
  let globalTime = 0

  const resize = () => {
    const rect = canvas.getBoundingClientRect()
    let w = Math.round(rect.width)
    let h = Math.round(rect.height)

    if (w < 100 || h < 100) {
      w = Math.max(w, 800)
      h = Math.max(h, 600)
    }

    canvas.width = w
    canvas.height = h

    const targets = buildHeartPoints(w, h)
    particles = targets.map((t, i) => new Particle(t, { w, h }, i))
  }

  setTimeout(resize, 100)
  window.addEventListener('resize', resize)

  const loop = () => {
    globalTime++
    const rect = canvas.getBoundingClientRect()
    const w = rect.width
    const h = rect.height

    ctx.fillStyle = 'rgba(5, 5, 15, 0.2)'
    ctx.fillRect(0, 0, w, h)

    const groundGradient = ctx.createLinearGradient(0, h * CONFIG.baseY, 0, h)
    groundGradient.addColorStop(0, 'rgba(255, 160, 190, 0.08)')
    groundGradient.addColorStop(0.4, 'rgba(230, 130, 170, 0.04)')
    groundGradient.addColorStop(1, 'rgba(0, 0, 0, 0)')
    ctx.fillStyle = groundGradient
    ctx.fillRect(0, h * CONFIG.baseY, w, h * (1 - CONFIG.baseY))

    if (phase === 'forming') {
      scanProgress += CONFIG.scanSpeed
      if (scanProgress >= totalRows + 5) {
        phase = 'holding'
        phaseTimer = 0
      }
    } else if (phase === 'holding') {
      phaseTimer++
      if (phaseTimer > CONFIG.holdFrames) {
        phase = 'dissolving'
        phaseTimer = 0
      }
    } else if (phase === 'dissolving') {
      phaseTimer++
      if (phaseTimer > 180) {
        phase = 'resetting'
      }
    } else if (phase === 'resetting') {
      scanProgress = 0
      phase = 'forming'
      particles.forEach(p => p.reset(false))
    }

    particles.forEach(p => {
      p.update(scanProgress, phase, globalTime)
      p.draw(ctx)
    })

    animationId = requestAnimationFrame(loop)
  }

  loop()

  return () => {
    window.removeEventListener('resize', resize)
    if (animationId) cancelAnimationFrame(animationId)
  }
}

onMounted(() => {
  const cleanup = initCanvas()
  onUnmounted(cleanup)
})
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

.love-page {
  width: 100vw;
  height: 100vh;
  background: #05050f;
  overflow: hidden;
  position: relative;
}

.heart-canvas {
  display: block;
  width: 100%;
  height: 100%;
}

.overlay {
  position: absolute;
  inset: 0;
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  align-items: center;
  padding-bottom: 10vh;
  pointer-events: none;
  text-align: center;
}

.title {
  font-size: clamp(2.5rem, 8vw, 5rem);
  font-weight: 200;
  letter-spacing: 0.3em;
  color: rgba(255, 200, 220, 0.9);
  text-shadow: 0 0 20px rgba(255, 120, 160, 0.5);
  font-family: 'Segoe UI', 'PingFang SC', sans-serif;
}

.subtitle {
  margin-top: 1rem;
  font-size: clamp(0.9rem, 2.5vw, 1.2rem);
  color: rgba(255, 180, 200, 0.7);
  letter-spacing: 0.15em;
  font-family: 'PingFang SC', 'Microsoft YaHei', sans-serif;
}
</style>
