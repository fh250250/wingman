<template>
<div class="page-list">
  <div class="page-list-header">
    <div class="title">页面列表</div>
    <div class="tool" @click="add_page"><i class="el-icon-circle-plus-outline"/> 添加</div>
  </div>

  <div class="page-list-body custom-scrollbar" ref="list_body">
    <div class="page-list-container" v-if="page_list.length">
      <div class="page-item"
          v-for="page of page_list"
          :key="page.id"
          :class="{ active: is_inspected(page) }"
          @click="inspect_page(page)">
        <div class="name">{{ page.name }}</div>
        <el-tag size="mini" v-if="is_main_page(page)">首页</el-tag>
      </div>
    </div>
    <div class="no-page" v-else>暂无页面, 请先添加</div>
  </div>
</div>
</template>

<script>
import { page as page_default_value } from './default_value'

export default {
  computed: {
    page_list () {
      return this.$root.app_data.page_list
    }
  },

  methods: {
    is_main_page (page) {
      return this.$root.app_data.main_page === page.id
    },

    is_inspected (page) {
      return this.$root.inspected_page_id === page.id
    },

    add_page () {
      const new_page = page_default_value()

      new_page.name = '新页面'

      this.page_list.push(new_page)

      // 如果未设置首页，则把新加页面设为首页
      if (!this.$root.app_data.main_page) { this.$root.app_data.main_page = new_page.id }

      // 审查新加页面
      this.$root.inspected_page_id = new_page.id
      this.$root.change_inspector_tab('page')

      // 滚动到底部
      this.$nextTick(() => {
        if (this.$refs.list_body) { this.$refs.list_body.scrollTo(0, this.$refs.list_body.scrollHeight) }
      })
    },

    inspect_page (page) {
      this.$root.inspected_page_id = page.id
      this.$root.change_inspector_tab('page')
    }
  }
}
</script>

<style lang="scss" scoped>
.page-list {
  height: 50%;
  box-sizing: border-box;
  border-bottom: 1px solid #ccc;
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
    .tool {
      cursor: pointer;
      &:hover { color: $--color-primary; }
    }
  }
  &-body {
    flex: 1 1 auto;
    overflow: auto;
  }
  .no-page {
    text-align: center;
    color: #999;
    font-size: 16px;
    padding: 40px 0;
  }
  &-container {
    padding: 10px;
    .page-item {
      display: flex;
      padding: 10px;
      background-color: #f0f0f0;
      &:not(:last-child) { margin-bottom: 10px; }
      &:hover { background-color: #e5e5e5; }
      &.active {
        background-color: rgba(53, 139, 189, 0.767);
        color: white;
      }
      .name {
        flex: 1 1 auto;
        margin-right: 10px;
      }
    }
  }
}
</style>
