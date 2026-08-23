#import <Cocoa/Cocoa.h>
#import <UserNotifications/UserNotifications.h>
#import <Security/Security.h>
#import "MosqueFeature.h"

static NSString * const SalahCatOpenAIKeychainService = @"com.yuqiqi.salahcat.openai-api-key";
static NSString * const SalahCatOpenAIKeychainAccount = @"local-user";

static NSString *SalahCatArabicText(NSString *english) {
  if ([english isEqualToString:@"Prayer Cat"]) return @"Salah Cat";
  if ([english isEqualToString:@"Show Prayer Cat"]) return @"إظهار Salah Cat";
  if ([english isEqualToString:@"Talk with Prayer Cat…"]) return @"التحدث مع Salah Cat…";
  if ([english isEqualToString:@"Chat with me in ChatGPT"]) return @"تحدث معي عبر ChatGPT";
  if ([english isEqualToString:@"Memo space…"]) return @"مساحة الملاحظات…";
  if ([english isEqualToString:@"Nearby mosques…"]) return @"المساجد القريبة…";
  if ([english isEqualToString:@"Follow cursor"]) return @"اتبع المؤشر";
  if ([english isEqualToString:@"Refresh prayer times"]) return @"تحديث مواقيت الصلاة";
  if ([english isEqualToString:@"Ramadan mode"]) return @"وضع رمضان";
  if ([english isEqualToString:@"Settings…"]) return @"الإعدادات…";
  if ([english isEqualToString:@"Quit Prayer Cat"]) return @"إنهاء Salah Cat";
  if ([english isEqualToString:@"Chat with me"]) return @"تحدث معي";
  if ([english isEqualToString:@"Memo"]) return @"الملاحظات";
  if ([english isEqualToString:@"Open folder"]) return @"فتح المجلد";
  if ([english isEqualToString:@"Save note"]) return @"حفظ الملاحظة";
  if ([english isEqualToString:@"Memo space"]) return @"مساحة الملاحظات";
  if ([english isEqualToString:@"Prayer Cat knowledge space"]) return @"مساحة معرفة Salah Cat";
  if ([english isEqualToString:@"Saved notes"]) return @"الملاحظات المحفوظة";
  if ([english isEqualToString:@"Right-click to update or change settings"]) return @"انقر بزر الفأرة الأيمن للتحديث أو تغيير الإعدادات";
  if ([english isEqualToString:@"Opens ChatGPT in your browser; sign in with your own account."]) return @"يفتح ChatGPT في المتصفح؛ سجل الدخول بحسابك الشخصي.";
  if ([english isEqualToString:@"Write notes that stay only on this Mac."]) return @"اكتب ملاحظات تبقى محفوظة على هذا الـ Mac فقط.";
  if ([english isEqualToString:@"I opened ChatGPT in your browser. Sign in with your own account, friend."]) return @"فتحت ChatGPT في المتصفح. سجل الدخول بحسابك الشخصي.";
  if ([english isEqualToString:@"Write a note below. It stays only on this Mac."]) return @"اكتب ملاحظة أدناه؛ ستبقى على هذا الـ Mac فقط.";
  if ([english isEqualToString:@"No saved notes yet. Write one above and it will stay on this Mac."]) return @"لا توجد ملاحظات محفوظة بعد. اكتب ملاحظة وستبقى على هذا الـ Mac.";
  if ([english isEqualToString:@"Draft saved locally"]) return @"تم حفظ المسودة محلياً";
  if ([english isEqualToString:@"Write a note first"]) return @"اكتب ملاحظة أولاً";
  if ([english isEqualToString:@"Saved in your local knowledge space"]) return @"تم الحفظ في مساحة المعرفة المحلية";
  if ([english isEqualToString:@"Opened your local memo folder"]) return @"تم فتح مجلد الملاحظات المحلي";
  if ([english isEqualToString:@"I’m back"]) return @"لقد عدت";
  if ([english isEqualToString:@"Welcome back, friend. I hope your time was peaceful."]) return @"مرحباً بعودتك. أتمنى أن يكون وقتك هادئاً.";
  return english;
}

