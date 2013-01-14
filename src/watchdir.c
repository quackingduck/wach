/*

Watches a directory for changes. When one happens, writes the path that
changed to stdout.

Only works on OS X 10.7 (Lion).

*/

#include <CoreServices/CoreServices.h>

static void _eventStreamCallback(
  __unused ConstFSEventStreamRef streamRef,
  __unused void* clientCallBackInfo,
  size_t numEvents,
  void* paths,
  __unused const FSEventStreamEventFlags eventFlags[],
  __unused const FSEventStreamEventId eventIds[]
) {
  char** pathsArr = paths; // woo! a C type
  for (unsigned long i = 0; i < numEvents; i++) { puts(pathsArr[i]); }
  fflush(stdout);
}

int main(int argc, char* argv[]) {
  if (argc != 2) {
    fprintf(stderr, "usage: %s <directory-to-watch>\n", argv[0]);
    exit(1);
  }

  CFStringRef path = CFStringCreateWithCString(
    kCFAllocatorDefault,
    argv[1],
    kCFStringEncodingUTF8
  );

  CFArrayRef pathsToWatch = CFArrayCreate(
    kCFAllocatorDefault,
    (const void **)&path,
    1,
    NULL
  );

  // create stream
  FSEventStreamRef stream = FSEventStreamCreate(
    kCFAllocatorDefault,
    _eventStreamCallback,
    NULL, // context for callback
    pathsToWatch,
    kFSEventStreamEventIdSinceNow,
    0, // latency
    kFSEventStreamCreateFlagFileEvents // this flag is lion only
  );

  FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
  FSEventStreamStart(stream);
  CFRunLoopRun();
  return EXIT_SUCCESS; // CFRunLoopRun never returns, we never get here
}

/*
Potential Improvements
- condition on eventFlags in callback to watch for specific types of changes
- support more than one dir to watch
*/
