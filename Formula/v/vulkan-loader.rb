class VulkanLoader < Formula
  desc "Vulkan ICD Loader"
  homepage "https://github.com/KhronosGroup/Vulkan-Loader"
  url "https://github.com/KhronosGroup/Vulkan-Loader/archive/refs/tags/v1.3.299.tar.gz"
  sha256 "32b268b140fa7a9eea46f25c83e0c86e5e9959dd85adea3807e332d0e19ce0f6"
  license "Apache-2.0"
  head "https://github.com/KhronosGroup/Vulkan-Loader.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 arm64_sequoia: "96efa9ed27f320527e963e3c44bcb840671d6f94f670f420ff12baaab6bf0a7e"
    sha256 arm64_sonoma:  "6a953846e3fb711d6cf73734d5df326055c355e2d71dc709ebbef58becf09ee7"
    sha256 arm64_ventura: "771b00ce91d5fec3393bccdc168db0363c049cc8aa092e933294f2388691dd80"
    sha256 sonoma:        "51d19f82bb932e54cbac413706d59f178eeca2127786eccf9cb457c53f0ae39b"
    sha256 ventura:       "21f10ad1b5dc8ff6ad444049f5dd2b1aef785641045ee7942685d2c1f671c81a"
    sha256 x86_64_linux:  "d7b8ea73b5eddc7ce28f823875c57948b86c89e0901d78a2ab18d27cc2ebe30c"
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "python@3.13" => :build
  depends_on "vulkan-headers"

  on_linux do
    depends_on "libxrandr" => :build
    depends_on "libx11"
    depends_on "libxcb"
    depends_on "wayland"
  end

  def install
    system "cmake", "-S", ".", "-B", "build",
                    "-DVULKAN_HEADERS_INSTALL_DIR=#{Formula["vulkan-headers"].prefix}",
                    "-DCMAKE_INSTALL_INCLUDEDIR=#{Formula["vulkan-headers"].include}",
                    "-DFALLBACK_DATA_DIRS=#{HOMEBREW_PREFIX}/share:/usr/local/share:/usr/share",
                    "-DCMAKE_INSTALL_SYSCONFDIR=#{etc}",
                    "-DFALLBACK_CONFIG_DIRS=#{etc}/xdg:/etc/xdg",
                    *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <vulkan/vulkan_core.h>
      int main() {
        uint32_t version;
        vkEnumerateInstanceVersion(&version);
        return (version >= VK_API_VERSION_1_1) ? 0 : 1;
      }
    EOS
    system ENV.cc, "-o", "test", "test.c", "-I#{Formula["vulkan-headers"].opt_include}",
                   "-L#{lib}", "-lvulkan"
    system "./test"
  end
end
