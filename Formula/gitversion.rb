class Gitversion < Formula
  desc "Easy semantic versioning for projects using Git"
  homepage "https://gitversion.net"
  url "https://github.com/GitTools/GitVersion/archive/5.6.11.tar.gz"
  sha256 "019aa795201d249929a179464d7f45d4c7b62c11b39146efe58b135d27d507c0"
  license "MIT"

  bottle do
    sha256 cellar: :any, big_sur:  "40640f290fe8127679c87abcc704592eebaf0eae52ca55fc20cb5d5faa37c72d"
    sha256 cellar: :any, catalina: "b004bbcba66e5dbf4dca5b66974e65f5b49e9a12b97724a91a2b029e0e4406f3"
    sha256 cellar: :any, mojave:   "85042a5e5f3791e1b07e9ee944c8a1217f3403836e7bac14793d1b37bb1fa906"
  end

  depends_on "dotnet"

  def install
    system "dotnet", "publish",
           "--configuration", "Release",
           "--framework", "net#{Formula["dotnet"].version.major_minor}",
           "--output", libexec,
           "src/GitVersion.App/GitVersion.App.csproj"

    (bin/"gitversion").write <<~EOS
      #!/bin/sh
      exec "#{Formula["dotnet"].opt_bin}/dotnet" "#{libexec}/gitversion.dll" "$@"
    EOS
  end

  test do
    # Circumvent GitVersion's build server detection scheme:
    ENV["GITHUB_ACTIONS"] = nil

    (testpath/"test.txt").write("test")
    system "git", "init"
    system "git", "config", "user.name", "Test"
    system "git", "config", "user.email", "test@example.com"
    system "git", "add", "test.txt"
    system "git", "commit", "-q", "--message='Test'"
    assert_match '"FullSemVer": "0.1.0+0"', shell_output("#{bin}/gitversion -output json")
  end
end
