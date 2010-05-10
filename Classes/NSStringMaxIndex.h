//
//  NSStringMaxIndex.h
//  Jotdown
//
//  Created by Geoff Pado on 5/10/10.
//  Copyright 2010 Cocoatype, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MaxIndex)

- (NSString *)substringToMaxIndex:(NSUInteger)anIndex;

@end