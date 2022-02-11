import { shallowMount } from '@vue/test-utils';
import Vue, { nextTick } from 'vue';
import Vuex from 'vuex';
import GkeMachineTypeDropdown from '~/create_cluster/gke_cluster/components/gke_machine_type_dropdown.vue';
import createState from '~/create_cluster/gke_cluster/store/state';
import DropdownButton from '~/vue_shared/components/dropdown/dropdown_button.vue';
import DropdownHiddenInput from '~/vue_shared/components/dropdown/dropdown_hidden_input.vue';
import { selectedMachineTypeMock, gapiMachineTypesResponseMock } from '../mock_data';

const componentConfig = {
  fieldId: 'cluster_provider_gcp_attributes_gcp_machine_type',
  fieldName: 'cluster[provider_gcp_attributes][gcp_machine_type]',
};
const setMachineType = jest.fn();

const LABELS = {
  LOADING: 'Fetching machine types',
  DISABLED_NO_PROJECT: 'Select project and zone to choose machine type',
  DISABLED_NO_ZONE: 'Select zone to choose machine type',
  DEFAULT: 'Select machine type',
};

Vue.use(Vuex);

const createComponent = (store, propsData = componentConfig) =>
  shallowMount(GkeMachineTypeDropdown, {
    propsData,
    store,
  });

const createStore = (initialState = {}, getters = {}) =>
  new Vuex.Store({
    state: {
      ...createState(),
      ...initialState,
    },
    getters: {
      hasZone: () => false,
      ...getters,
    },
    actions: {
      setMachineType,
    },
  });

describe('GkeMachineTypeDropdown', () => {
  let wrapper;
  let store;

  afterEach(() => {
    wrapper.destroy();
  });

  const dropdownButtonLabel = () => wrapper.find(DropdownButton).props('toggleText');
  const dropdownHiddenInputValue = () => wrapper.find(DropdownHiddenInput).props('value');

  describe('shows various toggle text depending on state', () => {
    it('returns disabled state toggle text when no project and zone are selected', () => {
      store = createStore({
        projectHasBillingEnabled: false,
      });
      wrapper = createComponent(store);

      expect(dropdownButtonLabel()).toBe(LABELS.DISABLED_NO_PROJECT);
    });

    it('returns disabled state toggle text when no zone is selected', () => {
      store = createStore({
        projectHasBillingEnabled: true,
      });
      wrapper = createComponent(store);

      expect(dropdownButtonLabel()).toBe(LABELS.DISABLED_NO_ZONE);
    });

    it('returns loading toggle text', async () => {
      store = createStore();
      wrapper = createComponent(store);

      // setData usage is discouraged. See https://gitlab.com/groups/gitlab-org/-/epics/7330 for details
      // eslint-disable-next-line no-restricted-syntax
      wrapper.setData({ isLoading: true });

      await nextTick();
      expect(dropdownButtonLabel()).toBe(LABELS.LOADING);
    });

    it('returns default toggle text', () => {
      store = createStore(
        {
          projectHasBillingEnabled: true,
        },
        { hasZone: () => true },
      );
      wrapper = createComponent(store);

      expect(dropdownButtonLabel()).toBe(LABELS.DEFAULT);
    });

    it('returns machine type name if machine type selected', () => {
      store = createStore(
        {
          projectHasBillingEnabled: true,
          selectedMachineType: selectedMachineTypeMock,
        },
        { hasZone: () => true },
      );
      wrapper = createComponent(store);

      expect(dropdownButtonLabel()).toBe(selectedMachineTypeMock);
    });
  });

  describe('form input', () => {
    it('reflects new value when dropdown item is clicked', async () => {
      store = createStore({
        machineTypes: gapiMachineTypesResponseMock.items,
      });
      wrapper = createComponent(store);

      expect(dropdownHiddenInputValue()).toBe('');

      wrapper.find('.dropdown-content button').trigger('click');

      await nextTick();
      expect(setMachineType).toHaveBeenCalledWith(expect.anything(), selectedMachineTypeMock);
    });
  });
});
