import '@/css/app'
import 'phoenix_html'

import path from 'path'
import axios from 'axios'
import Vue from 'vue'
import ElementUI from 'element-ui'
import * as helper from '@/lib/helper'

// 设置 axios 的 csrf token
axios.defaults.headers.common['X-CSRF-TOKEN'] = window._csrf_token

// vue 设置
Vue.use(ElementUI, { size: 'small' })
Vue.prototype.$helper = helper

// 加载所有 vue widget
const vue_widgets = require.context('@/vue_widgets', true, /_widget\.vue$/)

vue_widgets.keys().forEach(key => {
  const name = path.basename(path.dirname(key))
  const compile_opts = vue_widgets(key).default
  const origin_data = compile_opts.data ? compile_opts.data() : {}

  $(`[data-vue=${name}]`).each((_, el) => {
    const server_data = JSON.parse($(el).find('div').text())
    const merged_data = Object.assign({}, origin_data, server_data)

    new Vue({
      ...compile_opts,
      name,
      el,
      data () { return JSON.parse(JSON.stringify(merged_data)) }
    })
  })
})
