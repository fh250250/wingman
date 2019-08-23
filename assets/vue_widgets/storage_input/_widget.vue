<template>
<div class="storage-input">
  <input type="hidden" :name="form_name" :value="form_value">

  <div v-if="form_value" class="file-box" v-loading="loading">
    <div class="left">
      <el-image v-if="$helper.is_image(file.content_type)"
          :src="file.url"
          :preview-src-list="[file.url]"
          fit="cover"/>
      <i v-else class="el-icon-document"/>
    </div>
    <div class="right">
      <div>
        <div class="name" :title="file.name">{{ file.name }}</div>
        <div class="size">{{ $helper.human_readable_bytes(file.size) }}</div>
      </div>
      <div>
        <el-button icon="el-icon-edit" circle plain @click="find_file"/>
        <el-button type="danger" icon="el-icon-delete" circle plain @click="clear_file"/>
      </div>
    </div>
  </div>
  <div v-else class="no-file" @click="find_file">
    <i class="el-icon-plus"/>
  </div>
</div>
</template>

<script>
import axios from 'axios'

export default {
  data () {
    return {
      form_name: null,
      form_value: null,
      loading: false,
      file: {
        name: '',
        content_type: '',
        size: 0,
        url: ''
      }
    }
  },

  created () {
    this.load()
  },

  methods: {
    async load () {
      if (!this.form_value) { return }

      this.loading = true
      const { data } = await axios.get(`/storage/file/${this.form_value}`)
      this.loading = false

      this.file.name = data.name
      this.file.content_type = data.content_type
      this.file.size = data.size
      this.file.url = data.url
    },

    find_file () {
      window.storage_finder.open({ on_change: this.handle_file_change })
    },

    handle_file_change (file_id) {
      this.form_value = file_id

      this.load()
    },

    clear_file () {
      this.form_value = null
      this.file = {
        name: '',
        content_type: '',
        size: 0,
        url: ''
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.storage-input {
  .no-file {
    width: 200px;
    height: 100px;
    display: flex;
    justify-content: center;
    align-items: center;
    font-size: 48px;
    box-sizing: border-box;
    border: 1px dashed #ddd;
    color: #aaa;
    cursor: pointer;
    transition: all .3s;
    &:hover {
      border-color: $--color-primary;
      color: $--color-primary;
    }
  }
  .file-box {
    width: 350px;
    height: 120px;
    box-sizing: border-box;
    border: 1px solid #ddd;
    display: flex;
    > .left {
      flex: 0 0 120px;
      display: flex;
      justify-content: center;
      align-items: center;
      border-right: 1px solid #ddd;
      .el-image {
        display: block;
        width: 100%;
        height: 100%;
      }
      > i {
        font-size: 48px;
      }
    }
    > .right {
      flex: auto;
      padding: 10px;
      font-size: 12px;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
      .name {
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        margin-bottom: 5px;
      }
      .size {
        color: #aaa;
      }
    }
  }
}
</style>
