<template>
<el-dialog
    :visible.sync="visible"
    title="移动目录"
    width="500px"
    class="move-folder-dialog"
    append-to-body
    :close-on-click-modal="!loading"
    :close-on-press-escape="!loading"
    :show-close="!loading">
  <el-tree
      v-if="visible"
      node-key="id" lazy
      :props="{ label: 'name', isLeaf: 'leaf' }"
      :load="load_node"
      @node-click="handle_node_click">
    <div class="custom-tree-node" slot-scope="scope">
      <span>{{ scope.data.name }}</span>
      <i v-if="dest_folder_id === scope.data.id" class="el-icon-success"/>
    </div>
  </el-tree>

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
      folder_id: null,
      dest_folder_id: null
    }
  },

  methods: {
    open (folder) {
      this.folder_id = folder.id
      this.dest_folder_id = null
      this.visible = true
    },

    async load_node (node, resolve) {
      if (node.level === 0) {
        resolve([{ id: null, name: '根目录', leaf: false }])

        return
      }

      const { data } = await axios.post('/storage/ls-folders', {
        folder_id: node.data ? node.data.id : null
      })

      const list = data.filter(item => item.id !== this.folder_id)
                      .map(item => ({
                        id: item.id,
                        name: item.name,
                        leaf: 1 === (item.rgt - item.lft)
                      }))
                      .sort((a, b) => a.name.localeCompare(b.name))

      resolve(list)
    },

    handle_node_click (data) {
      this.dest_folder_id = data.id
    },

    async submit () {
      this.loading = true
      const { data } = await axios.post('/storage/move-folder', {
        folder_id: this.folder_id,
        dest_folder_id: this.dest_folder_id
      })
      this.loading = false

      if (data.errors) {
        this.$helper.json_error_message(data.errors)
      } else {
        this.$message.success('移动目录成功')
        this.visible = false
        this.$parent.load()
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.move-folder-dialog {
  .custom-tree-node {
    display: flex;
    align-items: center;
    .el-icon-success {
      color: $--color-success;
      margin-left: 10px;
      font-size: 16px;
    }
  }
}
</style>
