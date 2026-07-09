<template>
  <AppLayout>
    <div class="mx-auto max-w-6xl space-y-6">
      <header class="rounded-2xl border border-gray-100 bg-white p-6 shadow-card dark:border-dark-700/50 dark:bg-dark-800/50 md:p-8">
        <div class="flex flex-col gap-5 lg:flex-row lg:items-start lg:justify-between">
          <div class="max-w-3xl">
            <div class="mb-3 inline-flex items-center gap-2 rounded-full bg-primary-50 px-3 py-1 text-xs font-semibold text-primary-700 dark:bg-primary-900/20 dark:text-primary-300">
              <Icon name="book" size="sm" />
              OpenAI Compatible
            </div>
            <h1 class="text-2xl font-bold text-gray-900 dark:text-white md:text-3xl">
              帮助中心
            </h1>
            <p class="mt-3 text-sm leading-6 text-gray-500 dark:text-dark-300 md:text-base">
              当前仅支持 OpenAI 兼容接口，暂不支持 Anthropic / Claude Code 接入。以下配置适用于 Codex、OpenAI SDK、curl 以及支持 OpenAI 兼容接口的客户端。
            </p>
          </div>

          <div class="rounded-xl border border-primary-100 bg-primary-50 px-4 py-3 text-sm dark:border-primary-900/40 dark:bg-primary-900/20">
            <div class="text-xs font-semibold uppercase text-primary-600 dark:text-primary-300">
              Base URL
            </div>
            <code class="mt-1 block break-all font-mono text-primary-800 dark:text-primary-200">https://coldapi.site/v1</code>
          </div>
        </div>
      </header>

      <nav class="flex flex-wrap gap-2" aria-label="帮助中心导航">
        <a
          v-for="item in sections"
          :key="item.id"
          :href="`#${item.id}`"
          class="inline-flex items-center gap-2 rounded-xl border border-gray-200 bg-white px-3 py-2 text-sm font-medium text-gray-600 shadow-sm transition-colors hover:border-primary-200 hover:bg-primary-50 hover:text-primary-700 dark:border-dark-700 dark:bg-dark-800 dark:text-dark-300 dark:hover:border-primary-800 dark:hover:bg-primary-900/20 dark:hover:text-primary-300"
        >
          <Icon :name="item.icon" size="sm" />
          {{ item.label }}
        </a>
      </nav>

      <section id="codex" class="scroll-mt-24 space-y-4">
        <SectionHeader number="1" title="Codex 安装教程" description="按你的系统选择安装方式，安装后通过版本命令确认可用。" />

        <div class="rounded-2xl border border-gray-100 bg-white p-5 shadow-card dark:border-dark-700/50 dark:bg-dark-800/50">
          <ol class="space-y-2 pl-5 text-sm leading-6 text-gray-600 dark:text-dark-300">
            <li class="list-decimal">准备 Node.js LTS，或直接使用官方安装脚本。</li>
            <li class="list-decimal">安装完成后运行 <InlineCode>codex --version</InlineCode> 确认可用。</li>
            <li class="list-decimal">首次运行 <InlineCode>codex</InlineCode>，按提示登录或配置 API Key。</li>
          </ol>
        </div>

        <div class="grid gap-4 lg:grid-cols-2">
          <CodeBlock title="Windows PowerShell" :code="installWindows" />
          <CodeBlock title="macOS / Linux" :code="installUnix" />
        </div>

        <CodeBlock title="npm 备用方式" :code="installNpm" />
      </section>

      <section id="proxy" class="scroll-mt-24 space-y-4">
        <SectionHeader number="2" title="配置中转站" description="ColdAPI 基于 sub2api 开发，请按 OpenAI 兼容接口使用，不要配置 Anthropic 相关环境变量。" />

        <div class="overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-card dark:border-dark-700/50 dark:bg-dark-800/50">
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-100 text-sm dark:divide-dark-700">
              <thead class="bg-gray-50 text-left text-xs font-semibold uppercase text-gray-500 dark:bg-dark-900/60 dark:text-dark-400">
                <tr>
                  <th class="px-4 py-3">配置项</th>
                  <th class="px-4 py-3">值</th>
                  <th class="px-4 py-3">说明</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-100 text-gray-600 dark:divide-dark-700 dark:text-dark-300">
                <tr>
                  <td class="px-4 py-3 font-medium text-gray-900 dark:text-white">Base URL</td>
                  <td class="px-4 py-3"><InlineCode>https://coldapi.site/v1</InlineCode></td>
                  <td class="px-4 py-3">用于 Codex、OpenAI SDK、curl 等 OpenAI 兼容客户端。</td>
                </tr>
                <tr>
                  <td class="px-4 py-3 font-medium text-gray-900 dark:text-white">API Key</td>
                  <td class="px-4 py-3"><InlineCode>sk-你的中转站密钥</InlineCode></td>
                  <td class="px-4 py-3">在中转站后台生成并复制。</td>
                </tr>
                <tr>
                  <td class="px-4 py-3 font-medium text-gray-900 dark:text-white">模型名</td>
                  <td class="px-4 py-3">以后台可用模型为准</td>
                  <td class="px-4 py-3">本地填写的模型名必须和中转站模型名一致。</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <div class="rounded-2xl border border-gray-100 bg-white p-5 shadow-card dark:border-dark-700/50 dark:bg-dark-800/50">
          <h3 class="text-lg font-semibold text-gray-900 dark:text-white">方式一：使用 cc-switch</h3>
          <ol class="mt-3 space-y-2 pl-5 text-sm leading-6 text-gray-600 dark:text-dark-300">
            <li class="list-decimal">
              下载并安装 cc-switch：
              <a
                href="https://github.com/farion1231/cc-switch/releases"
                target="_blank"
                rel="noopener noreferrer"
                class="font-medium text-primary-600 hover:text-primary-700 dark:text-primary-300 dark:hover:text-primary-200"
              >
                https://github.com/farion1231/cc-switch/releases
              </a>
            </li>
            <li class="list-decimal">打开 cc-switch 后，按下方 cc-switch 使用教程导入或手动填写 ColdAPI 配置。</li>
            <li class="list-decimal">切换到 ColdAPI 配置后，重新打开终端再运行 <InlineCode>codex</InlineCode>。</li>
          </ol>
        </div>

        <div class="space-y-3">
          <h3 class="text-lg font-semibold text-gray-900 dark:text-white">方式二：手动修改 .codex 文件</h3>
          <p class="text-sm text-gray-500 dark:text-dark-400">
            打开 <InlineCode>~/.codex/config.toml</InlineCode>，Windows 路径通常是 <InlineCode>%USERPROFILE%\.codex\config.toml</InlineCode>，按下面示例填写中转站配置。
          </p>
          <CodeBlock title="config.toml" :code="codexConfig" />
        </div>

        <div class="space-y-3">
          <h3 class="text-lg font-semibold text-gray-900 dark:text-white">Codex Auth 配置</h3>
          <p class="text-sm text-gray-500 dark:text-dark-400">
            打开 <InlineCode>~/.codex/auth.json</InlineCode>，Windows 路径通常是 <InlineCode>%USERPROFILE%\.codex\auth.json</InlineCode>。如果文件不存在，请新建该文件。
          </p>
          <CodeBlock title="auth.json" :code="codexAuth" />
        </div>

        <div class="space-y-3">
          <h3 class="text-lg font-semibold text-gray-900 dark:text-white">连通性测试</h3>
          <CodeBlock title="curl" :code="curlTest" />
        </div>
      </section>

      <section id="cc-switch" class="scroll-mt-24 space-y-4">
        <SectionHeader number="3" title="cc-switch 使用教程" description="如果你使用 cc-switch 管理客户端配置，可以新增一组 ColdAPI 的 OpenAI 兼容配置。" />

        <div class="rounded-2xl border border-gray-100 bg-white p-5 shadow-card dark:border-dark-700/50 dark:bg-dark-800/50">
          <h3 class="text-lg font-semibold text-gray-900 dark:text-white">方式一：一键导入</h3>
          <ol class="space-y-2 pl-5 text-sm leading-6 text-gray-600 dark:text-dark-300">
            <li class="list-decimal">先安装并打开 cc-switch。</li>
            <li class="list-decimal">在 API 密钥列表中找到需要使用的密钥，点击操作栏里的 <InlineCode>导入到 CCS</InlineCode>，即可一键生成并导入 cc-switch 配置。</li>
            <li class="list-decimal">导入后在 cc-switch 中确认配置名称、Base URL、API Key 和模型信息，然后切换到该配置使用。</li>
            <li class="list-decimal">切换到该配置后，重新打开终端，再运行 <InlineCode>codex</InlineCode> 测试。</li>
          </ol>
        </div>

        <figure class="overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-card dark:border-dark-700/50 dark:bg-dark-800/50">
          <img
            :src="ccSwitchOneClickImage"
            alt="API 密钥列表中的导入到 CCS 一键配置入口"
            class="w-full"
            loading="lazy"
          />
          <figcaption class="border-t border-gray-100 px-4 py-3 text-sm text-gray-500 dark:border-dark-700 dark:text-dark-300">
            在 API 密钥页面点击“导入到 CCS”，即可把当前密钥快速写入 cc-switch 配置。
          </figcaption>
        </figure>

        <div class="rounded-2xl border border-gray-100 bg-white p-5 shadow-card dark:border-dark-700/50 dark:bg-dark-800/50">
          <h3 class="text-lg font-semibold text-gray-900 dark:text-white">方式二：手动配置</h3>
          <ol class="mt-3 space-y-2 pl-5 text-sm leading-6 text-gray-600 dark:text-dark-300">
            <li class="list-decimal">打开 cc-switch，选择 Codex / OpenAI 兼容配置项。</li>
            <li class="list-decimal">新增一个配置，例如命名为 <InlineCode>ColdAPI</InlineCode>。</li>
            <li class="list-decimal">Base URL 填 <InlineCode>https://coldapi.site/v1</InlineCode>。</li>
            <li class="list-decimal">API Key 填中转站生成的密钥，例如 <InlineCode>sk-你的中转站密钥</InlineCode>。</li>
            <li class="list-decimal">模型名填写后台可用模型，需与中转站模型名保持一致。</li>
            <li class="list-decimal">保存并切换到该配置后，重新打开终端，再运行 <InlineCode>codex</InlineCode> 测试。</li>
          </ol>
        </div>
      </section>

      <section id="faq" class="scroll-mt-24 space-y-4">
        <SectionHeader number="4" title="常见问题" description="遇到报错时，优先检查 Base URL、API Key、模型名和 auth.json 文件。" />

        <div class="space-y-3">
          <details
            v-for="item in faqs"
            :key="item.question"
            class="rounded-2xl border border-gray-100 bg-white p-4 shadow-card open:border-primary-100 dark:border-dark-700/50 dark:bg-dark-800/50 dark:open:border-primary-900/40"
            :open="item.open"
          >
            <summary class="cursor-pointer text-sm font-semibold text-gray-900 dark:text-white">
              {{ item.question }}
            </summary>
            <p class="mt-3 text-sm leading-6 text-gray-500 dark:text-dark-300">
              {{ item.answer }}
            </p>
          </details>
        </div>
      </section>

      <footer class="pb-4 text-sm text-gray-500 dark:text-dark-400">
        最后更新：2026-07-06。中转站：<InlineCode>https://coldapi.site</InlineCode>，OpenAI Base URL：<InlineCode>https://coldapi.site/v1</InlineCode>。
      </footer>
    </div>
  </AppLayout>
