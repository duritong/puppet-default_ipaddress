require 'spec_helper'
require 'facter/util/ip'

describe "ipaddress_default fact" do
  context "on Linux" do
    before :each do
      Facter.clear
    end

    def expect_def_ipaddress(address, iface, fixture)
      routes = my_fixture_read(fixture)

      original_read = File.method(:read)
      File.stubs(:read).with(anything()) { |*args| original_read.call(*args) }
      File.stubs(:read).with('/proc/net/route').returns(routes)

      Facter.stubs(:value).with("ipaddress_#{iface}").returns(address)
      Facter.fact(:kernel).stubs(:value).returns('Linux')

      expect(Facter.fact(:default_ipaddress).value).to eq(address)
      expect(Facter.fact(:default_interface).value).to eq(iface)
    end

    it "parses correctly on RHEL with some bond" do
      expect_def_ipaddress "10.0.0.1", 'bond0', "routes_rhel.txt"
    end

    it "parses correctly on RHEL (standard VM)" do
      expect_def_ipaddress "20.0.0.1", 'eth0', "routes_standard_vm.txt"
    end

    it "parses correctly on RHEL with vlan on bond" do
      expect_def_ipaddress "30.0.0.1", 'bond0_44', "routes_vlan_bond.txt"
    end

    it "parses correctly on RHEL VM with routes" do
      expect_def_ipaddress "40.0.0.1", 'eth0', "routes_vm_with_routes.txt"
    end
  end
end
