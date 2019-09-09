export function module_name () { return 'test_b' }
export function preview_component () { return require('./preview').default }
export function inspector_component () { return require('./inspector').default }

export function meta () {
  return {
    title: '测试模块 B',
    category: ['分类2', '分类3']
  }
}

export function config_data () {
  return {
    test_b: 'b'
  }
}
