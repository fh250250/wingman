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
    ref="tree"
    node-key="id"
    :data="tree"
    :props="{ label: 'name', children: 'children' }"
    highlight-current/>

  <div slot="footer">
    <el-button type="primary" :loading="loading" @click="submit">提交</el-button>
  </div>
</el-dialog>
</template>

<script>
import axios from 'axios'
import { find as _find } from 'lodash'

export default {
  data () {
    return {
      visible: false,
      loading: false,
      tree: [],
      id: null
    }
  },

  methods: {
    async load_tree () {
      const { data: { folders: list } } = await axios.get('/media/folders')
      const root = _find(list, item => item.parent_id === null)

      this.tree = [this.build_tree_node(list, { ...root, name: '根目录' })]
    },

    build_tree_node (list, node) {
      const children = list.filter(item => item.parent_id === node.id && item.id !== this.id)

      if (children.length) {
        node.children = children.map(item => this.build_tree_node(list, item))
                                .sort((a, b) => a.name.localeCompare(b.name))
      }

      return node
    },

    open (folder) {
      this.id = folder.id
      this.visible = true
      this.load_tree()

      if (this.$refs.tree) {
        this.$refs.tree.setCurrentKey(null)
      }
    },

    async submit () {
      const selected_folder = this.$refs.tree.getCurrentNode()

      if (!selected_folder) { return }

      this.loading = true
      const { data } = await axios.post('/media/folder', {
        id: this.id,
        folder: { parent_id: selected_folder.id }
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
  /deep/ .el-tree--highlight-current .el-tree-node.is-current > .el-tree-node__content {
    background-color: #3c8dbc;
    color: white;
  }
}
</style>
