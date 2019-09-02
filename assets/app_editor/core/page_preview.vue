<template>
<div class="page-preview">
  <div class="page-preview-header">
    <div class="title">页面预览</div>
    <div class="save">保存</div>
  </div>

  <div class="page-preview-body">
    <div class="document-root">
      root
    </div>
  </div>
</div>
</template>

<style lang="scss" scoped>
.page-preview {
  height: 100%;
  display: flex;
  flex-direction: column;
  &-header {
    flex: 0 0 auto;
    font-size: 12px;
    padding: 5px 10px;
    background-color: #f0f0f0;
    border-bottom: 1px solid #ccc;
    user-select: none;
    display: flex;
    justify-content: space-between;
    .save {
      cursor: pointer;
      color: $--color-primary;
    }
  }
  &-body {
    flex: 1 1 auto;
    box-sizing: border-box;
    padding: 40px 80px;
    background-color: #fafafa;
  }
  .document-root {
    box-sizing: border-box;
    width: 375px;
    height: 100%;
    background-color: white;
    box-shadow: 0 0 20px 5px rgba(0, 0, 0, .2);
    border-radius: 5px;
    overflow: auto;
  }
}
</style>
