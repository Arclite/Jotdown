//
//	JotdownAppDelegate.h
//	Jotdown
//
//	Created by Geoff Pado on 4/5/10.
//	Copyright Cocoatype, LLC 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JDFilesViewController;
@class JDDetailViewController;

@interface JotdownAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow *window;

	UISplitViewController *splitViewController;

	JDFilesViewController *rootViewController;
	JDDetailViewController *detailViewController;

	NSMutableArray *documentPaths;
	NSUInteger selectedDocumentIndex;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;
@property (nonatomic, retain) IBOutlet JDFilesViewController *rootViewController;
@property (nonatomic, retain) IBOutlet JDDetailViewController *detailViewController;
@property (nonatomic, retain) NSMutableArray *documentPaths;
@property (assign) NSUInteger selectedDocumentIndex;

- (void)reloadTitles;
- (void)reloadSelectedDocumentTitle;
- (void)exportDocument;

@end