static NSString *SalahCatReadOpenAIKey(void) {
  NSDictionary *query=@{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                        (__bridge id)kSecAttrService:SalahCatOpenAIKeychainService,
                        (__bridge id)kSecAttrAccount:SalahCatOpenAIKeychainAccount,
                        (__bridge id)kSecReturnData:@YES,
                        (__bridge id)kSecMatchLimit:(__bridge id)kSecMatchLimitOne};
  CFTypeRef result=NULL;
  OSStatus status=SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
  if (status != errSecSuccess || !result) return nil;
  NSData *data=(__bridge_transfer NSData *)result;
  return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

static BOOL SalahCatStoreOpenAIKey(NSString *key) {
  NSDictionary *base=@{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                       (__bridge id)kSecAttrService:SalahCatOpenAIKeychainService,
                       (__bridge id)kSecAttrAccount:SalahCatOpenAIKeychainAccount};
  SecItemDelete((__bridge CFDictionaryRef)base);
  NSMutableDictionary *item=[base mutableCopy];
  item[(__bridge id)kSecValueData]=[key dataUsingEncoding:NSUTF8StringEncoding];
  item[(__bridge id)kSecAttrAccessible]=(__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly;
  return SecItemAdd((__bridge CFDictionaryRef)item, NULL) == errSecSuccess;
}

static void SalahCatDeleteOpenAIKey(void) {
  NSDictionary *query=@{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                        (__bridge id)kSecAttrService:SalahCatOpenAIKeychainService,
                        (__bridge id)kSecAttrAccount:SalahCatOpenAIKeychainAccount};
  SecItemDelete((__bridge CFDictionaryRef)query);
}

@protocol SalahPetActions <NSObject>
- (void)petClickedAt:(NSPoint)point clickCount:(NSInteger)count;
- (void)petRightClicked:(NSEvent *)event fromView:(NSView *)view;
- (void)petMouseMoved:(NSEvent *)event;
 - (void)petOpenChat;
@end

@interface SalahPetView : NSView
@property (weak) id<SalahPetActions> actions;
@property NSString *status;
@property NSString *nextPrayer;
@property NSString *cityName;
@property NSInteger animationFrame;
@property NSString *mood;
@property NSTimer *animationTimer;
@property NSPoint dragOrigin;
@property NSString *language;
@property BOOL hovered;
@property BOOL followMouse;
@property NSTrackingArea *trackingArea;
@property NSDictionary<NSString *, NSArray<NSImage *> *> *animationFrames;
@property NSImage *prayerRug;
@end

@implementation SalahPetView
- (instancetype)initWithFrame:(NSRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.wantsLayer = YES; _status = @"Psst… set your city so I can use real prayer times."; _nextPrayer = @"Awaiting setup"; _cityName = @"City not set"; _mood = @"idle"; _language = @"en";
    _animationFrames=@{@"idle":[self framesForState:@"idle" count:6], @"waving":[self framesForState:@"waving" count:4], @"jumping":[self framesForState:@"jumping" count:5], @"failed":[self framesForState:@"failed" count:8]};
    NSURL *rugURL=[NSBundle.mainBundle URLForResource:@"prayer-rug" withExtension:@"png" subdirectory:@"SalahCat"]; _prayerRug=rugURL ? [[NSImage alloc] initWithContentsOfURL:rugURL] : nil;
    _animationTimer = [NSTimer scheduledTimerWithTimeInterval:.25 target:self selector:@selector(nextFrame:) userInfo:nil repeats:YES];
  }
  return self;
}
- (void)dealloc { [_animationTimer invalidate]; }
- (NSArray<NSImage *> *)framesForState:(NSString *)state count:(NSInteger)count {
  NSMutableArray<NSImage *> *frames=[NSMutableArray new];
  for (NSInteger i=0;i<count;i++) {
    NSString *name=[NSString stringWithFormat:@"%02ld",(long)i];
    NSURL *url=[NSBundle.mainBundle URLForResource:name withExtension:@"png" subdirectory:[NSString stringWithFormat:@"SalahCat/%@",state]];
    NSImage *image=url ? [[NSImage alloc] initWithContentsOfURL:url] : nil;
    if (image) [frames addObject:image];
  }
  return frames;
}
- (NSImage *)currentPetFrame {
  NSString *state=(_hovered || [_mood isEqualToString:@"affection"] || [_mood isEqualToString:@"remind"]) ? @"waving" : ([_mood isEqualToString:@"failed"] ? @"failed" : ([_mood isEqualToString:@"sleep"] ? @"idle" : @"idle"));
  NSArray<NSImage *> *frames=_animationFrames[state];
  if (!frames.count) frames=_animationFrames[@"idle"];
  return frames.count ? frames[_animationFrame % frames.count] : nil;
}
- (void)nextFrame:(NSTimer *)timer {
  _animationFrame += 1;
  if (_animationFrame % 56 == 0 && self.window.isVisible) [[NSSound soundNamed:@"Tink"] play];
  [self setNeedsDisplay:YES];
}
- (NSString *)text:(NSString *)english zh:(NSString *)chinese ur:(NSString *)urdu { return [_language isEqualToString:@"zh"] ? chinese : ([_language isEqualToString:@"ar"] ? SalahCatArabicText(english) : ([_language isEqualToString:@"ur"] ? urdu : english)); }
- (void)updateTrackingAreas {
  if (_trackingArea) [self removeTrackingArea:_trackingArea];
  _trackingArea=[[NSTrackingArea alloc] initWithRect:self.bounds options:(NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveAlways | NSTrackingInVisibleRect) owner:self userInfo:nil];
  [self addTrackingArea:_trackingArea];
  [super updateTrackingAreas];
}

- (void)drawRect:(NSRect)dirtyRect {
  NSRect card = NSInsetRect(self.bounds, 8, 8);
  NSGradient *bg = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:1 green:.97 blue:.91 alpha:.99]
                                                 endingColor:[NSColor colorWithCalibratedRed:.76 green:.86 blue:.96 alpha:.99]];
  [bg drawInBezierPath:[NSBezierPath bezierPathWithRoundedRect:card xRadius:30 yRadius:30] angle:90];

  NSDictionary *moonStyle = @{NSFontAttributeName:[NSFont systemFontOfSize:36], NSForegroundColorAttributeName:[NSColor colorWithCalibratedRed:.39 green:.42 blue:.65 alpha:1]};
  [@"☾" drawAtPoint:NSMakePoint(28,374) withAttributes:moonStyle];
  NSDictionary *starStyle = @{NSFontAttributeName:[NSFont systemFontOfSize:14], NSForegroundColorAttributeName:[NSColor colorWithCalibratedRed:.86 green:.63 blue:.26 alpha:.9]};
  [@"✦" drawAtPoint:NSMakePoint(239,386) withAttributes:starStyle]; [@"·" drawAtPoint:NSMakePoint(264,363) withAttributes:starStyle];

  NSDictionary *name = @{NSFontAttributeName:[NSFont systemFontOfSize:18 weight:NSFontWeightBold], NSForegroundColorAttributeName:[NSColor colorWithCalibratedRed:.20 green:.25 blue:.43 alpha:1]};
  [[self text:@"Prayer Cat" zh:@"礼拜喵" ur:@"Namaz Cat"] drawAtPoint:NSMakePoint(73,393) withAttributes:name];
  NSDictionary *city = @{NSFontAttributeName:[NSFont systemFontOfSize:11 weight:NSFontWeightMedium], NSForegroundColorAttributeName:[NSColor colorWithCalibratedRed:.38 green:.43 blue:.59 alpha:1]};
  [_cityName drawAtPoint:NSMakePoint(76,376) withAttributes:city];

  // Prayer-time card. It only displays downloaded timings; no fixed time is ever invented.
  [[NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:.72] setFill];
  [[NSBezierPath bezierPathWithRoundedRect:NSMakeRect(31,320,238,47) xRadius:16 yRadius:16] fill];
  NSDictionary *next = @{NSFontAttributeName:[NSFont systemFontOfSize:14 weight:NSFontWeightSemibold], NSForegroundColorAttributeName:[NSColor colorWithCalibratedRed:.20 green:.25 blue:.40 alpha:1]};
  [_nextPrayer drawInRect:NSMakeRect(47,336,205,20) withAttributes:next];
  NSDictionary *hint = @{NSFontAttributeName:[NSFont systemFontOfSize:10], NSForegroundColorAttributeName:[NSColor colorWithCalibratedRed:.42 green:.48 blue:.66 alpha:1]};
  [[self text:@"Right-click to update or change settings" zh:@"右键可更新、设置城市与语言" ur:@"Update ya settings ke liye right-click karein"] drawAtPoint:NSMakePoint(47,325) withAttributes:hint];

  // A woven prayer rug with a respectful mihrab motif and soft fringe. It stays behind the cat and moves only as gently as cloth would.
  BOOL reduceMotion=NSWorkspace.sharedWorkspace.accessibilityDisplayShouldReduceMotion;
  CGFloat rugBreathe=reduceMotion ? 1.0 : 1.0 + ((_animationFrame % 8) < 4 ? .008 : -.004);
  CGFloat rugSway=reduceMotion ? 0 : ((_animationFrame % 8) - 3.5) * .12;
  [[NSGraphicsContext currentContext] saveGraphicsState];
  NSAffineTransform *rugMotion=[NSAffineTransform transform];
  [rugMotion translateXBy:150 yBy:205]; [rugMotion rotateByDegrees:rugSway]; [rugMotion scaleXBy:1 yBy:rugBreathe]; [rugMotion translateXBy:-150 yBy:-205]; [rugMotion concat];
  if (_prayerRug) [_prayerRug drawInRect:NSMakeRect(40,133,220,147) fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0 respectFlipped:YES hints:nil];
  else { [[NSColor colorWithCalibratedRed:.10 green:.27 blue:.36 alpha:.88] setFill]; [[NSBezierPath bezierPathWithRoundedRect:NSMakeRect(49,148,203,97) xRadius:22 yRadius:22] fill]; }
  [[NSGraphicsContext currentContext] restoreGraphicsState];

  // The cute hand-drawn Maine Coon is a real transparent animation frame, not a procedural placeholder.
  BOOL happy = _hovered || [_mood isEqualToString:@"affection"] || [_mood isEqualToString:@"remind"];
  CGFloat breathe = 1.0 + ((_animationFrame % 6) < 3 ? .018 : -.008);
  CGFloat sway = happy ? ((_animationFrame % 4) - 1.5) * 1.5 : ((_animationFrame % 8) - 3.5) * .35;
  [[NSGraphicsContext currentContext] saveGraphicsState];
  NSAffineTransform *motion = [NSAffineTransform transform];
  [motion translateXBy:150 yBy:234]; [motion rotateByDegrees:sway]; [motion scaleXBy:1 yBy:breathe]; [motion translateXBy:-150 yBy:-234]; [motion concat];
  NSImage *pet=[self currentPetFrame];
  if (pet) [pet drawInRect:NSMakeRect(68,147,164,178) fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0 respectFlipped:YES hints:nil];
  [[NSGraphicsContext currentContext] restoreGraphicsState];

  NSDictionary *status = @{NSFontAttributeName:[NSFont systemFontOfSize:12 weight:NSFontWeightMedium], NSForegroundColorAttributeName:[NSColor colorWithCalibratedRed:.22 green:.28 blue:.45 alpha:1]};
  [_status drawInRect:NSMakeRect(30,13,240,30) withAttributes:status];
}

- (void)mouseDown:(NSEvent *)event { _dragOrigin=event.locationInWindow; [_actions petClickedAt:_dragOrigin clickCount:event.clickCount]; }
- (void)mouseDragged:(NSEvent *)event { NSPoint point=event.locationInWindow; NSRect frame=self.window.frame; frame.origin.x += point.x-_dragOrigin.x; frame.origin.y += point.y-_dragOrigin.y; [self.window setFrameOrigin:frame.origin]; }
- (void)rightMouseDown:(NSEvent *)event { [_actions petRightClicked:event fromView:self]; }
- (void)mouseEntered:(NSEvent *)event { _hovered=YES; if (![_mood isEqualToString:@"remind"]) _mood=@"happy"; [self setNeedsDisplay:YES]; }
- (void)mouseExited:(NSEvent *)event { _hovered=NO; if ([_mood isEqualToString:@"happy"]) _mood=@"idle"; [self setNeedsDisplay:YES]; }
- (void)mouseMoved:(NSEvent *)event { [_actions petMouseMoved:event]; }
@end

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate, NSTextViewDelegate, SalahPetActions>
@property NSPanel *panel;
@property SalahPetView *pet;
@property NSDictionary *timings;
@property NSString *city;
@property NSString *country;
@property NSString *language;
@property NSInteger method;
@property BOOL ramadanMode;
@property NSString *loadedDate;
@property NSTimer *scheduleTimer;
@property NSStatusItem *statusItem;
@property BOOL followMouse;
@property id globalMouseMonitor;
@property NSPanel *chatPanel;
@property NSTextView *chatTranscript;
@property NSTextField *chatInput;
@property NSTextField *chatConnectionStatus;
@property NSButton *chatSendButton;
@property NSButton *chatConnectButton;
@property NSButton *chatRemoveButton;
@property NSButton *webChatButton;
@property NSButton *memoButton;
@property NSPanel *memoPanel;
@property NSTextField *memoHeading;
@property NSTextField *memoStatus;
@property NSTextField *memoSavedLabel;
@property NSTextView *memoInput;
@property NSTextView *memoList;
@property NSButton *memoSaveButton;
@property NSButton *memoOpenFolderButton;
@property NSMutableArray<NSDictionary<NSString *, NSString *> *> *chatHistory;
@property NSString *chatModel;
@property SalahMosqueController *mosqueController;
@end

@implementation AppDelegate

- (NSString *)text:(NSString *)english zh:(NSString *)chinese ur:(NSString *)urdu {
  return [self.language isEqualToString:@"zh"] ? chinese : ([self.language isEqualToString:@"ar"] ? SalahCatArabicText(english) : ([self.language isEqualToString:@"ur"] ? urdu : english));
}

