# frozen_string_literal: true

RSpec.describe QA::Support::WaitForRequests do
  describe '.wait_for_requests' do
    before do
      allow(subject).to receive(:finished_all_ajax_requests?).and_return(true)
      allow(subject).to receive(:finished_loading?).and_return(true)
    end

    context 'when skip_finished_loading_check is defaulted to false' do
      it 'calls finished_loading?' do
        expect(subject).to receive(:finished_loading?).with(hash_including(wait: 1))

        subject.wait_for_requests
      end
    end

    context 'when skip_finished_loading_check is true' do
      it 'does not call finished_loading?' do
        expect(subject).not_to receive(:finished_loading?)

        subject.wait_for_requests(skip_finished_loading_check: true)
      end
    end

    context 'when skip_resp_code_check is defaulted to false' do
      it 'call report' do
        allow(QA::Support::PageErrorChecker).to receive(:check_page_for_error_code).with(Capybara.page)

        subject.wait_for_requests
      end
    end

    context 'when skip_resp_code_check is true' do
      it 'does not parse for an error code' do
        expect(QA::Support::PageErrorChecker).not_to receive(:check_page_for_error_code)

        subject.wait_for_requests(skip_resp_code_check: true)
      end
    end
  end
end
