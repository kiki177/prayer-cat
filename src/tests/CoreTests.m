#import "CompanionCore.h"
#define CHECK(x) do { if(!(x)){fprintf(stderr,"FAIL line %d: %s\n",__LINE__,#x);exit(1);}checks++; }while(0)
@interface SCTestDefaults:NSUserDefaults
@property NSMutableDictionary *values;
@end
@implementation SCTestDefaults
- (NSArray *)arrayForKey:(NSString *)key {return self.values[key];}
- (NSString *)stringForKey:(NSString *)key {return self.values[key];}
- (void)setObject:(id)value forKey:(NSString *)key {self.values[key]=value;}
@end
int main(int argc,const char **argv){@autoreleasepool{
 int checks=0;NSString *root=argc>1?@(argv[1]):@".";
 NSTimeZone *sh=[NSTimeZone timeZoneWithName:@"Asia/Shanghai"],*ny=[NSTimeZone timeZoneWithName:@"America/New_York"];
 NSISO8601DateFormatter *iso=[NSISO8601DateFormatter new];NSDate *now=[iso dateFromString:@"2026-09-06T23:30:00Z"];
 SCTestDefaults *prefs=[SCTestDefaults new];prefs.values=[NSMutableDictionary new];
 CHECK(SCClaimNewsDay(now,sh,prefs));CHECK(!SCClaimNewsDay(now,sh,prefs));
 SCTestDefaults *reopen=[SCTestDefaults new];reopen.values=[prefs.values mutableCopy];CHECK(!SCClaimNewsDay(now,sh,reopen));CHECK(SCClaimNewsDay([now dateByAddingTimeInterval:86400],sh,reopen));CHECK(!SCClaimNewsDay(now,sh,reopen));CHECK(!SCClaimNewsDay(now,nil,reopen));
 CHECK([SCDateKey(now,sh) isEqualToString:@"2026-09-07"]);CHECK([SCDateKey(now,ny) isEqualToString:@"2026-09-06"]);CHECK([SCCountryCode(@" 英国 ") isEqualToString:@"GB"]);CHECK([SCCountryCode(@"United Kingdom") isEqualToString:@"GB"]);
 NSString *rss=@"<rss><channel><item><title><![CDATA[Shanghai & news]]></title><link>https://example.org/a?utm_source=x</link><pubDate>Sun, 06 Sep 2026 23:00:00 +0000</pubDate></item><item><title>Undated</title><link>https://example.org/b</link></item><item><title>Unsafe</title><link>file:///tmp/a</link><pubDate>Sun, 06 Sep 2026 23:00:00 +0000</pubDate></item></channel></rss>";
 NSArray *parsed=[[SCFeedParser new] parse:[rss dataUsingEncoding:NSUTF8StringEncoding]];CHECK(parsed.count==1);CHECK([parsed[0][@"title"] isEqualToString:@"Shanghai & news"]);
 NSString *atom=@"<feed xmlns='http://www.w3.org/2005/Atom'><entry><title>London update</title><link href='https://example.org/c'/><published>2026-09-06T22:00:00Z</published><updated>2026-09-06T23:00:00Z</updated></entry></feed>";
 NSArray *a=[[SCFeedParser new] parse:[atom dataUsingEncoding:NSUTF8StringEncoding]];CHECK(a.count==1);CHECK([a[0][@"date"] isEqualToDate:[iso dateFromString:@"2026-09-06T22:00:00Z"]]);
 CHECK([[[SCFeedParser new] parse:[@"<!DOCTYPE a [<!ENTITY x 'bad'>]><rss/>" dataUsingEncoding:NSUTF8StringEncoding]] count]==0);
 NSMutableArray *items=[NSMutableArray arrayWithArray:parsed];[items addObjectsFromArray:a];NSMutableDictionary *duplicate=[parsed[0] mutableCopy];duplicate[@"link"]=@"https://example.org/a?utm_source=y";[items addObject:duplicate];NSMutableDictionary *future=[a[0] mutableCopy];future[@"date"]=[now dateByAddingTimeInterval:3600];future[@"title"]=@"Future";future[@"link"]=@"https://example.org/future";[items addObject:future];NSMutableDictionary *old=[a[0] mutableCopy];old[@"date"]=[now dateByAddingTimeInterval:-86400];old[@"link"]=@"https://example.org/old";old[@"title"]=@"Old";[items addObject:old];
 NSArray *selected=[SCNews selectItems:items city:@"Shanghai" now:now zone:sh];CHECK(selected.count==2);CHECK([selected.firstObject[@"title"] isEqualToString:@"Shanghai & news"]);
 for(NSString *file in @[@"govuk.atom",@"nasa.xml"]){NSData *data=[NSData dataWithContentsOfFile:[root stringByAppendingPathComponent:[@"fixtures/" stringByAppendingString:file]]];CHECK(data.length>0);CHECK([[[SCFeedParser new] parse:data] count]>0);}
 NSURL *dir=[NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:NSUUID.UUID.UUIDString]];SCMemory *memory=[[SCMemory alloc] initWithDirectory:dir];[memory record:@"user" text:@"今天有点累"];CHECK(memory.facts.count==0);
 [memory record:@"user" text:@"记住：我叫 Kiki"];[memory record:@"user" text:@"记住：我叫 Kiki"];CHECK(memory.facts.count==1);
 [memory record:@"dismiss" text:@"关闭提醒"];[memory record:@"dismiss" text:@"关闭提醒"];[memory record:@"dismiss" text:@"关闭提醒"];CHECK(memory.facts.count==1);
 for(int i=1;i<3;i++){[memory.events addObject:@{@"kind":@"dismiss",@"date":SCDateKey([NSDate.date dateByAddingTimeInterval:-86400*i],NSTimeZone.localTimeZone),@"text":@"关闭提醒",@"time":@([NSDate.date timeIntervalSince1970]-86400*i),@"id":NSUUID.UUID.UUIDString}];}
 [memory record:@"dismiss" text:@"关闭提醒"];CHECK(memory.facts.count==2);CHECK(memory.prefersQuiet);
 SCMemory *reloaded=[[SCMemory alloc] initWithDirectory:dir];CHECK(reloaded.facts.count==2);CHECK(reloaded.events.count==memory.events.count);
 NSURL *memo=[dir URLByAppendingPathComponent:@"Notes"];[NSFileManager.defaultManager createDirectoryAtURL:memo withIntermediateDirectories:YES attributes:nil error:nil];NSString *body=[[@"random\n" stringByPaddingToLength:2000 withString:@"random\n" startingAtIndex:0] stringByAppendingString:@"项目截止日期在周五。"];
 [body writeToURL:[memo URLByAppendingPathComponent:@"deadline.md"] atomically:YES encoding:NSUTF8StringEncoding error:nil];NSString *context=[reloaded contextFor:@"截止日期是什么时候" memoDirectory:memo];CHECK([context containsString:@"项目截止日期在周五"]);CHECK([context containsString:@"deadline.md"]);
 [reloaded clear];SCMemory *empty=[[SCMemory alloc] initWithDirectory:dir];CHECK(empty.events.count==0 && empty.facts.count==0);CHECK([NSFileManager.defaultManager fileExistsAtPath:[memo URLByAppendingPathComponent:@"deadline.md"].path]);
 [@"{\"events\":null,\"facts\":42}" writeToURL:[dir URLByAppendingPathComponent:@"memory-v1.json"] atomically:YES encoding:NSUTF8StringEncoding error:nil];CHECK([[SCMemory alloc] initWithDirectory:dir].events.count==0);
 [NSFileManager.defaultManager removeItemAtURL:dir error:nil];printf("PASS %d core checks\n",checks);
}return 0;}