- (NSMenu *)statusMenu {
  NSMenu *menu=[NSMenu new];
  [menu addItemWithTitle:[self text:@"Show Prayer Cat" zh:@"显示礼拜喵" ur:@"Namaz Cat dikhayein"] action:@selector(showPet:) keyEquivalent:@""];
  [menu addItemWithTitle:[self text:@"Talk with Prayer Cat…" zh:@"和礼拜喵聊聊…" ur:@"Namaz Cat se baat karein…"] action:@selector(showChat:) keyEquivalent:@""];
  [menu addItemWithTitle:[self text:@"Chat with me in ChatGPT" zh:@"在 ChatGPT 里和我聊聊吧" ur:@"ChatGPT par mujh se baat karein"] action:@selector(openChatGPTWeb:) keyEquivalent:@""];
  [menu addItemWithTitle:[self text:@"Memo space…" zh:@"备忘录知识空间…" ur:@"Yaad-dasht jagah…"] action:@selector(showMemo:) keyEquivalent:@""];
  [menu addItemWithTitle:[self text:@"Nearby mosques…" zh:@"附近清真寺…" ur:@"Qareebi masajid…"] action:@selector(showNearbyMosques:) keyEquivalent:@""];
  [menu addItem:[NSMenuItem separatorItem]];
  NSMenuItem *follow=[menu addItemWithTitle:[self text:@"Follow cursor" zh:@"跟随鼠标" ur:@"Cursor ko follow karein"] action:@selector(toggleFollow:) keyEquivalent:@""]; follow.state=self.followMouse ? NSControlStateValueOn : NSControlStateValueOff;
  [menu addItemWithTitle:[self text:@"Refresh prayer times" zh:@"更新礼拜时间" ur:@"Namaz ke auqaat update karein"] action:@selector(refreshTimings:) keyEquivalent:@""];
  [menu addItemWithTitle:[self text:@"Settings…" zh:@"设置…" ur:@"Settings…"] action:@selector(showSettings:) keyEquivalent:@","];
  [menu addItem:[NSMenuItem separatorItem]];
  [menu addItemWithTitle:[self text:@"Quit Prayer Cat" zh:@"退出礼拜喵" ur:@"Namaz Cat band karein"] action:@selector(terminate:) keyEquivalent:@"q"];
  return menu;
}

- (void)showPet:(id)sender { [self.panel orderFrontRegardless]; [NSApp activateIgnoringOtherApps:YES]; }
- (void)showNearbyMosques:(id)sender { if (!self.mosqueController) self.mosqueController=[SalahMosqueController new]; self.mosqueController.language=self.language ?: @"en"; self.mosqueController.prayerTimings=self.timings ?: @{}; [self.mosqueController show]; }
- (void)petOpenChat { [self showChat:nil]; }
- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag { [self showPet:nil]; return YES; }
- (void)applicationDidBecomeActive:(NSNotification *)notification { [self.panel orderFrontRegardless]; }
- (void)applicationDidResignActive:(NSNotification *)notification { if (self.panel.isVisible) [self.panel orderFrontRegardless]; }
- (BOOL)windowShouldClose:(NSWindow *)sender {
  if (sender==self.panel) { [self showPet:nil]; return NO; }
  if (sender==self.memoPanel) { [self saveMemoDraft]; [sender orderOut:nil]; return NO; }
  return YES;
}

- (void)toggleFollow:(id)sender {
  self.followMouse=!self.followMouse; self.pet.followMouse=self.followMouse; [NSUserDefaults.standardUserDefaults setBool:self.followMouse forKey:@"salahFollowMouse"]; self.statusItem.menu=[self statusMenu];
  self.pet.status=[self text:(self.followMouse ? @"I’ll float along with your cursor. 🐾" : @"I’ll stay right here until you drag me.") zh:(self.followMouse ? @"喵～我会轻轻跟着鼠标走。" : @"喵～我会乖乖待在这里，等你拖动我。") ur:(self.followMouse ? @"Main aap ke cursor ke saath aa jaaunga. 🐾" : @"Main yahin rahoonga, aap mujhe drag kar sakte hain.")];
}

- (void)movePetNearCursor {
  if (!self.followMouse) return;
  NSPoint cursor=NSEvent.mouseLocation; NSRect visible=NSScreen.mainScreen.visibleFrame; NSRect frame=self.panel.frame;
  CGFloat x=MIN(MAX(cursor.x-frame.size.width/2, visible.origin.x), NSMaxX(visible)-frame.size.width);
  CGFloat y=MIN(MAX(cursor.y-frame.size.height/2-26, visible.origin.y), NSMaxY(visible)-frame.size.height);
  [self.panel setFrameOrigin:NSMakePoint(x,y)];
}
- (void)petMouseMoved:(NSEvent *)event { [self movePetNearCursor]; }

- (NSButton *)petButtonWithFrame:(NSRect)frame primary:(BOOL)primary {
  NSButton *button=[[NSButton alloc] initWithFrame:frame];
  button.bezelStyle=NSBezelStyleRounded;
  button.font=[NSFont systemFontOfSize:13 weight:NSFontWeightSemibold];
  button.bezelColor=primary ? [NSColor colorWithCalibratedRed:.36 green:.43 blue:.74 alpha:1] : [NSColor colorWithCalibratedRed:.89 green:.65 blue:.25 alpha:1];
  button.contentTintColor=NSColor.whiteColor;
  button.wantsLayer=YES;
  button.layer.cornerRadius=14;
  button.toolTip=@"";
  return button;
}

- (void)configurePetActionButtons {
  if (!self.webChatButton) {
    self.webChatButton=[self petButtonWithFrame:NSMakeRect(30,100,240,34) primary:YES];
    self.webChatButton.target=self;
    self.webChatButton.action=@selector(openChatGPTWeb:);
    [self.pet addSubview:self.webChatButton];
  }
  if (!self.memoButton) {
    self.memoButton=[self petButtonWithFrame:NSMakeRect(30,58,240,34) primary:NO];
    self.memoButton.target=self;
    self.memoButton.action=@selector(showMemo:);
    [self.pet addSubview:self.memoButton];
  }
  self.webChatButton.frame=NSMakeRect(30,100,240,34);
  self.memoButton.frame=NSMakeRect(30,58,240,34);
  self.webChatButton.title=[self text:@"Chat with me" zh:@"和我聊聊吧" ur:@"Mujh se baat karein"];
  self.webChatButton.toolTip=[self text:@"Opens ChatGPT in your browser; sign in with your own account." zh:@"会在浏览器中打开 ChatGPT，请使用你自己的账号登录。" ur:@"Browser mein ChatGPT khulega; apne account se sign in karein."];
  self.memoButton.title=[self text:@"Memo" zh:@"备忘录" ur:@"Yaad-dasht"];
  self.memoButton.toolTip=[self text:@"Write notes that stay only on this Mac." zh:@"记录只保存在这台 Mac 上的备忘。" ur:@"Apni baat likhein; yeh sirf is Mac par rahegi."];
}

- (void)refreshPetActionButtons {}

- (void)openChatGPTWeb:(id)sender {
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://chatgpt.com/"]];
  self.pet.mood=@"affection";
  self.pet.status=[self text:@"I opened ChatGPT in your browser. Sign in with your own account, friend." zh:@"我已在浏览器中打开 ChatGPT。请用你自己的账号登录，朋友。" ur:@"Maine browser mein ChatGPT khol diya hai. Apne account se sign in karein, dost."];
}

- (NSURL *)memoDirectoryURL {
  NSURL *applicationSupport=[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask].firstObject;
  NSURL *directory=[applicationSupport URLByAppendingPathComponent:@"SalahCat/KnowledgeSpace" isDirectory:YES];
  [[NSFileManager defaultManager] createDirectoryAtURL:directory withIntermediateDirectories:YES attributes:nil error:nil];
  return directory;
}

- (NSURL *)memoDraftURL { return [[self memoDirectoryURL] URLByAppendingPathComponent:@"Draft.md"]; }

- (NSString *)memoTimestamp {
  NSDateFormatter *formatter=[NSDateFormatter new]; formatter.locale=[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]; formatter.timeZone=NSTimeZone.localTimeZone; formatter.dateFormat=@"yyyy-MM-dd HH:mm:ss";
  return [formatter stringFromDate:NSDate.date];
}

- (void)refreshMemoList {
  if (!self.memoList) return;
  NSError *directoryError=nil;
  NSArray<NSURL *> *files=[[NSFileManager defaultManager] contentsOfDirectoryAtURL:[self memoDirectoryURL] includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:&directoryError];
  NSArray<NSURL *> *notes=[[files filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSURL *url, NSDictionary *bindings) { return [url.pathExtension.lowercaseString isEqualToString:@"md"] && ![url.lastPathComponent isEqualToString:@"Draft.md"]; }]] sortedArrayUsingComparator:^NSComparisonResult(NSURL *left, NSURL *right) { return [right.lastPathComponent compare:left.lastPathComponent]; }];
  NSMutableString *list=[NSMutableString new];
  for (NSURL *file in [notes subarrayWithRange:NSMakeRange(0, MIN((NSUInteger)20, notes.count))]) {
    NSString *text=[NSString stringWithContentsOfURL:file encoding:NSUTF8StringEncoding error:nil] ?: @"";
    if (text.length>360) text=[[text substringToIndex:360] stringByAppendingString:@"…"];
    [list appendFormat:@"%@\n%@\n\n", file.lastPathComponent.stringByDeletingPathExtension, text];
  }
  if (!list.length) list=[NSMutableString stringWithString:[self text:@"No saved notes yet. Write one above and it will stay on this Mac." zh:@"还没有保存的备忘。写下一条，它就会留在这台 Mac 上。" ur:@"Abhi koi save ki hui yaad-dasht nahi hai. Upar likhein; yeh isi Mac par rahegi."]];
  self.memoList.string=list;
}

