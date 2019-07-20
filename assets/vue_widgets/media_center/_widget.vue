<template>
<el-tabs type="border-card">
  <el-tab-pane label="媒体库"><media-list/></el-tab-pane>
  <el-tab-pane label="任务列表"><task-list/></el-tab-pane>
</el-tabs>
</template>

<script>
import MediaList from './media_list'
import TaskList from './task_list'

export default {
  components: { MediaList, TaskList }
}
</script>
