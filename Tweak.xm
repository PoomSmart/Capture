#import "Header.h"
#import "CaptureSBClient.h"
#import "CapturePhraseAnalyzer.h"
#import "Identifiers.h"
#import "CP.x"
#import <notify.h>
#import <rocketbootstrap/rocketbootstrap.h>
#import <objcipc/objcipc.h>
#import <Flipswitch/FSSwitchDataSource.h>
#import <Flipswitch/FSSwitchPanel.h>
#import <AssistantServices/AFPreferences.h>
#import <UIKit/UIImage+Private.h>
#import <UIKit/UIAlertController+Private.h>
#import "CaptureDCPathButton.h"
#import "../PSPrefs.x"

#define dc ((UIDictationController *)[%c(UIDictationController) sharedInstance])

#define isVideoMode(mode) (mode == 1 || mode == 2 || mode == 6)
#define isPhotoMode(mode) (mode == 0 || mode == 4)
#define FS 1

NSObject <cameraControllerDelegate> *cont() {
    return (CAMCaptureController *)[objc_getClass("CAMCaptureController") sharedInstance];
}

/*BOOL isCameraRunning() {
        BKSSystemService *systemService = [[BKSSystemService alloc] init];
        pid_t pid = [systemService pidForApplication:@"com.apple.camera"];
        [systemService release];
        return pid != 0;
   }*/

BOOL tweakEnabled;
BOOL autoStart;
BOOL autoEnable;
BOOL muteEnabled;

NSString *pendingLanguage = nil;
CAMViewfinderViewController *vc;
CaptureDCPathButton *myButton;

BOOL cameraReady() {
    BOOL ready;
    @autoreleasepool {
        if (isiOS9Up)
            ready = [vc._captureController._captureEngine._captureSession isRunning];
        else
            ready = [cont() _isSessionReady];
        //HBLogDebug(@"cameraReady: %d", ready);
    }
    return ready;
}

BOOL isCapturingVideo() {
    BOOL capture;
    @autoreleasepool {
        if (isiOS9Up)
            capture = [vc._captureController isCapturingVideo];
        else
            capture = [cont() isCapturingVideo];
    }
    return capture;

}

BOOL dictationEverStarted = NO;
BOOL ready = NO;
BOOL running = NO;
BOOL shouldDetect = YES;

id viewForWarning = nil;

extern "C" UIImage *_UIImageWithName(NSString *name);

UIImage *whiteImage(NSString *imagePath) {
    return [_UIImageWithName(imagePath) _flatImageWithColor:UIColor.whiteColor];
}

void startDictation(BOOL);

void notifyDictationAvailabilityIfNecessary8(id self) {
    AFPreferences *pref = [AFPreferences sharedPreferences];
    if (!pref.streamingDictationEnabled || ![pref dictationIsEnabled]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:tweakName message:compatibilityMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
        viewForWarning = self;
    } else
        ready = YES;
}

extern CFStringRef kAFPreferencesDidChangeDarwinNotification;

void enableDictationFeaturesIfNecessary() {
#ifdef FS
    if (%c(FSSwitchPanel)) {
        FSSwitchPanel *panel = (FSSwitchPanel *)[%c(FSSwitchPanel) sharedPanel];
        if ([panel switchWithIdentifierIsEnabled:@"com.PS.DictationToggle"])
            [panel setState:FSSwitchStateOn forSwitchIdentifier:@"com.PS.DictationToggle"];
        if ([panel switchWithIdentifierIsEnabled:@"com.PS.StreamingDictation"])
            [panel setState:FSSwitchStateOn forSwitchIdentifier:@"com.PS.StreamingDictation"];
    }
#endif
    AFPreferences *pref = [AFPreferences sharedPreferences];
    if (!pref.dictationIsEnabled) {
        [pref setDictationIsEnabled:YES];
        [pref _setDictationIsEnabledLocal:YES];
        [pref synchronize];
    }
    if (!pref.streamingDictationEnabled) {
        CFPreferencesSetAppValue(CFSTR("Streaming Dictation Enabled"), kCFBooleanTrue, CFSTR("com.apple.assistant"));
        CFPreferencesAppSynchronize(CFSTR("com.apple.assistant"));
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), kAFPreferencesDidChangeDarwinNotification, NULL, NULL, YES);
    }
}

