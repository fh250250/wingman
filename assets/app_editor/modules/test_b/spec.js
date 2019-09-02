export function module_name () { return 'test_b' }
export function preview_component () { return require('./preview').default }

export function meta () {
  return {
    label: '测试模块 B',
    category: '测试'
  }
}

export function config_data () {
  return {}
}

export function inspector_data () {
  return {}
}
