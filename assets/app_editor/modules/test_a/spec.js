export function module_name () { return 'test_a' }
export function preview_component () { return require('./preview').default }

export function meta () {
  return {
    title: '测试模块 A',
    category: ['分类1', '分类2']
  }
}

export function config_data () {
  return {}
}

export function inspector_data () {
  return {}
}