void notifyDictationAvailabilityIfNecessary9(id self){
    AFPreferences *pref = [AFPreferences sharedPreferences];
    if (!pref.streamingDictationEnabled || !pref.dictationIsEnabled) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:tweakName message:compatibilityMessage preferredStyle:UIAlertControllerStyleAlert];
        [alert _addActionWithTitle:@"Enable" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            enableDictationFeaturesIfNecessary();
            ready = pref.streamingDictationEnabled && pref.dictationIsEnabled;
            [alert dismissViewControllerAnimated:YES completion:nil];
            startDictation(YES);
        }];
        [alert _addActionWithTitle:@"Later" style:UIAlertActionStyleDefault handler:NULL];
        [self presentViewController:alert animated:YES completion:nil];
    } else
        ready = YES;
}

void startDictation(BOOL v) {
    if (!ready) {
        HBLogDebug(@"Capture: Dictation not ready, can't invoke");
        if (viewForWarning && dictationEverStarted) {
            if (autoEnable)
                enableDictationFeaturesIfNecessary();
            else {
                if (isiOS9Up)
                    notifyDictationAvailabilityIfNecessary9(viewForWarning);
                else
                    notifyDictationAvailabilityIfNecessary8(viewForWarning);
            }
        }
        return;
    }
    //dispatch_async(dispatch_get_main_queue(), ^{
    if (v) {
        if (!running) {
            if (isVideoMode(vc._currentMode)) {
                HBLogDebug(@"Capture: try to remove audio input (startDictation())");
                [vc._captureController._captureEngine._captureSession cam_removeInputs:@[[vc._captureController._captureEngine audioCaptureDeviceInput]]];
            }
            [dc startDictation];
            HBLogDebug(@"Capture: startDictation (lang: %@)", dc.language);
            shouldDetect = YES;
        }
    } else {
        HBLogDebug(@"Capture: stopDictation");
        [dc cancelDictation];
    }
    //});
}

static void _checkPhrase(NSString *text) {
    NSString *phrase = [text lowercaseString];
    HBLogDebug(@"Capture: recognized: %@", phrase);
    [[CapturePhraseAnalyzer analyzer] addPhrase:phrase];
    [[CapturePhraseAnalyzer analyzer] perform];
}

static void checkPhrase(NSString *text) {
    if (!shouldDetect)
        return;
    //[dc _restartDictation];
    _checkPhrase(text);
}

%group Dictation

%hook UIDictationController

+ (void)applicationWillResignActive {
    HBLogDebug(@"Capture: applicationWillResignActive, dictation cancelled");
    %orig;
}

- (void)setupForDictationStartForReason:(int)reason {
    %orig;
    if (pendingLanguage && cameraReady()) {
        self.language = pendingLanguage;
        pendingLanguage = nil;
    }
}

- (void)_updateFromSelectedTextRange:(NSRange)range withNewHypothesis:(id)hypothesis {
    if (cameraReady() || !shouldDetect)
        return;
    %orig;
}

- (void)_displayLinkFired:(id)arg1 {
    if (cameraReady() || !shouldDetect)
        return;
    %orig;
}

- (void)cancelDictation {
    %log;
    shouldDetect = NO;
    %orig;
}

- (void)stopDictation {
    %log;
    shouldDetect = NO;
    %orig;
}

- (void)startRecordingLimitTimer {
    // Locally unlimited assertion?
    %log;
    %orig;
}

%end

%hook AFDictationConnection

- (void)_checkAndSetIsCapturingSpeech: (BOOL)c {
    %orig(running = c);
}

