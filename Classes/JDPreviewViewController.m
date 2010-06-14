//
//  JDPreviewViewController.m
//  Jotdown
//
//  Created by Geoff Pado on 4/15/10.
//  Copyright 2010 Cocoatype, LLC. All rights reserved.
//

#import "JDPreviewViewController.h"
#import "JotdownAppDelegate.h"

@implementation JDPreviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	NSString *previewPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"preview.html"];
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:previewPath]]];
}

- (IBAction)dismissSelf:(id)sender
{
	[[self parentViewController] dismissModalViewControllerAnimated:YES];
}

- (IBAction)savePreview:(id)sender
{
	[(JotdownAppDelegate *)[[UIApplication sharedApplication] delegate] exportMarkdown];
	[[self parentViewController] dismissModalViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	NSString *previewPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"preview.html"];
	[[NSFileManager defaultManager] removeItemAtPath:previewPath error:nil];
}

@end