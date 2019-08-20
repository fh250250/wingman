<template>
<el-dialog
    :visible.sync="visible"
    title="创建目录"
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
      name: ''
    }
  },

  methods: {
    open () {
      this.name = ''
      this.visible = true
    },

    handle_opened () {
      this.$refs.name_input.focus()
    },

    async submit () {
      if (!this.name) { return }

      this.loading = true
      const { data } = await axios.post('/storage/mkdir', {
        folder_id: this.$parent.current_folder_id,
        name: this.name
      })
      this.loading = false

      if (data.errors) {
        this.$helper.json_error_message(data.errors)
      } else {
        this.$message.success('创建目录成功')
        this.visible = false
        this.$parent.load()
      }
    }
  }
}
</script>