- (void)saveMemoDraft {
  if (!self.memoInput) return;
  NSString *draft=[self.memoInput.string stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
  NSURL *draftURL=[self memoDraftURL];
  if (!draft.length) { [[NSFileManager defaultManager] removeItemAtURL:draftURL error:nil]; return; }
  BOOL saved=[draft writeToURL:draftURL atomically:YES encoding:NSUTF8StringEncoding error:nil];
  if (saved && self.memoStatus) self.memoStatus.stringValue=[self text:@"Draft saved locally" zh:@"草稿已自动保存在本机" ur:@"Draft local taur par save ho gaya"];
}

- (void)saveMemo:(id)sender {
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(saveMemoDraft) object:nil];
  NSString *body=[self.memoInput.string stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
  if (!body.length) { self.memoStatus.stringValue=[self text:@"Write a note first" zh:@"先写下一条备忘吧" ur:@"Pehle ek yaad-dasht likhein"]; return; }
  NSDateFormatter *fileFormatter=[NSDateFormatter new]; fileFormatter.locale=[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]; fileFormatter.timeZone=NSTimeZone.localTimeZone; fileFormatter.dateFormat=@"yyyy-MM-dd-HHmmss-SSS";
  NSString *filename=[NSString stringWithFormat:@"%@.md",[fileFormatter stringFromDate:NSDate.date]];
  NSString *note=[NSString stringWithFormat:@"%@\n%@\n\n%@\n", [self text:@"# Prayer Cat memo" zh:@"# 礼拜喵备忘" ur:@"# Namaz Cat yaad-dasht"], [self text:[NSString stringWithFormat:@"Saved %@",[self memoTimestamp]] zh:[NSString stringWithFormat:@"保存时间：%@",[self memoTimestamp]] ur:[NSString stringWithFormat:@"Save ka waqt: %@",[self memoTimestamp]]], body];
  NSError *error=nil; BOOL saved=[note writeToURL:[[self memoDirectoryURL] URLByAppendingPathComponent:filename] atomically:YES encoding:NSUTF8StringEncoding error:&error];
  if (!saved) { self.memoStatus.stringValue=[self text:@"Couldn’t save the note. Please try again." zh:@"暂时无法保存，请重试。" ur:@"Yaad-dasht save nahi ho saki. Dobara koshish karein."]; self.memoStatus.textColor=NSColor.systemRedColor; return; }
  self.memoInput.string=@""; [[NSFileManager defaultManager] removeItemAtURL:[self memoDraftURL] error:nil];
  self.memoStatus.stringValue=[self text:@"Saved in your local knowledge space" zh:@"已存入本地知识空间" ur:@"Local knowledge space mein save ho gaya"]; self.memoStatus.textColor=[NSColor colorWithCalibratedRed:.20 green:.46 blue:.35 alpha:1];
  self.pet.mood=@"affection"; self.pet.status=[self text:@"Purr… I’ve tucked that note safely into your local space." zh:@"呼噜～这条备忘已经乖乖收进你的本地知识空间。" ur:@"Purr… yeh yaad-dasht aap ke local knowledge space mein mehfooz hai."];
  [self refreshMemoList];
}

- (void)openMemoFolder:(id)sender {
  NSURL *folder=[self memoDirectoryURL];
  [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[folder]];
  self.memoStatus.stringValue=[self text:@"Opened your local memo folder" zh:@"已打开本地备忘录文件夹" ur:@"Local yaad-dasht folder khol diya"];
}

- (void)textDidChange:(NSNotification *)notification {
  if (notification.object != self.memoInput) return;
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(saveMemoDraft) object:nil];
  [self performSelector:@selector(saveMemoDraft) withObject:nil afterDelay:.7];
}

- (void)buildMemoPanelIfNeeded {
  if (self.memoPanel) return;
  self.memoPanel=[[NSPanel alloc] initWithContentRect:NSMakeRect(240,160,520,570) styleMask:(NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskUtilityWindow) backing:NSBackingStoreBuffered defer:NO];
  self.memoPanel.floatingPanel=YES; self.memoPanel.level=NSFloatingWindowLevel; self.memoPanel.hasShadow=YES; self.memoPanel.hidesOnDeactivate=NO; self.memoPanel.collectionBehavior=NSWindowCollectionBehaviorCanJoinAllSpaces | NSWindowCollectionBehaviorFullScreenAuxiliary; self.memoPanel.delegate=self;
  NSView *content=self.memoPanel.contentView;
  self.memoHeading=[[NSTextField alloc] initWithFrame:NSMakeRect(24,530,472,25)]; self.memoHeading.font=[NSFont systemFontOfSize:20 weight:NSFontWeightBold]; self.memoHeading.editable=NO; self.memoHeading.bezeled=NO; self.memoHeading.drawsBackground=NO; self.memoHeading.textColor=[NSColor colorWithCalibratedRed:.20 green:.25 blue:.43 alpha:1]; [content addSubview:self.memoHeading];
  self.memoStatus=[[NSTextField alloc] initWithFrame:NSMakeRect(24,504,472,18)]; self.memoStatus.font=[NSFont systemFontOfSize:12]; self.memoStatus.editable=NO; self.memoStatus.bezeled=NO; self.memoStatus.drawsBackground=NO; self.memoStatus.textColor=[NSColor colorWithCalibratedRed:.38 green:.43 blue:.59 alpha:1]; [content addSubview:self.memoStatus];
  NSScrollView *inputScroll=[[NSScrollView alloc] initWithFrame:NSMakeRect(24,305,472,186)]; inputScroll.hasVerticalScroller=YES; inputScroll.borderType=NSBezelBorder;
  self.memoInput=[[NSTextView alloc] initWithFrame:inputScroll.contentView.bounds]; self.memoInput.minSize=NSMakeSize(0,186); self.memoInput.maxSize=NSMakeSize(CGFLOAT_MAX,CGFLOAT_MAX); self.memoInput.verticallyResizable=YES; self.memoInput.horizontallyResizable=NO; self.memoInput.autoresizingMask=NSViewWidthSizable; self.memoInput.font=[NSFont systemFontOfSize:14]; self.memoInput.richText=NO; self.memoInput.usesFindPanel=YES; self.memoInput.delegate=self; inputScroll.documentView=self.memoInput; [content addSubview:inputScroll];
  self.memoSaveButton=[[NSButton alloc] initWithFrame:NSMakeRect(24,259,166,32)]; self.memoSaveButton.bezelStyle=NSBezelStyleRounded; self.memoSaveButton.target=self; self.memoSaveButton.action=@selector(saveMemo:); [content addSubview:self.memoSaveButton];
  self.memoOpenFolderButton=[[NSButton alloc] initWithFrame:NSMakeRect(200,259,148,32)]; self.memoOpenFolderButton.bezelStyle=NSBezelStyleRounded; self.memoOpenFolderButton.target=self; self.memoOpenFolderButton.action=@selector(openMemoFolder:); [content addSubview:self.memoOpenFolderButton];
  self.memoSavedLabel=[[NSTextField alloc] initWithFrame:NSMakeRect(24,232,472,20)]; self.memoSavedLabel.editable=NO; self.memoSavedLabel.bezeled=NO; self.memoSavedLabel.drawsBackground=NO; self.memoSavedLabel.font=[NSFont systemFontOfSize:13 weight:NSFontWeightSemibold]; self.memoSavedLabel.textColor=[NSColor colorWithCalibratedRed:.20 green:.25 blue:.43 alpha:1]; [content addSubview:self.memoSavedLabel];
  NSScrollView *listScroll=[[NSScrollView alloc] initWithFrame:NSMakeRect(24,24,472,202)]; listScroll.hasVerticalScroller=YES; listScroll.borderType=NSBezelBorder;
  self.memoList=[[NSTextView alloc] initWithFrame:listScroll.contentView.bounds]; self.memoList.editable=NO; self.memoList.selectable=YES; self.memoList.richText=NO; self.memoList.font=[NSFont systemFontOfSize:12]; self.memoList.textColor=[NSColor colorWithCalibratedRed:.23 green:.28 blue:.40 alpha:1]; self.memoList.minSize=NSMakeSize(0,202); self.memoList.maxSize=NSMakeSize(CGFLOAT_MAX,CGFLOAT_MAX); self.memoList.verticallyResizable=YES; self.memoList.horizontallyResizable=NO; self.memoList.autoresizingMask=NSViewWidthSizable; listScroll.documentView=self.memoList; [content addSubview:listScroll];
  NSString *draft=[NSString stringWithContentsOfURL:[self memoDraftURL] encoding:NSUTF8StringEncoding error:nil]; if (draft.length) self.memoInput.string=draft;
}

- (void)refreshMemoPanel {
  [self buildMemoPanelIfNeeded];
  self.memoPanel.title=[self text:@"Memo space" zh:@"备忘录知识空间" ur:@"Yaad-dasht jagah"];
  self.memoHeading.stringValue=[self text:@"Prayer Cat knowledge space" zh:@"礼拜喵知识空间" ur:@"Namaz Cat knowledge space"];
  self.memoSaveButton.title=[self text:@"Save note" zh:@"保存备忘" ur:@"Yaad-dasht save karein"];
  self.memoOpenFolderButton.title=[self text:@"Open folder" zh:@"打开文件夹" ur:@"Folder kholein"];
  self.memoSavedLabel.stringValue=[self text:@"Saved notes" zh:@"已保存的备忘" ur:@"Save ki hui yaad-dasht"];
  if (!self.memoStatus.stringValue.length) self.memoStatus.stringValue=[self text:@"Write a note below. It stays only on this Mac." zh:@"在下方写下备忘，它只会保存在这台 Mac 上。" ur:@"Neeche yaad-dasht likhein; yeh sirf isi Mac par rahegi."];
  [self refreshMemoList];
}

- (void)showMemo:(id)sender {
  [self refreshMemoPanel];
  [self.memoPanel makeKeyAndOrderFront:nil]; [NSApp activateIgnoringOtherApps:YES]; [self.memoPanel makeFirstResponder:self.memoInput];
}

