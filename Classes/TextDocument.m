//
//  TextDocument.m
//  Markdown Editor
//
//  Created by Geoff Pado on 4/5/10.
//  Copyright 2010 Cocoatype, LLC. All rights reserved.
//

#import "TextDocument.h"

@implementation TextDocument

@synthesize text;
@synthesize filename;

- (id)init
{
	if (self = [super init]) {
		filename = [NSString new];
		text = [NSString new];
	}
	
	return self;
}

- (BOOL)writeToFile
{
	NSFileManager *defaultFileManager = [NSFileManager defaultManager];
	NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	
	if (![[self filename] isEqualToString:@""]) {
		if ([defaultFileManager fileExistsAtPath:[documentsDirectory stringByAppendingPathComponent:[self filename]]])
			[defaultFileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:[self filename]] error:nil];
		
		return [[self text] writeToFile:[documentsDirectory stringByAppendingPathComponent:[self filename]] atomically:YES encoding:NSUTF8StringEncoding error:nil];
	}
	
	else {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yDHms"];
		NSString *dateString = [formatter stringFromDate:[NSDate date]];
		
		[self setFilename:[NSString stringWithFormat:@"%@.txt", dateString]];
		return [[self text] writeToFile:[documentsDirectory stringByAppendingPathComponent:[self filename]] atomically:YES encoding:NSUTF8StringEncoding error:nil];
	}
}

@end