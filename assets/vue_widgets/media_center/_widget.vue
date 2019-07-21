<template>
<el-tabs v-model="tab" type="border-card">
  <el-tab-pane label="媒体库" name="media_list">
    <media-list ref="media_list"/>
  </el-tab-pane>
  <el-tab-pane label="上传任务" name="task_list">
    <task-list ref="task_list"/>
  </el-tab-pane>
</el-tabs>
</template>

<script>
import MediaList from './media_list'
import TaskList from './task_list'

export default {
  components: { MediaList, TaskList },

  provide () {
    return {
      media_center: this
    }
  },

  data () {
    return {
      tab: 'media_list'
    }
  }
}
</script>
