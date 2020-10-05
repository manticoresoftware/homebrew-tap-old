class Manticoresearch < Formula
  desc "Open source text search engine"
  homepage "https://www.manticoresearch.com"
  url "https://repo.manticoresearch.com/repository/manticoresearch_source/release/manticore-3.5.2-201002-8b2c175-release-source.tar.gz"
  version "3.5.2"
  sha256 "9eb41e68d422a9e0043415ffc5e2f6d39e8d94eae9c843b4b55b54eacc33a517"

  depends_on "cmake" => :build
  depends_on "icu4c" => :build
  depends_on "libpq" => :build
  depends_on "mysql" => :build
  depends_on "boost"=> :build
  depends_on "openssl@1.1"

  conflicts_with "sphinx",
   :because => "manticore, sphinx install the same binaries."

  def install
    args = %W[
      -DCMAKE_INSTALL_LOCALSTATEDIR=#{var}
      -DDISTR_BUILD=macosbrew
      -DBoost_NO_BOOST_CMAKE=ON
      -DWITH_ODBC=OFF
    ]
    mkdir "build" do
      system "cmake", "..", *std_cmake_args, *args
      system "make", "install"
    end
  end

  def post_install
    (var/"run/manticore").mkpath
    (var/"log/manticore").mkpath
    (var/"manticore/data").mkpath
  end

  plist_options :manual => "searchd --config #{HOMEBREW_PREFIX}/etc/manticore/manticore.conf"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <false/>
        <key>ProgramArguments</key>
        <array>
            <string>#{opt_bin}/searchd</string>
            <string>--config</string>
            <string>#{etc}/manticore/manticore.conf</string>
            <string>--nodetach</string>
        </array>
        <key>WorkingDirectory</key>
        <string>#{HOMEBREW_PREFIX}</string>
      </dict>
    </plist>
  EOS
  end

  test do
    (testpath/"manticore.conf").write <<~EOS
      searchd {
        pid_file = searchd.pid
        binlog_path=#
      }
    EOS
    pid = fork do
      exec bin/"searchd"
    end
  ensure
    Process.kill(9, pid)
    Process.wait(pid)
  end
end
