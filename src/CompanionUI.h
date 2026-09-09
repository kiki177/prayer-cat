#import <Cocoa/Cocoa.h>
#import "CompanionCore.h"
#import "LocalEngine.h"
@interface SCCompanion : NSObject <NSWindowDelegate>
@property NSString *city;
@property NSString *country;
@property NSString *language;
@property NSTimeZone *zone;
@property NSURL *memoDirectory;
@property SCMemory *memory;
@property NSPanel *panel;
@property (copy) void (^moodChanged)(NSString *,NSString *);
@property (readonly) BOOL quiet;
@property (readonly) BOOL memoryEnabled;
- (instancetype)initWithMemoDirectory:(NSURL *)directory;
- (void)showChat;
- (void)showSettings;
- (void)showMemory;
- (void)checkDailyNews;
- (void)manualNews;
- (void)record:(NSString *)kind text:(NSString *)text;
- (void)say:(NSString *)text;
- (void)stop;
@end
