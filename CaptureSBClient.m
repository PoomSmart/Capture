#import "CaptureSBClient.h"
#import "Identifiers.h"
#import <objcipc/objcipc.h>

@implementation CaptureSBClient

+ (CaptureSBClient *)client {
    static dispatch_once_t p = 0;
    __strong static CaptureSBClient *_sharedObject = nil;
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)handleMessageNamed:(NSString *)name withUserInfo:(NSDictionary *)userInfo {
    if (![name isEqualToString:send_assistantd])
        return;
    HBLogDebug(@"Capture: receiving result from assistantd");
    HBLogDebug(@"Capture: sending result to Camera");
    [OBJCIPC sendMessageToAppWithIdentifier:@"com.apple.camera" messageName:send_Camera dictionary:userInfo replyHandler:^(NSDictionary *response) {

    }];
}

@end