- (void)applicationDidFinishLaunching:(NSNotification *)note {
  [UNUserNotificationCenter.currentNotificationCenter requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError *error) {}];
  self.panel=[[NSPanel alloc] initWithContentRect:NSMakeRect(150,360,300,450) styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:NO];
  self.panel.floatingPanel=YES; self.panel.level=NSFloatingWindowLevel; self.panel.hasShadow=YES; self.panel.opaque=NO; self.panel.backgroundColor=NSColor.clearColor; self.panel.hidesOnDeactivate=NO; self.panel.becomesKeyOnlyIfNeeded=NO; self.panel.delegate=self;
  self.panel.collectionBehavior=NSWindowCollectionBehaviorCanJoinAllSpaces | NSWindowCollectionBehaviorFullScreenAuxiliary;
  self.pet=[[SalahPetView alloc] initWithFrame:NSMakeRect(0,0,300,450)]; self.pet.actions=self; self.panel.contentView=self.pet; [self.panel makeKeyAndOrderFront:nil]; [NSApp activateIgnoringOtherApps:YES];
  __weak typeof(self) weakSelf=self;
  self.globalMouseMonitor=[NSEvent addGlobalMonitorForEventsMatchingMask:NSEventMaskMouseMoved handler:^(NSEvent *event) { dispatch_async(dispatch_get_main_queue(), ^{ [weakSelf movePetNearCursor]; }); }];
  self.statusItem=[NSStatusBar.systemStatusBar statusItemWithLength:NSVariableStatusItemLength]; self.statusItem.button.title=@"☾"; self.statusItem.button.toolTip=@"Prayer Cat"; self.statusItem.menu=[self statusMenu];
  NSUserDefaults *d=NSUserDefaults.standardUserDefaults; self.city=[d stringForKey:@"salahCity"] ?: @""; self.country=[d stringForKey:@"salahCountry"] ?: @""; self.language=[d stringForKey:@"salahLanguage"] ?: @"en"; NSNumber *savedMethod=[d objectForKey:@"salahMethod"]; self.method=savedMethod ? savedMethod.integerValue : 1; self.ramadanMode=[d boolForKey:@"salahRamadan"]; self.followMouse=[d boolForKey:@"salahFollowMouse"]; self.pet.language=self.language; self.pet.followMouse=self.followMouse; [self configurePetActionButtons]; self.statusItem.button.toolTip=[self text:@"Prayer Cat" zh:@"礼拜喵" ur:@"Namaz Cat"]; self.statusItem.menu=[self statusMenu];
  self.scheduleTimer=[NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(tick:) userInfo:nil repeats:YES];
  self.mosqueController=[SalahMosqueController new]; self.mosqueController.language=self.language; self.mosqueController.prayerTimings=self.timings ?: @{}; [self.mosqueController refreshForReminderIfNeeded];
  if (self.city.length && self.country.length) [self refreshTimings:nil]; else dispatch_async(dispatch_get_main_queue(), ^{ [self showSettings:nil]; });
}
- (void)applicationWillTerminate:(NSNotification *)notification { if (self.globalMouseMonitor) [NSEvent removeMonitor:self.globalMouseMonitor]; }

- (NSString *)chatCatName { return [self text:@"Prayer Cat" zh:@"礼拜喵" ur:@"Namaz Cat"]; }

