include $(src)/util/kconfig/lxdialog/Makefile
CONFIG_SHELL = sh
check-lxdialog = $(src)/util/kconfig/lxdialog/check-lxdialog.sh
CURSESLIBS = $(shell $(CONFIG_SHELL) $(check-lxdialog) -ldflags $(HOSTCC))

.PHONY: menuconfig 
mconf-objects := mconf.o zconf.tab.o

menuconfig: prepare $(obj)/util/kconfig/lxdialog/lxdialog $(obj)/util/kconfig/mconf
	@$(obj)/util/kconfig/mconf Kconfig

$(obj)/util/kconfig/mconf: $(patsubst %,$(obj)/util/kconfig/%,$(mconf-objects))
	@printf "  HOSTCC  $(subst $(shell pwd)/,,$(@))\n"
	@$(HOSTCC) -o $@ $^ $(CURSESLIBS) $(INTLLIBS)

$(obj)/util/kconfig/mconf.o: $(src)/util/kconfig/mconf.c
	@mkdir -p $(dir $@)
	@printf "  HOSTCC  $(subst $(shell pwd)/,,$(@))\n"
	@$(HOSTCC) $(HOSTCFLAGS) $(INTLCFLAGS) -I$(src)/util/kconfig -c -o $@ $<

$(obj)/util/kconfig/zconf.tab.o: $(obj)/util/kconfig/zconf.tab.c $(obj)/util/kconfig/zconf.hash.c $(obj)/util/kconfig/lex.zconf.c
	@mkdir -p $(dir $@)
	@printf "  HOSTCC  $(subst $(shell pwd)/,,$(@))\n"
	@$(HOSTCC) $(HOSTCFLAGS) $(INTLCFLAGS) -I$(src)/util/kconfig  -c -o $@ $(obj)/util/kconfig/zconf.tab.c

$(obj)/util/kconfig/lex.zconf.c: $(src)/util/kconfig/lex.zconf.c
	@mkdir -p $(dir $@)
	@cp $< $@

$(obj)/util/kconfig/zconf.hash.c: $(src)/util/kconfig/zconf.hash.c
	@mkdir -p $(dir $@)
	@cp $< $@

$(obj)/util/kconfig/zconf.tab.c: $(src)/util/kconfig/zconf.tab.c
	@mkdir -p $(dir $@)
	@cp $< $@




