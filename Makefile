TARGET := iphone:clang:16.0
ARCHS := arm64 arm64e

TWEAK_NAME = RevolutDevModeSpoof
DISPLAY_NAME = Revolut DeveloperMode Spoof
BUNDLE_ID = com.maurice.revolutdevmodespoof

RevolutDevModeSpoof_FILES = Tweak.x
RevolutDevModeSpoof_CFLAGS = -fobjc-arc
RevolutDevModeSpoof_FRAMEWORKS = UIKit MobileGestalt Foundation

include $(THEOS)/makefiles/common.mk

TWEAK_CFLAGS += -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Revolut"
