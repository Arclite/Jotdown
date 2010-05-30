//
//	RootViewController.m
//	Jotdown
//
//	Created by Geoff Pado on 4/5/10.
//	Copyright Cocoatype, LLC 2010. All rights reserved.
//

#import "RootViewController.h"
#import "DetailViewController.h"

@implementation RootViewController

@synthesize detailViewController;

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self setClearsSelectionOnViewWillAppear:NO];
	[self setContentSizeForViewInPopover:CGSizeMake(320.0f, 600.0f)];

	[self loadDocumentTitles];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[[self tableView] selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
	[detailViewController setFilePath:[[documentPaths objectAtIndex:0] objectForKey:@"path"]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)loadDocumentTitles
{
	documentPaths = [[NSMutableArray alloc] init];

	NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSDirectoryEnumerator *documentsEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:documentsDirectory];
	NSString *filePath, *fileContents, *fileTitle;

	while (filePath = [documentsEnumerator nextObject]) {
		if ([[filePath pathExtension] isEqualToString:@"mdown"]) {
			filePath = [documentsDirectory stringByAppendingPathComponent:filePath];
			fileContents = [NSString stringWithContentsOfFile:filePath encoding:[NSString defaultCStringEncoding] error:nil];

			if (([[[fileContents componentsSeparatedByString:@"\n"] objectAtIndex:0] substringToMaxIndex:35] == nil) || ([[[[fileContents componentsSeparatedByString:@"\n"] objectAtIndex:0] substringToMaxIndex:35] isEqualToString: @""]))
				fileTitle = [NSString stringWithString:@"Untitled"];
			else
				fileTitle = [[[fileContents componentsSeparatedByString:@"\n"] objectAtIndex:0] substringToMaxIndex:35];

			[documentPaths addObject:[NSDictionary dictionaryWithObjectsAndKeys:filePath, @"path", fileTitle, @"title", nil]];
		}
	}

	if ([documentPaths count] == 0)
		[detailViewController createNewFile];
	
	[[self tableView] reloadData];
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