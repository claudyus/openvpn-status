<template>
  <v-app>
    <v-navigation-drawer temporary hide-overlay fixed v-model="drawer" class="text-xs-center" app>
      <v-list class="pt-0" dense>
        <v-list-tile v-for="srv in servers" :key="srv.id" :to="`/${srv.id}`">
          <v-list-tile-action>
            <v-icon>storage</v-icon>
          </v-list-tile-action>
          <v-list-tile-content>
            <v-list-tile-title>{{srv.name}}</v-list-tile-title>
          </v-list-tile-content>
        </v-list-tile>
      </v-list>
    </v-navigation-drawer>
    <v-toolbar fixed app>
      <v-toolbar-title>
        <v-toolbar-side-icon @click.stop="drawer = !drawer" v-if="servers.length > 1"></v-toolbar-side-icon>
        <span>{{(server ? server.name : '')}}</span>
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <v-text-field
        prepend-inner-icon="search"
        single-line
        :append-icon="(search.length ? 'clear' : '')"
        ref="searchField"
        @click:append="search = ''"
        @keyup.esc="search = ''"
        v-model="search"
      ></v-text-field>
      </v-toolbar-items>
    </v-toolbar>
    <v-content>
      <clients></clients>
      <events></events>
    </v-content>
    <v-footer app fixed>
      <v-flex>
        <v-card>
          <v-card-actions class="justify-center">
            <v-tooltip top>
              <span slot="activator">Server time: {{serverTime}}</span>
              <span>Server time</span>
            </v-tooltip>
            <v-spacer></v-spacer>
            <v-btn id="btn-github" flat icon href="https://github.com/AuspeXeu/openvpn-status" target="_blank" rel="noopener" small>
              <v-icon>fab fa-github</v-icon>
            </v-btn>
            <div class="noselect pr-2">© {{ new Date().getFullYear() }}</div>
          </v-card-actions>
        </v-card>
      </v-flex>
    </v-footer>
  </v-app>
</template>

<script>
import moment from 'moment'
import {mapState} from 'vuex'
import Clients from './components/Clients.vue'
import Events from './components/Events.vue'

export default {
  name: 'App',
  components: {
    Clients,
    Events
  },
  data() {
    return {
      snack: {
        visible: false,
        timeout: 3000,
        color: 'success',
        text: ''
      },
      search: '',
      drawer: false
    }
  },
  created() {
    window.addEventListener('keydown', this.onKeyDown)
  },
  computed: mapState({
    event: 'event',
    serverTime: state => moment(state.serverTime * 1000).format('DD.MM.YY - HH:mm:ss'),
    server: state => state.servers.find(srv => srv.id === state.server),
    servers: 'servers'
  }),
  methods: {
    notify(text, type) {
      this.snack.text = text
      this.snack.color = type
      this.snack.multi = type === 'error'
      this.snack.visible = true
    },
    onKeyDown(ev) {
      if (ev.keyCode === 70 && (ev.ctrlKey || ev.metaKey)) {
        ev.preventDefault()
        this.$refs.searchField.focus()
      }
    }
  },
  watch: {
    server() {
      this.drawer = false
      this.search = ''
    },
    event(value) {
      const map = new Map([['connect', 'success'], ['disconnect', 'error'], ['reconnect', 'info']])
      this.notify(`${value.node} ${value.event}ed`, map.get(value.event) || 'cyan darken-2')
    },
    search(value) {
      this.$store.commit('changeSearch', {text: value || ''})
    }
  }
}
</script>