- (void)startDictationWithLanguageCode:(NSString *)language options:(id)options speechOptions:(id)speechOptions {
    dictationEverStarted = YES;
    %orig;
}

- (void)_invokeRequestTimeout {
    %orig;
    /*if (shouldDetect) {
            HBLogDebug(@"Capture: restart Dictation because of timeout");
            startDictation(NO);
            startDictation(YES);
       }*/
}

%end

%end

void handleSendPartialResult(NSString *name, NSDictionary *userInfo) {
    if ([name isEqualToString:send_Camera]) {
        HBLogDebug(@"Capture: receiving result from SpringBoard (Camera)");
        checkPhrase(userInfo[sendPartialResultKey]);
    }
}

void registerCP(NSString *centerName, NSString *messageName, id target) {
    CPDistributedMessagingCenter *c = [CPDistributedMessagingCenter centerNamed:centerName];
    rocketbootstrap_distributedmessagingcenter_apply(c);
    [c registerForMessageName:messageName target:target selector:@selector(handleMessageNamed:withUserInfo:)];
    [c runServerOnCurrentThread];
}

void registerNotifications(id self) {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(capture_takePhoto:) name:takePhoto object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(capture_captureVideo:) name:captureVideo object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(capture_burstPhoto:) name:burstPhoto object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(capture_stopBurstPhoto:) name:stopBurstPhoto object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(capture_stopDictation:) name:stop_Dictation object:nil];
    HBLogDebug(@"Capture: registering notification for Camera");
    [OBJCIPC registerIncomingMessageFromSpringBoardHandlerForMessageName:send_Camera handler:^NSDictionary *(NSDictionary *userInfo) {
        handleSendPartialResult(send_Camera, userInfo);
        return nil;
    }];
}

void unregisterNotifications(id self){
    [NSNotificationCenter.defaultCenter removeObserver:self name:takePhoto object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:burstPhoto object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:stopBurstPhoto object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:captureVideo object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:stop_Dictation object:nil];
}

void updateCaptureDictationButtonItem(){
    if (myButton) {
        if (running) {
            ((CaptureDCPathItemButton *)(myButton.itemButtons[0])).alpha = 0.5;
            ((CaptureDCPathItemButton *)(myButton.itemButtons[2])).alpha = 1.0;
        } else {
            ((CaptureDCPathItemButton *)(myButton.itemButtons[2])).alpha = 0.5;
            ((CaptureDCPathItemButton *)(myButton.itemButtons[0])).alpha = 1.0;
        }
    }
}

void installCaptureDictationButton(id <DCPathButtonDelegate> self) {
    myButton = [[CaptureDCPathButton alloc] initWithCenterImage:whiteImage(@"dictation_portrait") highlightedImage:whiteImage(@"bold_dictation_portrait") scale:3.0];
    myButton.delegate = self;
    myButton.allowCenterButtonRotation = NO;
    myButton.bloomRadius = 65;
    CAMViewfinderView *viewfinderView = vc.view;
    myButton.dcButtonCenter = CGPointMake(viewfinderView.frame.size.width - 30, viewfinderView.frame.size.height - vc._bottomBar.frame.size.height - 25);
    myButton.bloomDirection = kDCPathButtonBloomDirectionTopLeft;
    UIImage *o1i = whiteImage(@"UIButtonBarPlay");
    CaptureDCPathItemButton *o1 = [[CaptureDCPathItemButton alloc] initWithImage:o1i
                                                                highlightedImage:o1i
                                                                 backgroundImage:o1i
                                                      backgroundHighlightedImage:o1i];
    UIImage *o2i = whiteImage(@"global_portrait");
    UIImage *o2ih = whiteImage(@"bold_global_portrait");
    CaptureDCPathItemButton *o2 = [[CaptureDCPathItemButton alloc] initWithImage:o2i
                                                                highlightedImage:o2ih
                                                                 backgroundImage:o2i
                                                      backgroundHighlightedImage:o2ih];
    UIImage *o3i = whiteImage(@"UIButtonBarStop");
    CaptureDCPathItemButton *o3 = [[CaptureDCPathItemButton alloc] initWithImage:o3i
                                                                highlightedImage:o3i
                                                                 backgroundImage:o3i
                                                      backgroundHighlightedImage:o3i];
    [myButton addPathItems:@[o1, o2, o3]];
    [viewfinderView addSubview:myButton];
    updateCaptureDictationButtonItem();
}

