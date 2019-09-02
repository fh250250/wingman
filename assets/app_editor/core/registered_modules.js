const loaded_spec = require.context('../modules', true, /spec\.js$/)
const registered_modules = {}

loaded_spec.keys().forEach(key => {
  const spec = loaded_spec(key)
  const module_name = spec.module_name()

  if (registered_modules[module_name]) { throw new Error(`${module_name} 已注册`) }

  registered_modules[module_name] = spec
})

export default registered_modules