</template>

<script setup lang="ts">
import { defineComponent, h } from 'vue'
import AppLayout from '@/components/layout/AppLayout.vue'
import Icon from '@/components/icons/Icon.vue'
import { useClipboard } from '@/composables/useClipboard'
import ccSwitchOneClickImage from '@/assets/help/cc-switch-one-click-config.png'

type IconName = InstanceType<typeof Icon>['$props']['name']

interface SectionNavItem {
  id: string
  label: string
  icon: IconName
}

interface FaqItem {
  question: string
  answer: string
  open?: boolean
}

const { copyToClipboard } = useClipboard()

const installWindows = 'powershell -ExecutionPolicy ByPass -c "irm https://chatgpt.com/codex/install.ps1 | iex"'
const installUnix = 'curl -fsSL https://chatgpt.com/codex/install.sh | sh'
const installNpm = 'npm install -g @openai/codex'
const codexConfig = `model = "填写中转站模型名"
model_provider = "coldapi"

[model_providers.coldapi]
name = "ColdAPI"
base_url = "https://coldapi.site/v1"
wire_api = "responses"
requires_openai_auth = true`
const codexAuth = `{
  "OPENAI_API_KEY": "sk-你的中转站密钥"
}`
const curlTest = `curl https://coldapi.site/v1/responses \\
  -H "Authorization: Bearer sk-你的中转站密钥" \\
  -H "Content-Type: application/json" \\
  -d '{"model":"填写中转站模型名","input":"ping"}'`

