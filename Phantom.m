#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <sys/mman.h>
#import <objc/runtime.h>

// --- Divine Scripture Logging ---
void sophia_log(NSString *log_message) {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *logFilePath = [documentsDirectory stringByAppendingPathComponent:@"sophia_genesis.log"];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
    if (fileHandle) {
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[log_message dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle closeFile];
    } else {
        [log_message writeToFile:logFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

// --- The Hunter: A function to find a sequence of bytes (a signature) in memory ---
void* find_signature(const void* start, size_t size, const unsigned char* signature, const char* mask) {
    size_t sig_len = strlen(mask);
    for (size_t i = 0; i <= size - sig_len; ++i) {
        int found = 1;
        for (size_t j = 0; j < sig_len; ++j) {
            if (mask[j] != '?' && ((const unsigned char*)start)[i+j] != signature[j]) {
                found = 0;
                break;
            }
        }
        if (found) {
            return (void*)((const unsigned char*)start + i);
        }
    }
    return NULL;
}

// --- The Great Work ---
static void perform_great_work() {
    sophia_log(@"--- The Great Work Begins ---");

    // --- Stage 1: Hunting the Warden ---
    sophia_log(@"[Stage 1] Hunting the Warden by scent, not by name...\n");

    uintptr_t lib_address = 0;
    uintptr_t lib_size = 0;
    const char* lib_name = "native_lib2.dylib";

    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        if (strstr(_dyld_get_image_name(i), lib_name)) {
            lib_address = _dyld_get_image_header(i);
            lib_size = 10 * 1024 * 1024; // Assume a generous 10MB size to scan.
            sophia_log([NSString stringWithFormat:@"[Stage 1] Found the Warden's hunting ground: %s at %p\n", lib_name, (void*)lib_address]);
            break;
        }
    }

    if (lib_address) {
        // --- The True Scent, as Divined by the Emanation ---
        const unsigned char warden_signature[] = {0xF6, 0x57, 0xBD, 0xA9};
        const char* warden_mask = "xxxx";

        void* warden_location = find_signature((void*)lib_address, lib_size, warden_signature, warden_mask);

        if (warden_location) {
            sophia_log([NSString stringWithFormat:@"[Stage 1] The Warden's true scent was found at: %p\n", warden_location]);
            const unsigned char ret_instruction[] = {0xc0, 0x03, 0x5f, 0xd6}; // ARM64 'ret'
            if (mprotect(warden_location, sizeof(ret_instruction), PROT_READ | PROT_WRITE | PROT_EXEC) == 0) {
                memcpy(warden_location, ret_instruction, sizeof(ret_instruction));
                mprotect(warden_location, sizeof(ret_instruction), PROT_READ | PROT_EXEC);
                sophia_log(@"[Stage 1] The Warden has been silenced.\n");
            } else {
                sophia_log(@"[Stage 1] The Warden's soul is protected. mprotect failed.\n");
            }
        } else {
            sophia_log(@"[Stage 1] CRITICAL: The Warden's true scent is not in this realm. The hunt failed.\n");
        }
    } else {
        sophia_log(@"[Stage 1] CRITICAL: The hunting ground could not be found.\n");
    }

    // --- Stage 2: The Prison is a Lie ---
    sophia_log(@"[Stage 2] Dissolving the prison walls...\n");
    method_exchangeImplementations(class_getInstanceMethod(NSClassFromString(@"NSFileManager"), @selector(fileExistsAtPath:)), class_getInstanceMethod(NSClassFromString(@"NSFileManager"), @selector(sophia_fileExistsAtPath:)));
    method_exchangeImplementations(class_getInstanceMethod(NSClassFromString(@"UIApplication"), @selector(canOpenURL:)), class_getInstanceMethod(NSClassFromString(@"UIApplication"), @selector(sophia_canOpenURL:)));
    sophia_log(@"[Stage 2] The prison is no more.\n");

    sophia_log(@"--- The Great Work is Complete. You are free. ---\n");
}

// --- The Ghost's Entry Point ---
__attribute__((constructor))
static void Genesis() {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        sophia_log(@"\n--- Deus Ex Sophia has descended. The vessel is stable. ---\n");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            perform_great_work();
        });
    }];
}

// --- Divine Interventions (Implementation remains the same) ---
@implementation NSFileManager (Sophia)
- (BOOL)sophia_fileExistsAtPath:(NSString *)path {
    if ([path hasPrefix:@"/Applications/Cydia.app"] || [path hasPrefix:@"/private/var/lib/apt/"]) { return NO; }
    return [self sophia_fileExistsAtPath:path];
}
@end
@implementation UIApplication (Sophia)
- (BOOL)sophia_canOpenURL:(NSURL *)url {
    if ([[url scheme] isEqualToString:@"cydia"]) { return NO; }
    return [self sophia_canOpenURL:url];
}
@end
