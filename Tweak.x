#import <libcolorpicker.h>

static UIColor *customColor;
static BOOL enabled, retainAlpha;

static void setupPrefs() {
	NSDictionary *settings;

	CFArrayRef keyList = CFPreferencesCopyKeyList(CFSTR("com.shepgoba.colorscrollprefs"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (keyList) {
		settings = (NSMutableDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, CFSTR("com.shepgoba.colorscrollprefs"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
		CFRelease(keyList);
	} else {
		settings = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.shepgoba.colorscrollprefs.plist"];
	}

	enabled = [([settings objectForKey:@"enabled"] ? [settings objectForKey:@"enabled"] : @(YES)) boolValue];
	retainAlpha = [([settings objectForKey:@"retainAlpha"] ? [settings objectForKey:@"retainAlpha"] : @(YES)) boolValue];

	NSDictionary *colors = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.shepgoba.colorscrollprefs.color.plist"];
	customColor = LCPParseColorString([colors objectForKey:@"scrollIndicatorColor"], @"#FFFFFF");
}

%hook _UIScrollViewScrollIndicator 
-(id)_colorForStyle:(long long)arg1 {

	CGFloat red, green, blue, alpha;
	[customColor getRed:&red green:&green blue:&blue alpha:&alpha];

	if (retainAlpha) {
		UIColor *orig = %orig;

		CGFloat origAlpha;
		[orig getRed:NULL green:NULL blue:NULL alpha:&origAlpha];
		alpha = origAlpha;
	}

	return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}
%end

%ctor {
	setupPrefs();
	if (enabled)
		%init(_ungrouped);
}