const sections: SectionNavItem[] = [
  { id: 'codex', label: 'Codex 安装', icon: 'terminal' },
  { id: 'proxy', label: '配置中转站', icon: 'server' },
  { id: 'cc-switch', label: 'cc-switch', icon: 'swap' },
  { id: 'faq', label: '常见问题', icon: 'questionCircle' },
]

const faqs: FaqItem[] = [
  {
    question: '401 / Unauthorized',
    answer: '检查 API Key 是否复制完整、是否过期，以及 auth.json 是否保存到正确路径。',
    open: true,
  },
  {
    question: '404 / endpoint not found',
    answer: 'Base URL 应为 https://coldapi.site/v1。不要填成根地址，也不要重复添加 /v1/v1。',
  },
  {
    question: 'model not found',
    answer: '模型名不正确或当前 Key 没有权限。请以中转站后台显示的模型名为准。',
  },
  {
    question: 'Codex 配置没有生效',
    answer: '检查 model_provider 是否为 coldapi，检查 requires_openai_auth 是否为 true，以及 auth.json 中是否存在 OPENAI_API_KEY。',
  },
  {
    question: '是否支持 Claude Code / Anthropic？',
    answer: '暂不支持。本页所有配置只针对 OpenAI 兼容接口。',
  },
  {
    question: '可以把 Key 写进页面或提交到仓库吗？',
    answer: '不可以。Key 只应放在本机环境变量、受保护的配置文件或系统后台中。',
  },
]

