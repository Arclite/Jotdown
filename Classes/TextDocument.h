//
//  TextDocument.h
//  Markdown Editor
//
//  Created by Geoff Pado on 4/5/10.
//  Copyright 2010 Cocoatype, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextDocument : NSObject
{
	NSString *text;
	NSString *filename;
}

@property (nonatomic, readwrite, retain) NSString *text;
@property (nonatomic, readwrite, retain) NSString *filename;

- (BOOL)writeToFile;

@end