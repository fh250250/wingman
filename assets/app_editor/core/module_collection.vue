<template>
<div class="module-collection">
  <div class="module-collection-header">模块集合</div>
  <div class="module-collection-body custom-scrollbar">
    <el-collapse>
      <el-collapse-item v-for="c of category_list" :key="c" :title="c" :name="c">
        <draggable class="module-list"
            :value="find_module_list_by_category(c)"
            :sort="false"
            :group="{ name: 'module_list', pull: 'clone', put: false }"
            :clone="clone_module">
          <div class="module" v-for="m of find_module_list_by_category(c)" :key="m.module_name">
            {{ m.meta.title }}
          </div>
        </draggable>
      </el-collapse-item>
    </el-collapse>
  </div>
</div>
</template>

<script>
import unique_string from 'unique-string'
import { map as _map, flatMap as _flatMap, uniq as _uniq, includes as _includes } from 'lodash'
import draggable from 'vuedraggable'
import registered_modules from './registered_modules'

export default {
  components: { draggable },

  data () {
    return {
      module_list: _map(registered_modules, (m, module_name) => ({ module_name, meta: m.meta() }))
    }
  },

  computed: {
    category_list () {
      return _uniq(_flatMap(this.module_list, 'meta.category'))
    }
  },

  methods: {
    find_module_list_by_category (category) {
      return this.module_list.filter(m => _includes(m.meta.category, category))
    },

    clone_module ({ module_name }) {
      const spec = registered_modules[module_name]

      return {
        id: unique_string(),
        module_name,
        config: spec.config_data()
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.module-collection {
  height: 50%;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
  user-select: none;
  &-header {
    flex: 0 0 auto;
    font-size: 12px;
    padding: 5px 10px;
    background-color: #f0f0f0;
    border-bottom: 1px solid #ccc;
  }
  &-body {
    flex: 1 1 auto;
    overflow: auto;
  }
  /deep/ .el-collapse {
    border-top: none;
    .el-collapse-item__header {
      padding-left: 10px;
      font-size: 12px;
      height: 32px;
      line-height: 32px;
    }
    .el-collapse-item__content {
      padding: 5px 10px 10px;
      font-size: 12px;
      color: #333;
      line-height: 1.5;
    }
  }
  .module-list {
    lost-flex-container: row;
    .module {
      lost-waffle: 1/3 3 10px flex;
      background-color: grey;
      color: white;
      height: 80px;
      line-height: 80px;
      text-align: center;
    }
  }
}
</style>
