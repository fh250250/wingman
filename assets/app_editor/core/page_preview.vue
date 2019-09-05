<template>
<div class="page-preview">
  <div class="page-preview-header">
    <div class="title">页面预览</div>
    <div class="save">保存</div>
  </div>

  <div class="page-preview-body">
    <div v-if="inspected_page" class="document-root custom-scrollbar">
      <draggable class="module-list"
          :list="inspected_page.module_list"
          group="module_list"
          handle=".module-move-handle">
        <div class="module" v-for="m of inspected_page.module_list" :key="m.id">
          <component :is="module_preview_component(m.module_name)" :config="m.config"/>

          <div class="module-tools">
            <i class="el-icon-setting"/>
            <i class="el-icon-rank module-move-handle"/>
            <i class="el-icon-delete"/>
          </div>
        </div>
      </draggable>
    </div>
    <div v-else class="no-page">请先选择页面</div>
  </div>
</div>
</template>

<script>
import draggable from 'vuedraggable'
import registered_modules from './registered_modules'

export default {
  components: { draggable },

  computed: {
    inspected_page () {
      return this.$root.inspected_page
    }
  },

  methods: {
    module_preview_component (module_name) {
      return registered_modules[module_name].preview_component()
    }
  }
}
</script>

<style lang="scss" scoped>
.page-preview {
  height: 100%;
  display: flex;
  flex-direction: column;
  user-select: none;
  &-header {
    flex: 0 0 auto;
    font-size: 12px;
    padding: 5px 10px;
    background-color: #f0f0f0;
    border-bottom: 1px solid #ccc;
    display: flex;
    justify-content: space-between;
    .save {
      cursor: pointer;
      color: $--color-primary;
    }
  }
  &-body {
    flex: 1 1 auto;
    box-sizing: border-box;
    padding: 40px;
    background-color: #fafafa;
    overflow: hidden;
  }
  .document-root {
    width: 375px;
    height: 100%;
    background-color: white;
    box-shadow: 0 0 20px 5px rgba(0, 0, 0, .2);
    border-radius: 5px;
    overflow: auto;
    .module-list {
      min-height: 100%;
      .module {
        position: relative;
        &:hover .module-tools { display: flex; }
        &-tools {
          position: absolute;
          top: 0;
          right: 0;
          font-size: 20px;
          display: none;
          background-color: rgba(0, 0, 0, .5);
          color: white;
          padding: 5px 10px;
          border-radius: 0 0 0 5px;
          > *:not(:last-child) { margin-right: 10px; }
          .el-icon-setting { cursor: pointer; }
          .el-icon-rank { cursor: move; }
          .el-icon-delete { cursor: pointer; }
        }
      }
    }
  }
  .no-page {
    width: 375px;
    height: 100%;
    text-align: center;
    font-size: 20px;
    color: #999;
  }
}
</style>
