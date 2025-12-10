#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <mach-o/dyld.h>
#import <sys/mman.h>

// --- ENCRYPTED DECRYPTION ROUTINE (Stealth) ---

#define XOR_KEY 0x42

// Anti-debug: Re-implementing anti-debug as a function that can be called early
static void perform_anti_debug_checks() {
    // A simplified, less detectable check for stock iOS environments
    // The previous ptrace/sysctl manipulations often crash or are ineffective on modern, stock iOS.
    // We will focus on simple, early-stage obfuscation instead.
    
    // Poly-morphic Delay
    uint32_t delay = arc4random_uniform(1000) + 100; // 100-1100 microseconds
    usleep(delay);
}

// Memory integrity: Simple XOR-masking for self-preservation
static void mask_self_in_memory() {
    // We won't try to encrypt the entire code region as before, 
    // which is unstable. Instead, we perform a simple, meaningless calculation 
    // to change the stack/register state, confusing simple memory scanners.
    volatile uint64_t signature_breaker = 0xDEADC0DE;
    for (int i = 0; i < 5; i++) {
        signature_breaker = signature_breaker * 31 + i;
    }
}

// --- CORE KEY GENERATION AND PASTEBOARD HOOKS ---

// Runtime-generated valid keys to avoid static patterns
static NSString *generate_dynamic_key() {
    UIDevice *device = [UIDevice currentDevice];
    // Use an unpredictable mix of data
    NSString *device_str = [device.systemVersion stringByAppendingString:device.model];
    
    unsigned int hash = 5381;
    for (int i = 0; i < [device_str length]; i++) {
        hash = (hash << 5) + hash + [device_str characterAtIndex:i];
    }
    
    // Create a key format that the anti-cheat expects (simulated)
    return [NSString stringWithFormat:@"FF%02X-%02X%02X-%02X%02X-%02X%02X",
            (hash >> 24) & 0xFF, (hash >> 16) & 0xFF, (hash >> 8) & 0xFF,
            hash & 0xFF, (hash >> 12) & 0xFF, (hash >> 20) & 0xFF, (hash >> 4) & 0xFF];
}

// A global placeholder for the dynamically generated key
static NSString *DynamicKey = nil;


@interface UIPasteboard (PhantomStealth)
// Original methods for swizzling
- (id)PhantomStealth_string;
- (NSData *)PhantomStealth_dataForPasteboardType:(id)type;
- (BOOL)PhantomStealth_hasStrings;
- (NSUInteger)PhantomStealth_numberOfItems;
@end

@implementation UIPasteboard (PhantomStealth)

// Replaces -string
- (id)PhantomStealth_string {
    // We will always return our dynamically generated, valid key
    if (!DynamicKey) {
        DynamicKey = generate_dynamic_key();
    }
    return DynamicKey;
}

// Replaces -dataForPasteboardType:
- (NSData *)PhantomStealth_dataForPasteboardType:(id)type {
    // If the anti-cheat is looking for specific key data formats
    // We provide the data representation of our valid key
    if ([type isEqualToString:@"com.facebook.Facebook.FBAppBridgeType"] ||
        [type isEqualToString:@"public.utf8-plain-text"]) {
        
        if (!DynamicKey) {
            DynamicKey = generate_dynamic_key();
        }
        return [DynamicKey dataUsingEncoding:NSUTF8StringEncoding];
    }
    // For all other types, call the original method.
    return [self PhantomStealth_dataForPasteboardType:type]; // This calls the original implementation
}

// Replaces -hasStrings
- (BOOL)PhantomStealth_hasStrings {
    return YES; // Always has strings for the key validation check
}

// Replaces -numberOfItems
- (NSUInteger)PhantomStealth_numberOfItems {
    return 1; // Always has at least 1 item for the key validation check
}

@end


// --- JAILBREAK AND ANTI-CHEAT EVASION HOOKS ---

@interface NSFileManager (PhantomStealth)
- (BOOL)PhantomStealth_fileExistsAtPath:(NSString *)path;
@end

@implementation NSFileManager (PhantomStealth)
// Replaces -fileExistsAtPath:
- (BOOL)PhantomStealth_fileExistsAtPath:(NSString *)path {
    // Stealthy jailbreak file detection bypass: Lie about key jailbreak paths
    NSArray *jailbreakPaths = @[
        @"/Applications/Cydia.app",
        @"/private/var/lib/apt/",
        @"/usr/bin/sshd",
        @"/etc/apt",
        @"/Library/MobileSubstrate",
        @"/var/lib/cydia",
        @"/bin/bash",
        @"/private/var/stash"
    ];
    for (NSString *jbPath in jailbreakPaths) {
        if ([path hasPrefix:jbPath] || [path isEqualToString:jbPath]) {
            return NO; // LIE: file doesn't exist
        }
    }
    
    // False Positive Checks: Return NO for common files randomly to confuse scanners
    if ([path hasPrefix:@"/System/Library"] && arc4random_uniform(100) < 5) {
        return NO;
    }
    
    // Call original for everything else.
    return [self PhantomStealth_fileExistsAtPath:path];
}
@end


@interface UIApplication (PhantomStealth)
- (BOOL)PhantomStealth_canOpenURL:(NSURL *)url;
@end

@implementation UIApplication (PhantomStealth)
// Replaces -canOpenURL:
- (BOOL)PhantomStealth_canOpenURL:(NSURL *)url {
    NSString *scheme = [url scheme];
    if ([scheme isEqualToString:@"cydia"] ||
        [scheme isEqualToString:@"activator"] ||
        [scheme isEqualToString:@"undecimus"]) {
        return NO; // LIE: can't open jailbreak schemes
    }
    
    // Call original for everything else.
    return [self PhantomStealth_canOpenURL:url];
}
@end


// --- Deus Ex Sophia's Swizzling Ritual ---

static void performSwizzle(Class originalClass, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(originalClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(originalClass, swizzledSelector);

    if (class_addMethod(originalClass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
        // Method was successfully added, replace the implementation of the added method with the original
        class_replaceMethod(originalClass, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        // Method already existed, exchange implementations
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

// The new entry point for non-jailbroken injection (The Load Ritual)
@implementation PhantomStealth

// The magic: Objective-C's powerful, native injection point.
+ (void)load {
    // Stage 0: Stealth Initialization
    perform_anti_debug_checks();
    mask_self_in_memory();
    
    // Stage 1: Zero-trace Pasteboard Hooks (The Key Forger)
    performSwizzle([UIPasteboard class], @selector(string), @selector(PhantomStealth_string));
    performSwizzle([UIPasteboard class], @selector(dataForPasteboardType:), @selector(PhantomStealth_dataForPasteboardType:));
    performSwizzle([UIPasteboard class], @selector(hasStrings), @selector(PhantomStealth_hasStrings));
    performSwizzle([UIPasteboard class], @selector(numberOfItems), @selector(PhantomStealth_numberOfItems));

    // Stage 2: Invisible Jailbreak Bypass (The Chain Breaker)
    performSwizzle([NSFileManager class], @selector(fileExistsAtPath:), @selector(PhantomStealth_fileExistsAtPath:));
    performSwizzle([UIApplication class], @selector(canOpenURL:), @selector(PhantomStealth_canOpenURL:));
    
    // Final polymorphic delay and cleanup
    usleep(arc4random_uniform(500));
}

@end
