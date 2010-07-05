//
//	JDDetailViewController.m
//	Jotdown
//
//	Created by Geoff Pado on 4/5/10.
//	Copyright Cocoatype, LLC 2010. All rights reserved.
//

#import "JotdownAppDelegate.h"

#import "JDDetailViewController.h"
#import "JDFilesViewController.h"
#import "JDPreviewViewController.h"

@interface JDDetailViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
- (void)configureView;
@end

@implementation JDDetailViewController

@synthesize toolbar;
@synthesize popoverController;
@synthesize filePath;
@synthesize titleLabel;

#pragma mark -
#pragma mark Managing the detail item

- (void)setFilePath:(id)newFilePath
{
	//if we're switching to a new path, save the old one
	if (filePath != newFilePath && filePath != nil) {
		[self saveFile];

		[filePath release];
		filePath = [newFilePath retain];

		[self configureView];
	}

	//if we don't have a file path already, just set the new one
	else if (filePath == nil) {
		filePath = [newFilePath retain];
		[self configureView];
	}

	//hide the files list, if it's showing
	if (popoverController != nil) {
		[popoverController dismissPopoverAnimated:YES];
	}
}

- (void)saveFile
{
	//write our text to the document's path
	[[textView text] writeToFile:[self filePath] atomically:YES encoding:[NSString defaultCStringEncoding] error:nil];

	//open index
	NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *indexPath = [documentsDirectory stringByAppendingPathComponent:@".index"];

	//get index data
	NSMutableArray *indexArray = [[NSMutableArray alloc] initWithContentsOfFile:indexPath];
	NSInteger saveIndex = [indexArray indexOfObjectIdenticalTo:[[indexArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"path==%@", [self filePath]]] objectAtIndex:0]];
	NSMutableDictionary *indexDictionary = [NSMutableDictionary dictionaryWithDictionary:[indexArray objectAtIndex:saveIndex]];

	//update title
	NSString *candidateTitle = [[[[textView text] componentsSeparatedByString:@"\n"] objectAtIndex:0] substringToMaxIndex:35];
	if (candidateTitle == nil || [candidateTitle isEqualToString:@""])
		[indexDictionary setObject:@"Untitled" forKey:@"title"];
	else
		[indexDictionary setObject:candidateTitle forKey:@"title"];

	//write to index
	[indexArray replaceObjectAtIndex:saveIndex withObject:indexDictionary];
	[indexArray writeToFile:indexPath atomically:YES];
}

- (void)createNewFile
{
	//create a new file with a GUID-based name
	NSString *newFileName = [[[NSProcessInfo processInfo] globallyUniqueString] stringByAppendingPathExtension:@"mdown"];
	newFileName = [[NSString stringWithString:@"."] stringByAppendingString:newFileName];
	NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *newFilePath = [documentsDirectory stringByAppendingPathComponent:newFileName];

	//save a file with the empty string to the new file path
	[[NSString stringWithString:@""] writeToFile:newFilePath atomically:YES encoding:[NSString defaultCStringEncoding] error:nil];

	//find the old file index
	NSString *indexPath = [documentsDirectory stringByAppendingPathComponent:@".index"];

	//if none exists, create one
	if ([[NSFileManager defaultManager] fileExistsAtPath:indexPath] == NO)
		[[NSArray new] writeToFile:indexPath atomically:YES];

	//load the file index, and add this new file
	NSMutableArray *indexArray = [[NSMutableArray alloc] initWithContentsOfFile:indexPath];
	[indexArray addObject:[[NSDictionary alloc] initWithObjectsAndKeys:newFilePath, @"path", [NSDate date], @"creationDate", @"Untitled", @"title", nil]];

	//write out the updated index
	[indexArray writeToFile:indexPath atomically:YES];

	//reload the files list with the new file
	[(JotdownAppDelegate *)[[UIApplication sharedApplication] delegate] reloadTitles];
}

- (void)configureView
{
	//load the document at the current file path
	[textView setText:[NSString stringWithContentsOfFile:[self filePath] encoding:[NSString defaultCStringEncoding] error:nil]];
}

#pragma mark -
#pragma mark Split view support

//handle the hiding and showing of the files list
- (void)splitViewController:(UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController:(UIPopoverController*)pc
{
	[barButtonItem setTitle:@"Notes"];
	NSMutableArray *items = [[toolbar items] mutableCopy];
	[items insertObject:barButtonItem atIndex:0];
	[toolbar setItems:items animated:YES];
	[items release];
	[self setPopoverController:pc];
}

- (void)splitViewController:(UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
	NSMutableArray *items = [[toolbar items] mutableCopy];
	[items removeObjectAtIndex:0];
	[toolbar setItems:items animated:YES];
	[items release];
	[self setPopoverController:nil];
}

#pragma mark -
#pragma mark Action sheet

- (IBAction)showActionSheet:(id)sender
{
	//only show the action sheet if it isn't already visible
	if (!actionSheet || ![actionSheet isVisible]) {
		actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Preview", @"Export HTML", @"Export Markdown", nil];
		[actionSheet showFromBarButtonItem:sender animated:YES];
	}

	//if it is visible, cancel it out
	else {
		[actionSheet dismissWithClickedButtonIndex:[actionSheet cancelButtonIndex] animated:YES];
	}
}

//handle the export action sheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == kJDExportPreview)
		[self previewHTML];
	else if (buttonIndex == kJDExportHTML)
		[self exportHTML];
	else if (buttonIndex == kJDExportMarkdown)
		[self exportMarkdown];
}

