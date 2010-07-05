//
//  JDFilesViewController.h
//  Jotdown
//
//  Created by Geoff Pado on 4/5/10.
//  Copyright Cocoatype, LLC 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JDDetailViewController;

@interface JDFilesViewController : UITableViewController
{
    JDDetailViewController *detailViewController;
	NSMutableArray *documentPaths;
}

@property (nonatomic, retain) IBOutlet JDDetailViewController *detailViewController;

- (void)loadDocumentTitles;
- (void)reloadSelectedTitle;

@end