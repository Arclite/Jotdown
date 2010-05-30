//
//	DetailViewController.m
//	Jotdown
//
//	Created by Geoff Pado on 4/5/10.
//	Copyright Cocoatype, LLC 2010. All rights reserved.
//

#import "JotdownAppDelegate.h"

#import "DetailViewController.h"
#import "RootViewController.h"
#import "PreviewViewController.h"

@interface DetailViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
- (void)configureView;
@end

@implementation DetailViewController

@synthesize toolbar;
@synthesize popoverController;
@synthesize filePath;
@synthesize titleLabel;

#pragma mark -
#pragma mark Managing the detail item

- (void)setFilePath:(id)newFilePath
{
	if (filePath != newFilePath && filePath != nil) {
		[self saveFile];

		[filePath release];
		filePath = [newFilePath retain];

		[self configureView];
	}
	
	else if (filePath == nil) {
		filePath = [newFilePath retain];
		[self configureView];
	}

	if (popoverController != nil) {
		[popoverController dismissPopoverAnimated:YES];
	}
}

- (void)saveFile
{
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
	NSString *newFileName = [[[NSProcessInfo processInfo] globallyUniqueString] stringByAppendingPathExtension:@"mdown"];
	newFileName = [[NSString stringWithString:@"."] stringByAppendingString:newFileName];
	NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *newFilePath = [documentsDirectory stringByAppendingPathComponent:newFileName];

	[[NSString stringWithString:@""] writeToFile:newFilePath atomically:YES encoding:[NSString defaultCStringEncoding] error:nil];

	//add file to the index
	NSString *indexPath = [documentsDirectory stringByAppendingPathComponent:@".index"];
	if ([[NSFileManager defaultManager] fileExistsAtPath:indexPath] == NO)
		[[NSArray new] writeToFile:indexPath atomically:YES];
	
	NSMutableArray *indexArray = [[NSMutableArray alloc] initWithContentsOfFile:indexPath];
	[indexArray addObject:[[NSDictionary alloc] initWithObjectsAndKeys:newFilePath, @"path", [NSDate date], @"creationDate", @"Untitled", @"title", nil]];
	
	[indexArray writeToFile:indexPath atomically:YES];
	
	[(JotdownAppDelegate *)[[UIApplication sharedApplication] delegate] reloadTitles];
}

- (void)configureView
{
	[textView setText:[NSString stringWithContentsOfFile:[self filePath] encoding:[NSString defaultCStringEncoding] error:nil]];
}

#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc
{
	[barButtonItem setTitle:@"Notes"];
	NSMutableArray *items = [[toolbar items] mutableCopy];
	[items insertObject:barButtonItem atIndex:0];
	[toolbar setItems:items animated:YES];
	[items release];
	[self setPopoverController:pc];
}

- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
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
	if (!actionSheet || ![actionSheet isVisible]) {
		actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Preview", @"Export HTML", nil];
		[actionSheet showFromBarButtonItem:sender animated:YES];
	}

	else {
		[actionSheet dismissWithClickedButtonIndex:[actionSheet cancelButtonIndex] animated:YES];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)
		[self previewHTML];
	else if (buttonIndex == 1)
		[self exportHTML];
}

- (void)previewHTML
{
	[textView resignFirstResponder];

	NSString *text = [textView text];
	char *rawString = (char *)[text cStringUsingEncoding:[NSString defaultCStringEncoding]];

	NSString *documentsPath = NSTemporaryDirectory();
	NSString *previewPath = [documentsPath stringByAppendingPathComponent:@"preview.html"];

	MMIOT *markdownDoc = mkd_string(rawString, strlen(rawString), 0);
	FILE *previewFile = fopen([previewPath cStringUsingEncoding:[NSString defaultCStringEncoding]], "w");
	markdown(markdownDoc, previewFile, 0);
	fclose(previewFile);

	PreviewViewController *previewController = [[PreviewViewController alloc] initWithNibName:@"PreviewViewController" bundle:nil];
	[previewController setModalPresentationStyle:UIModalPresentationPageSheet];
	[[self splitViewController] presentModalViewController:previewController animated:YES];

	[previewController release];
}

- (void)exportHTML
{
	NSString *text = [textView text];
	char *rawString = (char *)[text cStringUsingEncoding:[NSString defaultCStringEncoding]];

	NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *exportPath = [documentsPath stringByAppendingPathComponent:[[self title] stringByAppendingPathExtension:@"html"]];

	MMIOT *markdownDoc = mkd_string(rawString, strlen(rawString), 0);
	FILE *exportFile = fopen([exportPath cStringUsingEncoding:[NSString defaultCStringEncoding]], "w");
	markdown(markdownDoc, exportFile, 0);
	fclose(exportFile);

	UIAlertView *exportCompletedView = [[UIAlertView alloc] initWithTitle:@"Export completed." message:@"Your export completed successfully. You can find it in the \"Apps\" tab of iTunes when you sync your iPad." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
	[exportCompletedView show];

	[exportCompletedView release];
}

- (void)exportMarkdown
{
	NSString *text = [textView text];

	NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *exportPath = [documentsPath stringByAppendingPathComponent:[[self title] stringByAppendingPathExtension:@"txt"]];

	[text writeToFile:exportPath atomically:YES encoding:NSUTF8StringEncoding error:nil];

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
	NSString *text = [textView text];
	NSString *title = [[text componentsSeparatedByString:@"\n"] objectAtIndex:0];
	title = [title substringToMaxIndex:35];

	if ([title isEqualToString:@""])
		title = [NSString stringWithFormat:@"Untitled"];

	return title;
}

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
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedKeyboardNotification:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedKeyboardNotification:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidUnload
{
	[self setPopoverController:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
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