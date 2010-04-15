//
//  RootViewController.h
//  Markdown Editor
//
//  Created by Geoff Pado on 4/5/10.
//  Copyright Cocoatype, LLC 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface RootViewController : UITableViewController {
    DetailViewController *detailViewController;
}

@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;

@end