#ifdef MUTE

void _setMuteState(BOOL _mute) {
    if (_mute)
        sendCPMessage(center_toassistantd, send_toassistantd, @{ muteKey : mute });
    else
        sendCPMessage(center_toassistantd, send_toassistantd, @{ muteKey : unmute });
}

void setMuteState() {
    _setMuteState(muteEnabled);
}

#endif

#ifdef GESTURE

void installDictationLanguageGesture(id <UIGestureRecognizerDelegate> self) {
    UITapGestureRecognizer *doubleTapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(languageDictation:)] autorelease];
    doubleTapRecognizer.numberOfTouchesRequired = 3;
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.cancelsTouchesInView = NO;
    doubleTapRecognizer.delaysTouchesEnded = NO;
    doubleTapRecognizer.delegate = self;
    [(id) self addGestureRecognizer:doubleTapRecognizer];
}

void _installDirectDictationGesture(id <UIGestureRecognizerDelegate> self) {
    UITapGestureRecognizer *doubleTapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_directlyDictation:)] autorelease];
    doubleTapRecognizer.numberOfTouchesRequired = 2;
    doubleTapRecognizer.numberOfTapsRequired = 1;
    doubleTapRecognizer.cancelsTouchesInView = NO;
    doubleTapRecognizer.delaysTouchesEnded = NO;
    doubleTapRecognizer.delegate = self;
    [(id) self addGestureRecognizer:doubleTapRecognizer];
}

void _installDictationStopGesture(id <UIGestureRecognizerDelegate> self) {
    UITapGestureRecognizer *doubleTapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(capture_stopDictation:)] autorelease];
    doubleTapRecognizer.numberOfTouchesRequired = 3;
    doubleTapRecognizer.numberOfTapsRequired = 1;
    doubleTapRecognizer.cancelsTouchesInView = NO;
    doubleTapRecognizer.delaysTouchesEnded = NO;
    doubleTapRecognizer.delegate = self;
    [(id) self addGestureRecognizer:doubleTapRecognizer];
}

#endif

void _directlyDictation() {
    startDictation(NO);
    startDictation(YES);
}

extern "C" NSArray *AFPreferencesSupportedDictationLanguages();

NSString *cancelTitle = nil;
NSMutableDictionary *languageCache = nil;
NSArray *localizedLanguageCache = nil;

void languageDictation() {
    HBLogDebug(@"Capture: selecting dictation language");
    if (localizedLanguageCache == nil) {
        NSArray *languages = AFPreferencesSupportedDictationLanguages();
        localizedLanguageCache = [[languages sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] retain];
    }
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:tweakName message:@"Choose language" preferredStyle:UIAlertControllerStyleAlert];
    for (NSString *language in localizedLanguageCache) {
        NSString *preferLanguageTitle = languageCache[language];
        NSString *languageTitle = preferLanguageTitle ? preferLanguageTitle : language;
        [sheet _addActionWithTitle:languageTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *trueLanguage = [dc languageCodeForAssistantLanguageCode:[dc assistantCompatibleLanguageCodeForInputMode:language]];
            pendingLanguage = trueLanguage.copy;
        }];
    }
    if (cancelTitle == nil)
        cancelTitle = [[NSBundle bundleForClass:[UIApplication class]] localizedStringForKey:@"Cancel" value:@"Cancel" table:@"Localizable"];
    [sheet _addActionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:NULL];
    [sheet.view addConstraint:[NSLayoutConstraint constraintWithItem:sheet.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:vc.view.frame.size.height * 0.60]];
    [viewForWarning presentViewController:sheet animated:YES completion:nil];
}

