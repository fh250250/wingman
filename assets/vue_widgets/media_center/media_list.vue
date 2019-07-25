<template>
<div class="mc-list" v-loading="loading">
  <div class="mc-header">
    <div class="header-left">
      <el-button icon="el-icon-back" :disabled="path_stack.length < 1" @click="back"/>

      <el-button type="primary" icon="el-icon-upload2" @click="$refs.upload.click()"/>
      <input type="file" multiple style="display: none" ref="upload" @change="handle_upload">

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
      <div v-for="f of folders" :key="`folder-${f.id}`" class="content-item folder">
        <div class="item-header" @click="cd(f)">
          <div class="icon el-icon-folder"/>
        </div>
        <div class="item-body">
          <div class="name" :title="f.name">{{ f.name }}</div>
        </div>
      </div>

      <div v-for="f of files" :key="`file-${f.id}`" class="content-item">
        <div class="item-header">
          <el-image v-if="$helper.is_image(f.content_type)" :src="f.path" fit="cover"/>
          <div v-else class="icon el-icon-document"/>
        </div>
        <div class="item-body">
          <div class="name" :title="f.name">{{ f.name }}</div>
        </div>
      </div>
    </div>
    <div v-else class="no-content">暂无内容</div>
  </div>
</div>
</template>

<script>
import axios from 'axios'
import { last as _last, get as _get } from 'lodash'

export default {
  inject: ['media_center'],

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
      ev.target.files
        .forEach(file => this.media_center.$refs.task_list.add_task(this.current_folder_id, file))

      ev.target.value = null

      this.$message.success('已添加至上传队列')
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
    margin: 20px 0 15px 0
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
      .content-item
        margin: 5px
        box-sizing: border-box
        width: 120px
        border: 1px solid #eee
        line-height: 1
        transition: all .3s
        &:hover
          background: #fcfcfc
        &.folder .item-header
          cursor: pointer
        .item-header
          height: 72px
          display: flex
          justify-content: center
          align-items: center
          border-bottom: 1px solid #eee
          .el-image
            display: block
            width: 100%
            height: 100%
          .icon
            font-size: 48px
        .item-body
          padding: 10px
          .name
            font-size: 12px
            text-align: center
            white-space: nowrap
            overflow: hidden
            text-overflow: ellipsis
</style>
