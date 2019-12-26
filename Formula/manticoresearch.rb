class Manticoresearch < Formula
  desc "Open source text search engine"
  homepage "https://www.manticoresearch.com"
  url "https://github.com/manticoresoftware/manticoresearch/releases/download/3.2.2/manticore-3.2.2-191226-afd6046-release.tar.gz"
  sha256 "7942ae4d3484b125b9c336b75d751ac9b71b71f9f60ead9272be84ee69bb5e6f"
  head "https://github.com/manticoresoftware/manticoresearch.git"

  bottle do
    root_url "http://dev.manticoresearch.com/bottles"
    sha256 "e6a17fc5360bfd1f42e5981f0459c1ac807fc4aacccbaaf76ba610a5e651dee3" => :mojave
  end

  depends_on "cmake" => :build
  depends_on "libpq" => :build
  depends_on "icu4c" => :build
  depends_on "mysql" => :build
  depends_on "unixodbc" => :build
  depends_on "openssl@1.1"

  conflicts_with "sphinx",
   :because => "manticore, sphinx install the same binaries."

  def install
    args = %W[
      -DCMAKE_INSTALL_LOCALSTATEDIR=#{var}
      -DDISTR_BUILD=macosbrew
    ]
    mkdir "build" do
      system "cmake", "..", *std_cmake_args, *args
      system "make", "install"
    end
  end

  def post_install
    (var/"run/manticore").mkpath
    (var/"log/manticore").mkpath
    (var/"data/manticore").mkpath
  end

  plist_options :manual => "searchd --config #{HOMEBREW_PREFIX}/etc/manticore/sphinx.conf"

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
            <string>#{etc}/manticore/sphinx.conf</string>
            <string>--nodetach</string>
        </array>
        <key>WorkingDirectory</key>
        <string>#{HOMEBREW_PREFIX}</string>
      </dict>
    </plist>
  EOS
  end

  test do
    (testpath/"sphinx.conf").write <<~EOS
      searchd {
        pid_file = searchd.pid
        binlog_path=#
      }
    EOS
    system bin/"searchd"
    pid = fork do
      exec bin/"searchd"
    end
  ensure
    Process.kill(9, pid)
    Process.wait(pid)
  end
end
