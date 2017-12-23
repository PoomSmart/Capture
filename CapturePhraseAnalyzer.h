#define UIFUNCTIONS_NOT_C
#import "Header.h"

@interface CapturePhraseAnalyzer : NSObject {
    NSMutableArray <NSString *> *phrases;
    NSMutableString *currentPhrase;
    NSArray <NSString *> *takePhotoPhrases;
    NSArray <NSString *> *burstPhrases;
    NSArray <NSString *> *stopBurstPhrases;
    NSArray <NSString *> *captureVideoPhrases;
    NSArray <NSString *> *stopPhrases;
    CAMViewfinderViewController *vc;
}
@property(retain, nonatomic) NSMutableArray <NSString *> *phrases;
@property(retain, nonatomic) NSMutableString *currentPhrase;
@property(retain, nonatomic) NSArray <NSString *> *takePhotoPhrases;
@property(retain, nonatomic) NSArray <NSString *> *burstPhrases;
@property(retain, nonatomic) NSArray <NSString *> *stopBurstPhrases;
@property(retain, nonatomic) NSArray <NSString *> *captureVideoPhrases;
@property(retain, nonatomic) NSArray <NSString *> *stopPhrases;
@property(retain, nonatomic) CAMViewfinderViewController *vc;
+ (instancetype)analyzer;
- (void)computeMultiple;
- (void)addPhrase:(NSString *)phrase;
- (void)postNSNotification:(NSString *)name;
- (void)selectPostCaptureNotification:(NSString *)name;
- (BOOL)perform;
@end
