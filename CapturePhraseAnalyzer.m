#import "CapturePhraseAnalyzer.h"
#import "Identifiers.h"

@implementation CapturePhraseAnalyzer
@synthesize phrases, currentPhrase;
@synthesize takePhotoPhrases;
@synthesize burstPhrases, stopBurstPhrases;
@synthesize captureVideoPhrases;
@synthesize stopPhrases;
@synthesize vc;

+ (CapturePhraseAnalyzer *)analyzer {
    static dispatch_once_t p = 0;
    __strong static CapturePhraseAnalyzer *_sharedObject = nil;
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
        _sharedObject.currentPhrase = [NSMutableString string];
        _sharedObject.phrases = [NSMutableArray array];
    });
    return _sharedObject;
}

- (void)computeMultiple {
    [self.phrases removeAllObjects];
    for (NSString *phrase in self.takePhotoPhrases) {
        if ([phrase rangeOfString:@" "].location != NSNotFound)
            [self.phrases addObject:phrase];
    }
    for (NSString *phrase in self.captureVideoPhrases) {
        if ([phrase rangeOfString:@" "].location != NSNotFound)
            [self.phrases addObject:phrase];
    }
    for (NSString *phrase in self.stopPhrases) {
        if ([phrase rangeOfString:@" "].location != NSNotFound)
            [self.phrases addObject:phrase];
    }
    for (NSString *phrase in self.burstPhrases) {
        if ([phrase rangeOfString:@" "].location != NSNotFound)
            [self.phrases addObject:phrase];
    }
}

- (void)addPhrase:(NSString *)phrase {
    [self.currentPhrase appendString:@" "];
    [self.currentPhrase appendString:phrase];
}

- (void)postNSNotification:(NSString *)name {
    [NSNotificationCenter.defaultCenter postNotificationName:name object:nil];
}

- (BOOL)containPhrase:(NSArray <NSString *> *)_phrases forString:(NSString *)_phrase {
    for (NSString *check in _phrases) {
        if ([_phrase hasSuffix:check])
            return YES;
    }
    return NO;
}

- (BOOL)essential:(NSString *)_phrase {
    return [_phrase isEqualToString:@"bye"];
}

- (void)selectPostCaptureNotification:(NSString *)_phrase {
    if ([self containPhrase:takePhotoPhrases forString:_phrase])
        [self postNSNotification:takePhoto];
    else if ([self containPhrase:burstPhrases forString:_phrase])
        [self postNSNotification:burstPhoto];
    else if ([self containPhrase:captureVideoPhrases forString:_phrase])
        [self postNSNotification:captureVideo];
    else if ([self containPhrase:stopPhrases forString:_phrase]) {
        if ([vc._captureController isCapturingBurst] && ![self essential:_phrase]) {
            [self postNSNotification:stopBurstPhoto];
            [self postNSNotification:stop_Dictation];
        } else
            [self postNSNotification:stop_Dictation];
    }
}

- (BOOL)perform {
    for (NSString *origPhrase in self.phrases) {
        if ([self.currentPhrase hasSuffix:origPhrase]) {
            [self.currentPhrase setString:@""];
            HBLogDebug(@"Capture: recognized multiple: %@", origPhrase);
            [self selectPostCaptureNotification:origPhrase];
            return YES;
        }
    }
    [self selectPostCaptureNotification:self.currentPhrase];
    return NO;
}

@end
