OS := $(shell uname)

CPPFLAGS = -I./brotli/c/include/ -I./src -I./include

AR ?= ar
CC ?= gcc
CXX ?= g++

# It's helpful to be able to turn these off for fuzzing
CANONICAL_PREFIXES ?= -no-canonical-prefixes
NOISY_LOGGING ?= -DFONT_COMPRESSION_BIN
COMMON_FLAGS = -static -static-libgcc -static-libstdc++ -fno-omit-frame-pointer $(CANONICAL_PREFIXES) $(NOISY_LOGGING) -D __STDC_FORMAT_MACROS
LFLAGS += -static -static-libgcc -static-libstdc++

ARFLAGS = crf

ifeq ($(OS), Darwin)
  CPPFLAGS += -DOS_MACOSX
  ARFLAGS = cr
else
  COMMON_FLAGS += -fno-tree-vrp
endif


CFLAGS += $(COMMON_FLAGS)
CXXFLAGS += $(COMMON_FLAGS) -std=c++11

SRCDIR = src

OUROBJ = font.o glyph.o normalize.o table_tags.o transform.o \
         woff2_dec.o woff2_enc.o woff2_common.o woff2_out.o \
         variable_length.o

BROTLI = brotli
BROTLIOBJ = $(BROTLI)/bin/obj/c
ENCOBJ = $(BROTLIOBJ)/enc/*.o
DECOBJ = $(BROTLIOBJ)/dec/*.o
COMMONOBJ = $(BROTLIOBJ)/common/*.o

OBJS = $(patsubst %, $(SRCDIR)/%, $(OUROBJ))
EXECUTABLES=woff2
EXE_OBJS=$(patsubst %, $(SRCDIR)/%.o, $(EXECUTABLES))
ARCHIVES=convert_woff2ttf_fuzzer convert_woff2ttf_fuzzer_new_entry
ARCHIVE_OBJS=$(patsubst %, $(SRCDIR)/%.o, $(ARCHIVES))

ifeq (,$(wildcard $(BROTLI)/*))
  $(error Brotli dependency not found : you must initialize the Git submodule)
endif

all : $(OBJS) $(EXECUTABLES) $(ARCHIVES)

$(ARCHIVES) : $(ARCHIVE_OBJS) $(OBJS) deps
	$(AR) $(ARFLAGS) $(SRCDIR)/$@.a $(OBJS) \
	      $(COMMONOBJ) $(ENCOBJ) $(DECOBJ) $(SRCDIR)/$@.o

$(EXECUTABLES) : $(EXE_OBJS) deps
	$(CXX) $(LFLAGS) $(OBJS) $(COMMONOBJ) $(ENCOBJ) $(DECOBJ) $(SRCDIR)/$@.o -o $@

deps :
	$(MAKE) -C $(BROTLI) lib

clean :
	rm -f $(OBJS) $(EXE_OBJS) $(EXECUTABLES)
	$(MAKE) -C $(BROTLI) clean
