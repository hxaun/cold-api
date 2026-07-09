<template>
  <div v-if="groups && groups.length > 0" ref="triggerRef" class="relative max-w-56">
    <div
      class="flex max-h-14 cursor-pointer flex-wrap gap-1 overflow-hidden rounded-md transition-colors hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-1 dark:hover:bg-dark-700/40 dark:focus:ring-offset-dark-800"
      role="button"
      tabindex="0"
      :aria-expanded="showPopover"
      :title="t('admin.accounts.groupCountTotal', { count: groups.length })"
      @click.stop="togglePopover"
      @keydown.enter.prevent="togglePopover"
      @keydown.space.prevent="togglePopover"
    >
      <GroupBadge
        v-for="group in displayGroups"
        :key="group.id"
        :name="group.name"
        :platform="group.platform"
        :subscription-type="group.subscription_type"
        :rate-multiplier="group.rate_multiplier"
        :show-rate="false"
        class="max-w-24"
      />
      <span
        v-if="hiddenCount > 0"
        class="inline-flex items-center gap-0.5 whitespace-nowrap rounded-md bg-gray-100 px-1.5 py-0.5 text-xs font-medium text-gray-600 transition-colors dark:bg-dark-600 dark:text-gray-300"
      >
        +{{ hiddenCount }}
      </span>
    </div>

    <Teleport to="body">
      <Transition
        enter-active-class="transition duration-150 ease-out"
        enter-from-class="opacity-0 scale-95"
        enter-to-class="opacity-100 scale-100"
        leave-active-class="transition duration-100 ease-in"
        leave-from-class="opacity-100 scale-100"
        leave-to-class="opacity-0 scale-95"
      >
        <div
          v-if="showPopover"
          ref="popoverRef"
          class="fixed z-50 min-w-48 max-w-96 origin-top-left rounded-lg border border-gray-200 bg-white p-3 shadow-lg dark:border-dark-600 dark:bg-dark-800"
          :style="popoverStyle"
          @click.stop
        >
          <div class="mb-2 flex items-center justify-between gap-3">
            <span class="text-xs font-medium text-gray-500 dark:text-gray-400">
              {{ t('admin.accounts.groupCountTotal', { count: groups.length }) }}
            </span>
            <button
              type="button"
              :aria-label="t('common.close')"
              class="rounded p-0.5 text-gray-400 hover:bg-gray-100 hover:text-gray-600 dark:hover:bg-dark-700 dark:hover:text-gray-300"
              @click="showPopover = false"
            >
              <svg class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
          <div class="flex max-h-64 flex-wrap gap-1.5 overflow-y-auto">
            <GroupBadge
              v-for="group in groups"
              :key="group.id"
              :name="group.name"
              :platform="group.platform"
              :subscription-type="group.subscription_type"
              :rate-multiplier="group.rate_multiplier"
              :show-rate="false"
            />
          </div>
        </div>
      </Transition>
    </Teleport>

    <div
      v-if="showPopover"
      class="fixed inset-0 z-40"
      @click="showPopover = false"
    />
  </div>
  <span v-else class="text-sm text-gray-400 dark:text-dark-500">-</span>
</template>

<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import GroupBadge from '@/components/common/GroupBadge.vue'
import type { Group } from '@/types'

interface Props {
  groups: Group[] | null | undefined
  maxDisplay?: number
}

const props = withDefaults(defineProps<Props>(), {
  maxDisplay: 4
})

const { t } = useI18n()

const triggerRef = ref<HTMLElement | null>(null)
const popoverRef = ref<HTMLElement | null>(null)
const showPopover = ref(false)

const displayGroups = computed(() => {
  if (!props.groups) return []
  if (props.groups.length <= props.maxDisplay) return props.groups
  return props.groups.slice(0, props.maxDisplay - 1)
})

const hiddenCount = computed(() => {
  if (!props.groups) return 0
  if (props.groups.length <= props.maxDisplay) return 0
  return props.groups.length - (props.maxDisplay - 1)
})

const popoverStyle = computed(() => {
  if (!triggerRef.value) return {}

  const rect = triggerRef.value.getBoundingClientRect()
  const viewportHeight = window.innerHeight
  const viewportWidth = window.innerWidth
  const popoverHeight = 280
  const popoverWidth = 384

  let top = rect.bottom + 8
  let left = rect.left

  if (top + popoverHeight > viewportHeight) {
    top = Math.max(8, rect.top - popoverHeight)
  }

  if (left + popoverWidth > viewportWidth) {
    left = Math.max(8, viewportWidth - popoverWidth - 8)
  }

  return {
    top: `${top}px`,
    left: `${left}px`
  }
})

const togglePopover = () => {
  showPopover.value = !showPopover.value
}

const handleKeydown = (event: KeyboardEvent) => {
  if (event.key === 'Escape') {
    showPopover.value = false
  }
}

onMounted(() => {
  window.addEventListener('keydown', handleKeydown)
})

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeydown)
})
</script>
