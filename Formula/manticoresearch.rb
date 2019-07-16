class Manticoresearch < Formula
  desc "Open source text search engine"
  homepage "https://www.manticoresearch.com"
  url "https://github.com/manticoresoftware/manticoresearch/releases/download/3.1.0/manticore-3.1.0-190716-445e806-release.tar.gz"
  version "3.1.0"
  sha256 "b8eba31eea5f6f5cf7cb7986c94cb40904f96da99e178c724e7f0081de02388e"
  head "https://github.com/manticoresoftware/manticoresearch.git"
  
  depends_on "cmake" => :build
  depends_on "icu4c" => :build
  depends_on "libpq" => :build
  depends_on "mysql@5.7" => :build
  depends_on "unixodbc" => :build
  depends_on "openssl"
  conflicts_with "sphinx",
   :because => "manticore,sphinx install the same binaries."
  def datadir
    var/"manticore/data"
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
