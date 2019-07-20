import '@/css/app'
import 'phoenix_html'

import path from 'path'
import axios from 'axios'
import Vue from 'vue'
import ElementUI from 'element-ui'

// 设置 axios 的 csrf token
axios.defaults.headers.common['X-CSRF-TOKEN'] = window._csrf_token

// vue 设置
Vue.use(ElementUI, { size: 'small' })

// 加载所有 vue widget
const vue_widgets = require.context('@/vue_widgets', true, /_widget\.vue$/)

vue_widgets.keys().forEach(key => {
  const name = path.basename(path.dirname(key))
  const compile_opts = vue_widgets(key).default

  $(`[data-vue=${name}]`).each((_, el) => new Vue({
    ...compile_opts,
    name,
    el,
    data () { return JSON.parse($(el).find('div').text()) }
  }))
})
