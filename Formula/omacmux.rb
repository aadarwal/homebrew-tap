class Omacmux < Formula
  desc "Agent-first IDE built on tmux — AI agents as first-class panes"
  homepage "https://github.com/aadarwal/omacmux"
  url "https://github.com/aadarwal/omacmux/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "7be69a4fe6a3d54efe17f643de8e753108d777acd7d1a249cbc9a43e59707b77"
  license "MIT"
  head "https://github.com/aadarwal/omacmux.git", branch: "master"

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
    # Install everything into libexec; the CLI script resolves OMACMUX_ROOT
    # by walking the symlink chain back to its parent, so siblings (links.sh,
    # config/, shell/, mesh/, Brewfile) need to live next to bin/omacmux.
    libexec.install Dir["*"]
    bin.install_symlink libexec/"bin/omacmux"
  end

  def caveats
    <<~EOS
      omacmux is installed. To set up your config files, run:

        omacmux init

      This interactively links tmux, neovim, bash, and other configs.
      Existing files are backed up before any changes.

      Useful commands:

        omacmux status     # show current state of all config links
        omacmux doctor     # check installation health
        omacmux unlink     # remove all configs, restore backups

      For the Nerd Font (terminal icons), install separately:

        brew install --cask font-jetbrains-mono-nerd-font
    EOS
  end

  test do
    assert_match "agent-first IDE", shell_output("#{bin}/omacmux help")
  end
end
