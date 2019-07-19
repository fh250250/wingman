<template>
<div class="media-center nav-tabs-custom">
  <ul class="nav nav-tabs">
    <li class="active"><a href="#media_center_media" data-toggle="tab">媒体库</a></li>
    <li><a href="#media_center_task" data-toggle="tab">任务列表</a></li>
  </ul>

  <div class="tab-content">
    <div id="media_center_media" class="tab-pane active">
      <media-list/>
    </div>
    <div id="media_center_task" class="tab-pane">
      <task-list/>
    </div>
  </div>
</div>
</template>

<script>
import MediaList from './media_list'
import TaskList from './task_list'

export default {
  components: { MediaList, TaskList }
}
</script>
