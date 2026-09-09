#import <Foundation/Foundation.h>
@interface SCLocalEngine : NSObject
@property (atomic) BOOL cancelled;
- (void)generate:(NSArray<NSDictionary *> *)messages path:(NSString *)path partial:(void (^)(NSString *))partial completion:(void (^)(NSString *, NSString *))completion;
- (void)cancel;
@end
@interface SCModelStore : NSObject <NSURLSessionDownloadDelegate>
@property NSArray<NSDictionary *> *catalog;
@property NSURL *directory;
@property NSURLSession *session;
@property NSURLSessionDownloadTask *download;
@property NSDictionary *downloadingModel;
@property (copy) void (^changed)(double, NSString *);
- (instancetype)initWithDirectory:(NSURL *)directory;
- (NSURL *)installedURL:(NSDictionary *)model;
- (void)downloadModel:(NSDictionary *)model;
- (void)cancel;
- (BOOL)removeModel:(NSDictionary *)model error:(NSError **)error;
@end
