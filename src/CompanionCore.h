#import <Foundation/Foundation.h>
NSString *SCDateKey(NSDate *date, NSTimeZone *zone);
BOOL SCClaimNewsDay(NSDate *date, NSTimeZone *zone, NSUserDefaults *defaults);
NSString *SCCountryCode(NSString *country);
@interface SCMemory : NSObject
@property NSURL *directory;
@property NSMutableArray<NSDictionary *> *events;
@property NSMutableArray<NSDictionary *> *facts;
@property NSString *lastError;
- (instancetype)initWithDirectory:(NSURL *)directory;
- (void)record:(NSString *)kind text:(NSString *)text;
- (NSString *)contextFor:(NSString *)query memoDirectory:(NSURL *)directory;
- (NSString *)report;
- (void)clear;
- (BOOL)prefersQuiet;
@end
@interface SCFeedParser : NSObject <NSXMLParserDelegate>
@property NSMutableArray<NSDictionary *> *items;
- (NSArray<NSDictionary *> *)parse:(NSData *)data;
@end
@interface SCNews : NSObject
@property NSURLSession *session;
+ (NSArray<NSDictionary *> *)sourcesForCountry:(NSString *)country language:(NSString *)language;
+ (NSArray<NSDictionary *> *)selectItems:(NSArray<NSDictionary *> *)items city:(NSString *)city now:(NSDate *)now zone:(NSTimeZone *)zone;
- (void)fetchCity:(NSString *)city country:(NSString *)country language:(NSString *)language zone:(NSTimeZone *)zone completion:(void (^)(NSArray<NSDictionary *> *, NSString *))completion;
@end
