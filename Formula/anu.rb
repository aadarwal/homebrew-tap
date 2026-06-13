class Anu < Formula
  desc "Research agent harness — AI agents as first-class terminal panes"
  homepage "https://michelangelo.sh"
  url "https://github.com/aadarwal/anu/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "5a792d8fdae85d02a67381d4749f35967bff30f9d61fcfc99c57e0452e6a5bc2"
  license "MIT"
  head "https://github.com/aadarwal/anu.git", branch: "master"

  depends_on "bash"
  depends_on "bat"
  depends_on "eza"
  depends_on "fd"
  depends_on "fzf"
  depends_on "gh"
  depends_on "jq"
  depends_on :macos
  depends_on "mise"
  depends_on "neovim"
  depends_on "ripgrep"
  depends_on "starship"
  depends_on "tmux"
  depends_on "tree"
  depends_on "zoxide"

  def install
    # The CLI resolves ANU_ROOT by walking the symlink chain back to its
    # parent, so all siblings (links.sh, config/, shell/, plugins/, bin/,
    # mesh/, box/, Brewfile) must live next to bin/anu.
    libexec.install Dir["*"]
    bin.install_symlink libexec/"bin/anu"
  end

  def caveats
    <<~EOS
      anu is installed. To set up your config files, run:

        anu init

      This interactively links tmux, neovim, bash, and other configs.
      Existing files are backed up before any changes.

      Useful commands:

        anu status     # show current state of all config links
        anu doctor     # check installation health
        anu unlink     # remove all configs, restore backups

      For the Nerd Font (terminal icons), install separately:

        brew install --cask font-jetbrains-mono-nerd-font
    EOS
  end

  test do
    assert_match "agent-first IDE", shell_output("#{bin}/anu help")
  end
end
