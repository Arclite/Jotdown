//
//  JDPreviewViewController.h
//  Jotdown
//
//  Created by Geoff Pado on 4/15/10.
//  Copyright 2010 Cocoatype, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JDPreviewViewController : UIViewController
{
	IBOutlet UIWebView *webView;
}

- (IBAction)dismissSelf:(id)sender;
- (IBAction)savePreview:(id)sender;

@end