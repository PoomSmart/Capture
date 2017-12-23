#define UNRESTRICTED_AVAILABILITY
#import "../PS.h"
#import <Preferences/PSListController.h>

@protocol AFDictationDelegate <NSObject>
- (void)dictationConnection:(id)connection didRecognizeTokens:(NSArray *)tokens languageModel:(NSString *)language;
@end

@interface AFDictationConnection : NSObject {
    id <AFDictationDelegate> _delegate;
}
@property(retain, nonatomic) id <AFDictationDelegate> delegate;
@end

@interface UIDictationController : NSObject <AFDictationDelegate>
+ (UIDictationController *)activeInstance;
+ (UIDictationController *)sharedInstance;
+ (BOOL)isRunning;
- (BOOL)dictationEnabled;
- (NSString *)assistantCompatibleLanguageCodeForInputMode:(NSString *)inputMode;
- (NSString *)languageCodeForAssistantLanguageCode:(NSString *)assistantLanguageCode;
@property(retain, nonatomic) NSString *language;
- (void)startDictation;
- (void)stopDictation;
- (void)cancelDictation;
- (void)_restartDictation;
- (void)cancelRecordingLimitTimer;
@end

@interface AFSpeechToken : NSObject
@property (retain, nonatomic) NSString *text;
@end

@interface AVVoiceController : NSObject
@property (assign) float playbackVolume;
- (BOOL)setAlertSoundFromURL:(NSURL *)arg1 forType:(int)arg2;
@end

@interface AceObject : NSObject
@property(nonatomic, readonly) NSMutableDictionary *dict;
@property(nonatomic, readonly) NSData *plistData;
@end

@interface SABaseCommand : AceObject
@end

@interface SABaseClientBoundCommand : SABaseCommand
@property(nonatomic, copy) NSString *appId;
@end

// SAObjects
@interface SASSpeechPartialResult : SABaseClientBoundCommand
- (NSArray *)tokens;
- (void)setTokens:(NSArray *)tokens;

// AssistantServices
- (id)af_bestTextInterpretation;
- (id)af_correctionContext;
- (id)af_userUtteranceValue;
@end

@interface ADSpeechRecorder : NSObject
- (AVVoiceController *)_voiceController;
- (void)_setAlertsIfNeeded;
@end

@interface ADSpeechManager : NSObject
- (ADSpeechRecorder *)_speechRecorder;
@end

@protocol ADCommandCenterSpeechDelegate <NSObject>
- (void)adSpeechRecognizedPartialResult:(SASSpeechPartialResult *)partialResult usingSpeechModel:(NSString *)language;
- (void)adSpeechRecognitionDidFail:(NSError *)error;
@end

@interface AFDictationConnectionServiceDelegate : NSObject {
    AFDictationConnection *_connection;
}
@end

@interface AFDictationConnectionServiceDelegate ()
- (void)_capture_sendPartialResult:(SASSpeechPartialResult *)result;
@end

@interface ADDictationConnection : NSObject <ADCommandCenterSpeechDelegate> {
    AFDictationConnectionServiceDelegate *_serviceDelegate;
}
@end

@interface ADCommandCenter : NSObject
- (id <ADCommandCenterSpeechDelegate>)_speechDelegate;
@end

@interface SASToken : NSObject
@property(nonatomic, copy) NSString *originalText;
@property(nonatomic, copy) NSString *text;
@end

@interface AssistanController : PSListController
+ (NSMutableDictionary *)assistantLanguageTitlesDictionary;
+ (NSMutableDictionary *)titlesForLanguageIdentifiers:(NSSet *)set;
+ (NSMutableDictionary *)shortTitlesForLanguageIdentifiers:(NSSet *)set;
@end

@interface CAMViewfinderView (Capture)
- (void)_directlyDictation:(id)arg1;
- (void)languageDictation:(id)arg1;
@end

@interface CAMViewfinderViewController (Capture)
- (void)capture_stopDictation:(id)arg1;
@end

#define compatibilityMessage @"You need to enable both dictation and streaming dictation."
