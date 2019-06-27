// CSS
import 'element-ui/lib/theme-chalk'
import '@/css/app'

// from node_modules
import Vue from 'vue'
import ElementUI from 'element-ui'
import axios from 'axios'

// JS
import 'phoenix_html'

// vue 插件
Vue.use(ElementUI, { size: 'small' })

// 设置 axios 的 csrf token
axios.defaults.headers.common['X-CSRF-TOKEN'] = window._csrf_token
