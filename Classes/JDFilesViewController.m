//
//	JDRootViewController.m
//	Jotdown
//
//	Created by Geoff Pado on 4/5/10.
//	Copyright Cocoatype, LLC 2010. All rights reserved.
//

#import "JDFilesViewController.h"

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
	[super viewWillAppear:animated];

	//load the document at the top of the list
	[[self tableView] selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
	[detailViewController setFilePath:[[documentPaths objectAtIndex:0] objectForKey:@"path"]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)loadDocumentTitles
{
	//get the document paths out of the index file
	NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *indexPath = [documentsDirectory stringByAppendingPathComponent:@".index"];
	documentPaths = [[NSArray alloc] initWithContentsOfFile:indexPath];

	//if no documents exist, create a new document
	if ([documentPaths count] == 0)
		[detailViewController createNewFile];

	//otherwise, sort the documents according to creation date
	else
		[documentPaths sortUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO]]];

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
	return [documentPaths count];
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
	else
		[[cell textLabel] setText:[[documentPaths objectAtIndex:indexPath.row] objectForKey:@"title"]];

	return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[detailViewController setFilePath:[[documentPaths objectAtIndex:indexPath.row] objectForKey:@"path"]];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)dealloc
{
	[detailViewController release];
	[documentPaths release];

	[super dealloc];
}

@end