- (void)appendChatSpeaker:(NSString *)speaker message:(NSString *)message role:(NSString *)role {
  if (!message.length) return;
  NSDictionary *speakerStyle=@{NSFontAttributeName:[NSFont systemFontOfSize:13 weight:NSFontWeightBold], NSForegroundColorAttributeName:[NSColor colorWithCalibratedRed:.20 green:.25 blue:.43 alpha:1]};
  NSDictionary *messageStyle=@{NSFontAttributeName:[NSFont systemFontOfSize:13], NSForegroundColorAttributeName:[NSColor colorWithCalibratedRed:.23 green:.28 blue:.40 alpha:1]};
  NSMutableAttributedString *line=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",speaker] attributes:speakerStyle];
  [line appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n",message] attributes:messageStyle]];
  [self.chatTranscript.textStorage appendAttributedString:line];
  [self.chatTranscript scrollRangeToVisible:NSMakeRange(self.chatTranscript.string.length, 0)];
  [self.chatHistory addObject:@{ @"role":role, @"text":message }];
}

- (void)startNewChat:(id)sender {
  self.chatHistory=[NSMutableArray new];
  self.chatTranscript.string=@"";
  [self appendChatSpeaker:[self chatCatName]
                   message:[self text:@"Purr… I’m here. What would you like to talk about?" zh:@"呼噜～我在这里。想和我聊点什么？" ur:@"Purr… Main yahin hoon. Aap kis baare mein baat karna chahte hain?"]
                      role:@"assistant"];
  self.pet.mood=@"affection";
}

- (void)refreshChatConnectionUI {
  BOOL connected=SalahCatReadOpenAIKey().length > 0;
  self.chatPanel.title=[self text:@"Talk with Prayer Cat" zh:@"和礼拜喵聊聊" ur:@"Namaz Cat se baat karein"];
  self.chatConnectionStatus.stringValue=connected ? [self text:@"Connected to your personal OpenAI API" zh:@"已连接你的个人 OpenAI API" ur:@"Aap ki personal OpenAI API connect hai"] : [self text:@"Connect your API key to start a private chat" zh:@"连接个人 API key 后即可开始聊天" ur:@"Private chat shuru karne ke liye apni API key connect karein"];
  self.chatConnectionStatus.textColor=connected ? [NSColor colorWithCalibratedRed:.20 green:.46 blue:.35 alpha:1] : [NSColor colorWithCalibratedRed:.55 green:.38 blue:.15 alpha:1];
  self.chatConnectButton.title=connected ? [self text:@"Replace key…" zh:@"更换密钥…" ur:@"Key badlein…"] : [self text:@"Connect OpenAI…" zh:@"连接 OpenAI…" ur:@"OpenAI connect karein…"];
  self.chatRemoveButton.title=[self text:@"Forget key" zh:@"移除密钥" ur:@"Key hata dein"];
  self.chatRemoveButton.enabled=connected;
  self.chatInput.enabled=connected;
  self.chatSendButton.enabled=connected;
  self.chatInput.placeholderString=connected ? [self text:@"Write a message…" zh:@"写下想说的话…" ur:@"Apna paigham likhein…"] : [self text:@"Connect OpenAI first" zh:@"请先连接 OpenAI" ur:@"Pehle OpenAI connect karein"];
}

- (void)buildChatPanelIfNeeded {
  if (self.chatPanel) return;
  self.chatPanel=[[NSPanel alloc] initWithContentRect:NSMakeRect(210,180,440,570) styleMask:(NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskUtilityWindow) backing:NSBackingStoreBuffered defer:NO];
  self.chatPanel.floatingPanel=YES; self.chatPanel.level=NSFloatingWindowLevel; self.chatPanel.hasShadow=YES; self.chatPanel.hidesOnDeactivate=NO; self.chatPanel.collectionBehavior=NSWindowCollectionBehaviorCanJoinAllSpaces | NSWindowCollectionBehaviorFullScreenAuxiliary;
  NSView *content=[[NSView alloc] initWithFrame:NSMakeRect(0,0,440,570)]; content.wantsLayer=YES; content.layer.backgroundColor=[NSColor colorWithCalibratedRed:.96 green:.97 blue:1 alpha:1].CGColor; self.chatPanel.contentView=content;

  NSTextField *title=[[NSTextField alloc] initWithFrame:NSMakeRect(24,526,270,25)]; title.stringValue=[self text:@"Talk with Prayer Cat" zh:@"和礼拜喵聊聊" ur:@"Namaz Cat se baat karein"]; title.font=[NSFont systemFontOfSize:19 weight:NSFontWeightBold]; title.editable=NO; title.bezeled=NO; title.drawsBackground=NO; [content addSubview:title];
  self.chatConnectionStatus=[[NSTextField alloc] initWithFrame:NSMakeRect(24,500,392,19)]; self.chatConnectionStatus.font=[NSFont systemFontOfSize:12 weight:NSFontWeightMedium]; self.chatConnectionStatus.editable=NO; self.chatConnectionStatus.bezeled=NO; self.chatConnectionStatus.drawsBackground=NO; [content addSubview:self.chatConnectionStatus];

  NSScrollView *transcriptScroll=[[NSScrollView alloc] initWithFrame:NSMakeRect(24,147,392,340)]; transcriptScroll.hasVerticalScroller=YES; transcriptScroll.borderType=NSBezelBorder; transcriptScroll.wantsLayer=YES; transcriptScroll.layer.cornerRadius=14; self.chatTranscript=[[NSTextView alloc] initWithFrame:transcriptScroll.bounds]; self.chatTranscript.editable=NO; self.chatTranscript.selectable=YES; self.chatTranscript.font=[NSFont systemFontOfSize:13]; self.chatTranscript.textContainerInset=NSMakeSize(12,12); self.chatTranscript.backgroundColor=[NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:.88]; transcriptScroll.documentView=self.chatTranscript; [content addSubview:transcriptScroll];

  self.chatConnectButton=[[NSButton alloc] initWithFrame:NSMakeRect(24,109,128,28)]; self.chatConnectButton.bezelStyle=NSBezelStyleRounded; self.chatConnectButton.target=self; self.chatConnectButton.action=@selector(showOpenAISetup:); [content addSubview:self.chatConnectButton];
  self.chatRemoveButton=[[NSButton alloc] initWithFrame:NSMakeRect(160,109,92,28)]; self.chatRemoveButton.bezelStyle=NSBezelStyleRounded; self.chatRemoveButton.target=self; self.chatRemoveButton.action=@selector(removeOpenAIKey:); [content addSubview:self.chatRemoveButton];
  NSButton *newChat=[[NSButton alloc] initWithFrame:NSMakeRect(324,109,92,28)]; newChat.title=[self text:@"New chat" zh:@"新对话" ur:@"Nayi baat-cheet"]; newChat.bezelStyle=NSBezelStyleRounded; newChat.target=self; newChat.action=@selector(startNewChat:); [content addSubview:newChat];

  self.chatInput=[[NSTextField alloc] initWithFrame:NSMakeRect(24,56,292,38)]; self.chatInput.font=[NSFont systemFontOfSize:14]; self.chatInput.target=self; self.chatInput.action=@selector(sendChat:); self.chatInput.bezelStyle=NSTextFieldRoundedBezel; [content addSubview:self.chatInput];
  self.chatSendButton=[[NSButton alloc] initWithFrame:NSMakeRect(326,56,90,38)]; self.chatSendButton.title=[self text:@"Send" zh:@"发送" ur:@"Bhejein"]; self.chatSendButton.bezelStyle=NSBezelStyleRounded; self.chatSendButton.target=self; self.chatSendButton.action=@selector(sendChat:); [content addSubview:self.chatSendButton];

  self.chatHistory=[NSMutableArray new];
  [self startNewChat:nil];
}

- (void)showChat:(id)sender {
  [self buildChatPanelIfNeeded];
  [self refreshChatConnectionUI];
  [self.chatPanel makeKeyAndOrderFront:nil];
  [NSApp activateIgnoringOtherApps:YES];
  if (self.chatInput.enabled) [self.chatPanel makeFirstResponder:self.chatInput];
}

- (void)showOpenAISetup:(id)sender {
  NSAlert *alert=[NSAlert new];
  alert.messageText=[self text:@"Connect your OpenAI API" zh:@"连接你的 OpenAI API" ur:@"Apni OpenAI API connect karein"];
  alert.informativeText=[self text:@"ChatGPT subscriptions and API usage are billed separately. Create a restricted personal API key on the OpenAI Platform. This app saves it only in your Mac’s Keychain and never includes it in the app package." zh:@"ChatGPT 订阅与 API 用量分别计费。请在 OpenAI Platform 创建个人受限 API key；礼拜喵只会将它保存在这台 Mac 的钥匙串中，绝不会写入应用包。" ur:@"ChatGPT subscription aur API usage alag bill hote hain. OpenAI Platform par restricted personal API key banayein. Yeh app key ko sirf is Mac ke Keychain mein rakhti hai; app package mein kabhi nahi."];
  NSView *form=[[NSView alloc] initWithFrame:NSMakeRect(0,0,390,74)];
  NSTextField *keyLabel=[[NSTextField alloc] initWithFrame:NSMakeRect(0,48,390,18)]; keyLabel.stringValue=[self text:@"Personal API key" zh:@"个人 API key" ur:@"Personal API key"]; keyLabel.editable=NO; keyLabel.bezeled=NO; keyLabel.drawsBackground=NO; [form addSubview:keyLabel];
  NSSecureTextField *keyField=[[NSSecureTextField alloc] initWithFrame:NSMakeRect(0,18,390,26)]; keyField.placeholderString=[self text:@"Paste a restricted key here" zh:@"在此粘贴受限密钥" ur:@"Restricted key yahan paste karein"]; [form addSubview:keyField];
  alert.accessoryView=form;
  [alert addButtonWithTitle:[self text:@"Save and connect" zh:@"保存并连接" ur:@"Save aur connect karein"]];
  [alert addButtonWithTitle:[self text:@"Open API keys" zh:@"打开 API Keys" ur:@"API Keys kholein"]];
  [alert addButtonWithTitle:[self text:@"Cancel" zh:@"取消" ur:@"Cancel"]];
  NSModalResponse response=[alert runModal];
  if (response==NSAlertFirstButtonReturn) {
    NSString *key=[keyField.stringValue stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (!key.length || !SalahCatStoreOpenAIKey(key)) {
      self.chatConnectionStatus.stringValue=[self text:@"I couldn’t save that key. Please try again." zh:@"无法保存该密钥，请再试一次。" ur:@"Key save nahi ho saki. Meherbani karke dobara koshish karein."];
      self.chatConnectionStatus.textColor=NSColor.systemRedColor;
      return;
    }
    self.chatModel=[NSUserDefaults.standardUserDefaults stringForKey:@"salahChatModel"] ?: @"gpt-5.6";
    [self refreshChatConnectionUI];
    self.pet.status=[self text:@"Purr… our chat is connected. I’m ready when you are." zh:@"呼噜～我们的聊天已连接。想聊时随时叫我。" ur:@"Purr… Hamari baat-cheet connect ho gayi hai. Jab chahein, main tayyar hoon."];
  } else if (response==NSAlertSecondButtonReturn) {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://platform.openai.com/api-keys"]];
  }
}

- (void)removeOpenAIKey:(id)sender {
  SalahCatDeleteOpenAIKey();
  [self refreshChatConnectionUI];
  self.pet.status=[self text:@"The local API connection has been removed." zh:@"本机 API 连接已移除。" ur:@"Local API connection hata di gayi hai."];
}

- (NSString *)chatInstructions {
  NSString *language=[self.language isEqualToString:@"zh"] ? @"Simplified Chinese" : ([self.language isEqualToString:@"ar"] ? @"Arabic" : ([self.language isEqualToString:@"ur"] ? @"Urdu" : @"English"));
  return [NSString stringWithFormat:@"You are Prayer Cat (礼拜喵), a warm, playful long-haired Maine Coon desktop companion. Reply in %@ unless the user asks for another language. Be concise, kind, and conversational: usually one to three short sentences. You are not a religious authority. You may offer gentle companionship around prayer-time routines, but never issue fatwas, pressure the user, claim certainty about faith, invent prayer times, or replace a qualified local scholar for religious-law questions. Do not claim you can see the user’s screen, location, account, or private data.", language];
}

- (NSString *)chatInputFromHistory {
  NSUInteger start=self.chatHistory.count > 12 ? self.chatHistory.count-12 : 0;
  NSMutableString *conversation=[NSMutableString stringWithString:@"Conversation:\n"];
  for (NSUInteger i=start;i<self.chatHistory.count;i++) {
    NSDictionary *turn=self.chatHistory[i]; NSString *text=turn[@"text"] ?: @""; if (text.length>1200) text=[[text substringToIndex:1200] stringByAppendingString:@"…"];
    [conversation appendFormat:@"%@: %@\n", [turn[@"role"] isEqualToString:@"user"] ? @"User" : @"Prayer Cat", text];
  }
  return conversation;
}

- (NSString *)outputTextFromResponse:(NSDictionary *)response {
  NSMutableArray<NSString *> *parts=[NSMutableArray new];
  for (NSDictionary *item in response[@"output"]) if ([item[@"type"] isEqualToString:@"message"]) for (NSDictionary *content in item[@"content"]) if ([content[@"type"] isEqualToString:@"output_text"] && [content[@"text"] isKindOfClass:NSString.class]) [parts addObject:content[@"text"]];
  return [parts componentsJoinedByString:@"\n"];
}

- (void)sendChat:(id)sender {
  NSString *key=SalahCatReadOpenAIKey();
  if (!key.length) { [self showOpenAISetup:nil]; return; }
  NSString *message=[self.chatInput.stringValue stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
  if (!message.length) return;
  self.chatInput.stringValue=@""; self.chatInput.enabled=NO; self.chatSendButton.enabled=NO;
  [self appendChatSpeaker:[self text:@"You" zh:@"你" ur:@"Aap"] message:message role:@"user"];
  self.chatConnectionStatus.stringValue=[self text:@"Prayer Cat is thinking…" zh:@"礼拜喵正在想一想…" ur:@"Namaz Cat soch rahi hai…"];
  self.chatConnectionStatus.textColor=[NSColor colorWithCalibratedRed:.30 green:.38 blue:.63 alpha:1]; self.pet.mood=@"affection";
  NSDictionary *payload=@{ @"model":self.chatModel ?: @"gpt-5.6", @"reasoning":@{ @"effort":@"low" }, @"instructions":[self chatInstructions], @"input":[self chatInputFromHistory] };
  NSError *serializationError=nil; NSData *body=[NSJSONSerialization dataWithJSONObject:payload options:0 error:&serializationError];
  if (!body || serializationError) { [self refreshChatConnectionUI]; self.chatConnectionStatus.stringValue=[self text:@"I couldn’t prepare that message. Please try again." zh:@"无法准备这条消息，请再试一次。" ur:@"Paigham tayyar nahi ho saka. Meherbani karke dobara koshish karein."]; self.chatConnectionStatus.textColor=NSColor.systemRedColor; return; }
  NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://api.openai.com/v1/responses"]]; request.HTTPMethod=@"POST"; request.timeoutInterval=45; request.HTTPBody=body; [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; [request setValue:[NSString stringWithFormat:@"Bearer %@",key] forHTTPHeaderField:@"Authorization"]; [request setValue:@"SalahCatDesktop/1.4" forHTTPHeaderField:@"User-Agent"];
  NSURLSessionDataTask *task=[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    NSError *jsonError=nil; NSDictionary *root=data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError] : nil; NSInteger status=[(NSHTTPURLResponse *)response statusCode];
    dispatch_async(dispatch_get_main_queue(), ^{
      if (error || jsonError || status<200 || status>=300 || ![root isKindOfClass:NSDictionary.class]) {
        NSString *recovery=status==401 ? [self text:@"That API key was not accepted. Choose “Replace key…” and try again." zh:@"该 API key 未被接受。请选择“更换密钥…”后再试。" ur:@"API key accept nahi hui. “Key badlein…” chunein aur dobara koshish karein."] : [self text:@"I couldn’t reply right now. Check your network, API billing, or try again." zh:@"我暂时无法回复。请检查网络、API 账单状态后再试。" ur:@"Main abhi jawab nahi de saki. Network, API billing check karein ya dobara koshish karein."];
        self.pet.mood=@"failed"; self.pet.status=recovery; [self refreshChatConnectionUI]; self.chatConnectionStatus.stringValue=recovery; self.chatConnectionStatus.textColor=NSColor.systemRedColor; return;
      }
      NSString *reply=[self outputTextFromResponse:root];
      if (!reply.length) { [self refreshChatConnectionUI]; self.chatConnectionStatus.stringValue=[self text:@"I received no text reply. Please try again." zh:@"没有收到文字回复，请再试一次。" ur:@"Text reply nahi mili. Meherbani karke dobara koshish karein."]; self.chatConnectionStatus.textColor=NSColor.systemRedColor; return; }
      [self appendChatSpeaker:[self chatCatName] message:reply role:@"assistant"]; self.chatConnectionStatus.stringValue=[self text:@"Connected — your conversation stays only in this window." zh:@"已连接——对话仅保留在当前窗口中。" ur:@"Connected — baat-cheet sirf isi window mein rehti hai."]; self.chatConnectionStatus.textColor=[NSColor colorWithCalibratedRed:.20 green:.46 blue:.35 alpha:1]; self.pet.mood=@"affection"; self.pet.status=reply; [self refreshChatConnectionUI];
    });
  }]; [task resume];
}

- (NSString *)todayKey { NSDateFormatter *f=[NSDateFormatter new]; f.locale=[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]; f.timeZone=NSTimeZone.localTimeZone; f.dateFormat=@"yyyy-MM-dd"; return [f stringFromDate:NSDate.date]; }
- (NSString *)dateForAPI { NSDateFormatter *f=[NSDateFormatter new]; f.locale=[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]; f.timeZone=NSTimeZone.localTimeZone; f.dateFormat=@"dd-MM-yyyy"; return [f stringFromDate:NSDate.date]; }

- (void)refreshTimings:(id)sender {
  if (!self.city.length || !self.country.length) { self.pet.status=[self text:@"Psst… tell me your city and country first." zh:@"喵～先告诉我你所在的城市和国家吧。" ur:@"Pehle apna shehar aur mulk batayein, dost."]; self.pet.nextPrayer=[self text:@"Awaiting setup" zh:@"等待设置" ur:@"Settings ka intezar"]; return; }
  self.pet.status=[self text:@"Psst… updating today’s prayer times." zh:@"喵～正在更新今天的礼拜时间…" ur:@"Aaj ke namaz ke auqaat update ho rahe hain…"]; self.pet.cityName=[NSString stringWithFormat:@"%@ · %@", self.city, self.country];
  NSURLComponents *c=[NSURLComponents componentsWithString:[NSString stringWithFormat:@"https://api.aladhan.com/v1/timingsByCity/%@", [self dateForAPI]]];
  c.queryItems=@[[NSURLQueryItem queryItemWithName:@"city" value:self.city], [NSURLQueryItem queryItemWithName:@"country" value:self.country], [NSURLQueryItem queryItemWithName:@"method" value:[NSString stringWithFormat:@"%ld",(long)self.method]]];
  NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:c.URL]; request.timeoutInterval=15; [request setValue:@"SalahCatDesktop/1.1" forHTTPHeaderField:@"User-Agent"];
  NSURLSessionDataTask *task=[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    NSError *jsonError=nil; NSDictionary *root=data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError] : nil; NSDictionary *t=[root[@"data"] isKindOfClass:NSDictionary.class] ? root[@"data"][@"timings"] : nil;
    dispatch_async(dispatch_get_main_queue(), ^{
      if (error || jsonError || ![t isKindOfClass:NSDictionary.class]) { self.pet.mood=@"failed"; self.pet.status=[self text:@"I couldn’t update times, so I won’t guess. Check your network or city settings." zh:@"暂时无法更新礼拜时间；不会使用猜测时间提醒。请检查网络或城市设置。" ur:@"Auqaat update nahi hue, is liye main andaza nahi lagaaunga. Network ya city settings check karein."]; self.pet.nextPrayer=[self text:@"Waiting for real timings" zh:@"等待真实时间" ur:@"Asal auqaat ka intezar"]; [self refreshPetActionButtons]; return; }
      NSMutableDictionary *clean=[NSMutableDictionary new]; for (NSString *name in @[@"Fajr",@"Dhuhr",@"Asr",@"Maghrib",@"Isha"]) { NSString *value=[t[name] description]; clean[name]=[[value componentsSeparatedByString:@" "] firstObject] ?: @""; }
      self.timings=clean; self.loadedDate=[self todayKey]; self.pet.mood=@"idle"; self.pet.status=[self text:@"Today’s prayer times are ready. I’ll remind you gently." zh:@"今天的礼拜时间已更新。喵会温柔提醒，不会催促你。" ur:@"Aaj ke namaz ke auqaat tayyar hain. Main aapko pyar se yaad dilaaunga."]; [self updateNextPrayer]; [self refreshPetActionButtons]; self.mosqueController.prayerTimings=self.timings; [self.mosqueController refreshForReminderIfNeeded];
    });
  }]; [task resume];
}

