<template>
<div id="app_editor">
  <div class="editor-header">
    <div>
      <el-link :underline="false" icon="el-icon-back">返回</el-link>
    </div>
    <div>
      <el-button type="text" size="medium" icon="el-icon-view">预览</el-button>
      <el-button type="text" size="medium" icon="el-icon-edit-outline">保存</el-button>
    </div>
  </div>

  <div class="editor-body">
    <div class="left-section">
      <page-list/>
      <module-collection/>
    </div>
    <div class="middle-section">
      <edit-canvas/>
    </div>
    <div class="right-section">
      <inspector ref="inspector"/>
    </div>
  </div>
</div>
</template>

<script>
import { find as _find } from 'lodash'
import { app as app_defaule_value } from './core/default_value'
import PageList from './core/page_list'
import ModuleCollection from './core/module_collection'
import EditCanvas from './core/edit_canvas'
import Inspector from './core/inspector'

export default {
  components: { PageList, ModuleCollection, EditCanvas, Inspector },

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
  flex-direction: column;
  .editor-header {
    flex: 0 0 auto;
    height: 40px;
    padding: 0 20px;
    border-bottom: 1px solid #ccc;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  .editor-body {
    flex: 1 1 auto;
    display: flex;
    overflow: hidden;
    .left-section {
      width: 300px;
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
}
</style>
