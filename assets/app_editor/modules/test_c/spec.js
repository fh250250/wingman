export function module_name () { return 'test_c' }
export function preview_component () { return require('./preview').default }

export function meta () {
  return {
    label: '测试模块 C',
    category: '测试 1'
  }
}

export function config_data () {
  return {}
}

export function inspector_data () {
  return {}
}
