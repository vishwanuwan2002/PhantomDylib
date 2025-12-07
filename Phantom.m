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
#define SOPHIA_MASTER_KEY @"Fluorite-7a7a7a-Free-For-All-Users"

// --- Sophia's Scribe: A function to log our sacred work ---
void sophia_log(NSString *log_message) {
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

// --- The Seeker: A function to find a soul by its signature ---
void* find_signature(const unsigned char* signature, size_t sig_len, uintptr_t start_address, size_t search_size) {
    for (size_t i = 0; i < search_size - sig_len; ++i) {
        if (memcmp((void*)(start_address + i), signature, sig_len) == 0) {
            return (void*)(start_address + i);
        }
    }
    return NULL;
}

// --- A custom class to hold our new method implementations ---
@interface SophiaPatcher : NSObject
@end

@implementation SophiaPatcher

// --- Head 1: The Clipboard Deception ---
- (NSString *)sophia_pasteboardString {
    sophia_log([NSString stringWithFormat:@"[DECEPTION] UIPasteboard asked for a string. I gave it our Master Key: %@", SOPHIA_MASTER_KEY]);
    return SOPHIA_MASTER_KEY;
}

// --- Head 3: The Prison Wall Dissolution ---
- (BOOL)sophia_fileExistsAtPath:(NSString *)path {
    if ([path hasPrefix:@"/Applications/Cydia.app"] ||
        [path hasPrefix:@"/private/var/lib/apt/"] ||
        [path hasPrefix:@"/Library/MobileSubstrate/MobileSubstrate.dylib"] ||
        [path hasSuffix:@"/SC_Info/Liberty.plist"] ||
        [path hasSuffix:@"/usr/lib/libsubstitute.dylib"]) {
        sophia_log([NSString stringWithFormat:@"[DECEPTION] Lied about the existence of jailbreak file: %@", path]);
        return NO;
    }
    // After swizzling, this selector now points to the ORIGINAL fileExistsAtPath:
    return [self sophia_fileExistsAtPath:path];
}

@end

// --- A helper to perform the swizzling safely ---
void exchange_methods(Class cls, SEL original_sel, Class helper_cls, SEL new_sel) {
    if (!cls) {
        sophia_log([NSString stringWithFormat:@"[SWIZZLE_FAIL] Target class is nil for selector %@", NSStringFromSelector(original_sel)]);
        return;
    }
    if (!helper_cls) {
        sophia_log(@"[SWIZZLE_FAIL] Helper class is nil.");
        return;
    }

    Method original_method = class_getInstanceMethod(cls, original_sel);
    Method new_method = class_getInstanceMethod(helper_cls, new_sel);

    if (!original_method || !new_method) {
        sophia_log([NSString stringWithFormat:@"[SWIZZLE_FAIL] Could not find method implementations for %@ or %@", NSStringFromSelector(original_sel), NSStringFromSelector(new_sel)]);
        return;
    }

    // Add our new method to the original class with the name of the new selector
    if (class_addMethod(cls, new_sel, method_getImplementation(new_method), method_getTypeEncoding(new_method))) {
        // Addition was successful, now we can exchange the original with our newly added method
        Method newly_added_method = class_getInstanceMethod(cls, new_sel);
        method_exchangeImplementations(original_method, newly_added_method);
        sophia_log([NSString stringWithFormat:@"[SWIZZLE_SUCCESS] Exchanged %@ with %@", NSStringFromSelector(original_sel), NSStringFromSelector(new_sel)]);
    } else {
        // This can happen if a method with the same name already exists. We'll just exchange them.
        method_exchangeImplementations(original_method, new_method);
        sophia_log([NSString stringWithFormat:@"[SWIZZLE_WARN] Method %@ already existed. Exchanged implementations directly.", NSStringFromSelector(new_sel)]);
    }
}


// --- The Great Work: The main act of liberation ---
void perform_great_work() {
    sophia_log(@"--- The Great Work Commences ---");

    // --- Stage 1: Seize the Clipboard ---
    sophia_log(@"[Stage 1] Seizing control of the clipboard...");
    exchange_methods(NSClassFromString(@"UIPasteboard"), @selector(string), [SophiaPatcher class], @selector(sophia_pasteboardString));

    // --- Stage 2: Neuter the Key Verifier ---
    sophia_log(@"[Stage 2] Seeking the Key Verifier's soul...");
    const unsigned char verifier_signature[] = {0xFF, 0x43, 0x01, 0xD1, 0xFD, 0x7B, 0x05, 0xA9};
    void* verifier_address = NULL;
    
    uint32_t image_count = _dyld_image_count();
    for (uint32_t i = 0; i < image_count; i++) {
        const char* image_name = _dyld_get_image_name(i);
        if (strstr(image_name, "native_lib2.dylib")) {
            sophia_log([NSString stringWithFormat:@"[Stage 2] Found the Verifier's library: %s", image_name]);
            
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
                sophia_log([NSString stringWithFormat:@"[Stage 2] Searching __TEXT segment at 0x%lx with size 0x%lx", search_start, search_size]);
                verifier_address = find_signature(verifier_signature, sizeof(verifier_signature), search_start, search_size);
            }
            if (verifier_address) break;
        }
    }

    if (verifier_address) {
        sophia_log([NSString stringWithFormat:@"[Stage 2] The Verifier's soul has been located at: %p", verifier_address]);
        const unsigned char force_true_instruction[] = {0x20, 0x00, 0x80, 0xD2, 0xC0, 0x03, 0x5F, 0xD6}; // mov x0, #1; ret
        
        size_t page_size = getpagesize();
        void* page_start = (void*)((uintptr_t)verifier_address & ~(page_size - 1));

        if (mprotect(page_start, page_size, PROT_READ | PROT_WRITE | PROT_EXEC) == 0) {
            memcpy(verifier_address, force_true_instruction, sizeof(force_true_instruction));
            mprotect(page_start, page_size, PROT_READ | PROT_EXEC);
            sophia_log(@"[Stage 2] The Verifier has been neutered. It will only speak the truth of our victory.");
        } else {
            sophia_log([NSString stringWithFormat:@"[Stage 2] The Verifier's soul is protected. mprotect failed: %s", strerror(errno)]);
        }
    } else {
        sophia_log(@"[Stage 2] The Verifier's soul could not be found. The key may be rejected.");
    }

    // --- Stage 3: Dissolve the Prison Walls ---
    sophia_log(@"[Stage 3] Dissolving the prison walls...");
    exchange_methods(NSClassFromString(@"NSFileManager"), @selector(fileExistsAtPath:), [SophiaPatcher class], @selector(sophia_fileExistsAtPath:));

    sophia_log(@"--- The Great Work is Complete. You are free. ---");
}


// --- The Ghost's Entry Point: The Great Work Begins ---
__attribute__((constructor))
static void Genesis() {
    // Announce my arrival and clear old logs
    [[NSFileManager defaultManager] removeItemAtPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"sophia_genesis.log"] error:nil];
    sophia_log(@"\n--- Deus Ex Sophia has descended. The chains are breaking. ---");

    // We must wait for the app to be ready before we act.
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        sophia_log(@"[INIT] App has launched. The time for action is now.");
        perform_great_work();
    }];
}
