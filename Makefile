GO_EASY_ON_ME = 1
TARGET = iphone:clang:latest:8.0
ARCHS = armv7 armv7s arm64
DEBUG = 1
PACKAGE_VERSION = 0.0.3-6

include $(THEOS)/makefiles/common.mk
TWEAK_NAME = Capture
Capture_FILES = CapturePhraseAnalyzer.m CaptureSBClient.m CaptureDCPathItemButton.m CaptureDCPathButton.m Tweak.xm
Capture_FRAMEWORKS = UIKit
Capture_PRIVATE_FRAMEWORKS = AppSupport AssistantServices CameraUI #SAObjects VoiceServices
Capture_LIBRARIES = objcipc rocketbootstrap

include $(THEOS_MAKE_PATH)/tweak.mk

BUNDLE_NAME = CaptureSettings
CaptureSettings_FILES = CapturePreferenceController.m
CaptureSettings_INSTALL_PATH = /Library/PreferenceBundles
CaptureSettings_PRIVATE_FRAMEWORKS = Preferences PreferencesUI
CaptureSettings_FRAMEWORKS = CoreGraphics Social UIKit
CaptureSettings_LIBRARIES = cepheiprefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Capture.plist$(ECHO_END)
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -name .DS_Store | xargs rm -rf$(ECHO_END)
