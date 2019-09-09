<template>
<div class="module-inspector">
  <component v-if="inspected_module" :is="inspector_component" :config="inspected_module.config"/>
  <div v-else class="no-module">模块审查器</div>
</div>
</template>

<script>
import registered_modules from './registered_modules'

export default {
  computed: {
    inspected_module () {
      return this.$root.inspected_module
    },

    inspector_component () {
      if (!this.inspected_module) { return null }

      return registered_modules[this.inspected_module.module_name].inspector_component()
    }
  }
}
</script>
