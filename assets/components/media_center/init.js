import Vue from 'vue'
import MediaCenter from './media_center'

const element = $('#media_center').get(0)

if (element) {
  new Vue({ el: element, ...MediaCenter })
}
