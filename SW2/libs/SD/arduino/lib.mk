LIB_SRC  += $(ROOT_DIR)/libs/SD/arduino/src/wiring_digital.cpp
LIB_SRC  += $(ROOT_DIR)/libs/SD/arduino/src/Print.cpp
LIB_SRC  += $(ROOT_DIR)/libs/SD/arduino/src/arduino_hack.c
INC_DIRS += $(ROOT_DIR)/libs/SD/arduino/include




#	LIB_SRC  += $(ROOT_DIR)/libs/SD/SD_ard/src/Sd2Card.cpp
#	LIB_SRC  += $(ROOT_DIR)/libs/SD/SD_ard/src/SdVolume.cpp
#	LIB_SRC  += $(ROOT_DIR)/libs/SD/SD_ard/src/File.cpp
#	LIB_SRC  += $(ROOT_DIR)/libs/SD/SD_ard/src/SdFile.cpp
#	LIB_SRC  += $(ROOT_DIR)/libs/SD/SD_ard/src/SPI.cpp
#	LIB_SRC  += $(ROOT_DIR)/libs/SD/SD_ard/src/SD.cpp
#	INC_DIRS += $(ROOT_DIR)/libs/SD/SD_ard/include
#	
#	LIB_SRC  += $(ROOT_DIR)/libs/SD/SD_ard/src/arduino_hack.c	## millis
#	
#	# INC_DIRS += $(HOME)/.arduino15/packages/arduino/hardware/avr/1.8.6/cores/arduino/
#	
#	ARDUINO_CORE = $(HOME)/.arduino15/packages/arduino/hardware/avr/1.8.6/cores/arduino/
#	
#	CXXFLAGS += -I$(ARDUINO_CORE)
#	ARDUINO_CORE_SRC = $(wildcard $(ARDUINO_CORE)/*.c) \
#	                   $(wildcard $(ARDUINO_CORE)/*.cpp)
#	
#	ARDUINO_CORE_OBJ = $(patsubst $(ARDUINO_CORE)/%, build/core/%, $(ARDUINO_CORE_SRC:.cpp=.o))
#	ARDUINO_CORE_OBJ := $(ARDUINO_CORE_OBJ:.c=.o)
#	
#	
#	build/core/%.o: $(ARDUINO_CORE)/%.c
#		mkdir -p $(dir $@)
#		avr-gcc $(CFLAGS) -mmcu=atmega2560 -c $< -o $@
#	
#	build/core/%.o: $(ARDUINO_CORE)/%.cpp
#		mkdir -p $(dir $@)
#		avr-g++ $(CXXFLAGS) -mmcu=atmega2560 -c $< -o $@
#	
#	
#	OBJS += $(ARDUINO_CORE_OBJ)
#	ARDUINO_VARIANT = $(HOME)/.arduino15/packages/arduino/hardware/avr/1.8.6/variants/mega
#	
#	CXXFLAGS += -I$(ARDUINO_VARIANT)
