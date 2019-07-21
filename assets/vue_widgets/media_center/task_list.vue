<template>
<div class="task-list">
  <el-table :data="list" border size="mini" empty-text="暂无上传任务">
    <el-table-column label="文件名" prop="name"/>

    <el-table-column label="大小" width="100px">
      <template slot-scope="scope">
        {{ $helper.human_readable_bytes(scope.row.size) }}
      </template>
    </el-table-column>

    <el-table-column label="状态" width="100px">
      <template slot-scope="scope">
        <el-tag :type="status_tag_type(scope.row.status)">{{ status_text(scope.row.status) }}</el-tag>
      </template>
    </el-table-column>

    <el-table-column label="进度" width="200px">
      <template slot-scope="scope">
        <el-image v-if="scope.row.preview_url" :src="scope.row.preview_url" fit="cover" style="width: 100%; height: 80px"/>
        <el-progress :percentage="scope.row.progress" :stroke-width="14" text-inside :color="() => status_progress_color(scope.row.status)"/>
      </template>
    </el-table-column>

    <el-table-column label="操作" width="120px"/>
  </el-table>
</div>
</template>

<script>
import axios from 'axios'
import {
  clamp as _clamp,
  floor as _floor,
  throttle as _throttle,
  findIndex as _findIndex
} from 'lodash'

const STATUS = {
  IDLE: 'IDLE',
  RUNNING: 'RUNNING',
  ERROR: 'ERROR'
}
const REQUEST_LIMIT = 3

export default {
  inject: ['media_center'],

  data () {
    return {
      list: []
    }
  },

  created () {
    this.throttle_update_media_list = _throttle(this.update_media_list, 2000)
  },

  methods: {
    status_text (status) {
      switch (status) {
        case STATUS.IDLE: return '等待中'
        case STATUS.RUNNING: return '上传中'
        case STATUS.ERROR: return '失败'
        default: return ''
      }
    },

    status_tag_type (status) {
      switch (status) {
        case STATUS.IDLE: return 'info'
        case STATUS.RUNNING: return 'default'
        case STATUS.ERROR: return 'danger'
        default: return ''
      }
    },

    status_progress_color (status) {
      switch (status) {
        case STATUS.IDLE: return '#3c8dbc'
        case STATUS.RUNNING: return '#3c8dbc'
        case STATUS.ERROR: return '#dd4b39'
        default: return '#3c8dbc'
      }
    },

    add_task (folder_id, file) {
      const task = {
        folder_id,
        file,
        name: file.name,
        size: file.size,
        content_type: file.type,
        preview_url: this.$helper.is_image(file.type) ? URL.createObjectURL(file) : null,
        status: STATUS.IDLE,
        progress: 0
      }

      this.list.push(task)
      this.schedule()
    },

    schedule () {
      const running_count = this.list.filter(t => t.status === STATUS.RUNNING).length
      const free_count = REQUEST_LIMIT - running_count

      if (free_count <= 0) { return }

      this.list
        .filter(t => t.status === STATUS.IDLE)
        .slice(0, free_count)
        .forEach(t => this.upload_file(t))
    },

    async upload_file (task) {
      task.status = STATUS.RUNNING

      const form_data = new FormData()

      task.folder_id && form_data.append('folder_id', task.folder_id)
      form_data.append('file', task.file)

      let has_error = false
      try {
        const { data } = await axios.post('/media/upload', form_data, {
          onUploadProgress (ev) { task.progress = _floor(_clamp(ev.loaded / ev.total * 100, 0, 100), 2) }
        })

        if (data.errors) { has_error = true }
      } catch (e) {
        has_error = true
      }

      if (has_error) {
        task.status = STATUS.ERROR
        this.$notify.error({
          title: '上传失败',
          message: task.name
        })
      } else {
        this.$notify.success({
          title: '上传成功',
          message: task.name
        })
        this.throttle_update_media_list(task)
        this.remove_task(task)
      }

      this.schedule()
    },

    update_media_list (task) {
      if (this.media_center.$refs.media_list.current_folder_id === task.folder_id) {
        this.media_center.$refs.media_list.load()
      }
    },

    remove_task (task) {
      if (task.preview_url) { URL.revokeObjectURL(task.preview_url) }

      const idx = _findIndex(this.list, t => t === task)

      if (idx >= 0) { this.list.splice(idx, 1) }
    }
  }
}
</script>

<style lang="sass" scoped>
.task-list
  /deep/
    .el-progress-bar__outer,
    .el-progress-bar__inner
      border-radius: 0
</style>
