<template>
<div class="task-list">
  <el-table :data="list" row-key="id" border size="mini" empty-text="暂无上传任务">
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

    <el-table-column label="操作" width="180px">
      <template slot-scope="scope">
        <el-button type="primary" :disabled="scope.row.status !== 'ERROR'" @click="reset_task(scope.row)">重新执行</el-button>
        <el-button type="danger" :disabled="scope.row.status === 'RUNNING'" @click="remove_task(scope.row)">删除</el-button>
      </template>
    </el-table-column>
  </el-table>
</div>
</template>

<script>
import axios from 'axios'
import {
  clamp as _clamp,
  floor as _floor,
  throttle as _throttle,
  find as _find,
  findIndex as _findIndex
} from 'lodash'
import unique_string from 'unique-string'

const STATUS = {
  IDLE: 'IDLE',
  RUNNING: 'RUNNING',
  ERROR: 'ERROR'
}
const MAX_TASK = 3

export default {
  data () {
    return {
      list: []
    }
  },

  created () {
    this.throttle_update_explorer = _throttle(this.update_explorer, 2000)
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

    async add_task (folder_id, file) {
      const task = {
        id: unique_string(),
        is_large: file.size > 4 * 1024 * 1024,
        folder_id,
        file,
        name: file.name,
        size: file.size,
        content_type: file.type,
        preview_url: this.$helper.is_image(file.type) ? URL.createObjectURL(file) : null,
        status: STATUS.IDLE,
        progress: 0
      }

      if (task.is_large) {
        task.chunks = []

        // 计算一个 8M 内容的 md5 值，用于判断任务是否存在，避免计算过大
        task.md5_part = await this.$helper.calc_blob_md5(task.file.slice(0, 8 * 1024 * 1024))

        // 在同一个目录下只能有一个大文件任务
        if (_find(this.list, t => t.folder_id === task.folder_id && t.md5_part === task.md5_part)) { return }
      }

      this.list.push(task)
      this.schedule()
    },

    schedule () {
      const running_count = this.list.filter(t => t.status === STATUS.RUNNING).length
      const free_count = MAX_TASK - running_count

      if (free_count <= 0) { return }

      this.list
        .filter(t => t.status === STATUS.IDLE)
        .slice(0, free_count)
        .forEach(t => t.is_large ? this.upload_large_file(t) : this.upload_small_file(t))
    },

    async upload_small_file (task) {
      task.status = STATUS.RUNNING

      const form_data = new FormData()

      task.folder_id && form_data.append('folder_id', task.folder_id)
      form_data.append('file', task.file)

      try {
        const { data } = await axios.post('/storage/small-upload', form_data, {
          onUploadProgress (ev) { task.progress = _floor(_clamp(ev.loaded / ev.total * 100, 0, 100), 2) }
        })

        if (data.errors) { throw new Error('上传失败') }

        this.$notify.success({ title: '上传成功', message: task.name })
        this.throttle_update_explorer(task)
        this.remove_task(task)
      } catch (e) {
        task.status = STATUS.ERROR
        this.$notify.error({ title: '上传失败', message: task.name })
      }

      this.schedule()
    },

    async upload_large_file (task) {
      task.status = STATUS.RUNNING

      try {
        // 计算整个文件的 md5 值
        task.md5 = await this.$helper.calc_blob_md5(task.file)

        await this.create_upload_task(task)
        await this.upload_chunks(task)
        await this.combine_chunks(task)

        this.$notify.success({ title: '上传成功', message: task.name })
        this.throttle_update_explorer(task)
        this.remove_task(task)
      } catch (e) {
        task.status = STATUS.ERROR
        this.$notify.error({ title: '上传失败', message: task.name })
      }

      this.schedule()
    },

    async create_upload_task (task) {
      const { data } = await axios.post('/storage/large-upload', {
        folder_id: task.folder_id,
        md5: task.md5,
        filename: task.name,
        size: task.size
      })

      if (data.errors) { throw new Error('创建大文件任务失败') }

      task.upload_id = data.upload_id
      task.chunks = data.chunks.map(c => ({
        ...c,
        progress: c.loaded ? 100 : 0
      }))
    },

    async upload_chunks (task) {
      const not_loaded_chunks = task.chunks.filter(c => !c.loaded)

      for (const chunk of not_loaded_chunks) {
        const form_data = new FormData()

        form_data.append('upload_id', task.upload_id)
        form_data.append('number', chunk.number)
        form_data.append('chunk', task.file.slice(chunk.offset, chunk.offset + chunk.size))

        try {
          const { data } = await axios.post('/storage/chunk', form_data, {
            onUploadProgress (ev) {
              chunk.progress = _floor(_clamp(ev.loaded / ev.total * 100, 0, 100), 2)
              task.progress = _floor(_clamp(task.chunks.reduce((acc, c) => acc + c.progress, 0) / task.chunks.length, 0, 100), 2)
            }
          })

          if (data.errors) { throw new Error('分块上传失败') }

          chunk.loaded = true
        } catch (e) {
        }
      }
    },

    async combine_chunks (task) {
      if (task.chunks.some(c => !c.loaded)) { throw new Error('分块未上传完') }

      const { data } = await axios.post('/storage/combine', {
        upload_id: task.upload_id
      })

      if (data.errors) { throw new Error('合并分块失败') }
    },

    update_explorer (task) {
      if (this.$root.$refs.explorer.current_folder_id === task.folder_id) {
        this.$root.$refs.explorer.load()
      }
    },

    remove_task (task) {
      if (task.preview_url) { URL.revokeObjectURL(task.preview_url) }

      const idx = _findIndex(this.list, t => t === task)

      if (idx >= 0) { this.list.splice(idx, 1) }
    },

    reset_task (task) {
      task.status = STATUS.IDLE
      task.progress = 0

      if (task.is_large) {
        task.chunks = []
      }

      this.schedule()
    }
  }
}
</script>

<style lang="scss" scoped>
.task-list {
  /deep/ {
    .el-progress-bar__outer,
    .el-progress-bar__inner {
      border-radius: 0;
    }
  }
}
</style>
