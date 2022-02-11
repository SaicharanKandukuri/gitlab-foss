# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Metrics::Exporter::BaseExporter do
  let(:settings) { double('settings') }
  let(:log_enabled) { false }
  let(:exporter) { described_class.new(settings, log_enabled: log_enabled, log_file: 'test_exporter.log') }

  describe 'when exporter is enabled' do
    before do
      allow(::WEBrick::HTTPServer).to receive(:new).with(
        Port: anything,
        BindAddress: anything,
        Logger: anything,
        AccessLog: anything
      ).and_call_original

      allow(settings).to receive(:enabled).and_return(true)
      allow(settings).to receive(:port).and_return(0)
      allow(settings).to receive(:address).and_return('127.0.0.1')
    end

    after do
      exporter.stop
    end

    describe 'when exporter is stopped' do
      describe '#start' do
        it 'starts the exporter' do
          expect_any_instance_of(::WEBrick::HTTPServer).to receive(:start)

          expect { exporter.start.join }.to change { exporter.thread? }.from(false).to(true)
        end

        describe 'with custom settings' do
          let(:port) { 99999 }
          let(:address) { 'sidekiq_exporter_address' }

          before do
            allow(settings).to receive(:port).and_return(port)
            allow(settings).to receive(:address).and_return(address)
          end

          it 'starts server with port and address from settings' do
            expect(::WEBrick::HTTPServer).to receive(:new).with(
              Port: port,
              BindAddress: address,
              Logger: anything,
              AccessLog: anything
            ).and_wrap_original do |m, *args|
              m.call(DoNotListen: true, Logger: args.first[:Logger])
            end

            allow_any_instance_of(::WEBrick::HTTPServer).to receive(:start)

            exporter.start.join
          end

          context 'logging enabled' do
            let(:log_enabled) { true }
            let(:logger) { instance_double(WEBrick::Log) }

            before do
              allow(logger).to receive(:time_format=)
              allow(logger).to receive(:info)
            end

            it 'configures a WEBrick logger with the given file' do
              expect(WEBrick::Log).to receive(:new).with(end_with('test_exporter.log')).and_return(logger)

              exporter
            end

            it 'logs any errors during startup' do
              expect(::WEBrick::Log).to receive(:new).and_return(logger)
              expect(::WEBrick::HTTPServer).to receive(:new).and_raise 'fail'
              expect(logger).to receive(:error)

              exporter.start
            end
          end

          context 'logging disabled' do
            it 'configures a WEBrick logger with the null device' do
              expect(WEBrick::Log).to receive(:new).with(File::NULL).and_call_original

              exporter
            end
          end
        end

        describe 'when thread is not alive' do
          it 'does close listeners' do
            expect_any_instance_of(::WEBrick::HTTPServer).to receive(:start)
            expect_any_instance_of(::WEBrick::HTTPServer).to receive(:listeners)
              .and_call_original

            expect { exporter.start.join }.to change { exporter.thread? }.from(false).to(true)

            exporter.stop
          end
        end
      end

      describe '#stop' do
        it "doesn't shutdown stopped server" do
          expect_any_instance_of(::WEBrick::HTTPServer).not_to receive(:shutdown)

          expect { exporter.stop }.not_to change { exporter.thread? }
        end
      end
    end

    describe 'when exporter is running' do
      before do
        exporter.start
      end

      describe '#start' do
        it "doesn't start running server" do
          expect_any_instance_of(::WEBrick::HTTPServer).not_to receive(:start)

          expect { exporter.start }.not_to change { exporter.thread? }
        end
      end

      describe '#stop' do
        it 'shutdowns server' do
          expect_any_instance_of(::WEBrick::HTTPServer).to receive(:shutdown)

          expect { exporter.stop }.to change { exporter.thread? }.from(true).to(false)
        end
      end
    end
  end

  describe 'request handling' do
    using RSpec::Parameterized::TableSyntax

    let(:fake_collector) do
      Class.new do
        def initialize(app, ...)
          @app = app
        end

        def call(env)
          @app.call(env)
        end
      end
    end

    where(:method_class, :path, :http_status) do
      Net::HTTP::Get | '/metrics' | 200
      Net::HTTP::Get | '/liveness' | 200
      Net::HTTP::Get | '/readiness' | 200
      Net::HTTP::Get | '/' | 404
    end

    before do
      allow(settings).to receive(:enabled).and_return(true)
      allow(settings).to receive(:port).and_return(0)
      allow(settings).to receive(:address).and_return('127.0.0.1')

      stub_const('Gitlab::Metrics::Exporter::MetricsMiddleware', fake_collector)

      # We want to wrap original method
      # and run handling of requests
      # in separate thread
      allow_any_instance_of(::WEBrick::HTTPServer)
        .to receive(:start).and_wrap_original do |m, *args|
        Thread.new do
          m.call(*args)
        rescue IOError
          # is raised as we close listeners
        end
      end
    end

    after do
      exporter.stop
    end

    with_them do
      let(:config) { exporter.server.config }
      let(:request) { method_class.new(path) }

      subject(:response) do
        http = Net::HTTP.new(config[:BindAddress], config[:Port])
        http.request(request)
      end

      it 'responds with proper http_status' do
        exporter.start.join

        expect(response.code).to eq(http_status.to_s)
      end

      it 'collects request metrics' do
        expect_next_instance_of(fake_collector) do |instance|
          expect(instance).to receive(:call).and_call_original
        end

        exporter.start.join
        response
      end
    end
  end

  describe 'when exporter is disabled' do
    before do
      allow(settings).to receive(:enabled).and_return(false)
    end

    describe '#start' do
      it "doesn't start" do
        expect_any_instance_of(::WEBrick::HTTPServer).not_to receive(:start)

        expect(exporter.start).to be_nil
        expect { exporter.start }.not_to change { exporter.thread? }
      end
    end

    describe '#stop' do
      it "doesn't shutdown" do
        expect_any_instance_of(::WEBrick::HTTPServer).not_to receive(:shutdown)

        expect { exporter.stop }.not_to change { exporter.thread? }
      end
    end
  end
end
