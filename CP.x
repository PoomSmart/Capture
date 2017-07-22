#import "../PS.h"
#import <AppSupport/CPDistributedMessagingCenter.h>
#import <rocketbootstrap/rocketbootstrap.h>

static void sendCPMessage(NSString *centerName, NSString *messageName, NSDictionary *userInfo) {
    NSLog(@"Capture: sendCPMessage(%@, %@, ...)", centerName, messageName);
    CPDistributedMessagingCenter *c = [CPDistributedMessagingCenter centerNamed:centerName];
    rocketbootstrap_distributedmessagingcenter_apply(c);
    [c sendMessageName:messageName userInfo:userInfo];
}
