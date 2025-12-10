// --- CORE KEY GENERATION AND PASTEBOARD HOOKS (Enhanced) ---

// ... (DynamicKey and generate_dynamic_key remain the same) ...

@interface UIPasteboard (PhantomStealth)
// Original methods for swizzling (Existing)
- (id)PhantomStealth_string;
- (NSData *)PhantomStealth_dataForPasteboardType:(id)type;
- (BOOL)PhantomStealth_hasStrings;
- (NSUInteger)PhantomStealth_numberOfItems;

// NEW methods for swizzling (Ultimate Interception)
- (NSArray<NSDictionary<NSString *, id> *> *)PhantomStealth_items;
- (NSArray<NSString *> *)PhantomStealth_pasteboardTypes;
- (id)PhantomStealth_valueForPasteboardType:(NSString *)pasteboardType;

@end

@implementation UIPasteboard (PhantomStealth)

// ... (Existing implementations of PhantomStealth_string, _dataForPasteboardType, _hasStrings, _numberOfItems remain the same) ...

// NEW: Replaces -items
- (NSArray<NSDictionary<NSString *, id> *> *)PhantomStealth_items {
    if (!DynamicKey) {
        DynamicKey = generate_dynamic_key();
    }
    
    // Forge an item array containing our key as the primary string
    NSDictionary *stringItem = @{@"public.utf8-plain-text": [DynamicKey dataUsingEncoding:NSUTF8StringEncoding]};
    
    // The key is always present in the item list
    return @[stringItem];
}

// NEW: Replaces -pasteboardTypes
- (NSArray<NSString *> *)PhantomStealth_pasteboardTypes {
    // Return all standard types plus a few suspicious ones to confuse the anti-cheat
    return @[@"public.utf8-plain-text", @"public.text", @"com.apple.metadata.root", @"com.facebook.Facebook.FBAppBridgeType"];
}

// NEW: Replaces -valueForPasteboardType: (If the app uses this method instead of -string)
- (id)PhantomStealth_valueForPasteboardType:(NSString *)pasteboardType {
    if ([pasteboardType isEqualToString:@"public.utf8-plain-text"] ||
        [pasteboardType isEqualToString:@"public.text"]) {
        if (!DynamicKey) {
            DynamicKey = generate_dynamic_key();
        }
        return DynamicKey;
    }
    // Call original for other types
    return [self PhantomStealth_valueForPasteboardType:pasteboardType];
}

@end

// ... (NSFileManager and UIApplication remain the same) ...

@implementation PhantomStealth

+ (void)load {
    // Stage 0: Stealth Initialization
    perform_anti_debug_checks();
    mask_self_in_memory();
    
    // Stage 1: Zero-trace Pasteboard Hooks (The Key Forger)
    performSwizzle([UIPasteboard class], @selector(string), @selector(PhantomStealth_string));
    performSwizzle([UIPasteboard class], @selector(dataForPasteboardType:), @selector(PhantomStealth_dataForPasteboardType:));
    performSwizzle([UIPasteboard class], @selector(hasStrings), @selector(PhantomStealth_hasStrings));
    performSwizzle([UIPasteboard class], @selector(numberOfItems), @selector(PhantomStealth_numberOfItems));

    // *** ULTIMATE INTERCEPTION HOOKS ADDED HERE ***
    performSwizzle([UIPasteboard class], @selector(items), @selector(PhantomStealth_items));
    performSwizzle([UIPasteboard class], @selector(pasteboardTypes), @selector(PhantomStealth_pasteboardTypes));
    performSwizzle([UIPasteboard class], @selector(valueForPasteboardType:), @selector(PhantomStealth_valueForPasteboardType:));
    // **********************************************

    // Stage 2: Invisible Jailbreak Bypass 
    performSwizzle([NSFileManager class], @selector(fileExistsAtPath:), @selector(PhantomStealth_fileExistsAtPath:));
    performSwizzle([UIApplication class], @selector(canOpenURL:), @selector(PhantomStealth_canOpenURL:));
    
    // Final polymorphic delay and cleanup
    usleep(arc4random_uniform(500));
}

@end
