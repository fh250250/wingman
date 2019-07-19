// CSS
import '@/css/app'

// from node_modules
import axios from 'axios'

// JS
import 'phoenix_html'
import '@/components/tags_input/init'
import '@/components/media_center/init'

// 设置 axios 的 csrf token
axios.defaults.headers.common['X-CSRF-TOKEN'] = window._csrf_token
