<template>
<div class="tags-input">
  <div class="tag-item"
      v-for="(item, idx) of list"
      :key="idx"
      :class="['form-group', state_class(item, 'title')]">
    <input v-if="item.id" type="hidden" :name="`${name}[${idx}][id]`" :value="item.id">

    <div class="field-title">
      <input v-model="item.title" class="form-control" type="text" :name="`${name}[${idx}][title]`">
      <span class="help-block" v-for="(e, eidx) of field_errors(item, 'title')" :key="eidx">{{ e }}</span>
    </div>

    <div class="btn btn-warning btn-flat" @click="delete_tag(idx)">删除</div>
  </div>

  <div class="add-tag">
    <div class="btn btn-primary btn-flat" @click="add_tag">增加</div>
  </div>
</div>
</template>

<script>
import { get as _get } from 'lodash'

export default {
  data () {
    return {
      list: [],
      name: ''
    }
  },

  methods: {
    state_class (item, field) {
      if (item.action) {
        return _get(item, ['errors', field], null) ? 'has-error' : 'has-success'
      } else {
        return null
      }
    },

    field_errors (item, field) {
      return _get(item, ['errors', field], [])
    },

    add_tag () {
      this.list.push({ title: '' })
    },

    delete_tag (idx) {
      this.list.splice(idx, 1)
    }
  }
}
</script>

<style lang="scss" scoped>
.tags-input {
  .tag-item {
    display: flex;
    align-items: flex-start;
    .field-title {
      margin-right: 20px;
      flex: 1 1 auto;
    }
  }
  .help-block {
    margin-bottom: 0;
  }
}
</style>
