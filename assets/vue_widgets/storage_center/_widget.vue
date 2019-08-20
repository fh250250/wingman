<template>
<el-tabs type="border-card">
  <el-tab-pane label="存储库"><explorer ref="explorer"/></el-tab-pane>
  <el-tab-pane label="任务列表"><task-list ref="task_list"/></el-tab-pane>
</el-tabs>
</template>

<script>
import Explorer from './explorer'
import TaskList from './task_list'

export default {
  components: { Explorer, TaskList }
}
</script>