%group Camera8

%hook CAMCameraView

- (id)initWithFrame: (CGRect)frame spec: (id)spec {
    self = %orig;
    if (self) {
        registerNotifications(self);
        notifyDictationAvailabilityIfNecessary8(viewForWarning = self);
    }
    return self;
}

- (void)dealloc {
    unregisterNotifications(self);
    %orig;
}

%new
- (void)languageDictation: (id)arg1 {
    languageDictation();
}

/*#ifdef GESTURE

   - (void)_createLivePreviewHierarchyIfNecessary {
        %orig;
        _installDirectDictationGesture((id <UIGestureRecognizerDelegate>)self);
        _installDictationStopGesture((id <UIGestureRecognizerDelegate>)self);
   }

 #endif*/

%new
- (void)_directlyDictation: (id)arg1 {
    _directlyDictation();
}

%new
- (void)capture_stopDictation: (id)arg1 {
    startDictation(NO);
}

%new
- (void)capture_takePhoto: (id)arg1 {
    if (cameraReady() && isPhotoMode(self.cameraMode))
        [self takePicture];
}

%new
- (void)capture_captureVideo: (id)arg1 {
    HBLogDebug(@"Capture: capture video");
    if (cameraReady() && isVideoMode(self.cameraMode) && !isCapturingVideo())
        [self cameraShutterReleased:nil];
}

- (void)_switchFromCameraModeAtIndex:(NSUInteger)from toCameraModeAtIndex:(NSUInteger)to {
    %orig;
    if (autoStart)
        startDictation(YES);
}

- (void)enableCamera {
    %orig;
    if (autoStart)
        startDictation(YES);
}

- (void)disableCamera {
    startDictation(NO);
    %orig;
}

%end

%end

%group Camera9

%hook CAMViewfinderView

%new
- (void)languageDictation: (id)arg1 {
    languageDictation();
}

%new
- (void)_directlyDictation: (id)arg1 {
    _directlyDictation();
}

%new
- (void)capture_stopDictation: (id)arg1 {
    startDictation(NO);
}

%end

/*%hook CAMPreviewViewController

   - (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
        // test if our control subview is on-screen
        if (myButton.superview != nil && myButton) {
                if ([touch.view isDescendantOfView:myButton]) {
                        // we touched our control surface
                        return NO; // ignore the touch
                }
        }
    return %orig;
   }

   %end*/

%hook CAMViewfinderViewController

%new
- (void)didPresentDCPathButtonItems: (CaptureDCPathButton *)dcPathButton {
    updateCaptureDictationButtonItem();
}

%new
- (void)pathButton: (CaptureDCPathButton *)dcPathButton clickItemButtonAtIndex: (NSUInteger)itemButtonIndex {
    switch (itemButtonIndex) {
        case 0:
            [self.view _directlyDictation:nil];
            break;
        case 1:
            [self.view languageDictation:nil];
            break;
        case 2:
            [self capture_stopDictation:nil];
    }
}

- (void)viewDidAppear:(id)arg1 {
    %orig;
    vc = self;
    [CapturePhraseAnalyzer analyzer].vc = vc;
    registerNotifications(self);
    notifyDictationAvailabilityIfNecessary9(viewForWarning = self);
    installCaptureDictationButton((id <DCPathButtonDelegate>)self);
}

/*#ifdef GESTURE

   - (void)_createCommonGestureRecognizersIfNecessary {
        %orig;
        _installDirectDictationGesture((id <UIGestureRecognizerDelegate>)(self.view));
        _installDictationStopGesture((id <UIGestureRecognizerDelegate>)(self.view));
   }

 #endif*/

- (void)dealloc {
    unregisterNotifications(self);
    %orig;
}

%new
- (void)capture_stopDictation: (id)arg1 {
    startDictation(NO);
}

