#define main compress_main
#include "./woff2_compress.cc"
#undef main

#define main decompress_main
#include "./woff2_decompress.cc"
#undef main

#define main info_main
#include "./woff2_info.cc"
#undef main

int main(int argc, char **argv) {
  using std::string;

  if (argc == 3) {
    switch (argv[1][0] | 0x20) {
      case 'c': return compress_main(argc - 1, argv + 1);
      case 'd': return decompress_main(argc - 1, argv + 1);
      case 'i': return info_main(argc - 1, argv + 1);
    }
  }

  fprintf(stderr, "Usage:\nwoff2 i filename.woff2\nwoff2 c filename.ttf\nwoff2 d filename.woff2\n");
  return 1;
}
