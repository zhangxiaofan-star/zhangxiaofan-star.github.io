---
title: 爱心粒子特效
sidebar: false
navbar: false
---

<div class="heart-page-wrapper">
  <HeartBackground />
</div>

<style scoped>
.heart-page-wrapper {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  z-index: 9999;
  overflow: hidden;
}
.heart-page-wrapper .heart-bg-wrapper {
  position: absolute !important;
  z-index: 1;
}
</style>
