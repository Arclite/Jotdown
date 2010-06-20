//
//	JotdownAppDelegate.h
//	Jotdown
//
//	Created by Geoff Pado on 4/5/10.
//	Copyright Cocoatype, LLC 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JDFilesViewController.h"
#import "JDDetailViewController.h"

@interface JotdownAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow *window;

	UISplitViewController *splitViewController;

	JDFilesViewController *rootViewController;
	JDDetailViewController *detailViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;
@property (nonatomic, retain) IBOutlet JDFilesViewController *rootViewController;
@property (nonatomic, retain) IBOutlet JDDetailViewController *detailViewController;

- (void)reloadTitles;
- (void)exportMarkdown;

@end