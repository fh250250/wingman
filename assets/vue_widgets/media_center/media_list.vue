<template>
<div class="mc-list" v-loading="loading">
  <div class="mc-header">
    <div class="header-left">
      <el-button icon="el-icon-back" :disabled="path_stack.length < 1" @click="back"/>

      <el-button type="primary" icon="el-icon-folder-add" @click="$refs.create_folder_dialog.open()"/>

      <el-button type="primary" icon="el-icon-upload2" @click="$refs.upload.click()"/>
      <input type="file" multiple style="display: none" ref="upload" @change="handle_upload">
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
          <div class="preview-icon el-icon-folder"/>
        </div>
        <div class="item-body">
          <div class="name" :title="f.name">{{ f.name }}</div>
          <el-dropdown class="tools" @command="handle_folder_op">
            <i class="el-icon-setting"/>
            <el-dropdown-menu slot="dropdown">
              <el-dropdown-item :command="{ folder: f, op: 'rename' }" icon="el-icon-edit">重命名</el-dropdown-item>
              <el-dropdown-item :command="{ folder: f, op: 'move' }" icon="el-icon-folder">移动</el-dropdown-item>
              <el-dropdown-item :command="{ folder: f, op: 'delete' }" icon="el-icon-delete">删除</el-dropdown-item>
            </el-dropdown-menu>
          </el-dropdown>
        </div>
      </div>

      <div v-for="f of files" :key="`file-${f.id}`" class="content-item">
        <div class="item-header">
          <el-image v-if="$helper.is_image(f.content_type)" :src="f.path" fit="cover" class="preview-image"/>
          <div v-else class="preview-icon el-icon-document"/>
        </div>
        <div class="item-body">
          <div class="name" :title="f.name">{{ f.name }}</div>
          <el-dropdown class="tools" @command="handle_file_op">
            <i class="el-icon-setting"/>
            <el-dropdown-menu slot="dropdown">
              <el-dropdown-item :command="{ file: f, op: 'rename' }" icon="el-icon-edit">重命名</el-dropdown-item>
              <el-dropdown-item :command="{ file: f, op: 'move' }" icon="el-icon-folder">移动</el-dropdown-item>
              <el-dropdown-item :command="{ file: f, op: 'delete' }" icon="el-icon-delete">删除</el-dropdown-item>
            </el-dropdown-menu>
          </el-dropdown>
        </div>
      </div>
    </div>
    <div v-else class="no-content">暂无内容</div>
  </div>

  <!-- 弹框 -->
  <create-folder-dialog ref="create_folder_dialog"/>
  <rename-folder-dialog ref="rename_folder_dialog"/>
  <move-folder-dialog ref="move_folder_dialog"/>
  <rename-file-dialog ref="rename_file_dialog"/>
  <move-file-dialog ref="move_file_dialog"/>
</div>
</template>

<script>
import axios from 'axios'
import { last as _last, get as _get } from 'lodash'
import CreateFolderDialog from './dialog/create_folder'
import RenameFolderDialog from './dialog/rename_folder'
import MoveFolderDialog from './dialog/move_folder'
import RenameFileDialog from './dialog/rename_file'
import MoveFileDialog from './dialog/move_file'

export default {
  inject: ['media_center'],
  components: { CreateFolderDialog, RenameFolderDialog, MoveFolderDialog, RenameFileDialog, MoveFileDialog },

  data () {
    return {
      loading: false,
      folders: [],
      files: [],
      path_stack: []
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

      this.folders = data.folders.sort((a, b) => a.name.localeCompare(b.name))
      this.files = data.files.sort((a, b) => a.name.localeCompare(b.name))
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

    async handle_upload (ev) {
      ev.target.files
        .forEach(file => this.media_center.$refs.task_list.add_task(this.current_folder_id, file))

      ev.target.value = null

      this.$message.success('已添加至上传队列')
    },

    handle_folder_op ({ op, folder }) {
      switch (op) {
        case 'rename':
          this.$refs.rename_folder_dialog.open(folder)
          break
        case 'move':
          this.$refs.move_folder_dialog.open(folder)
          break
        case 'delete':
          this.delete_folder(folder)
          break
      }
    },

    async delete_folder (folder) {
      try {
        await this.$confirm('是否删除此目录?', '提示', { type: 'warning' })
      } catch (_error) {
        return
      }

      this.loading = true
      const { data } = await axios.delete('/media/folder', {
        data: { id: folder.id }
      })
      this.loading = false

      if (data.errors) {
        this.$helper.json_error_message(data.errors)
      } else {
        this.$message.success('删除目录成功')
        this.load()
      }
    },

    handle_file_op ({ op, file }) {
      switch (op) {
        case 'rename':
          this.$refs.rename_file_dialog.open(file)
          break
        case 'move':
          this.$refs.move_file_dialog.open(file)
          break
        case 'delete':
          this.delete_file(file)
          break
      }
    },

    async delete_file (file) {
      try {
        await this.$confirm('是否删除此文件?', '提示', { type: 'warning' })
      } catch (_error) {
        return
      }

      this.loading = true
      const { data } = await axios.delete('/media/file', {
        data: { id: file.id }
      })
      this.loading = false

      if (data.errors) {
        this.$helper.json_error_message(data.errors)
      } else {
        this.$message.success('删除文件成功')
        this.load()
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.mc-list {
  .mc-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    .header-left,
    .header-right {
      display: flex;
      align-items: center;
      > * {
        margin: 0;
        &:not(:last-child) { margin-right: 15px; }
      }
    }
  }
  .breadcrumb {
    margin: 20px 0 15px 0;
    border-radius: 0;
    li:not(.active) { cursor: pointer; }
  }
  .mc-body {
    height: 500px;
    overflow: auto;
    position: relative;
    .no-content {
      font-size: 36px;
      text-align: center;
      color: grey;
      position: absolute;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
    }
    .content-view {
      user-select: none;
      display: flex;
      flex-wrap: wrap;
      .content-item {
        margin: 5px;
        box-sizing: border-box;
        width: 150px;
        border: 1px solid #eee;
        line-height: 1;
        transition: all .3s;
        &:hover { background: #fcfcfc; }
        &.folder .item-header { cursor: pointer; }
        .item-header {
          height: 96px;
          position: relative;
          border-bottom: 1px solid #eee;
          .preview-image {
            display: block;
            width: 100%;
            height: 100%;
          }
          .preview-icon {
            position: absolute;
            left: 50%;
            top: 50%;
            transform: translate(-50%, -50%);
            font-size: 48px;
            &.el-icon-folder { color: #f39c12; }
          }
        }
        .item-body {
          padding: 10px;
          display: flex;
          .name {
            flex: 1 1 auto;
            font-size: 12px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
          }
          .tools {
            flex: 0 0 auto;
          }
        }
      }
    }
  }
}
</style>
