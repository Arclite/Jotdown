//
//	JotdownAppDelegate.h
//	Jotdown
//
//	Created by Geoff Pado on 4/5/10.
//	Copyright Cocoatype, LLC 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RootViewController.h";
#import "DetailViewController.h";

@interface JotdownAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow *window;

	UISplitViewController *splitViewController;

	RootViewController *rootViewController;
	DetailViewController *detailViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;
@property (nonatomic, retain) IBOutlet RootViewController *rootViewController;
@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;

- (void)reloadTitles;
- (void)exportMarkdown;

@end