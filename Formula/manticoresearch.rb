class Manticoresearch < Formula
  desc "Open source text search engine"
  homepage "https://www.manticoresearch.com"
  url "http://dev.manticoresearch.com/manticore-3.0.3-190613-43a3006.tar.gz"
  version "3.0.3"
  sha256 "52e924bb7b79ac59ccbd5832d209b101cdb8a63b8b8ef115ab0430654df8ea84"
  head "https://github.com/manticoresoftware/manticoresearch.git"
  depends_on "cmake" => :build
  depends_on "libpq" => :build
  depends_on "mysql-connector-c" => :build
  depends_on "unixodbc" => :build
  depends_on "openssl"
  conflicts_with "sphinx",
   :because => "manticore,sphinx install the same binaries."
  def datadir
    var/"manticore/data"
  end

  bottle do
    sha256 "7a1f85bb570a53aee8719b66b1dd8709ad323e59d221bf0bd08ada435dbf7d0f" => :sierra
  end

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
    datadir.mkpath
  end

  def caveats
    <<~EOS
      Config file is located at #{etc}/manticore/sphinx.conf
    EOS
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
        </array>
        <key>WorkingDirectory</key>
        <string>#{datadir}</string>
      </dict>
    </plist>
  EOS
  end
  test do
    begin
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
end
