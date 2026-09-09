#import "LocalEngine.h"
#import <CommonCrypto/CommonDigest.h>
#include "llama.h"
#include <vector>
#include <string>
#include <memory>
static void SCQuietLog(enum ggml_log_level level,const char *text,void *user) {}
static BOOL SCHashFile(NSURL *url, NSString *expected) {
    NSInputStream *s=[NSInputStream inputStreamWithURL:url];[s open];CC_SHA256_CTX ctx;CC_SHA256_Init(&ctx);
    uint8_t buffer[65536];NSInteger n;
    while((n=[s read:buffer maxLength:sizeof(buffer)])>0) CC_SHA256_Update(&ctx,buffer,(CC_LONG)n);
    [s close];if(n<0)return NO;unsigned char digest[CC_SHA256_DIGEST_LENGTH];CC_SHA256_Final(digest,&ctx);
    NSMutableString *hex=[NSMutableString new];for(int i=0;i<CC_SHA256_DIGEST_LENGTH;i++)[hex appendFormat:@"%02x",digest[i]];
    return [hex isEqualToString:expected];
}
@interface SCLocalEngine ()
@property dispatch_queue_t queue;
@end
@implementation SCLocalEngine
- (instancetype)init {if((self=[super init])){_queue=dispatch_queue_create("com.salahcat.inference",DISPATCH_QUEUE_SERIAL);static dispatch_once_t once;dispatch_once(&once,^{llama_log_set(SCQuietLog,NULL);llama_backend_init();});}return self;}
- (void)cancel {self.cancelled=YES;}
- (void)generate:(NSArray *)messages path:(NSString *)path partial:(void (^)(NSString *))partial completion:(void (^)(NSString *,NSString *))completion {
    self.cancelled=NO;
    dispatch_async(self.queue,^{ @autoreleasepool {
        auto done=^(NSString *text,NSString *error){dispatch_async(dispatch_get_main_queue(),^{completion(text,error);});};
        llama_model_params mp=llama_model_default_params();mp.n_gpu_layers=0;
        mp.progress_callback=[](float progress,void *data)->bool{return ![(__bridge SCLocalEngine *)data cancelled];};mp.progress_callback_user_data=(__bridge void *)self;
        std::unique_ptr<llama_model,decltype(&llama_model_free)> model(llama_model_load_from_file(path.fileSystemRepresentation,mp),llama_model_free);
        if(!model){done(nil,self.cancelled?@"已停止。":@"模型无法载入，请在设置中重新下载。");return;}
        llama_context_params cp=llama_context_default_params();cp.n_ctx=8192;cp.n_batch=256;cp.n_ubatch=256;cp.n_threads=(int32_t)MIN(4,NSProcessInfo.processInfo.activeProcessorCount);cp.n_threads_batch=cp.n_threads;
        cp.abort_callback=[](void *data)->bool{return [(__bridge SCLocalEngine *)data cancelled];};cp.abort_callback_data=(__bridge void *)self;
        std::unique_ptr<llama_context,decltype(&llama_free)> ctx(llama_init_from_model(model.get(),cp),llama_free);
        if(!ctx){done(nil,@"可用内存不足，请选择轻量模型或关闭其他应用。");return;}
        // Fixed ChatML template for the pinned Qwen3 models; disable thinking for concise companion replies.
        NSMutableString *prompt=[NSMutableString new];
        for(NSDictionary *m in messages){NSString *role=m[@"role"],*content=m[@"content"];if(![@[@"system",@"user",@"assistant"] containsObject:role]||![content isKindOfClass:NSString.class])continue;
            content=[content stringByReplacingOccurrencesOfString:@"<|" withString:@"＜｜"];
            [prompt appendFormat:@"<|im_start|>%@\n%@<|im_end|>\n",role,content];}
        [prompt appendString:@"<|im_start|>assistant\n<think>\n\n</think>\n\n"];
        const llama_vocab *vocab=llama_model_get_vocab(model.get());std::string input=prompt.UTF8String;
        int n=-llama_tokenize(vocab,input.data(),(int)input.size(),NULL,0,true,true);
        if(n<=0 || n>7500){done(nil,@"这次上下文较长，请开启新对话或缩短备忘内容后重试。");return;}
        std::vector<llama_token> tokens(n);llama_tokenize(vocab,input.data(),(int)input.size(),tokens.data(),n,true,true);
        for(int offset=0;offset<n;offset+=256){int count=std::min(256,n-offset);auto batch=llama_batch_get_one(tokens.data()+offset,count);if(self.cancelled||llama_decode(ctx.get(),batch)!=0){done(nil,self.cancelled?@"已停止。":@"本次模型计算失败，请重试。");return;}}
        std::unique_ptr<llama_sampler,decltype(&llama_sampler_free)> sampler(llama_sampler_chain_init(llama_sampler_chain_default_params()),llama_sampler_free);
        llama_sampler_chain_add(sampler.get(),llama_sampler_init_top_k(40));llama_sampler_chain_add(sampler.get(),llama_sampler_init_top_p(.9,1));llama_sampler_chain_add(sampler.get(),llama_sampler_init_temp(.65));llama_sampler_chain_add(sampler.get(),llama_sampler_init_dist(LLAMA_DEFAULT_SEED));
        std::string output;NSTimeInterval started=NSDate.timeIntervalSinceReferenceDate,last=started;
        for(int i=0;i<400&&!self.cancelled;i++){
            if(NSDate.timeIntervalSinceReferenceDate-started>90)break;
            llama_token token=llama_sampler_sample(sampler.get(),ctx.get(),-1);if(llama_vocab_is_eog(vocab,token))break;
            char piece[256];int length=llama_token_to_piece(vocab,token,piece,sizeof(piece),0,false);if(length>0)output.append(piece,length);
            if(NSDate.timeIntervalSinceReferenceDate-last>.12){NSString *text=[[NSString alloc] initWithBytes:output.data() length:output.size() encoding:NSUTF8StringEncoding];if(text){dispatch_async(dispatch_get_main_queue(),^{partial(text);});last=NSDate.timeIntervalSinceReferenceDate;}}
            auto batch=llama_batch_get_one(&token,1);if(llama_decode(ctx.get(),batch)!=0)break;
        }
        NSString *reply=[[NSString alloc] initWithBytes:output.data() length:output.size() encoding:NSUTF8StringEncoding];
        if(self.cancelled)done(nil,@"已停止回复。");else done(reply,reply.length?nil:@"这次没有生成文字，请重试。");
    }});
}
@end
@implementation SCModelStore
- (instancetype)initWithDirectory:(NSURL *)directory {
    if((self=[super init])){
        _directory=directory;[NSFileManager.defaultManager createDirectoryAtURL:directory withIntermediateDirectories:YES attributes:@{NSFilePosixPermissions:@0700} error:nil];
        NSData *data=[NSData dataWithContentsOfURL:[NSBundle.mainBundle URLForResource:@"Models" withExtension:@"json"]];
        _catalog=data?[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]:@[];
        NSURLSessionConfiguration *c=NSURLSessionConfiguration.ephemeralSessionConfiguration;c.timeoutIntervalForRequest=60;c.timeoutIntervalForResource=3600;
        _session=[NSURLSession sessionWithConfiguration:c delegate:self delegateQueue:nil];
    }return self;
}
- (NSURL *)installedURL:(NSDictionary *)model {
    if(![model[@"filename"] isKindOfClass:NSString.class])return nil;
    NSURL *url=[self.directory URLByAppendingPathComponent:model[@"filename"]];
    NSDictionary *a=[NSFileManager.defaultManager attributesOfItemAtPath:url.path error:nil];
    NSString *stamp=[NSString stringWithContentsOfURL:[url URLByAppendingPathExtension:@"verified"] encoding:NSUTF8StringEncoding error:nil];
    if([a[NSFileSize] unsignedLongLongValue]==[model[@"size"] unsignedLongLongValue] && [stamp isEqualToString:model[@"sha256"]])return url;
    NSURL *bundled=[NSBundle.mainBundle URLForResource:model[@"filename"] withExtension:nil subdirectory:@"Models"];
    NSDictionary *packaged=bundled?[NSFileManager.defaultManager attributesOfItemAtPath:bundled.path error:nil]:nil;
    return [packaged[NSFileSize] unsignedLongLongValue]==[model[@"size"] unsignedLongLongValue] ? bundled:nil;
}
- (void)notify:(double)progress text:(NSString *)text {dispatch_async(dispatch_get_main_queue(),^{if(self.changed)self.changed(progress,text);});}
- (void)downloadModel:(NSDictionary *)model {
    if(self.download)return;
    NSNumber *space=nil;[self.directory getResourceValue:&space forKey:NSURLVolumeAvailableCapacityForImportantUsageKey error:nil];
    if(space && space.longLongValue<[model[@"size"] longLongValue]+512*1024*1024){[self notify:-1 text:@"存储空间不足，请先释放空间。"];return;}
    self.downloadingModel=model;self.download=[self.session downloadTaskWithURL:[NSURL URLWithString:model[@"url"]]];
    [self notify:0 text:@"开始下载模型，可以取消。首次下载后可离线聊天。"];[self.download resume];
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)task didWriteData:(int64_t)bytes totalBytesWritten:(int64_t)written totalBytesExpectedToWrite:(int64_t)expected {
    double total=[self.downloadingModel[@"size"] doubleValue];
    [self notify:MIN(.99,written/total) text:[NSString stringWithFormat:@"下载中 · %.0f / %.0f MB",written/1e6,total/1e6]];
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)task didFinishDownloadingToURL:(NSURL *)location {
    NSDictionary *model=self.downloadingModel;
    NSDictionary *attrs=[NSFileManager.defaultManager attributesOfItemAtPath:location.path error:nil];
    [self notify:.99 text:@"下载完成，正在验证完整性…"];
    if([(NSHTTPURLResponse *)task.response statusCode]!=200 || [attrs[NSFileSize] unsignedLongLongValue]!=[model[@"size"] unsignedLongLongValue] || !SCHashFile(location,model[@"sha256"])){
        [self notify:-1 text:@"下载文件校验未通过，请重试。"];return;
    }
    if(task.state==NSURLSessionTaskStateCanceling)return;
    NSURL *target=[self.directory URLByAppendingPathComponent:model[@"filename"]];NSError *error=nil;
    if([NSFileManager.defaultManager fileExistsAtPath:target.path])[NSFileManager.defaultManager removeItemAtURL:target error:&error];
    if(!error)[NSFileManager.defaultManager moveItemAtURL:location toURL:target error:&error];
    if(!error)[model[@"sha256"] writeToURL:[target URLByAppendingPathExtension:@"verified"] atomically:YES encoding:NSUTF8StringEncoding error:&error];
    [target setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:nil];
    [self notify:error?-1:1 text:error?@"模型保存失败，请检查可用空间后重试。":@"模型已就绪，可以离线聊天。"];
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(),^{self.download=nil;self.downloadingModel=nil;if(error && self.changed)self.changed(-1,error.code==NSURLErrorCancelled?@"下载已取消，可重新下载。":@"下载中断，请检查网络后重试。");});
}
- (void)cancel {[self.download cancel];}
- (BOOL)removeModel:(NSDictionary *)model error:(NSError **)error {
    NSURL *url=[self.directory URLByAppendingPathComponent:model[@"filename"]];
    if(![NSFileManager.defaultManager fileExistsAtPath:url.path])return YES;
    BOOL ok=[NSFileManager.defaultManager removeItemAtURL:url error:error];
    if(ok)[NSFileManager.defaultManager removeItemAtURL:[url URLByAppendingPathExtension:@"verified"] error:nil];return ok;
}
@end