%new
- (void)capture_takePhoto: (id)arg1 {
    if (cameraReady() && isPhotoMode(self._currentMode)) {
        HBLogDebug(@"Capture: take photo");
        [self _captureStillImageWithCurrentSettings];
    }
}

%new
- (void)capture_burstPhoto: (id)arg1 {
    if (cameraReady() && isPhotoMode(self._currentMode)) {
        HBLogDebug(@"Capture: start burst photos");
        [self _handleShutterButtonPressed:nil];
    }
}

%new
- (void)capture_stopBurstPhoto: (id)arg1 {
    if (cameraReady() && isPhotoMode(self._currentMode)) {
        HBLogDebug(@"Capture: stop burst photos");
        [self _handleShutterButtonReleased:nil];
    }
}

%new
- (void)capture_captureVideo: (id)arg1 {
    if (cameraReady() && isVideoMode(self._currentMode) && !isCapturingVideo()) {
        HBLogDebug(@"Capture: capture video");
        startDictation(NO); // do we need?
        [self._captureController._captureEngine._captureSession cam_ensureInputs:@[[self._captureController._captureEngine audioCaptureDeviceInput]]];
        [self _handleShutterButtonReleased:nil];
    }
}

- (void)_willChangeFromMode:(NSInteger)fromMode toMode:(NSInteger)toMode fromDevice:(NSInteger)fromDevice toDevice:(NSInteger)toDevice animated:(BOOL)animated {
    if (autoStart) {
        if (fromMode != toMode || fromDevice != toDevice) {
            if (dictationEverStarted)
                startDictation(NO);
        }
    }
    %orig;
}

- (void)captureControllerDidStopRunning:(id)arg1 {
    startDictation(NO);
    %orig;
}

%end

extern "C" NSString *CAMModeAndDeviceCommandDevice;
extern "C" NSString *CAMModeAndDeviceCommandModeWithOptions;

%hook CUCaptureController

- (void)_handleCaptureEngineExecutionNotification: (NSNotification *)notification {
    %orig;
    // This is when camera is active and mode set
    if (autoStart) {
        @autoreleasepool {
            NSDictionary *userInfo = notification.userInfo;
            if (userInfo[CAMModeAndDeviceCommandDevice] && userInfo[CAMModeAndDeviceCommandModeWithOptions]) {
                shouldDetect = YES;
                startDictation(YES);
            }
        }
    }
}

%end

%end

%group assistantd

/*#ifdef MUTE

   %hook ADCommandCenter

   - (id)init
   {
        self = %orig;
        HBLogDebug(@"Capture: Register notifications for ADSpeechManager");
        registerCP(center_toassistantd, send_toassistantd, [self _speechManager]);
        return self;
   }

   %end

   %hook ADSpeechManager

   %new
   - (void)handleMessageNamed:(NSString *)name withUserInfo:(NSDictionary *)userInfo
   {
        HBLogDebug(@"TTTT");
        if (![name isEqualToString:send_toassistantd])
                return;
        HBLogDebug(@"Capture: receiving result from SpringBoard");
        NSString *type = userInfo[muteKey];
        if ([type isEqualToString:mute])
                [self capture_mute:nil];
        else if ([type isEqualToString:unmute])
                [self capture_unmute:nil];
   }

   %new
   - (void)capture_mute:(id)arg1
   {
        HBLogDebug(@"Capture: mute microphone activation sound");
        [[[self _speechRecorder] _voiceController] setAlertSoundFromURL:nil forType:1];
        [[[self _speechRecorder] _voiceController] setAlertSoundFromURL:nil forType:2];
        [[[self _speechRecorder] _voiceController] setAlertSoundFromURL:nil forType:3];
   }

   %new
   - (void)capture_unmute:(id)arg1
   {
        HBLogDebug(@"Capture: unmute microphone activation sound");
        MSHookIvar<BOOL>([[self _speechRecorder] _voiceController], "_needsAlertsSet") = YES;
        [[self _speechRecorder] _setAlertsIfNeeded];
   }

   %end

 #endif*/

