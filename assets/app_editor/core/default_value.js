import unique_string from 'unique-string'

// 应用默认值
export function app () {
  return {
    name: '',             // 应用名称
    page_list: [],        // 页面列表
    main_page: null,      // 主页 id
  }
}

// 页面默认值
export function page () {
  return {
    id: unique_string(),
    name: '',             // 页面名称
    module_list: [],      // 模块列表
  }
}
