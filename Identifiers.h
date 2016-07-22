#import <Foundation/Foundation.h>

#define tweakName @"Capture"
#define tweakIdentifier @"com.PS.Capture"
#define mute @"com.ps.capture.mute"
#define unmute @"com.ps.capture.unmute"
#define takePhoto @"com.ps.capture.takePhoto"
#define captureVideo @"com.ps.capture.captureVideo"
#define burstPhoto @"com.ps.capture.burstPhoto"
#define stopBurstPhoto @"com.ps.capture.stopBurstPhoto"
#define send_Camera @"com.ps.capture.sendtocamera"
#define sendPartialResultKey @"partialResult"
#define center_assistantd @"com.ps.capture.inassistantd"
#define send_assistantd @"com.ps.capture.sendfromassistantd"
#define center_toassistantd @"com.ps.capture.toassistantd"
#define send_toassistantd @"com.ps.capture.sendtoassistantd"
#define stop_Dictation @"com.ps.capture.stopdictation"

#define tweakEnabledKey @"tweakEnabled"
#define autoEnableKey @"autoEnable"
#define autoStartKey @"autoStart"
#define muteKey @"mute"

#define photoKey @"Photo"
#define burstKey @"Burst"
#define burstStopKey @"StopBurst"
#define videoKey @"Video"
#define stopKey @"Stop"

#ifdef INTERNAL
#define PtakePhoto @[@"capture", @"cheese", @"shoot", @"smile", @"snap", @"selfie", @"photo", @"ถ่ายรูป", @"แชะ", @"กล้อง", @"ยิ้ม"]
#define Pburst @[@"burst", @"continuous", @"ต่อเนื่อง"]
#define PcaptureVideo @[@"อัดวีดีโอ", @"video", @"film", @"record video", @"take video"]
#define Pstop @[@"stop", @"enough", @"bye", @"พอ", @"หยุด"]
#define PstopBurst PstopVideo
#else
#define PtakePhoto @[@"capture", @"cheese", @"shoot", @"smile", @"snap", @"selfie", @"photo"]
#define Pburst @[@"burst", @"continuous"]
#define PcaptureVideo @[@"video", @"film", @"record video", @"take video"]
#define Pstop @[@"stop", @"enough", @"bye"]
#define PstopBurst Pstop
#endif