CONFIG_SHELL:=sh

check-lxdialog  := $(src)/util/kconfig/lxdialog/check-lxdialog.sh

# Use recursively expanded variables so we do not call gcc unless
# we really need to do so. (Do not call gcc as part of make mrproper)
HOST_EXTRACFLAGS = $(shell $(CONFIG_SHELL) $(check-lxdialog) -ccflags)
HOST_LOADLIBS   = $(shell $(CONFIG_SHELL) $(check-lxdialog) -ldflags $(HOSTCC))
 
HOST_EXTRACFLAGS += -DLOCALE 

.PHONY: dochecklxdialog
$(obj)/dochecklxdialog:
	@printf "  CHECK   $(subst $(shell pwd)/,,$(@))\n"
	@$(CONFIG_SHELL) $(check-lxdialog) -check $(HOSTCC) $(HOST_LOADLIBS)

always		:= lxdialog dochecklxdialog

lxdialog-objs := checklist.o menubox.o textbox.o yesno.o inputbox.o \
		 util.o lxdialog.o msgbox.o

$(obj)/util/kconfig/lxdialog/lxdialog: $(obj)/dochecklxdialog $(patsubst %,$(obj)/util/kconfig/lxdialog/%,$(lxdialog-objs))
	@printf "  HOStCC  $(subst $(shell pwd)/,,$(@))\n"
	@$(HOSTCC) \
		$(patsubst %,$(obj)/util/kconfig/lxdialog/%,$(lxdialog-objs)) -o $@ $(HOST_LOADLIBS)

$(obj)/util/kconfig/lxdialog/%.o: $(src)/util/kconfig/lxdialog/%.c
	@mkdir -p $(obj)/util/kconfig/lxdialog/
	@printf "  HOSTCC  $(subst $(shell pwd)/,,$(@))\n"
	@$(HOSTCC) $(HOST_EXTRACFLAGS) $^ -c -o $@


