#import "DesktopCat.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
@interface SCWalkerView:NSView
@property (weak) SCDesktopCat *owner;
@property NSImage *image;
@property NSString *state;
@property CGFloat look;
@property CGFloat bounce;
@property NSPoint down;
@property BOOL dragging;
@property NSTrackingArea *tracking;
@end
@interface SCDesktopCat ()
@property SCWalkerView *view;
@property NSTimer *timer;
@property NSDictionary *frames;
@property NSString *state;
@property NSPoint target;
@property NSTimeInterval deadline;
@property NSTimeInterval lastTick;
@property NSTimeInterval lastTouch;
@property NSTimeInterval lastAsk;
@property NSTimeInterval lastPounce;
@property NSPoint lastMouse;
@property CGFloat petDistance;
@property NSInteger pokes;
@property NSUInteger frame;
@property CGWindowID perchID;
@property NSRect perchBounds;
@end
@implementation SCWalkerView
- (BOOL)isOpaque{return NO;}
- (void)drawRect:(NSRect)dirty {
    BOOL reduced=NSWorkspace.sharedWorkspace.accessibilityDisplayShouldReduceMotion;
    [[NSGraphicsContext currentContext] saveGraphicsState];NSAffineTransform *t=[NSAffineTransform transform];[t translateXBy:80 yBy:40];
    if([self.state isEqualToString:@"sleep"]){[t rotateByDegrees:78];[t scaleBy:.82];}
    else if([self.state isEqualToString:@"angry"] && !reduced)[t rotateByDegrees:sin(NSDate.timeIntervalSinceReferenceDate*14)*4];
    else if(!reduced)[t rotateByDegrees:self.look*5];
    [t translateXBy:-80 yBy:-40];[t concat];[self.image drawInRect:NSMakeRect(14,8+(reduced?0:self.bounce),132,140) fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1 respectFlipped:NO hints:nil];[[NSGraphicsContext currentContext] restoreGraphicsState];
    NSString *label=[self.state isEqualToString:@"sleep"]?@"z Z":([self.state isEqualToString:@"angry"]?@"!":([self.state isEqualToString:@"affection"]?@"♡":([self.state isEqualToString:@"ask"]?@"♡ ?":@"")));
    [label drawAtPoint:NSMakePoint(118,130) withAttributes:@{NSFontAttributeName:[NSFont systemFontOfSize:20 weight:NSFontWeightSemibold],NSForegroundColorAttributeName:NSColor.labelColor}];
}
- (void)updateTrackingAreas {if(self.tracking)[self removeTrackingArea:self.tracking];self.tracking=[[NSTrackingArea alloc] initWithRect:self.bounds options:NSTrackingMouseMoved|NSTrackingActiveAlways|NSTrackingInVisibleRect owner:self userInfo:nil];[self addTrackingArea:self.tracking];[super updateTrackingAreas];}
- (void)mouseDown:(NSEvent *)e {self.down=NSEvent.mouseLocation;self.dragging=NO;self.owner.lastTouch=NSDate.timeIntervalSinceReferenceDate;}
- (void)mouseDragged:(NSEvent *)e {NSPoint now=NSEvent.mouseLocation;CGFloat dx=now.x-self.down.x,dy=now.y-self.down.y;if(hypot(dx,dy)>4)self.dragging=YES;if(self.dragging){NSRect f=self.window.frame;f.origin.x+=dx;f.origin.y+=dy;[self.window setFrameOrigin:f.origin];self.down=now;self.owner.state=@"drag";}}
- (void)mouseUp:(NSEvent *)e {if(self.dragging){self.dragging=NO;[self.owner perch];return;}if(e.clickCount>=2){if(self.owner.openChat)self.owner.openChat();return;}self.owner.pokes++;self.owner.state=@"angry";self.owner.deadline=NSDate.timeIntervalSinceReferenceDate+3;self.owner.perchID=0;if(self.owner.event)self.owner.event(@"poke",@"喵！轻一点嘛。");}
- (void)rightMouseDown:(NSEvent *)e {NSMenu *m=[NSMenu new];for(NSArray *a in @[@[@"聊聊天 / Chat",@"chat"],@[@"扑鼠标 / Pounce",@"pounce"],@[@"趴窗边 / Perch",@"perch"],@[@"跑一圈 / Run",@"run"],@[@"睡一会 / Sleep",@"sleep"],@[@"回小窝 / Return",@"hide"]]){NSMenuItem *i=[m addItemWithTitle:a[0] action:NSSelectorFromString(a[1]) keyEquivalent:@""];i.target=self.owner;}[NSMenu popUpContextMenu:m withEvent:e forView:self];}
@end
@implementation SCDesktopCat
- (instancetype)init {if((self=[super init])){NSMutableDictionary *frames=[NSMutableDictionary new];for(NSString *state in @[@"idle",@"waving",@"running-left",@"running-right"]){NSMutableArray *a=[NSMutableArray new];for(int i=0;i<8;i++){NSURL *u=[NSBundle.mainBundle URLForResource:[NSString stringWithFormat:@"%02d",i] withExtension:@"png" subdirectory:[@"SalahCat/" stringByAppendingString:state]];if(u){NSImage *image=[[NSImage alloc]initWithContentsOfURL:u];if(image)[a addObject:image];}}frames[state]=a;}_frames=frames;_state=@"idle";_lastTouch=NSDate.timeIntervalSinceReferenceDate;_lastAsk=_lastTouch;_lastPounce=_lastTouch;_deadline=_lastTouch+20;}return self;}
- (void)show {if(!self.panel){self.panel=[[NSPanel alloc]initWithContentRect:NSMakeRect(300,100,160,166) styleMask:NSWindowStyleMaskBorderless|NSWindowStyleMaskNonactivatingPanel backing:NSBackingStoreBuffered defer:NO];self.panel.opaque=NO;self.panel.backgroundColor=NSColor.clearColor;self.panel.level=NSFloatingWindowLevel;self.panel.hidesOnDeactivate=NO;self.panel.hasShadow=NO;self.panel.collectionBehavior=NSWindowCollectionBehaviorCanJoinAllSpaces|NSWindowCollectionBehaviorFullScreenAuxiliary;self.view=[[SCWalkerView alloc]initWithFrame:NSMakeRect(0,0,160,166)];self.view.owner=self;self.view.accessibilityLabel=@"礼拜喵 / Prayer Cat";self.panel.contentView=self.view;}[self.panel orderFront:nil];self.lastTick=NSDate.timeIntervalSinceReferenceDate;if(!self.timer)self.timer=[NSTimer scheduledTimerWithTimeInterval:1.0/30 target:self selector:@selector(tick) userInfo:nil repeats:YES];[self run];}
- (void)hide {[self.panel orderOut:nil];[self.timer invalidate];self.timer=nil;if(self.event)self.event(@"home",@"");}
- (void)chat {if(self.openChat)self.openChat();}
- (NSScreen *)screenForPoint:(NSPoint)p {for(NSScreen *s in NSScreen.screens)if(NSPointInRect(p,s.frame))return s;return self.panel.screen ?: NSScreen.mainScreen;}
- (void)run {NSRect screen=[self screenForPoint:self.panel.frame.origin].visibleFrame;self.state=@"run";self.perchID=0;self.target=NSMakePoint(screen.origin.x+arc4random_uniform(MAX(1,(uint32_t)(screen.size.width-160))),screen.origin.y+8);self.deadline=NSDate.timeIntervalSinceReferenceDate+8;}
- (void)sleep {self.state=@"sleep";self.deadline=NSDate.timeIntervalSinceReferenceDate+120;self.perchID=0;if(self.event)self.event(@"quiet",@"我睡一小会儿，安静陪你。");}
- (void)pounce {if(NSWorkspace.sharedWorkspace.accessibilityDisplayShouldReduceMotion)return;self.state=@"pounce";self.perchID=0;NSPoint cursor=NSEvent.mouseLocation;self.target=NSMakePoint(cursor.x-80,cursor.y-30);self.deadline=NSDate.timeIntervalSinceReferenceDate+.85;self.lastPounce=NSDate.timeIntervalSinceReferenceDate;}
- (NSArray *)windowBounds {CFArrayRef raw=CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly|kCGWindowListExcludeDesktopElements,kCGNullWindowID);return CFBridgingRelease(raw) ?: @[];}
- (void)perch {
    self.state=@"perch";self.deadline=NSDate.timeIntervalSinceReferenceDate+45;self.perchID=0;
    // Only public window geometry. No titles, screenshots, Accessibility permission or input injection.
    CGFloat top=NSMaxY(NSScreen.screens.firstObject.frame);
    for(NSDictionary *w in [self windowBounds]){if([w[(id)kCGWindowLayer] intValue]!=0 || [w[(id)kCGWindowOwnerPID] intValue]==NSProcessInfo.processInfo.processIdentifier)continue;CGRect b; if(!CGRectMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)w[(id)kCGWindowBounds],&b)||b.size.width<280||b.size.height<180)continue;
        self.perchID=[w[(id)kCGWindowNumber] unsignedIntValue];self.perchBounds=NSMakeRect(b.origin.x,top-b.origin.y-b.size.height,b.size.width,b.size.height);self.target=NSMakePoint(NSMaxX(self.perchBounds)-155,NSMaxY(self.perchBounds)-16);return;}
    NSRect area=[self screenForPoint:self.panel.frame.origin].visibleFrame;self.target=NSMakePoint(NSMaxX(area)-180,area.origin.y+8);
}
- (void)tick {
    NSTimeInterval now=NSDate.timeIntervalSinceReferenceDate,dt=MIN(.05,now-self.lastTick);self.lastTick=now;self.frame++;
    BOOL reduced=NSWorkspace.sharedWorkspace.accessibilityDisplayShouldReduceMotion;BOOL quiet=self.quiet?self.quiet():NO;
    NSPoint cursor=NSEvent.mouseLocation;NSRect current=self.panel.frame;BOOL over=NSPointInRect(cursor,NSInsetRect(current,20,18));CGFloat mouseTravel=hypot(cursor.x-self.lastMouse.x,cursor.y-self.lastMouse.y);
    if(over && !self.view.dragging && mouseTravel<50 && mouseTravel>1){self.petDistance+=mouseTravel;self.lastTouch=now;if(self.petDistance>160){self.petDistance=0;self.state=@"affection";self.deadline=now+4;if(self.event)self.event(@"pet",@"呼噜～这样摸摸，好舒服。");}}
    else if(!over)self.petDistance=0;self.lastMouse=cursor;
    if(self.view.dragging)return;
    if(quiet && ([@[@"run",@"pounce",@"ask"] containsObject:self.state])){self.state=@"idle";self.deadline=now+60;}
    if(now>self.deadline){if(quiet || now-self.lastTouch>180){self.state=@"sleep";self.deadline=now+60;}else if(now-self.lastAsk>1200){self.state=@"ask";self.deadline=now+6;self.lastAsk=now;if(self.event)self.event(@"ask",@"有空的时候，可以摸摸我吗？");}else if(arc4random_uniform(3)==0)[self run];else [self perch];}
    if(!quiet&&!reduced&&!over&&mouseTravel>2&&mouseTravel<80&&now-self.lastPounce>45&&hypot(cursor.x-NSMidX(current),cursor.y-NSMidY(current))<260)[self pounce];
    if(self.perchID && self.frame%15==0){BOOL found=NO;CGFloat top=NSMaxY(NSScreen.screens.firstObject.frame);for(NSDictionary *w in [self windowBounds])if([w[(id)kCGWindowNumber] unsignedIntValue]==self.perchID){CGRect b;if(CGRectMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)w[(id)kCGWindowBounds],&b)){self.target=NSMakePoint(b.origin.x+b.size.width-155,top-b.origin.y-16);found=YES;}break;}if(!found)[self run];}
    BOOL moving=[@[@"run",@"perch",@"pounce"] containsObject:self.state];CGFloat dx=self.target.x-current.origin.x,dy=self.target.y-current.origin.y;
    if(moving&&!reduced){CGFloat distance=hypot(dx,dy),speed=[self.state isEqualToString:@"pounce"]?650:180;if(distance>2){CGFloat step=MIN(1,speed*dt/MAX(1,distance));current.origin.x+=dx*step;current.origin.y+=dy*step;}else if([self.state isEqualToString:@"run"]){self.state=@"idle";self.deadline=now+20;}}
    NSScreen *screen=[self screenForPoint:NSMakePoint(NSMidX(current),NSMidY(current))];NSRect area=screen.visibleFrame;current.origin.x=MAX(area.origin.x,MIN(current.origin.x,NSMaxX(area)-current.size.width));current.origin.y=MAX(area.origin.y,MIN(current.origin.y,NSMaxY(area)-current.size.height));[self.panel setFrameOrigin:current.origin];
    NSString *sprite=moving&&hypot(dx,dy)>5&&!reduced?(dx<0?@"running-left":@"running-right"):( [@[@"affection",@"ask"] containsObject:self.state]?@"waving":@"idle");NSArray *frames=self.frames[sprite];if(!frames.count)frames=self.frames[@"idle"];
    self.view.image=frames.count?frames[(reduced?0:self.frame/4)%frames.count]:nil;self.view.state=self.state;self.view.look=MAX(-1,MIN(1,(cursor.x-NSMidX(current))/200));self.view.bounce=[self.state isEqualToString:@"pounce"]?MAX(0,sin((.85-(self.deadline-now))/.85*M_PI)*22):0;[self.view setNeedsDisplay:YES];
}
- (void)stop {[self.timer invalidate];self.timer=nil;[self.panel orderOut:nil];}
@end
