class Manticoresearch < Formula
  desc "Open source text search engine"
  homepage "https://www.manticoresearch.com"
  url "https://github.com/manticoresoftware/manticoresearch/releases/download/3.1.2/manticore-3.1.2-190822-47b6bc2-release.tar.gz"
  version "3.1.2"
  sha256 "6ca1cb0d39aff7a4fa2a13da362a9106ff16c75bb4a89bc8e4f327ce2bbad2a9"
  head "https://github.com/manticoresoftware/manticoresearch.git"

  bottle do
    root_url "http://dev.manticoresearch.com/bottles"
    sha256 "5604b8183e2d006ce0c34ab415dcccb1f8f2b58d299390ee5e440a42f8dcf20e" => :mojave
  end

  depends_on "cmake" => :build
  depends_on "icu4c" => :build
  depends_on "libpq" => :build
  depends_on "mysql@5.7" => :build
  depends_on "unixodbc" => :build
  depends_on "openssl"

  conflicts_with "sphinx",
   :because => "manticore,sphinx install the same binaries."

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
            <string>--nodetach</string>
        </array>
        <key>WorkingDirectory</key>
        <string>#{HOMEBREW_PREFIX}</string>
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
