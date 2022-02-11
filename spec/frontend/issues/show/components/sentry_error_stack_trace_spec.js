import Vue from 'vue';
import { GlLoadingIcon } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import Vuex from 'vuex';
import Stacktrace from '~/error_tracking/components/stacktrace.vue';
import SentryErrorStackTrace from '~/issues/show/components/sentry_error_stack_trace.vue';

describe('Sentry Error Stack Trace', () => {
  let actions;
  let getters;
  let store;
  let wrapper;

  Vue.use(Vuex);

  function mountComponent({
    stubs = {
      stacktrace: Stacktrace,
    },
  } = {}) {
    wrapper = shallowMount(SentryErrorStackTrace, {
      stubs,
      store,
      propsData: {
        issueStackTracePath: '/stacktrace',
      },
    });
  }

  beforeEach(() => {
    actions = {
      startPollingStacktrace: () => {},
    };

    getters = {
      stacktrace: () => [{ context: [1, 2], lineNo: 53, filename: 'index.js' }],
    };

    const state = {
      stacktraceData: {},
      loadingStacktrace: true,
    };

    store = new Vuex.Store({
      modules: {
        details: {
          namespaced: true,
          actions,
          getters,
          state,
        },
      },
    });
  });

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
    }
  });

  describe('loading', () => {
    it('should show spinner while loading', () => {
      mountComponent();
      expect(wrapper.find(GlLoadingIcon).exists()).toBe(true);
      expect(wrapper.find(Stacktrace).exists()).toBe(false);
    });
  });

  describe('Stack trace', () => {
    beforeEach(() => {
      store.state.details.loadingStacktrace = false;
    });

    it('should show stacktrace', () => {
      mountComponent({ stubs: {} });
      expect(wrapper.find(GlLoadingIcon).exists()).toBe(false);
      expect(wrapper.find(Stacktrace).exists()).toBe(true);
    });
  });
});