async function copyCode(code: string) {
  await copyToClipboard(code)
}

const SectionHeader = defineComponent({
  name: 'SectionHeader',
  props: {
    number: { type: String, required: true },
    title: { type: String, required: true },
    description: { type: String, required: true },
  },
  setup(props) {
    return () =>
      h('div', { class: 'flex flex-col gap-3 sm:flex-row sm:items-start' }, [
        h(
          'div',
          { class: 'flex h-9 w-9 flex-shrink-0 items-center justify-center rounded-xl bg-primary-500 text-sm font-bold text-white shadow-md shadow-primary-500/20' },
          props.number,
        ),
        h('div', [
          h('h2', { class: 'text-xl font-bold text-gray-900 dark:text-white' }, props.title),
          h('p', { class: 'mt-1 text-sm leading-6 text-gray-500 dark:text-dark-400' }, props.description),
        ]),
      ])
  },
})

const InlineCode = defineComponent({
  name: 'InlineCode',
  setup(_, { slots }) {
    return () =>
      h(
        'code',
        { class: 'rounded-md border border-gray-200 bg-gray-50 px-1.5 py-0.5 font-mono text-[0.92em] text-primary-700 dark:border-dark-700 dark:bg-dark-900 dark:text-primary-300' },
        slots.default?.(),
      )
  },
})

const CodeBlock = defineComponent({
  name: 'CodeBlock',
  props: {
    title: { type: String, required: true },
    code: { type: String, required: true },
  },
  setup(props) {
    return () =>
      h('div', { class: 'overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-card dark:border-dark-700/50 dark:bg-dark-800/50' }, [
        h('div', { class: 'flex items-center justify-between gap-3 border-b border-gray-100 bg-gray-50 px-4 py-3 dark:border-dark-700 dark:bg-dark-900/60' }, [
          h('span', { class: 'min-w-0 truncate text-sm font-semibold text-gray-700 dark:text-dark-200' }, props.title),
          h(
            'button',
            {
              type: 'button',
              class: 'btn btn-secondary btn-sm flex-shrink-0',
              onClick: () => copyCode(props.code),
            },
            [h(Icon, { name: 'copy', size: 'sm' }), '复制'],
          ),
        ]),
        h('pre', { class: 'overflow-x-auto bg-gray-950 p-4 text-sm leading-6 text-gray-100' }, [
          h('code', props.code),
        ]),
      ])
  },
})
</script>
