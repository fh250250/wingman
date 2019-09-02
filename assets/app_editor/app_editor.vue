<template>
<div id="app_editor">
  <div class="left-section">
    <page-list/>
    <module-collection/>
  </div>
  <div class="middle-section">
    <page-preview/>
  </div>
  <div class="right-section">
    <inspector ref="inspector"/>
  </div>
</div>
</template>

<script>
import { find as _find } from 'lodash'
import { app as app_defaule_value } from './core/default_value'
import PageList from './core/page_list'
import ModuleCollection from './core/module_collection'
import PagePreview from './core/page_preview'
import Inspector from './core/inspector'

export default {
  components: { PageList, ModuleCollection, PagePreview, Inspector },

  data () {
    return {
      app_data: app_defaule_value(),
      inspected_page_id: null,
      inspected_module_id: null
    }
  },

  computed: {
    inspected_page () {
      return _find(this.app_data.page_list, p => p.id === this.inspected_page_id) || null
    },

    inspected_module () {
      if (!this.inspected_page) { return null }

      return _find(this.inspected_page.module_list, m => m.id === this.inspected_module_id) || null
    }
  },

  methods: {
    change_inspector_tab (tab_name) {
      this.$refs.inspector.change_tab(tab_name)
    }
  }
}
</script>

<style lang="scss" scoped>
#app_editor {
  display: flex;
  overflow: hidden;
  .left-section {
    width: 400px;
    flex: 0 0 auto;
  }
  .middle-section {
    border-left: 1px solid #ccc;
    border-right: 1px solid #ccc;
    flex: 0 0 auto;
  }
  .right-section {
    flex: 1 1 auto;
  }
}
</style>