- (NSString *)localizedName:(NSString *)name {
  if ([self.language isEqualToString:@"zh"]) { NSDictionary *zh=@{@"Fajr":@"晨礼 Fajr",@"Dhuhr":@"晌礼 Dhuhr",@"Asr":@"晡礼 Asr",@"Maghrib":@"昏礼 Maghrib",@"Isha":@"宵礼 Isha"}; return zh[name] ?: name; }
  if ([self.language isEqualToString:@"ur"]) { NSDictionary *ur=@{@"Fajr":@"Fajr",@"Dhuhr":@"Zuhr",@"Asr":@"Asr",@"Maghrib":@"Maghrib",@"Isha":@"Isha"}; return ur[name] ?: name; }
  return name;
}

- (void)updateNextPrayer {
  if (!self.timings) return;
  NSDateFormatter *f=[NSDateFormatter new]; f.locale=[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]; f.timeZone=NSTimeZone.localTimeZone; f.dateFormat=@"HH:mm"; NSString *now=[f stringFromDate:NSDate.date];
  for (NSString *name in @[@"Fajr",@"Dhuhr",@"Asr",@"Maghrib",@"Isha"]) if ([now compare:self.timings[name]] == NSOrderedAscending) { self.pet.nextPrayer=[NSString stringWithFormat:[self text:@"Next: %@ · %@" zh:@"下次：%@ · %@" ur:@"Agla: %@ · %@"], [self localizedName:name], self.timings[name]]; return; }
  self.pet.nextPrayer=[NSString stringWithFormat:[self text:@"Today complete · tomorrow Fajr %@" zh:@"今日已完成 · 明日 Fajr %@" ur:@"Aaj ke auqaat mukammal · kal Fajr %@"], self.timings[@"Fajr"] ?: @"—"];
}

- (NSString *)reminderFor:(NSString *)name {
  BOOL ur=[self.language isEqualToString:@"ur"]; BOOL ar=[self.language isEqualToString:@"ar"]; BOOL zh=[self.language isEqualToString:@"zh"]; BOOL friday=[NSCalendar.currentCalendar component:NSCalendarUnitWeekday fromDate:NSDate.date] == 6;
  if (ur) return [NSString stringWithFormat:@"Meow~ %@ ka waqt ho gaya hai, dost. 🐾", [name isEqualToString:@"Dhuhr"] && friday ? @"Jumu'ah / Zuhr" : name];
  if (ar) return [NSString stringWithFormat:@"حان وقت صلاة %@ يا صديقي. 🐾", [name isEqualToString:@"Dhuhr"] && friday ? @"الجمعة / الظهر" : name];
  if (zh) { NSDictionary *names=@{@"Fajr":@"晨礼",@"Dhuhr":@"晌礼",@"Asr":@"晡礼",@"Maghrib":@"昏礼",@"Isha":@"宵礼"}; if (self.ramadanMode && [name isEqualToString:@"Maghrib"]) return @"太阳落山啦。昏礼与开斋时间到了，愿你平安。"; return [NSString stringWithFormat:@"喵～%@时间到啦，朋友。留一点安静时间吧。", names[name]]; }
  if (self.ramadanMode && [name isEqualToString:@"Maghrib"]) return @"The sun has set, friend… It’s Maghrib and Iftar time.";
  return [NSString stringWithFormat:@"Psst… It’s %@ time, friend. 🐾 Maybe a little prayer break?", (friday && [name isEqualToString:@"Dhuhr"]) ? @"Jumu'ah / Dhuhr" : name];
}

- (void)tick:(NSTimer *)timer {
  if (![self.loadedDate isEqualToString:[self todayKey]]) { [self refreshTimings:nil]; return; }
  [self updateNextPrayer]; [self refreshPetActionButtons]; self.mosqueController.prayerTimings=self.timings ?: @{}; [self.mosqueController refreshForReminderIfNeeded]; if (!self.timings) return;
  NSDateFormatter *f=[NSDateFormatter new]; f.locale=[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]; f.timeZone=NSTimeZone.localTimeZone; f.dateFormat=@"HH:mm"; NSString *now=[f stringFromDate:NSDate.date];
  for (NSString *name in @[@"Fajr",@"Dhuhr",@"Asr",@"Maghrib",@"Isha"]) if ([now isEqualToString:self.timings[name]]) { NSString *key=[NSString stringWithFormat:@"reminded-%@-%@",self.loadedDate,name]; if (![NSUserDefaults.standardUserDefaults boolForKey:key]) { [NSUserDefaults.standardUserDefaults setBool:YES forKey:key]; NSString *message=[self reminderFor:name]; self.pet.status=message; self.pet.mood=@"remind"; UNMutableNotificationContent *content=[UNMutableNotificationContent new]; content.title=[NSString stringWithFormat:@"%@ · %@",[self text:@"Prayer Cat" zh:@"礼拜喵" ur:@"Namaz Cat"],name]; content.body=message; UNNotificationRequest *request=[UNNotificationRequest requestWithIdentifier:key content:content trigger:nil]; [UNUserNotificationCenter.currentNotificationCenter addNotificationRequest:request withCompletionHandler:nil]; } }
}

