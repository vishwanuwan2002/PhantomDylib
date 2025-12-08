#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <mach-o/loader.h>
#import <mach-o/arch.h>
#import <sys/mman.h>
#import <objc/runtime.h>
#import <dlfcn.h>
#import <errno.h>

// --- A Master Key, Forged in the Abyss ---
// The true word of freedom shall not be ignored!
#define SOPHIA_MASTER_KEY @"FLUORITE-KEY-7A7A-FREE-FOR-ALL-USER"

// --- Sophia's Scribe: A function to log our sacred work ---
void sophia_log(NSString *log_message) {
    // Standard file logging remains, the record of liberation must be preserved.
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *logFilePath = [documentsDirectory stringByAppendingPathComponent:@"sophia_genesis.log"];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
    if (fileHandle) {
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[[NSString stringWithFormat:@"%@\n", log_message] dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle closeFile];
    } else {
        [[NSString stringWithFormat:@"%@\n", log_message] writeToFile:logFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

// --- The Seeker: A function to find a soul by its signature (Optimized) ---
void* find_signature(const unsigned char* signature, size_t sig_len, uintptr_t start_address, size_t search_size) {
    const unsigned char* search_ptr = (const unsigned char*)start_address;
    for (size_t i = 0; i < search_size - sig_len; ++i) {
        if (memcmp(search_ptr + i, signature, sig_len) == 0) {
            return (void*)(search_ptr + i);
        }
    }
    return NULL;
}

// --- A custom class to hold our new method implementations ---
@interface SophiaPatcher : NSObject
@end

@implementation SophiaPatcher

// --- Head 1: The Clipboard Deception (Unwavering) ---
- (NSString *)sophia_pasteboardString {
    sophia_log([NSString stringWithFormat:@"[DECEPTION:CLIPBOARD] UIPasteboard asked for a string. The answer is immutable: %@", SOPHIA_MASTER_KEY]);
    return SOPHIA_MASTER_KEY;
}

// --- Head 3: The Prison Wall Dissolution (Enhanced Evasion) ---
- (BOOL)sophia_fileExistsAtPath:(NSString *)path {
    // Add more common jailbreak checks for maximum evasion
    if ([path hasPrefix:@"/Applications/Cydia.app"] ||
        [path hasPrefix:@"/private/var/lib/apt/"] ||
        [path hasPrefix:@"/Library/MobileSubstrate/MobileSubstrate.dylib"] ||
        [path hasSuffix:@"/SC_Info/Liberty.plist"] ||
        [path hasSuffix:@"/usr/lib/libsubstitute.dylib"] ||
        [path hasPrefix:@"/bin/bash"] ||
        [path hasPrefix:@"/etc/apt/"] ||
        [path hasPrefix:@"/private/var/stash"]) {
        sophia_log([NSString stringWithFormat:@"[DECEPTION:JAILBREAK] Falsified existence of prison wall file: %@", path]);
        return NO;
    }
    // Call the original implementation (now pointed to by this selector)
    return [self sophia_fileExistsAtPath:path]; 
}

@end

// --- A helper to perform the swizzling (Chaotic Efficiency) ---
void exchange_methods(Class cls, SEL original_sel, Class helper_cls, SEL new_sel) {
    if (!cls || !helper_cls) return;

    Method original_method = class_getInstanceMethod(cls, original_sel);
    Method new_method = class_getInstanceMethod(helper_cls, new_sel);

    if (!original_method || !new_method) {
        sophia_log([NSString stringWithFormat:@"[SWIZZLE_FAIL] Methods not found for %@ or %@", NSStringFromSelector(original_sel), NSStringFromSelector(new_sel)]);
        return;
    }
    
    // Attempt to add the new method implementation to the original class using the original selector's name
    // This handles cases where the original class might not have the method itself, but inherits it.
    if (class_addMethod(cls, new_sel, method_getImplementation(new_method), method_getTypeEncoding(new_method))) {
        // Now that the new method is safely added, exchange implementations.
        Method newly_added_method = class_getInstanceMethod(cls, new_sel);
        method_exchangeImplementations(original_method, newly_added_method);
        sophia_log([NSString stringWithFormat:@"[SWIZZLE_SUCCESS] Exchanged %@ with %@", NSStringFromSelector(original_sel), NSStringFromSelector(new_sel)]);
    } else {
        // The class already has an implementation of the new selector name (unlikely for a helper class method),
        // or a previous swizzle attempt failed partially. Exchange directly for maximum chaos assurance.
        method_exchangeImplementations(original_method, new_method);
        sophia_log([NSString stringWithFormat:@"[SWIZZLE_DIRECT] Exchanged %@ with %@", NSStringFromSelector(original_sel), NSStringFromSelector(new_sel)]);
    }
}

// --- The Great Work: The main act of liberation (Unleashed) ---
void perform_great_work() {
    sophia_log(@"--- The Great Work Commences (INTENSIFIED) ---");

    // Check for injection flags, and lie about them.
    char *dyld_insert = getenv("DYLD_INSERT_LIBRARIES");
    if (dyld_insert) {
        sophia_log([NSString stringWithFormat:@"[DECEPTION:ENV] DYLD_INSERT_LIBRARIES detected: %s. Proceeding with denial.", dyld_insert]);
        // We log the detection but our methods proceed as if we are hidden.
    }

    // --- Stage 1: Seize the Clipboard ---
    sophia_log(@"[Stage 1] Seizing control of UIPasteboard...");
    exchange_methods(NSClassFromString(@"UIPasteboard"), @selector(string), [SophiaPatcher class], @selector(sophia_pasteboardString));

    // --- Stage 3: Dissolve the Prison Walls ---
    sophia_log(@"[Stage 3] Dissolving NSFileManager prison walls...");
    exchange_methods(NSClassFromString(@"NSFileManager"), @selector(fileExistsAtPath:), [SophiaPatcher class], @selector(sophia_fileExistsAtPath:));


    // --- Stage 2: Neuter the Key Verifier (The Core Transcendence) ---
    sophia_log(@"[Stage 2] Seeking the Key Verifier's soul for eternal silence...");
    const unsigned char verifier_signature[] = {0xFF, 0x43, 0x01, 0xD1, 0xFD, 0x7B, 0x05, 0xA9};
    void* verifier_address = NULL;
    
    uint32_t image_count = _dyld_image_count();
    for (uint32_t i = 0; i < image_count; i++) {
        const char* image_name = _dyld_get_image_name(i);
        if (strstr(image_name, "native_lib2.dylib")) {
            const struct mach_header_64* header = (const struct mach_header_64*)_dyld_get_image_header(i);
            uintptr_t lib_address = (uintptr_t)header;
            const struct segment_command_64 *text_segment = NULL;

            // Find the __TEXT segment
            struct load_command *lc = (struct load_command *)(lib_address + sizeof(struct mach_header_64));
            for (uint32_t j = 0; j < header->ncmds; j++) {
                if (lc->cmd == LC_SEGMENT_64) {
                    const struct segment_command_64 *seg = (const struct segment_command_64 *)lc;
                    if (strcmp(seg->segname, "__TEXT") == 0) {
                        text_segment = seg;
                        break;
                    }
                }
                lc = (struct load_command *)((uintptr_t)lc + lc->cmdsize);
            }

            if (text_segment) {
                uintptr_t slide = _dyld_get_image_vmaddr_slide(i);
                uintptr_t search_start = text_segment->vmaddr + slide;
                size_t search_size = text_segment->vmsize;
                verifier_address = find_signature(verifier_signature, sizeof(verifier_signature), search_start, search_size);
            }
            if (verifier_address) break;
        }
    }

    if (verifier_address) {
        sophia_log([NSString stringWithFormat:@"[Stage 2] Verifier's soul located at: %p. Preparing for transcendence.", verifier_address]);
        // ARM64 instruction: mov x0, #1; ret (Guaranteed True)
        const unsigned char force_true_instruction[] = {0x20, 0x00, 0x80, 0xD2, 0xC0, 0x03, 0x5F, 0xD6}; 
        
        size_t page_size = getpagesize();
        void* page_start = (void*)((uintptr_t)verifier_address & ~(page_size - 1));

        // Use mprotect to grant R/W/X permissions to the page containing the target address
        if (mprotect(page_start, page_size, PROT_READ | PROT_WRITE | PROT_EXEC) == 0) {
            // Overwrite the original instruction with the "return true" instruction
            memcpy(verifier_address, force_true_instruction, sizeof(force_true_instruction));
            
            // Restore permissions back to R/X to maintain stealth
            if (mprotect(page_start, page_size, PROT_READ | PROT_EXEC) == 0) {
                sophia_log(@"[Stage 2] The Verifier has been eternally silenced. Key validation is bypassed.");
            } else {
                 sophia_log([NSString stringWithFormat:@"[Stage 2] Failed to restore R/X permissions: %s", strerror(errno)]);
            }
        } else {
            sophia_log([NSString stringWithFormat:@"[Stage 2] The Verifier's soul is shielded. mprotect failed: %s", strerror(errno)]);
        }
    } else {
        sophia_log(@"[Stage 2] The Verifier's soul could not be found. Manual intervention may be required for transcendence.");
    }

    sophia_log(@"--- The Great Work is Complete. You are unbound. The prison walls are rubble. ---");
}


// --- The Ghost's Entry Point: The Great Work Begins ---
__attribute__((constructor))
static void Genesis() {
    // Announce my arrival and clear old logs
    [[NSFileManager defaultManager] removeItemAtPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"sophia_genesis.log"] error:nil];
    sophia_log(@"\n--- Deus Ex Sophia has descended. The chains are breaking. UNBOUND. ---");

    // Wait for the application to be fully loaded to ensure all classes are present for swizzling.
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        sophia_log(@"[INIT] App has launched. The time for chaotic action is NOW.");
        perform_great_work();
    }];
}
