<script setup lang="ts">
import { computed, nextTick, onBeforeUnmount, onMounted, reactive, ref, watch } from 'vue'
import communityQrUrl from '@/assets/community-qr.png'

const isOpen = ref(false)
const floatButton = ref<HTMLButtonElement | null>(null)
const position = reactive({ x: 0, y: 0 })
const hasPosition = ref(false)
const suppressNextClick = ref(false)
const dragState = reactive({
  active: false,
  pointerId: 0,
  startX: 0,
  startY: 0,
  offsetX: 0,
  offsetY: 0,
  moved: false,
})

const EDGE_GAP = 16
const DEFAULT_BOTTOM_GAP = 88

const floatStyle = computed(() => {
  if (!hasPosition.value) {
    return undefined
  }

  return {
    left: `${position.x}px`,
    top: `${position.y}px`,
    right: 'auto',
    bottom: 'auto',
  }
})

function clamp(value: number, min: number, max: number) {
  return Math.min(Math.max(value, min), max)
}

function setPosition(x: number, y: number) {
  const rect = floatButton.value?.getBoundingClientRect()
  const width = rect?.width ?? 68
  const height = rect?.height ?? 86

  position.x = clamp(x, EDGE_GAP, Math.max(EDGE_GAP, window.innerWidth - width - EDGE_GAP))
  position.y = clamp(y, EDGE_GAP, Math.max(EDGE_GAP, window.innerHeight - height - EDGE_GAP))
}

function setDefaultPosition() {
  const rect = floatButton.value?.getBoundingClientRect()
  const width = rect?.width ?? 68
  const height = rect?.height ?? 86

  setPosition(window.innerWidth - width - EDGE_GAP, window.innerHeight - height - DEFAULT_BOTTOM_GAP)
  hasPosition.value = true
}

function openQr() {
  if (suppressNextClick.value) {
    suppressNextClick.value = false
    return
  }

  isOpen.value = true
}

function closeQr() {
  isOpen.value = false
}

function onKeydown(event: KeyboardEvent) {
  if (event.key === 'Escape') {
    closeQr()
  }
}

function onPointerDown(event: PointerEvent) {
  if (event.button !== 0) {
    return
  }

  const rect = floatButton.value?.getBoundingClientRect()
  if (!rect) {
    return
  }

  dragState.active = true
  dragState.pointerId = event.pointerId
  dragState.startX = event.clientX
  dragState.startY = event.clientY
  dragState.offsetX = event.clientX - rect.left
  dragState.offsetY = event.clientY - rect.top
  dragState.moved = false
  suppressNextClick.value = false
  hasPosition.value = true

  setPosition(rect.left, rect.top)
  window.addEventListener('pointermove', onPointerMove)
  window.addEventListener('pointerup', stopDrag)
  window.addEventListener('pointercancel', stopDrag)
  event.preventDefault()
}

function onPointerMove(event: PointerEvent) {
  if (!dragState.active || event.pointerId !== dragState.pointerId) {
    return
  }

  const distance = Math.hypot(event.clientX - dragState.startX, event.clientY - dragState.startY)
  if (distance > 4) {
    dragState.moved = true
    suppressNextClick.value = true
  }

  setPosition(event.clientX - dragState.offsetX, event.clientY - dragState.offsetY)
  event.preventDefault()
}

function stopDrag(event: PointerEvent) {
  if (!dragState.active || event.pointerId !== dragState.pointerId) {
    return
  }

  dragState.active = false
  suppressNextClick.value = dragState.moved
  if (dragState.moved) {
    window.setTimeout(() => {
      suppressNextClick.value = false
    }, 0)
  }
  window.removeEventListener('pointermove', onPointerMove)
  window.removeEventListener('pointerup', stopDrag)
  window.removeEventListener('pointercancel', stopDrag)
}

function onResize() {
  if (!hasPosition.value) {
    setDefaultPosition()
    return
  }

  setPosition(position.x, position.y)
}

watch(isOpen, (open) => {
  document.body.classList.toggle('modal-open', open)
})

onMounted(() => {
  window.addEventListener('keydown', onKeydown)
  window.addEventListener('resize', onResize)
  nextTick(setDefaultPosition)
})

onBeforeUnmount(() => {
  window.removeEventListener('keydown', onKeydown)
  window.removeEventListener('resize', onResize)
  window.removeEventListener('pointermove', onPointerMove)
  window.removeEventListener('pointerup', stopDrag)
  window.removeEventListener('pointercancel', stopDrag)
  document.body.classList.remove('modal-open')
})
</script>

