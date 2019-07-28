<template>
<el-dialog
    :visible.sync="visible"
    title="重命名目录"
    width="500px"
    append-to-body
    :close-on-click-modal="!loading"
    :close-on-press-escape="!loading"
    :show-close="!loading"
    @opened="handle_opened">
  <el-input
    ref="name_input"
    v-model="name"
    placeholder="请输入目录名"
    :disabled="loading"
    @keydown.enter.native="submit"/>

  <div slot="footer">
    <el-button type="primary" :loading="loading" @click="submit">提交</el-button>
  </div>
</el-dialog>
</template>

<script>
import axios from 'axios'

export default {
  data () {
    return {
      visible: false,
      loading: false,
      id: null,
      name: ''
    }
  },

  methods: {
    open (folder) {
      this.id = folder.id
      this.name = folder.name
      this.visible = true
    },

    handle_opened () {
      this.$refs.name_input.focus()
    },

    async submit () {
      if (!this.name) { return }

      this.loading = true
      const { data } = await axios.post('/media/folder', {
        id: this.id,
        folder: { name: this.name }
      })
      this.loading = false

      if (data.errors) {
        this.$helper.json_error_message(data.errors)
      } else {
        this.$message.success('重命名目录成功')
        this.visible = false
        this.$parent.load()
      }
    }
  }
}
</script>
