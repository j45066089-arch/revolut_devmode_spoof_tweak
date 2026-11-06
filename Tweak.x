/*
 * Revolut Incognia Jailbreak Bypass
 * Hooks Incognia SDK and MobileGestalt to bypass jailbreak detection
 */

#include <UIKit/UIKit.h>
#include <Foundation/Foundation.h>
#include <substrate.h>

static bool isRevolut() {
    return [[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.revolut.revolut"];
}

// Hook Incognia SDK
%hook ICGIncognia
- (void)trackLocalizedEvent:(NSString *)event withProperties:(NSDictionary *)properties {
    NSLog(@"[RevolutJB] ICGIncognia trackLocalizedEvent: %@", event);
    %orig;
}

- (void)startWithCompletion:(void(^)(BOOL))completion {
    NSLog(@"[RevolutJB] ICGIncognia startWithCompletion");
    %orig(^{
        if (isRevolut()) {
            NSLog(@"[RevolutJB] Incognia started");
        }
    });
}
%end

// Hook MobileGestalt for DeveloperMode
%hook MobileGestalt
+ (id)answerForKey:(NSString *)key {
    id result = %orig;
    
    if (isRevolut() && [key isEqualToString:@"DeveloperMode"]) {
        NSLog(@"[RevolutJB] Spoofing DeveloperMode -> false");
        return @NO;
    }
    
    return result;
}

+ (NSDictionary *)answersForKeys:(NSArray *)keys {
    NSDictionary *result = %orig;
    
    if (!isRevolut()) {
        return result;
    }
    
    NSMutableDictionary *spoofed = [result mutableCopy];
    
    for (NSString *key in keys) {
        if ([key isEqualToString:@"DeveloperMode"]) {
            NSLog(@"[RevolutJB] Spoofing DeveloperMode in answersForKeys -> false");
            spoofed[key] = @NO;
        }
    }
    
    return spoofed;
}
%end

// Hook cydia:// URL scheme
%hook UIApplication
- (BOOL)openURL:(NSURL *)url {
    if ([url.scheme isEqualToString:@"cydia"]) {
        NSLog(@"[RevolutJB] Blocking cydia:// URL");
        return NO;
    }
    return %orig;
}
%end

// Hook file system for jailbreak paths
%hook NSFileManager
- (BOOL)fileExistsAtPath:(NSString *)path {
    BOOL exists = %orig;
    
    if (!isRevolut()) {
        return exists;
    }
    
    NSArray *jbPaths = @[
        @"/var/lib/cydia",
        @"/Applications/Cydia.app",
        @"/Applications/Sileo.app",
        @"/Applications/Zebra.app",
        @"/Applications/SBSettings.app",
        @"/private/var/tmp/cydia.log",
        @"/usr/libexec/cydia",
        @"/Library/MobileSubstrate/CydiaSubstrate.dylib",
        @"/.cydia_no_stash",
        @"/jb/jailbreakd.plist"
    ];
    
    for (NSString *jbPath in jbPaths) {
        if ([path isEqualToString:jbPath] || [path hasPrefix:jbPath]) {
            NSLog(@"[RevolutJB] Spoofing file exists: %@", path);
            return NO;
        }
    }
    
    return exists;
}
%end

%ctor {
    NSLog(@"[RevolutJB] Tweak loaded for %@", [[NSBundle mainBundle] bundleIdentifier]);
    
    // Set Incognia options
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"skipAdvancedJailbreakValidation"];
    [defaults setBool:YES forKey:@"key_disableJailbreakDetection"];
    [defaults setBool:NO forKey:@"can_open_cydia_url"];
    [defaults synchronize];
    
    NSLog(@"[RevolutJB] Incognia options set");
}
