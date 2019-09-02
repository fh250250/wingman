<template>
<div class="module-collection">
  <div class="module-collection-header">模块集合</div>
  <div class="module-collection-body custom-scrollbar">
    <el-collapse>
      <el-collapse-item v-for="c of category_list" :key="c" :title="c" :name="c">
        kjdfs
      </el-collapse-item>
    </el-collapse>
  </div>
</div>
</template>

<script>
import { map as _map, uniq as _uniq } from 'lodash'
import registered_modules from './registered_modules'

export default {
  data () {
    return {
      category_list: _uniq(_map(registered_modules, m => m.meta().category))
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
  &-header {
    flex: 0 0 auto;
    font-size: 12px;
    padding: 5px 10px;
    background-color: #f0f0f0;
    border-bottom: 1px solid #ccc;
    user-select: none;
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
}
</style>