%hook ADSpeechRecorder

- (void)_playAudioAlert: (int)type
{
    %log;
    %orig;
}

%end

void sendResult(ADCommandCenter *center, SASSpeechPartialResult *result) {
    if (result.tokens.count > 0) {
        SASToken *token = (SASToken *)(result.tokens.lastObject);
        HBLogDebug(@"Capture: sending result from assistantd (saying \"%@\")", token.text);
        sendCPMessage(center_assistantd, send_assistantd, @{ sendPartialResultKey : token.text });
    }
}

%hook ADCommandCenter

// iOS 8
- (void)_sasSpeechPartialResult: (SASSpeechPartialResult *)partialResult {
    sendResult(self, partialResult);
    %orig;
}

// iOS 9
- (void)_sasSpeechPartialResult:(SASSpeechPartialResult *)partialResult completion:(id)completion {
    sendResult(self, partialResult);
    %orig;
}

%end

/*%hook ADDictationConnection

   // iOS 8
   - (void)adSpeechRecognitionDidFail:(id)arg1 {
        //%log;
        %orig;
   }

   // iOS 9
   - (void)adSpeechRecognitionDidFail:(id)arg1 sessionUUID:(id)arg2 {
        //%log;
        %orig;
   }

   %end*/

%end

HaveCallback() {
    GetPrefs()
    GetBool2(tweakEnabled, YES)
    GetBool2(autoStart, NO)
    GetBool2(autoEnable, NO)
    GetBool(muteEnabled, muteKey, NO)
    CapturePhraseAnalyzer *analyzer = [CapturePhraseAnalyzer analyzer];
    GetObject(analyzer.takePhotoPhrases, photoKey, PtakePhoto)
    GetObject(analyzer.captureVideoPhrases, videoKey, PcaptureVideo)
    GetObject(analyzer.stopPhrases, stopKey, Pstop)
    GetObject(analyzer.burstPhrases, burstKey, Pburst)
    [analyzer computeMultiple];
}

%ctor
{
    @autoreleasepool {
        NSArray *args = [[NSClassFromString(@"NSProcessInfo") processInfo] arguments];
        if (args.count) {
            NSString *executablePath = args[0];
            if (executablePath) {
                NSString *processName = [executablePath lastPathComponent];
                HBLogDebug(@"Capture: init for %@", processName);
                if ([processName isEqualToString:@"assistantd"]) {
                    %init(assistantd);
                } else {
                    dlopen("/System/Library/PrivateFrameworks/AssistantServices.framework/AssistantServices", RTLD_LAZY);
                    if ([processName isEqualToString:@"SpringBoard"]) {
                        HBLogDebug(@"Capture: registering notification for SpringBoard");
                        registerCP(center_assistantd, send_assistantd, [CaptureSBClient client]);
                        rocketbootstrap_unlock([center_assistantd UTF8String]);
#ifdef MUTE
                        rocketbootstrap_unlock([center_toassistantd UTF8String]);
                        setMuteState();
                        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)setMuteState, CFSTR("com.PS.Capture/ReloadPrefs"), NULL, kNilOptions);
#endif
                    } else {
#ifdef FS
                        dlopen("/usr/lib/libflipswitch.dylib", RTLD_LAZY);
#endif
                        void *as = dlopen("/System/Library/PreferenceBundles/Assistant.bundle/Assistant", RTLD_LAZY);
                        if (as != NULL) {
                            languageCache = [%c(AssistantController) titlesForLanguageIdentifiers:[NSSet setWithArray:AFPreferencesSupportedDictationLanguages()]].copy;
                            dlclose(as);
                        }
                        HaveObserver();
                        callback();
                        if (isiOS9Up) {
                            openCamera9();
                            %init(Camera9);
                        } else if (isiOS8) {
                            openCamera8();
                            %init(Camera8);
                        }
                        %init(Dictation);
                    }
                }
            }
        }
    }
}
