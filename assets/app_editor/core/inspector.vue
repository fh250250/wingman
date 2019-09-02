<template>
<div class="inspector">
  <div class="inspector-tab">
    <div class="tab-item"
        v-for="item of inspectors"
        :key="item.name"
        :class="{ active: item.name === tab }"
        @click="change_tab(item.name)">
      {{ item.label }}
    </div>
  </div>

  <div class="inspector-body">
    <component :is="inspector_component"/>
  </div>
</div>
</template>

<script>
import { find as _find } from 'lodash'
import AppInspector from './app_inspector'
import PageInspector from './page_inspector'
import ModuleInspector from './module_inspector'

export default {
  data () {
    return {
      tab: 'app',
      inspectors: [
        { name: 'app', label: '应用', component: AppInspector },
        { name: 'page', label: '页面', component: PageInspector },
        { name: 'module', label: '模块', component: ModuleInspector }
      ]
    }
  },

  computed: {
    inspector_component () {
      return _find(this.inspectors, item => item.name === this.tab).component
    }
  },

  methods: {
    change_tab (name) {
      const is_name_valid = !!_find(this.inspectors, item => item.name === name)

      if (is_name_valid && this.tab !== name) {
        this.tab = name
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.inspector {
  height: 100%;
  display: flex;
  flex-direction: column;
  .inspector-tab {
    user-select: none;
    font-size: 12px;
    flex: 0 0 auto;
    display: flex;
    background-color: #f0f0f0;
    border-bottom: 1px solid #ccc;
    .tab-item {
      padding: 5px 10px;
      cursor: pointer;
      &:hover { color: #666; }
      &.active {
        background-color: white;
      }
    }
  }
  .inspector-body {
    flex: 1 1 auto;
    overflow: auto;
    box-sizing: border-box;
    padding: 10px;
  }
}
</style>
