//
//	JDRootViewController.m
//	Jotdown
//
//	Created by Geoff Pado on 4/5/10.
//	Copyright Cocoatype, LLC 2010. All rights reserved.
//

#import "JDFilesViewController.h"

#import "JotdownAppDelegate.h"
#import "JDDetailViewController.h"

@implementation JDFilesViewController

@synthesize detailViewController;

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self setClearsSelectionOnViewWillAppear:NO];
	[self setContentSizeForViewInPopover:CGSizeMake(320.0f, 600.0f)];

	//fill our table view with the document titles
	[self loadDocumentTitles];
}

- (void)viewWillAppear:(BOOL)animated
{
	//select the row for the current selected document
	JotdownAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[[self tableView] selectRowAtIndexPath:[NSIndexPath indexPathForRow:[appDelegate selectedDocumentIndex] inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)loadDocumentTitles
{
	//tell the app delegate to load the titles
	[(JotdownAppDelegate *)[[UIApplication sharedApplication] delegate] reloadTitles];

	//reload the table view so all the titles show up
	[[self tableView] reloadData];
}

- (void)reloadSelectedTitle
{
	//reload only the selected row (this is for "live updating" of the current document)
	NSIndexPath *selectedRowIndex = [[self tableView] indexPathForSelectedRow];
	[[self tableView] reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedRowIndex] withRowAnimation:UITableViewRowAnimationNone];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
	//return the number of document paths the app delegate knows about
	return [[(JotdownAppDelegate *)[[UIApplication sharedApplication] delegate] documentPaths] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"CellIdentifier";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		[cell setAccessoryType:UITableViewCellAccessoryNone];
	}

	//if we are updating the selected row, go straight to the source
	if ([indexPath isEqual:[tableView indexPathForSelectedRow]])
		[[cell textLabel] setText:[detailViewController title]];

	//otherwise, fetch the title out of the index
	else {
		JotdownAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		[[cell textLabel] setText:[[[appDelegate documentPaths] objectAtIndex:indexPath.row] objectForKey:@"title"]];
	}

	return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	JotdownAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate setSelectedDocumentIndex:indexPath.row];
	[detailViewController setFilePath:[[[appDelegate documentPaths] objectAtIndex:indexPath.row] objectForKey:@"path"]];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)dealloc
{
	[detailViewController release];
	[super dealloc];
}

@end