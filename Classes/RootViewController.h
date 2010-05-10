//
//  RootViewController.h
//  Jotdown
//
//  Created by Geoff Pado on 4/5/10.
//  Copyright Cocoatype, LLC 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DetailViewController.h";

@interface RootViewController : UITableViewController
{
    DetailViewController *detailViewController;
	NSMutableArray *documentTitles;
	NSMutableArray *documentPaths;
}

@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;

- (void)loadDocumentTitles;

@end