#import <Foundation/Foundation.h>

@interface CaptureSBClient : NSObject
+ (instancetype)client;
- (void)handleMessageNamed:(NSString *)name withUserInfo:(NSDictionary *)userInfo;
@end
