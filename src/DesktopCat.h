#import <Cocoa/Cocoa.h>
@interface SCDesktopCat : NSObject
@property NSPanel *panel;
@property (copy) void (^event)(NSString *,NSString *);
@property (copy) void (^openChat)(void);
@property (copy) BOOL (^quiet)(void);
- (void)show;
- (void)hide;
- (void)run;
- (void)sleep;
- (void)perch;
- (void)pounce;
- (void)stop;
@end
