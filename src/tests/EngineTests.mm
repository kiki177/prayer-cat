#import "LocalEngine.h"
int main(int argc,const char **argv){@autoreleasepool{
 if(argc<2)return 2;
 SCLocalEngine *engine=[SCLocalEngine new];__block BOOL done=NO;__block BOOL passed=NO;__block NSUInteger partials=0;NSDate *start=NSDate.date;
 [engine generate:@[@{@"role":@"system",@"content":@"你自己的名字是礼拜喵。用户的名字是Kiki。请简短回复中文。用户问他的名字时，回答“你叫Kiki”，不能说“我叫Kiki”。/no_think"},@{@"role":@"user",@"content":@"你记得我叫什么名字吗？"}] path:@(argv[1]) partial:^(NSString *t){partials++;} completion:^(NSString *text,NSString *error){printf("reply: %s\n",(text ?: error).UTF8String);passed=text.length>0 && [text containsString:@"Kiki"] && ![text containsString:@"我叫"];done=YES;}];
 while(!done && -start.timeIntervalSinceNow<180)[NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.05]];
 printf("inference: %s; partials=%lu; seconds=%.1f\n",passed?"PASS":"FAIL",(unsigned long)partials,-start.timeIntervalSinceNow);
 if(!passed)return 1;
 done=NO;passed=NO;start=NSDate.date;
 [engine generate:@[@{@"role":@"user",@"content":@"写一篇很长的故事"}] path:@(argv[1]) partial:^(NSString *t){} completion:^(NSString *text,NSString *error){passed=error.length>0;done=YES;}];
 [engine cancel];while(!done && -start.timeIntervalSinceNow<30)[NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.05]];
 printf("cancellation: %s\n",passed?"PASS":"FAIL");return passed?0:1;
}}
