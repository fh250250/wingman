<template>
<el-drawer class="storage-finder"
    :visible.sync="visible"
    direction="btt"
    size="80%"
    :show-close="false">
  <template slot="title">
    <div>
      <el-button icon="el-icon-back" :disabled="loading || path_stack.length < 1" @click="back"/>
      <el-button icon="el-icon-refresh" :disabled="loading" @click="load"/>
    </div>
    <div>
      <el-button type="primary" :disabled="selected_count < 1" @click="handle_ok">确定</el-button>
      <el-button @click="visible = false">取消</el-button>
    </div>
  </template>

  <div class="finder-wrap" v-loading="loading">
    <ol class="breadcrumb">
      <li key="root" @click="change_path(-1)">根目录</li>
      <li v-for="(f, idx) of path_stack"
        :key="f.id"
        :class="{ active: idx === path_stack.length - 1 }"
        @click="change_path(idx)">{{ f.name }}</li>
    </ol>

    <div class="finder-body">
      <div v-if="folders.length || files.length" class="content-view">
        <div class="content-item" v-for="f of folders" :key="`folder-${f.id}`">
          <div class="item-header" @click.stop="cd(f)">
            <div class="preview-icon el-icon-folder"/>
          </div>
          <div class="item-name" :title="f.name">{{ f.name }}</div>
        </div>

        <div class="content-item"
            v-for="f of files"
            :key="`file-${f.id}`"
            :class="{ selected: f.selected }"
            @click="toggle_select(f)">
          <div class="item-header">
            <el-image v-if="$helper.is_image(f.content_type)" :src="f.url" fit="cover" class="preview-image"/>
            <div v-else class="preview-icon el-icon-document"/>
          </div>
          <div class="item-name" :title="f.name">{{ f.name }}</div>
        </div>
      </div>
      <div v-else class="no-content">暂无内容</div>
    </div>
  </div>
</el-drawer>
</template>

<script>
import axios from 'axios'
import {
  last as _last,
  get as _get,
  find as _find,
  isFunction as _isFunction
} from 'lodash'

export default {
  el: '#storage_finder',

  data () {
    return {
      visible: false,
      loading: false,
      folders: [],
      files: [],
      path_stack: [],
      is_multi_select: false
    }
  },

  computed: {
    current_folder_id () {
      return _get(_last(this.path_stack), 'id', null)
    },

    selected_files () {
      return this.files.filter(f => f.selected)
    },

    selected_count () {
      return this.selected_files.length
    }
  },

  methods: {
    async load () {
      if (this.loading) { return }

      this.loading = true
      const { data } = await axios.post('/storage/ls', { folder_id: this.current_folder_id })
      this.loading = false

      this.folders = data.folders.sort((a, b) => a.name.localeCompare(b.name))
      this.files = data.files.sort((a, b) => a.name.localeCompare(b.name)).map(f => ({ ...f, selected: false }))
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

    toggle_select (file) {
      if (this.is_multi_select) {
        file.selected = !file.selected
        return
      }

      if (this.selected_count > 0 && !file.selected) {
        _find(this.files, f => f.selected).selected = false
        file.selected = true
      } else {
        file.selected = !file.selected
      }
    },

    open (opts) {
      if (this.visible) { return }

      this.visible = true
      this.is_multi_select = !!_get(opts, 'multi', false)
      this._open_callback = _get(opts, 'on_change', null)
      this.load()
    },

    handle_ok () {
      if (this.selected_count < 1) { return }

      this.visible = false

      const result = this.is_multi_select
                    ? this.selected_files.map(f => f.id)
                    : this.selected_files[0].id

      if (_isFunction(this._open_callback)) {
        this._open_callback(result)
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.storage-finder {
  /deep/ {
    .el-drawer__header {
      padding: 15px 15px 0;
      margin-bottom: 15px;
      justify-content: space-between;
      > :first-child { flex: initial; }
    }
    .el-drawer__body {
      flex: 1 1 auto;
      overflow: auto;
    }
  }
  .finder-wrap {
    height: 100%;
    display: flex;
    flex-direction: column;
    overflow: auto;
  }
  .breadcrumb {
    flex: 0 0 auto;
    margin: 0;
    padding: 5px 15px;
    border-radius: 0;
    li:not(.active) { cursor: pointer; }
  }
  .finder-body {
    flex: 1 1 auto;
    padding: 10px;
    box-sizing: border-box;
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
        outline: 3px solid transparent;
        line-height: 1;
        transition: all .3s;
        cursor: pointer;
        &:hover { background: #fafafa; }
        &.selected {
          border-color: $--color-primary;
          outline-color: $--color-primary;
        }
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
            &.el-icon-folder { color: $--color-warning; }
          }
        }
        .item-name {
          padding: 10px;
          font-size: 12px;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
        }
      }
    }
  }
}
</style>
