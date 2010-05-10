//
//	JotdownAppDelegate.m
//	Jotdown
//
//	Created by Geoff Pado on 4/5/10.
//	Copyright Cocoatype, LLC 2010. All rights reserved.
//

#import "JotdownAppDelegate.h"

#import "RootViewController.h"
#import "DetailViewController.h"

@implementation JotdownAppDelegate

@synthesize window;
@synthesize splitViewController;
@synthesize rootViewController;
@synthesize detailViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[window addSubview:splitViewController.view];
	[window makeKeyAndVisible];

	return YES;
}

- (void)reloadTitles
{
	[rootViewController loadDocumentTitles];
}

- (void)exportMarkdown
{
	[detailViewController exportMarkdown];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[detailViewController saveFile];
}

- (void)dealloc
{
	[splitViewController release];
	[window release];
	[super dealloc];
}

@end