//
//	JotdownAppDelegate.m
//	Jotdown
//
//	Created by Geoff Pado on 4/5/10.
//	Copyright Cocoatype, LLC 2010. All rights reserved.
//

#import "JotdownAppDelegate.h"

#import "JDFilesViewController.h"
#import "JDDetailViewController.h"

@implementation JotdownAppDelegate

@synthesize window;
@synthesize splitViewController;
@synthesize rootViewController;
@synthesize detailViewController;
@synthesize documentPaths;
@synthesize selectedDocumentIndex;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[window addSubview:splitViewController.view];
	[window makeKeyAndVisible];

	//load all the document titles
	[self reloadTitles];

	//load the document at the top of the list
	[detailViewController setFilePath:[[documentPaths objectAtIndex:0] objectForKey:@"path"]];

	return YES;
}

- (void)reloadTitles
{
	//get the document paths out of the index file
	NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *indexPath = [documentsDirectory stringByAppendingPathComponent:@".index"];
	documentPaths = [[NSArray alloc] initWithContentsOfFile:indexPath];
	
	//if no documents exist, create a new document
	if ([documentPaths count] == 0)
		[detailViewController createNewFile];
	
	//otherwise, sort the documents according to creation date
	else
		[documentPaths sortUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO]]];
	
	[rootViewController reloadData];
}

- (void)reloadSelectedDocumentTitle
{
	[rootViewController reloadSelectedTitle];
}

- (void)exportDocument
{
	[detailViewController exportHTML];
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