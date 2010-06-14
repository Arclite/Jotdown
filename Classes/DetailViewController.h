//
//  DetailViewController.h
//  Jotdown
//
//  Created by Geoff Pado on 4/5/10.
//  Copyright Cocoatype, LLC 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mkdio.h"

typedef enum _JDExportAction {
	kJDExportPreview,
	kJDExportHTML,
	kJDExportMarkdown
} JDExportAction;

@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate, UIActionSheetDelegate>
{
    UIPopoverController *popoverController;
    UIToolbar *toolbar;

	IBOutlet UITextView *textView;

    NSString *filePath;
    UILabel *titleLabel;

	UIActionSheet *actionSheet;
}

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

@property (nonatomic, retain) NSString *filePath;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

- (IBAction)newFile:(id)sender;

- (void)saveFile;
- (void)createNewFile;

- (IBAction)showActionSheet:(id)sender;
- (void)previewHTML;
- (void)exportHTML;
- (void)exportMarkdown;

@end