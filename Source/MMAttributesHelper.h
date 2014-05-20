//
//  MMAttributesHelper.h
//  KoaMarkdownRenderDemo
//
//  Created by Isaac Roldan on 20/05/14.
//  Copyright (c) 2014 Isaac Roldan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMElement;

@interface MMAttributesHelper : NSObject

+ (NSAttributedString*)startStringForElement:(MMElement *)anElement listType:(NSString *)listType;
+ (NSMutableDictionary *)attributesDictionaryForElement:(MMElement *)anElement nestedStyles:(NSMutableArray *)nestedStyles;
+ (NSString *)endStringForElement:(MMElement *)anElement;

@end
