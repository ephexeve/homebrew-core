class I2p < Formula
  desc "Anonymous overlay network - a network within a network"
  homepage "https://geti2p.net"
  url "https://download.i2p2.de/releases/0.9.25/i2pinstall_0.9.25.jar"
  sha256 "47c9d361940fc429effd57cc6718d72fde7a66663d5dfbb18fa30aba569b69fc"

  bottle :unneeded

  depends_on :java => "1.6+"

  def install
    (buildpath/"path.conf").write "INSTALL_PATH=#{libexec}"

    system "java", "-jar", "i2pinstall_#{version}.jar", "-options", "path.conf"

    wrapper_name = "i2psvc-macosx-universal-#{MacOS.prefer_64_bit? ? 64 : 32}"
    libexec.install_symlink libexec/wrapper_name => "i2psvc"
    bin.write_exec_script Dir["#{libexec}/{eepget,i2prouter}"]
    man1.install Dir["#{libexec}/man/*"]
  end

  test do
    wrapper_pid = fork do
      exec "#{bin}/i2prouter console"
    end
    router_pid = 0
    sleep 5

    begin
      status = shell_output("#{bin}/i2prouter status")
      assert_match(/I2P Service is running/, status)
      /PID:(\d+)/ =~ status
      router_pid = Regexp.last_match(1)
    ensure
      Process.kill("SIGINT", router_pid.to_i) unless router_pid.nil?
      Process.kill("SIGINT", wrapper_pid)
      Process.wait(wrapper_pid)
    end
  end
end
