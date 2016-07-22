#import <Foundation/Foundation.h>

@interface CaptureSBClient : NSObject
+ (CaptureSBClient *)client;
- (void)handleMessageNamed:(NSString *)name withUserInfo:(NSDictionary *)userInfo;
@end