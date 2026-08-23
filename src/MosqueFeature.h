#import <Cocoa/Cocoa.h>

@interface SalahMosqueController : NSObject
@property (copy) NSString *language;
@property (copy) NSDictionary<NSString *, NSString *> *prayerTimings;
- (void)show;
- (void)refreshForReminderIfNeeded;
@end
