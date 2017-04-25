if Gem::Version.new(Facter::FACTERVERSION) < Gem::Version.new('3.0')
  require 'facter/util/ip'

  Facter.add("default_interface") do
    confine :kernel => :linux
    setcode do
      def_interface = nil
      routes = File.read('/proc/net/route')
      routes.split("\n").each do |line|
        parts = line.split
        if parts[1] == "00000000"
          def_interface = Facter::Util::IP.alphafy(parts[0])
          break
        end
      end
      def_interface
    end
  end

  Facter.add("default_ipaddress") do
    confine :kernel => :linux
    setcode do
      def_ipaddress = nil
      def_interface = Facter.fact(:default_interface).value
      if def_interface
        def_ipaddress = Facter.value("ipaddress_#{def_interface}")
      end
      def_ipaddress
    end
  end
end
