INSTALL_DIR ?= $(HOME)/.claude

.PHONY: install uninstall

install:
	install -d $(INSTALL_DIR)
	install -m 755 bin/cc-search $(INSTALL_DIR)/cc-search
	install -m 755 bin/transcript $(INSTALL_DIR)/transcript
	@echo "Installed cc-search and transcript to $(INSTALL_DIR)"
	@echo "To install the session-audit skill:"
	@echo "  claude install ."

uninstall:
	rm -f $(INSTALL_DIR)/cc-search $(INSTALL_DIR)/transcript
	@echo "Removed cc-search and transcript from $(INSTALL_DIR)"
