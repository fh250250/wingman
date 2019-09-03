export function module_name () { return 'test_c' }
export function preview_component () { return require('./preview').default }

export function meta () {
  return {
    title: '测试模块 C',
    category: ['分类1', '分类3']
  }
}

export function config_data () {
  return {}
}

export function inspector_data () {
  return {}
}
