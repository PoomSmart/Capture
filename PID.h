#include <sys/sysctl.h>
#include <pwd.h>

int PIDForProcessNamed(NSString *name){
    int mib[4] = {
        CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0
    };
    size_t miblen = 4;
    size_t size;
    int st = sysctl(mib, (u_int)miblen, NULL, &size, NULL, 0);
    struct kinfo_proc *process = NULL;
    struct kinfo_proc *newprocess = NULL;
    do {
        size += size / 10;
        newprocess = (struct kinfo_proc *)realloc(process, size);
        if (!newprocess) {
            if (process) {
                free(process);
            }
            return 0;
        }
        process = newprocess;
        st = sysctl(mib, (u_int)miblen, process, &size, NULL, 0);
    } while (st == -1 && errno == ENOMEM);
    if (st == 0 && size % sizeof(struct kinfo_proc) == 0) {
        int nprocess = (int)(size / sizeof(struct kinfo_proc));
        if (nprocess) {
            for (int i = nprocess - 1; i >= 0; i--) {
                NSString *processName = [[[NSString alloc] initWithFormat:@"%s", process[i].kp_proc.p_comm] autorelease];
                if ([processName isEqualToString:name])
                    return process[i].kp_proc.p_pid;
            }
            free(process);
        }
    }
    return 0;
}
