<template>
<div class="mc-list" v-loading="loading">
  <div class="mc-header">
    <div class="header-left">
      <el-button icon="el-icon-back" :disabled="path_stack.length < 1" @click="back"/>

      <el-button type="primary" icon="el-icon-upload2" @click="$refs.upload.click()"/>
      <input type="file" style="display: none" ref="upload" @change="handle_upload">

      <el-input v-model="create_folder.name"
          :maxlength="32"
          :disabled="create_folder.loading"
          placeholder="创建目录">
        <el-button slot="append"
            type="primary"
            icon="el-icon-folder-add"
            :loading="create_folder.loading"
            @click="mkdir"/>
      </el-input>
    </div>

    <div class="header-right">
      <el-button icon="el-icon-refresh" @click="load"/>
    </div>
  </div>

  <ol class="breadcrumb">
    <li key="root" @click="change_path(-1)">根目录</li>
    <li v-for="(f, idx) of path_stack"
      :key="f.id"
      :class="{ active: idx === path_stack.length - 1 }"
      @click="change_path(idx)">{{ f.name }}</li>
  </ol>

  <div class="mc-body">
    <div v-if="folders.length || files.length" class="content-view">
      <div v-for="f of folders" :key="`folder-${f.id}`" class="folder" @click="cd(f)">
        <div class="icon el-icon-folder"/>
        <div class="name">{{ f.name }}</div>
      </div>

      <div v-for="f of files" :key="`file-${f.id}`" class="file">
        <el-image v-if="is_image(f)" :src="f.path" fit="cover"/>
        <div v-else class="icon el-icon-document"/>
        <div class="name">{{ f.name }}</div>
      </div>
    </div>
    <div v-else class="no-content">暂无内容</div>
  </div>
</div>
</template>

<script>
import axios from 'axios'
import { last as _last, get as _get, includes as _includes } from 'lodash'

export default {
  data () {
    return {
      loading: false,
      folders: [],
      files: [],
      path_stack: [],
      create_folder: {
        loading: false,
        name: ''
      }
    }
  },

  created () {
    this.load()
  },

  computed: {
    current_folder_id () {
      return _get(_last(this.path_stack), 'id', null)
    }
  },

  methods: {
    async load () {
      if (this.loading) { return }

      this.loading = true
      const { data } = await axios.get('/media/ls', {
        params: { folder_id: this.current_folder_id}
      })
      this.loading = false

      this.folders = data.folders
      this.files = data.files
    },

    cd (folder) {
      this.path_stack.push(folder)
      this.load()
    },

    back () {
      this.path_stack.pop()
      this.load()
    },

    change_path (idx) {
      if (idx < 0) {
        this.path_stack = []
        this.load()
      } else if (idx < this.path_stack.length - 1) {
        this.path_stack.splice(idx + 1)
        this.load()
      }
    },

    async mkdir () {
      if (!this.create_folder.name) { return }

      this.create_folder.loading = true
      const { data } = await axios.post('/media/mkdir', {
        folder_id: this.current_folder_id,
        folder: { name: this.create_folder.name }
      })
      this.create_folder.loading = false

      const error = _get(data, 'errors.name[0]')

      if (error) {
        this.$message.error(error)
      } else {
        this.create_folder.name = ''
        this.$message.success('创建目录成功')
        this.load()
      }
    },

    async handle_upload (ev) {
      const form_data = new FormData()

      if (this.current_folder_id) {
        form_data.append('folder_id', this.current_folder_id)
      }

      form_data.append('file', ev.target.files[0])

      const { data } = await axios.post('/media/upload', form_data)

      if (data.errors) {
        this.$message.error('上传失败')
      } else {
        this.$message.success('上传成功')
        ev.target.value = null
        this.load()
      }
    },

    is_image (file) {
      return _includes([
        'image/png',
        'image/jpeg',
        'image/gif',
      ], file.content_type)
    }
  }
}
</script>

<style lang="sass" scoped>
.mc-list
  .mc-header
    display: flex
    justify-content: space-between
    align-items: center
    .header-left,
    .header-right
      display: flex
      align-items: center
      > *
        margin: 0
        &:not(:last-child)
          margin-right: 15px
  .breadcrumb
    margin: 20px 0
    border-radius: 0
    li:not(.active)
      cursor: pointer
  .mc-body
    height: 500px
    overflow: auto
    position: relative
    .no-content
      font-size: 36px
      text-align: center
      color: grey
      position: absolute
      top: 50%
      left: 50%
      transform: translate(-50%, -50%)
    .content-view
      user-select: none
      display: flex
      flex-wrap: wrap
      > div
        margin: 5px
        box-sizing: border-box
        width: 120px
        padding: 10px
        border: 1px solid #eee
        line-height: 1
        transition: all .3s
        &:hover
          background: #eee
      .folder
        cursor: pointer
      .icon
        display: block
        font-size: 48px
        text-align: center
      .el-image
        display: block
        height: 60px
      .name
        font-size: 12px
        text-align: center
        white-space: nowrap
        overflow: hidden
        text-overflow: ellipsis
</style>
