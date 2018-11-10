all: check_latest ci-deps test

TARGETDIR:=$(HOME)/toolchain
SOURCEDIR:=$(HOME)/src

test: 
	grep . $(TARGETDIR)/*.ver
	$(MAKE) -s -C verilog test
	$(MAKE) -C verilog/test BOARD=alhambra  hwbin
	$(MAKE) -C verilog/test BOARD=ice40hx8k hwbin

clean:
	$(MAKE) -C verilog clean
	$(MAKE) -C verilog/test BOARD=alhambra  clean
	$(MAKE) -C verilog/test BOARD=alhambra  hwclean
	$(MAKE) -C verilog/test BOARD=ice40hx8k clean
	$(MAKE) -C verilog/test BOARD=ice40hx8k hwclean
	rm -rf verilog/builddir

GIT_ICEST:=https://github.com/cliffordwolf/icestorm.git
GIT_YOSYS:=https://github.com/cliffordwolf/yosys.git
GIT_ARACH:=https://github.com/cseed/arachne-pnr.git
GIT_SYMBI:=https://github.com/cliffordwolf/SymbiYosys.git
GIT_YICES:=https://github.com/SRI-CSL/yices2.git

VER_ICEST:=$(TARGETDIR)/icestorm.ver
VER_YOSYS:=$(TARGETDIR)/yosys.ver
VER_ARACH:=$(TARGETDIR)/arachne-pnr.ver
VER_SYMBI:=$(TARGETDIR)/symbiyosys.ver
VER_YICES:=$(TARGETDIR)/yices2.ver

check_latest:
	[ -e $(VER_ICEST) ] && ( git ls-remote --heads $(GIT_ICEST) refs/heads/master | cut -f1 | cmp $(VER_ICEST) - || rm -f $(VER_ICEST) ) || true
	[ -e $(VER_YOSYS) ] && ( git ls-remote --heads $(GIT_YOSYS) refs/heads/master | cut -f1 | cmp $(VER_YOSYS) - || rm -f $(VER_YOSYS) ) || true
	[ -e $(VER_ARACH) ] && ( git ls-remote --heads $(GIT_ARACH) refs/heads/master | cut -f1 | cmp $(VER_ARACH) - || rm -f $(VER_ARACH) ) || true
	[ -e $(VER_SYMBI) ] && ( git ls-remote --heads $(GIT_SYMBI) refs/heads/master | cut -f1 | cmp $(VER_SYMBI) - || rm -f $(VER_SYMBI) ) || true
	[ -e $(VER_YICES) ] && ( git ls-remote --heads $(GIT_YICES) refs/heads/master | cut -f1 | cmp $(VER_YICES) - || rm -f $(VER_YICES) ) || true	

ci-deps: $(VER_ICEST) $(VER_YOSYS) $(VER_ARACH) $(VER_SYMBI) $(VER_YICES)

ifndef TRAVIS
  NPROC:= -j$(shell nproc)
endif

$(VER_ICEST):
	mkdir -p $(SOURCEDIR); cd $(SOURCEDIR) && \
	( [ -e icestorm ] || git clone $(GIT_ICEST) ) && \
	cd icestorm && \
	git pull && \
	git log -1 && \
	nice make $(NPROC) DESTDIR=$(TARGETDIR) PREFIX= install && \
	git rev-parse HEAD > $(VER_ICEST)

$(VER_YOSYS):
	mkdir -p $(SOURCEDIR); cd $(SOURCEDIR) && \
	( [ -e yosys ] || git clone $(GIT_YOSYS) ) && \
	cd yosys && \
	git pull && \
	git log -1 && \
	nice make $(NPROC) PREFIX=$(TARGETDIR) install && \
	git rev-parse HEAD > $(VER_YOSYS)

$(VER_ARACH):
	mkdir -p $(SOURCEDIR); cd $(SOURCEDIR) && \
	( [ -e arachne-pnr ] || git clone $(GIT_ARACH) ) && \
	cd arachne-pnr && \
	git pull && \
	git log -1 && \
	nice make $(NPROC) PREFIX=$(TARGETDIR) install && \
	git rev-parse HEAD > $(VER_ARACH)

$(VER_SYMBI):
	mkdir -p $(SOURCEDIR); cd $(SOURCEDIR) && \
	( [ -e SymbiYosys ] || git clone $(GIT_SYMBI) ) && \
	cd SymbiYosys && \
	git pull && \
	git log -1 && \
	nice make PREFIX=$(TARGETDIR) install && \
	git rev-parse HEAD > $(VER_SYMBI)

$(VER_YICES):
	mkdir -p $(SOURCEDIR); cd $(SOURCEDIR) && \
	( [ -e yices2 ] || git clone $(GIT_YICES) ) && \
	cd yices2 && \
	git pull && \
	git log -1 && \
	autoconf && \
	./configure --prefix=$(TARGETDIR) && \
	nice make $(NPROC) install && \
	git rev-parse HEAD > $(VER_YICES)

.PHONY: test clean ci-deps check_latest