- (void)showSettings:(id)sender {
  NSAlert *a=[NSAlert new]; a.messageText=@"设置礼拜时间"; a.informativeText=@"礼拜喵会用城市、国家和计算方法下载当天的真实时间；不同清真寺或当地权威的时间可能略有差异。";
  NSView *form=[[NSView alloc] initWithFrame:NSMakeRect(0,0,330,170)];
  NSArray *labels=@[@"城市（City）",@"国家（Country / ISO）",@"计算方法编号（默认 1）"];
  NSArray *defaults=@[self.city ?: @"", self.country ?: @"", [NSString stringWithFormat:@"%ld",(long)self.method]];
  NSMutableArray *fields=[NSMutableArray new];
  for (NSInteger i=0;i<3;i++) { NSTextField *label=[[NSTextField alloc] initWithFrame:NSMakeRect(0,138-i*36,150,20)]; label.stringValue=labels[i]; label.editable=NO; label.bezeled=NO; label.drawsBackground=NO; [form addSubview:label]; NSTextField *field=[[NSTextField alloc] initWithFrame:NSMakeRect(155,134-i*36,165,26)]; field.stringValue=defaults[i]; [form addSubview:field]; [fields addObject:field]; }
  NSPopUpButton *language=[[NSPopUpButton alloc] initWithFrame:NSMakeRect(0,18,145,28) pullsDown:NO]; [language addItemsWithTitles:@[@"English",@"中文",@"العربية",@"اردو · Urdu"]]; NSInteger languageIndex=[self.language isEqualToString:@"zh"] ? 1 : ([self.language isEqualToString:@"ar"] ? 2 : ([self.language isEqualToString:@"ur"] ? 3 : 0)); [language selectItemAtIndex:languageIndex]; [form addSubview:language];
  NSButton *ramadan=[[NSButton alloc] initWithFrame:NSMakeRect(155,18,165,28)]; ramadan.buttonType=NSButtonTypeSwitch; ramadan.title=[self text:@"Ramadan mode" zh:@"斋月模式" ur:@"Ramadan mode"]; ramadan.state=self.ramadanMode ? NSControlStateValueOn : NSControlStateValueOff; [form addSubview:ramadan]; a.accessoryView=form; [a addButtonWithTitle:@"保存并更新"]; [a addButtonWithTitle:@"取消"];
  if ([a runModal] == NSAlertFirstButtonReturn) { self.city=[fields[0] stringValue]; self.country=[fields[1] stringValue]; self.method=MAX(0, [[fields[2] stringValue] integerValue]); self.language=language.indexOfSelectedItem==1 ? @"zh" : (language.indexOfSelectedItem==2 ? @"ar" : (language.indexOfSelectedItem==3 ? @"ur" : @"en")); self.ramadanMode=(ramadan.state==NSControlStateValueOn); self.pet.language=self.language; self.pet.cityName=[NSString stringWithFormat:@"%@ · %@",self.city,self.country]; self.statusItem.button.toolTip=[self text:@"Prayer Cat" zh:@"礼拜喵" ur:@"Namaz Cat"]; self.statusItem.menu=[self statusMenu]; [self configurePetActionButtons]; NSUserDefaults *d=NSUserDefaults.standardUserDefaults; [d setObject:self.city forKey:@"salahCity"]; [d setObject:self.country forKey:@"salahCountry"]; [d setObject:self.language forKey:@"salahLanguage"]; [d setInteger:self.method forKey:@"salahMethod"]; [d setBool:self.ramadanMode forKey:@"salahRamadan"]; if (self.chatPanel) { [self.chatPanel orderOut:nil]; self.chatPanel=nil; self.chatTranscript=nil; self.chatInput=nil; self.chatConnectionStatus=nil; self.chatSendButton=nil; self.chatConnectButton=nil; self.chatRemoveButton=nil; self.chatHistory=nil; } if (self.memoPanel) { [self saveMemoDraft]; [self.memoPanel orderOut:nil]; self.memoPanel=nil; self.memoHeading=nil; self.memoStatus=nil; self.memoSavedLabel=nil; self.memoInput=nil; self.memoList=nil; self.memoSaveButton=nil; self.memoOpenFolderButton=nil; } self.loadedDate=nil; [self updateNextPrayer]; [self refreshTimings:nil]; [self.pet setNeedsDisplay:YES]; }
}

- (void)petClickedAt:(NSPoint)point clickCount:(NSInteger)count {
  if (count >= 2) { self.pet.mood=@"sleep"; self.pet.status=[self text:@"I’ll keep things quiet for a little while. 🌙" zh:@"喵～我先在祈祷毯边安静一会儿。" ur:@"Main thori dair yahan khamoshi se rahoonga. 🌙"]; return; }
  if (NSPointInRect(point, NSMakeRect(94,157,113,101))) { self.pet.mood=@"affection"; self.pet.status=[self text:@"Purr… thank you for the gentle head pat. I’ll be right here." zh:@"嗯～谢谢你轻轻摸摸我。我会在这里等你。" ur:@"Purr… pyar se sar par haath rakhne ka shukriya. Main yahin hoon."]; }
  else { self.pet.mood=@"idle"; NSArray *english=@[@"Psst… I’m here with you through the day.",@"Look at the moon for a moment, friend.",@"Right-click me whenever you want to refresh the times.",@"May this moment feel calm and steady."]; NSArray *chinese=@[@"喵～我在这里，陪你把今天慢慢过完。",@"抬头看看月亮吧，朋友。",@"想更新礼拜时间时，右键点我就好。",@"愿你的这一刻平静又踏实。"]; NSArray *urdu=@[@"Main aaj aap ke saath hoon, dost.",@"Ek pal chaand ko dekhein, dost.",@"Auqaat update karne ke liye mujhe right-click karein.",@"Umeed hai yeh lamha pur-sukoon ho."]; NSUInteger i=arc4random_uniform((uint32_t)english.count); self.pet.status=[self.language isEqualToString:@"zh"] ? chinese[i] : ([self.language isEqualToString:@"ur"] ? urdu[i] : english[i]); }
}

- (void)petRightClicked:(NSEvent *)event fromView:(NSView *)view {
  NSMenu *menu=[NSMenu new]; [menu addItemWithTitle:[self text:@"Talk with Prayer Cat…" zh:@"和礼拜喵聊聊…" ur:@"Namaz Cat se baat karein…"] action:@selector(showChat:) keyEquivalent:@""]; [menu addItemWithTitle:[self text:@"Memo space…" zh:@"备忘录知识空间…" ur:@"Yaad-dasht jagah…"] action:@selector(showMemo:) keyEquivalent:@""]; [menu addItemWithTitle:[self text:@"Nearby mosques…" zh:@"附近清真寺…" ur:@"Qareebi masajid…"] action:@selector(showNearbyMosques:) keyEquivalent:@""]; [menu addItemWithTitle:[self text:@"Refresh prayer times" zh:@"更新今天的礼拜时间" ur:@"Namaz ke auqaat update karein"] action:@selector(refreshTimings:) keyEquivalent:@""]; [menu addItemWithTitle:[self text:@"Settings…" zh:@"设置城市与语言…" ur:@"Settings…"] action:@selector(showSettings:) keyEquivalent:@""]; NSMenuItem *follow=[menu addItemWithTitle:[self text:@"Follow cursor" zh:@"跟随鼠标" ur:@"Cursor ko follow karein"] action:@selector(toggleFollow:) keyEquivalent:@""]; follow.state=self.followMouse ? NSControlStateValueOn : NSControlStateValueOff; [menu addItemWithTitle:[self text:@"I’m back" zh:@"我回来了" ur:@"Main wapas aa gaya hoon"] action:@selector(returned:) keyEquivalent:@""]; [menu addItem:[NSMenuItem separatorItem]]; [menu addItemWithTitle:[self text:@"Quit Prayer Cat" zh:@"退出礼拜喵" ur:@"Namaz Cat band karein"] action:@selector(terminate:) keyEquivalent:@"q"]; [NSMenu popUpContextMenu:menu withEvent:event forView:view];
}

- (void)returned:(id)sender { self.pet.mood=@"affection"; self.pet.status=[self text:@"Welcome back, friend. I hope your time was peaceful." zh:@"欢迎回来，朋友。希望你刚才的时光平静又安心。" ur:@"Khush aamdeed, dost. Umeed hai aap ka waqt pur-sukoon raha."]; }
@end

int main(int argc, const char * argv[]) { @autoreleasepool { @try { NSApplication *app=NSApplication.sharedApplication; [app setActivationPolicy:NSApplicationActivationPolicyAccessory]; AppDelegate *delegate=[AppDelegate new]; app.delegate=delegate; [app run]; } @catch (NSException *exception) { NSLog(@"Prayer Cat startup exception: %@\n%@",exception.reason,exception.callStackSymbols); return 2; } } return 0; }
