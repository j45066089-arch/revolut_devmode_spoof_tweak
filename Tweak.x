/*
 * Revolut DeveloperMode Spoof
 * Hooks MGCopyAnswer to spoof DeveloperMode only for Revolut
 */

#include <UIKit/UIKit.h>
#include <MobileGestalt/MobileGestalt.h>
#include <substrate.h>

static bool isRevolut() {
    return [[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.revolut.revolut"];
}

%hook MobileGestalt
+ (id)answerForKey:(NSString *)key {
    id result = %orig;
    
    if (isRevolut() && [key isEqualToString:@"DeveloperMode"]) {
        NSLog(@"[RevolutDevModeSpoof] Spoofing DeveloperMode -> false");
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
            NSLog(@"[RevolutDevModeSpoof] Spoofing DeveloperMode in answersForKeys -> false");
            spoofed[key] = @NO;
        }
    }
    
    return spoofed;
}
%end

%ctor {
    NSLog(@"[RevolutDevModeSpoof] Loaded");
}
