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

// storage_finder
window.storage_finder = new Vue(require('@/vue_widgets/storage_finder').default)
window.storage_finder.$mount('#storage_finder')

// 初始化所有 iCheck
$('[data-icheck]').each(function () {
  const $el = $(this)
  const color = $el.data('icheck') || 'blue'

  $el.iCheck({
    checkboxClass: `icheckbox_square-${color}`,
    radioClass: `iradio_square-${color}`
  })
})
