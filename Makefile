DIR_INC := ./inc
DIR_SRC := ./src
DIR_OBJ := ./obj

PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
INCLUDE_DIRS ?=
LIBRARY_DIRS ?=

SRC := $(wildcard ${DIR_SRC}/*.cpp)
OBJ := $(patsubst %.cpp,${DIR_OBJ}/%.o,$(notdir ${SRC}))

TARGET := fastp

BIN_TARGET := ${TARGET}

CXX ?= g++
LINKER ?= g++

CXXFLAGS := -std=c++11 -pthread -g -O3 -I${DIR_INC} $(foreach includedir,$(INCLUDE_DIRS),-I$(includedir)) $(CPPFLAGS) ${CXXFLAGS}
LIBS := -lisal -ldeflate -lpthread
STATIC_FLAGS := -static -Wl,--no-as-needed -pthread
LD_FLAGS := $(foreach librarydir,$(LIBRARY_DIRS),-L$(librarydir)) $(LDFLAGS) $(LD_FLAGS)
STATIC_LD_FLAGS := $(foreach librarydir,$(LIBRARY_DIRS),-L$(librarydir)) $(STATIC_FLAGS) $(LDFLAGS) $(STATIC_LD_FLAGS)

#${BIN_TARGET}:${OBJ}
#	$(CXX) $(OBJ) -o $@ $(LD_FLAGS)

.PHONY : all

all: fastp

fastp : obj ${OBJ}
	${LINKER} ${LD_FLAGS} -o $@ ${filter-out obj %.a %.so, $^} ${LIBS}
obj:
	mkdir obj

static:${OBJ}
	$(CXX) $(OBJ) -o ${BIN_TARGET} $(STATIC_LD_FLAGS) ${LIBS}

${DIR_OBJ}/%.o : ${DIR_SRC}/%.cpp
	$(CXX) -c $< -o $@ $(CXXFLAGS)


.PHONY:clean
.PHONY:static

clean:
	@if test -d $(DIR_OBJ) ; \
	then \
		find $(DIR_OBJ) -name *.o -delete; \
	fi
	@if test -e $(TARGET) ; \
	then \
		rm $(TARGET) ; \
	fi

make_obj_dir:
	@if test ! -d $(DIR_OBJ) ; \
	then \
		mkdir $(DIR_OBJ) ; \
	fi

install:
	install $(TARGET) $(BINDIR)/$(TARGET)
	@echo "Installed."
