#import "CompanionUI.h"
@interface SCCompanion (Testing)
- (void)build;
- (NSTextField *)addBubble:(NSString *)text user:(BOOL)user;
@end
static void InvalidateTree(NSView *v){v.needsDisplay=YES;for(NSView *child in v.subviews)InvalidateTree(child);}
int main(int argc,const char **argv){@autoreleasepool{
 if(argc<2)return 2;[NSApplication sharedApplication];NSString *destination=@(argv[1]);
 NSURL *tmp=[NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:NSUUID.UUID.UUIDString]];
 SCCompanion *c=[[SCCompanion alloc] initWithMemoDirectory:[tmp URLByAppendingPathComponent:@"KnowledgeSpace"]];c.language=@"zh";[c build];
 [c addBubble:@"今天有点累，想安静待一会儿。" user:YES];
 [c addBubble:@"那就先歇一会儿吧。我在窗边陪着你，不着急说话。" user:NO];
 for(NSString *theme in @[@"light",@"dark"]){
  c.panel.appearance=[NSAppearance appearanceNamed:[theme isEqualToString:@"dark"]?NSAppearanceNameDarkAqua:NSAppearanceNameAqua];
  for(NSNumber *width in @[@460,@420]){
   [c.panel setContentSize:NSMakeSize(width.doubleValue,640)];[c.panel.contentView layoutSubtreeIfNeeded];
   NSDate *until=[NSDate dateWithTimeIntervalSinceNow:.25];while(until.timeIntervalSinceNow>0)[NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.02]];
   NSView *v=c.panel.contentView;InvalidateTree(v);[v displayIfNeeded];NSBitmapImageRep *rep=[v bitmapImageRepForCachingDisplayInRect:v.bounds];[v cacheDisplayInRect:v.bounds toBitmapImageRep:rep];
   NSString *file=[destination stringByAppendingPathComponent:[NSString stringWithFormat:@"chat-%@-%@.png",theme,width]];
   [[rep representationUsingType:NSBitmapImageFileTypePNG properties:@{}] writeToFile:file atomically:YES];printf("render %s\n",file.UTF8String);
  }
 }
 [c stop];[NSFileManager.defaultManager removeItemAtURL:tmp error:nil];return 0;
}}
