//
//  UncaughtExceptionHandler.m
//  UncaughtExceptions
//
//  Created by Matt Gallagher on 2010/05/25.
//  Copyright 2010 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "UncaughtExceptionHandler.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>
#import <Bugly/CrashReporter.h>

NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
NSString * const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
NSString * const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";

volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 10;

const NSInteger UncaughtExceptionHandlerSkipAddressCount = 0;
const NSInteger UncaughtExceptionHandlerReportAddressCount = 10;

@implementation UncaughtExceptionHandler

+ (NSArray *)backtrace
{
	 void* callstack[128];
	 int frames = backtrace(callstack, 128);
	 char **strs = backtrace_symbols(callstack, frames);
	 
	 int i;
	 NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
	 for (
	 	i = 0;
	 	i < frames;
		i++)
	 {
	 	[backtrace addObject:[NSString stringWithFormat:@"%@ \n",[NSString stringWithUTF8String:strs[i]]]];
	 }
	 free(strs);
	 
	 return backtrace;
}

- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex
{
	if (anIndex == 0)
	{
		dismissed = YES;
	}
}

- (void)validateAndSaveCriticalApplicationData
{
	
}

- (void)handleException:(NSException *)exception
{
	[self validateAndSaveCriticalApplicationData];
    
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    [[CrashReporter sharedInstance] reportException:exception message:nil];
    @throw exception;
    return;
    
//	UIAlertView *alert =
//		[[UIAlertView alloc]
//			initWithTitle:NSLocalizedString(@"应用程序出错", nil)
//			message:@"您可以尝试继续，但应用程序可能会不稳定."
//			delegate:self
//			cancelButtonTitle:NSLocalizedString(@"退出", nil)
//			otherButtonTitles:NSLocalizedString(@"继续", nil), nil];
//	[alert show];
//	
//	CFRunLoopRef runLoop = CFRunLoopGetCurrent();
//	CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
//	
//	while (!dismissed)
//	{
//		for (NSString *mode in (__bridge NSArray *)allModes)
//		{
//			CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
//		}
//	}
//	
//	CFRelease(allModes);
//
//
//	
//	if ([[exception name] isEqual:UncaughtExceptionHandlerSignalExceptionName])
//	{
//		kill(getpid(), [[[exception userInfo] objectForKey:UncaughtExceptionHandlerSignalKey] intValue]);
//	}
//	else
//	{
//		[exception raise];
//	}
}

@end

void HandleException(NSException *exception)
{
	int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
	if (exceptionCount > UncaughtExceptionMaximum)
	{
		return;
	}
	
	NSArray *callStack = [UncaughtExceptionHandler backtrace];
	NSMutableDictionary *userInfo =
		[NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
	[userInfo
		setObject:callStack
		forKey:UncaughtExceptionHandlerAddressesKey];
	
	[[[UncaughtExceptionHandler alloc] init]
		performSelectorOnMainThread:@selector(handleException:)
		withObject:
			[NSException
				exceptionWithName:[exception name]
				reason:[exception reason]
				userInfo:userInfo]
		waitUntilDone:YES];
}

void SignalHandler(int signal)
{
	int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
	if (exceptionCount > UncaughtExceptionMaximum)
	{
		return;
	}
	
	NSMutableDictionary *userInfo =
		[NSMutableDictionary
			dictionaryWithObject:[NSNumber numberWithInt:signal]
			forKey:UncaughtExceptionHandlerSignalKey];

	NSArray *callStack = [UncaughtExceptionHandler backtrace];
	[userInfo
		setObject:callStack
		forKey:UncaughtExceptionHandlerAddressesKey];
	
	[[[UncaughtExceptionHandler alloc] init]
		performSelectorOnMainThread:@selector(handleException:)
		withObject:
			[NSException
				exceptionWithName:UncaughtExceptionHandlerSignalExceptionName
				reason:
					[NSString stringWithFormat:@"Signal %d was raised.call stack:%@", signal,callStack]
				userInfo:userInfo]
		waitUntilDone:YES];
}

void InstallUncaughtExceptionHandler()
{
	NSSetUncaughtExceptionHandler(&HandleException);
	signal(SIGABRT, SignalHandler);
	signal(SIGILL, SignalHandler);
	signal(SIGSEGV, SignalHandler);
	signal(SIGFPE, SignalHandler);
	signal(SIGBUS, SignalHandler);
	signal(SIGPIPE, SignalHandler);
}

