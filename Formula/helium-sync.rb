class HeliumSync < Formula
  desc "Bidirectional sync of Helium browser bookmarks + saved tab groups via your private git repo"
  homepage "https://github.com/aadarwal/helium-sync"
  url "https://github.com/aadarwal/helium-sync/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "a797e3d9bf75f3f6ff71cc7b0b647f2845a543f60049ad4fcd381c516566f534"
  license "MIT"
  head "https://github.com/aadarwal/helium-sync.git", branch: "main"

  depends_on "leveldb"
  depends_on "protobuf"
  depends_on "python@3.13"

  resource "leveldb-writer" do
    on_arm do
      url "https://github.com/aadarwal/helium-sync/releases/download/v0.2.0/leveldb-writer-darwin-arm64"
      sha256 "6aaea4632a63b170f97f047621b0ebddc26865924e869db694664ad838ce9ab7"
    end

    on_intel do
      url "https://github.com/aadarwal/helium-sync/releases/download/v0.2.0/leveldb-writer-darwin-amd64"
      sha256 "f1115686af42a4812f6e4ed527cd5f4d531b4a52195208d1d3853226d0b719e5"
    end
  end

  def install
    # Drop everything into libexec; bin/ becomes a single symlink to the CLI.
    libexec.install Dir["*"]

    # Replace the committed (arm64-only) binary with the right-arch one.
    rm libexec/"bin/leveldb-writer"
    resource("leveldb-writer").stage do
      writer_files = Dir["*"]
      libexec_bin = libexec/"bin/leveldb-writer"
      libexec_bin.write File.binread(writer_files.first)
      libexec_bin.chmod 0755
    end

    # Build a venv inside libexec and install protobuf into it.
    # The CLI's auto-relaunch logic looks for .venv/bin/python3 next to its
    # parent dir (`_self.parent.parent / ".venv"`), which resolves correctly
    # under this layout.
    system Formula["python@3.13"].opt_bin/"python3.13", "-m", "venv", libexec/".venv"
    system libexec/".venv/bin/pip", "install", "--quiet", "-r", libexec/"requirements.txt"

    # Expose the CLI on PATH.
    bin.install_symlink libexec/"bin/helium-sync"
  end

  def caveats
    <<~EOS
      Run `helium-sync setup` once to configure your private data repo and
      bootstrap from your live Helium state.

      The CLI lives at:
        #{libexec}
      The wrapper symlink:
        #{bin}/helium-sync

      See the upstream README for the full setup walkthrough:
        #{homepage}
    EOS
  end

  test do
    # `helium-sync --help` exits 2 (argparse with required subcommand), but
    # we just want to confirm the binary launches and the venv is wired up.
    output = shell_output("#{bin}/helium-sync --help 2>&1", 2)
    assert_match "helium-sync", output
    assert_match "push", output
    assert_match "pull", output
    assert_match "setup", output
  end
end
