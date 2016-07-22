#import <Foundation/Foundation.h>
#import "../PS.h"

@interface CapturePhraseAnalyzer : NSObject {
	NSMutableArray *phrases;
	NSMutableString *currentPhrase;
	NSArray *takePhotoPhrases;
	NSArray *burstPhrases;
	NSArray *stopBurstPhrases;
	NSArray *captureVideoPhrases;
	NSArray *stopPhrases;
	CAMViewfinderViewController *vc;
}
@property(retain, nonatomic) NSMutableArray *phrases;
@property(retain, nonatomic) NSMutableString *currentPhrase;
@property(retain, nonatomic) NSArray *takePhotoPhrases;
@property(retain, nonatomic) NSArray *burstPhrases;
@property(retain, nonatomic) NSArray *stopBurstPhrases;
@property(retain, nonatomic) NSArray *captureVideoPhrases;
@property(retain, nonatomic) NSArray *stopPhrases;
@property(retain, nonatomic) CAMViewfinderViewController *vc;
+ (CapturePhraseAnalyzer *)analyzer;
- (void)computeMultiple;
- (void)addPhrase:(NSString *)phrase;
- (void)postNSNotification:(NSString *)name;
- (void)selectPostCaptureNotification:(NSString *)name;
- (BOOL)perform;
@end