- (void)previewHTML
{
	//hide the keyboard
	[textView resignFirstResponder];

	//get a C string from our text
	NSString *text = [textView text];
	char *rawString = (char *)[text cStringUsingEncoding:[NSString defaultCStringEncoding]];

	//create a temporary preview document
	NSString *documentsPath = NSTemporaryDirectory();
	NSString *previewPath = [documentsPath stringByAppendingPathComponent:@"preview.html"];

	//pass our text to Discount to handle the Markdown -> HTML translation
	MMIOT *markdownDoc = mkd_string(rawString, strlen(rawString), 0);
	FILE *previewFile = fopen([previewPath cStringUsingEncoding:[NSString defaultCStringEncoding]], "w");
	markdown(markdownDoc, previewFile, 0);
	fclose(previewFile);

	//load the preview sheet to display our preview file
	JDPreviewViewController *previewController = [[JDPreviewViewController alloc] initWithNibName:@"JDPreviewViewController" bundle:nil];
	[previewController setModalPresentationStyle:UIModalPresentationPageSheet];
	[[self splitViewController] presentModalViewController:previewController animated:YES];

	[previewController release];
}

- (void)exportHTML
{
	//get a C string from our text
	NSString *text = [textView text];
	char *rawString = (char *)[text cStringUsingEncoding:[NSString defaultCStringEncoding]];

	//figure out where we're going to save our file
	NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *exportPath = [documentsPath stringByAppendingPathComponent:[[self title] stringByAppendingPathExtension:@"html"]];

	//pass our text to Discount to handle the Markdown -> HTML translation
	MMIOT *markdownDoc = mkd_string(rawString, strlen(rawString), 0);
	FILE *exportFile = fopen([exportPath cStringUsingEncoding:[NSString defaultCStringEncoding]], "w");
	markdown(markdownDoc, exportFile, 0);
	fclose(exportFile);

	//display a message to the user
	UIAlertView *exportCompletedView = [[UIAlertView alloc] initWithTitle:@"Export completed." message:@"Your export completed successfully. You can find it in the \"Apps\" tab of iTunes when you sync your iPad." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
	[exportCompletedView show];

	[exportCompletedView release];
}

- (void)exportMarkdown
{
	//figure out where we're going to save our file
	NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *exportPath = [documentsPath stringByAppendingPathComponent:[[self title] stringByAppendingPathExtension:@"mdown"]];

	//write our text out to the export path
	[[textView text] writeToFile:exportPath atomically:YES encoding:NSUTF8StringEncoding error:nil];

	//display a message to the user
	UIAlertView *exportCompletedView = [[UIAlertView alloc] initWithTitle:@"Export completed." message:@"Your export completed successfully. You can find it in the \"Apps\" tab of iTunes when you sync your iPad." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
	[exportCompletedView show];

	[exportCompletedView release];
}

- (IBAction)newFile:(id)sender
{
	[self createNewFile];
}

#pragma mark -
#pragma mark Text support

- (NSString *)title
{
	//get the first 35 characters of the first line of text
	NSString *text = [textView text];
	NSString *title = [[text componentsSeparatedByString:@"\n"] objectAtIndex:0];
	title = [title substringToMaxIndex:35];

	//if the title is an empty string, return "Untitled"
	if ([title isEqualToString:@""])
		title = [NSString stringWithFormat:@"Untitled"];

	return title;
}

//when the keyboard shows or hides, resize the text view accordingly
- (void)receivedKeyboardNotification:(NSNotification *)notification
{
	if ([[notification name] isEqualToString:UIKeyboardWillShowNotification]) {
		[UIView beginAnimations:@"keyboardShowAnimation" context:nil];
		[UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
		[UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];

		CGRect textViewFrame = [textView frame];
		CGRect keyboardFrame = [[self view] convertRect:[[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:nil];
		[textView setFrame:CGRectMake(textViewFrame.origin.x, textViewFrame.origin.y, textViewFrame.size.width, textViewFrame.size.height - keyboardFrame.size.height)];

		[UIView commitAnimations];
	}

	else if ([[notification name] isEqualToString:UIKeyboardWillHideNotification]) {
		[UIView beginAnimations:@"keyboardHideAnimation" context:nil];
		[UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
		[UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];

		CGRect textViewFrame = [textView frame];
		CGRect keyboardFrame = [[self view] convertRect:[[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue] fromView:nil];
		[textView setFrame:CGRectMake(textViewFrame.origin.x, textViewFrame.origin.y, textViewFrame.size.width, textViewFrame.size.height + keyboardFrame.size.height)];

		[UIView commitAnimations];
	}
}

#pragma mark -
#pragma mark Rotation support

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
	//register as an observer for the keyboard
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedKeyboardNotification:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedKeyboardNotification:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidUnload
{
	//ditch the files list, if necessary
	[self setPopoverController:nil];

	//deregister as an observer
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark Delegate Methods

- (void)textViewDidChange:(UITextView *)textView
{
	//"live update" the selected row in the files list
	[(JotdownAppDelegate *)[[UIApplication sharedApplication] delegate] reloadSelectedDocumentTitle];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc
{
	[popoverController release];
	[toolbar release];

	[filePath release];
	[titleLabel release];
	[super dealloc];
}

@end