//
//  Markdown_EditorAppDelegate.m
//  Markdown Editor
//
//  Created by Geoff Pado on 4/5/10.
//  Copyright Cocoatype, LLC 2010. All rights reserved.
//

#import "Markdown_EditorAppDelegate.h"


#import "RootViewController.h"
#import "DetailViewController.h"


@implementation Markdown_EditorAppDelegate

@synthesize window, splitViewController, rootViewController, detailViewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after app launch    
    
    // Add the split view controller's view to the window and display.
    [window addSubview:splitViewController.view];
    [window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Save data if appropriate
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [splitViewController release];
    [window release];
    [super dealloc];
}


@end

