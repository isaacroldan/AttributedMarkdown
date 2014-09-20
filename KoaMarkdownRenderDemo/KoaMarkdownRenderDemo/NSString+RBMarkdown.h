//
//  NSString+RBMarkdown.h
//  Redbooth
//
//  Created by Isaac Roldan on 04/07/14.
//  Copyright (c) 2014 teambox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (RBMarkdown)

- (NSString*)markdownizedString;
+ (NSString*)markdownizedStringWithString:(NSString*)string;

@end
