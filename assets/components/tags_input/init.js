import Vue from 'vue'
import componentOpts from './tags_input'

$('[data-vue="tags_input"]').each((_idx, el) => {
  const instance = new Vue({ el, ...componentOpts })
  const errors = $(el).data('errors')
  const list = $(el).data('list')

  if (errors) {
    instance.list = list.map((item, idx) => ({ ...item, errors: errors[idx] }))
  } else {
    instance.list = list
  }

  instance.name = $(el).data('name')
})