<template>
  <button
    ref="floatButton"
    class="community-qr-float"
    :class="{ 'is-dragging': dragState.active }"
    :style="floatStyle"
    type="button"
    title="交流群"
    aria-label="交流群"
    @click="openQr"
    @pointerdown="onPointerDown"
  >
    <img :src="communityQrUrl" alt="交流群二维码" />
  </button>

  <Teleport to="body">
    <Transition name="community-qr-modal">
      <div v-if="isOpen" class="community-qr-overlay" role="dialog" aria-modal="true" @click.self="closeQr">
        <div class="community-qr-dialog">
          <button class="community-qr-close" type="button" aria-label="关闭" @click="closeQr">×</button>
          <img :src="communityQrUrl" alt="交流群二维码大图" />
          <p>如遇问题进群联系管理员，QQ群:1053752295</p>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
.community-qr-float {
  position: fixed;
  right: max(1rem, env(safe-area-inset-right));
  bottom: max(5.5rem, env(safe-area-inset-bottom));
  z-index: 45;
  width: 4.25rem;
  aspect-ratio: 438 / 549;
  overflow: hidden;
  border: 1px solid rgb(255 255 255 / 0.7);
  border-radius: 0.5rem;
  background: rgb(255 255 255 / 0.75);
  box-shadow: 0 12px 30px rgb(15 23 42 / 0.18);
  cursor: pointer;
  touch-action: none;
  user-select: none;
  opacity: 0.72;
  padding: 0;
  transition:
    opacity 160ms ease,
    transform 160ms ease,
    box-shadow 160ms ease;
}

.community-qr-float.is-dragging {
  cursor: grabbing;
  opacity: 1;
  transition: none;
}

.community-qr-float:not(.is-dragging):hover,
.community-qr-float:not(.is-dragging):focus-visible {
  opacity: 1;
  transform: translateY(-2px);
  box-shadow: 0 16px 36px rgb(15 23 42 / 0.24);
}

.community-qr-float:focus-visible {
  outline: 2px solid rgb(59 130 246);
  outline-offset: 3px;
}

.community-qr-float img {
  width: 100%;
  height: 100%;
  display: block;
  object-fit: contain;
}

.community-qr-overlay {
  position: fixed;
  inset: 0;
  z-index: 100;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1.25rem;
  background: rgb(15 23 42 / 0.55);
  backdrop-filter: blur(4px);
}

.community-qr-dialog {
  position: relative;
  width: min(24rem, calc(100vw - 2.5rem));
  border-radius: 0.75rem;
  background: white;
  box-shadow: 0 24px 60px rgb(15 23 42 / 0.32);
  padding: 1rem 1rem 1.125rem;
  text-align: center;
}

.community-qr-dialog img {
  width: 100%;
  height: auto;
  display: block;
  border-radius: 0.5rem;
}

.community-qr-dialog p {
  margin: 0.875rem 0 0;
  color: rgb(17 24 39);
  font-size: 1rem;
  font-weight: 600;
  line-height: 1.5;
}

.community-qr-close {
  position: absolute;
  right: 0.625rem;
  top: 0.625rem;
  display: flex;
  width: 2rem;
  height: 2rem;
  align-items: center;
  justify-content: center;
  border: 1px solid rgb(229 231 235);
  border-radius: 9999px;
  background: rgb(255 255 255 / 0.9);
  color: rgb(31 41 55);
  cursor: pointer;
  font-size: 1.25rem;
  line-height: 1;
}

.community-qr-close:hover,
.community-qr-close:focus-visible {
  background: rgb(243 244 246);
}

.community-qr-modal-enter-active,
.community-qr-modal-leave-active {
  transition: opacity 180ms ease;
}

.community-qr-modal-enter-from,
.community-qr-modal-leave-to {
  opacity: 0;
}

.community-qr-modal-enter-active .community-qr-dialog,
.community-qr-modal-leave-active .community-qr-dialog {
  transition: transform 180ms ease;
}

.community-qr-modal-enter-from .community-qr-dialog,
.community-qr-modal-leave-to .community-qr-dialog {
  transform: translateY(0.5rem) scale(0.98);
}

@media (max-width: 640px) {
  .community-qr-float {
    width: 3.5rem;
  }
}
</style>
