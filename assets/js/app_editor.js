import 'normalize.css'
import '@/css/app_editor'

import axios from 'axios'
import Vue from 'vue'
import ElementUI from 'element-ui'
import * as helper from '@/lib/helper'

// 设置 axios 的 csrf token
axios.defaults.headers.common['X-CSRF-TOKEN'] = window._csrf_token

// vue 设置
Vue.use(ElementUI, { size: 'small' })
Vue.prototype.$helper = helper

// storage_finder
window.storage_finder = new Vue(require('@/vue_widgets/storage_finder').default)
window.storage_finder.$mount('#storage_finder')

// 主应用
const app_editor = new Vue(require('@/app_editor/app_editor').default)
app_editor.$mount('#app_editor')
