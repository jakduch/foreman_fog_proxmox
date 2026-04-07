# frozen_string_literal: true

require 'test_plugin_helper'

module ForemanFogProxmox
  class ProxmoxOrchestrationComputeTest < ActiveSupport::TestCase
    class ComputeValueHost
      include Orchestration::Proxmox::Compute

      attr_accessor :compute_resource, :vm
    end

    test '#computeValue prefixes raw vmid for uuid' do
      host = host_with_vm_value('113')

      assert_equal '4_113', host.computeValue(:uuid, :foreman_uuid)
    end

    test '#computeValue does not prefix existing proxmox uuid' do
      host = host_with_vm_value('4_113')

      assert_equal '4_113', host.computeValue(:uuid, :foreman_uuid)
    end

    describe 'unmanaged host with Proxmox compute resource' do
      let(:cr) { FactoryBot.build_stubbed(:proxmox_cr) }
      let(:host) do
        FactoryBot.build(:host_empty,
          :managed => false,
          :compute_resource => cr,
          :compute_attributes => { 'type' => 'qemu' })
      end

      test 'setComputeUpdate skips orchestration for unmanaged host' do
        assert host.setComputeUpdate
      end

      test 'setComputeUpdate logs info when skipping for unmanaged host' do
        mock_logger = mock('logger')
        mock_logger.expects(:info).with(format("Skipping Proxmox compute update for %s - host is not managed", host.name))
        host.stubs(:logger).returns(mock_logger)
        host.setComputeUpdate
      end

      test 'delComputeUpdate skips orchestration for unmanaged host' do
        assert host.delComputeUpdate
      end

      test 'delComputeUpdate logs info when skipping for unmanaged host' do
        mock_logger = mock('logger')
        mock_logger.expects(:info).with(format("Skipping Proxmox compute update rollback for %s - host is not managed", host.name))
        host.stubs(:logger).returns(mock_logger)
        host.delComputeUpdate
      end

      test 'setComputeDetails skips orchestration for unmanaged host' do
        assert host.setComputeDetails
      end

      test 'setComputeDetails logs info when skipping for unmanaged host' do
        mock_logger = mock('logger')
        mock_logger.expects(:info).with(format("Skipping Proxmox compute details for %s - host is not managed", host.name))
        host.stubs(:logger).returns(mock_logger)
        host.setComputeDetails
      end
    end

    private

    def host_with_vm_value(value)
      host = ComputeValueHost.new
      host.compute_resource = OpenStruct.new(id: 4)
      host.vm = OpenStruct.new(foreman_uuid: value)
      host
    end
  end
end
