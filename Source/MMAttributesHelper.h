//
//  MMAttributesHelper.h
//  KoaMarkdownRenderDemo
//
//  Created by Isaac Roldan on 20/05/14.
//  Copyright (c) 2014 Isaac Roldan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMGenerator.h"

@class MMElement;

@interface MMAttributesHelper : NSObject <AttributedStringStylesGeneratorDelegate>

+ (NSAttributedString*)startStringForElement:(MMElement *)anElement listType:(NSString *)listType nestedStyles:(NSMutableArray *)nestedStyles;
+ (NSMutableDictionary *)attributesDictionaryForElement:(MMElement *)anElement nestedStyles:(NSMutableArray *)nestedStyles;
+ (NSAttributedString *)endStringForElement:(MMElement *)anElement  nestedStyles:(NSMutableArray *)nestedStyles;

@end
