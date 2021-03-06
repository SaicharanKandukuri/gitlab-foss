import initDeprecatedRemoveRowBehavior from '~/behaviors/deprecated_remove_row_behavior';
import AjaxLoadingSpinner from '~/branches/ajax_loading_spinner';
import BranchSortDropdown from '~/branches/branch_sort_dropdown';
import initDiverganceGraph from '~/branches/divergence_graph';
import initDeleteBranchButton from '~/branches/init_delete_branch_button';
import initDeleteBranchModal from '~/branches/init_delete_branch_modal';

AjaxLoadingSpinner.init();

const { divergingCountsEndpoint, defaultBranch } = document.querySelector(
  '.js-branch-list',
).dataset;

initDiverganceGraph(divergingCountsEndpoint, defaultBranch);
BranchSortDropdown();
initDeprecatedRemoveRowBehavior();

document
  .querySelectorAll('.js-delete-branch-button')
  .forEach((elem) => initDeleteBranchButton(elem));

initDeleteBranchModal();
