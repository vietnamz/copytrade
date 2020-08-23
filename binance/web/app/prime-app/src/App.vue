<template>
  <div id="app">
    <img alt="Vue logo" src="./assets/logo.png">
    <Home msg="Welcome to Your Vue.js + TypeScript App"/>
  </div>
</template>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator';
import Home from './components/Home.vue';

@Component({
  components: {
    Home,
  },
})
export default class App extends Vue {}
</script>

<style>
#app {
    color: #cccccc;
    background-color: #1a1a1a;
    text-align: center;
    font-family: "Courier New", Courier, monospace;
    font-size: 1.25em;
}
</style>
