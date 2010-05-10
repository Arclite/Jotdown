//
//  NSStringMaxIndex.m
//  Jotdown
//
//  Created by Geoff Pado on 5/10/10.
//  Copyright 2010 Cocoatype, LLC. All rights reserved.
//

#import "NSStringMaxIndex.h"

@implementation NSString (MaxIndex)

- (NSString *)substringToMaxIndex:(NSUInteger)anIndex
{
	if ([self length] < anIndex)
		return self;
	else
		return [self substringToIndex:anIndex];
}

@end
