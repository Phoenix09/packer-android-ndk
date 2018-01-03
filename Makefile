COMMON_SOURCES := android.json $(wildcard http/* scripts/* include/*)

OUTPUT_PREFIX = ubuntu-zesty-amd64-android-
CONFIGS := $(sort $(patsubst config/%.json,%,$(wildcard config/*.json)))
BOXES := $(foreach x,$(CONFIGS),$(OUTPUT_PREFIX)$(x).box)

help:
	@echo Available targets:
	@$(foreach x,$(CONFIGS),echo "\t$(x)";)

all: $(BOXES)

$(CONFIGS): %: $(OUTPUT_PREFIX)%.box
	@true

$(OUTPUT_PREFIX)%.box: output/$(OUTPUT_PREFIX)%.box
	@true

output/$(OUTPUT_PREFIX)%.box: config/%.json $(COMMON_SOURCES)
	@echo ">>> Building $@"
	mkdir -p logs
	PACKER_KEY_INTERVAL=10ms packer build -var-file=$< android.json 2>&1 | tee logs/$*.log

clean:
	$(RM) -R logs output tmp

.PHONY: all clean
