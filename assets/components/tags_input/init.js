import Vue from 'vue'
import componentOpts from './tags_input'

$('[data-vue="tags_input"]').each((_idx, el) => {
  const instance = new Vue({ el, ...componentOpts })

  instance.name = $(el).data('name')
  instance.list = $(el).data('list')
})
