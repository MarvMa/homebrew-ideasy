# typed: false
# frozen_string_literal: true

# Homebrew formula for IDEasy - Development Environment Automation Tool
# Homepage: https://github.com/devonfw/IDEasy
# License: Apache-2.0
#
# IDEasy automates the setup and updates of development environments for any project.
# It allows developers to set up a complete dev environment with a single CLI command
# on Windows, Mac, or Linux, getting all tools in the configured versions.

class Ideasy < Formula
  desc "Tool to automate the setup and updates of a development environment for any project"
  homepage "https://github.com/devonfw/IDEasy"
  license "Apache-2.0"
  version "2026.04.002"

  # Platform-specific downloads from Maven Central
  on_macos do
    on_arm do
      url "https://repo1.maven.org/maven2/com/devonfw/tools/IDEasy/ide-cli/#{version}/ide-cli-#{version}-mac-arm64.tar.gz"
      sha256 "c252864ce597cf0a0f23578a37cc4c2fd086974ae847c025289811c849f69bb8"
    end
    on_intel do
      url "https://repo1.maven.org/maven2/com/devonfw/tools/IDEasy/ide-cli/#{version}/ide-cli-#{version}-mac-x64.tar.gz"
      sha256 "91453d7314c39db60b0e45772755e6c288e205d2661fc1b5999e77c02653a104"
    end
  end

  on_linux do
    on_intel do
      url "https://repo1.maven.org/maven2/com/devonfw/tools/IDEasy/ide-cli/#{version}/ide-cli-#{version}-linux-x64.tar.gz"
      sha256 "5c7102b7a0405a03dd04cd1b92ef1007af41f5499af01cc0167d2b974c2b568b"
    end
  end

  depends_on "git"
  depends_on "bash"

  def install
    # IDEasy ships as a pre-built CLI distribution in a tar.gz archive.
    # The archive contains a bin/ directory with the 'ide' launcher script/binary
    # and a lib/ directory with supporting files.

    # Install all files from the extracted archive into the Homebrew prefix
    libexec.install Dir["*"]

    # Create a wrapper script in bin/ that points to the actual binary in libexec
    if File.exist?(libexec/"bin/ide")
      (bin/"ide").write_env_script libexec/"bin/ide",
        IDEASY_HOME: libexec.to_s
    elsif File.exist?(libexec/"ide")
      (bin/"ide").write_env_script libexec/"ide",
        IDEASY_HOME: libexec.to_s
    else
      # Fallback: find the main executable and link it
      Dir.glob(libexec/"**/*").select { |f| File.executable?(f) && File.basename(f) == "ide" }.each do |exe|
        (bin/"ide").write_env_script exe,
          IDEASY_HOME: libexec.to_s
      end
    end
  end

  def caveats
    <<~EOS
      IDEasy has been installed. To get started:

        1. Run 'ide --version' to verify the installation
        2. Run 'ide create <project-name>' to set up a new project
        3. Visit https://github.com/devonfw/IDEasy/blob/main/documentation/setup.adoc for full documentation

      Note: IDEasy requires 'git' to be installed (included as a dependency).

      For IDEasy to manage your development tools, it will create project-specific
      directories. See the documentation for details on the directory structure.
    EOS
  end

  test do
    # Verify the ide command is available and responds
    assert_match(/IDEasy|ide|version/i, shell_output("#{bin}/ide --version 2>&1", 0).strip)
  end
end
