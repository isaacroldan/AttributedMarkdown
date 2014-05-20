//
//  MMAttributesHelper.m
//  KoaMarkdownRenderDemo
//
//  Created by Isaac Roldan on 20/05/14.
//  Copyright (c) 2014 Isaac Roldan. All rights reserved.
//

#import "MMAttributesHelper.h"
#import "MMElement.h"

static  NSString *kNormalFont      = @"OpenSans";
static  NSString *kBoldFont        = @"OpenSans-Bold";
static  NSString *kLightFont       = @"OpenSans-Light";
static  NSString *kSemiboldFont    = @"OpenSans-Semibold";
static  NSString *kItalicFont      = @"OpenSans-Italic";
static  NSString *kBoldItalicFont  = @"OpenSans-BoldItalic";

@implementation MMAttributesHelper

+ (NSAttributedString *)startStringForElement:(MMElement *)anElement listType:(NSString *)listType
{
    switch (anElement.type)
    {
        case MMElementTypeHeader:
            return [[NSAttributedString alloc] initWithString:@"" attributes:@{}];
        case MMElementTypeParagraph:
            return [[NSAttributedString alloc] initWithString:@"" attributes:@{}];//@"<p>";
        case MMElementTypeBulletedList:
            return [[NSAttributedString alloc] initWithString:@"" attributes:@{}];//@"<ul>\n";
        case MMElementTypeNumberedList:
            return [[NSAttributedString alloc] initWithString:@"" attributes:@{}];//@"<ol>\n";
        case MMElementTypeListItem:
            if ([listType isEqualToString:@"- "] || [listType isEqualToString:@"* "] || [listType isEqualToString:@"+ "] ) {
                listType = @"  • ";
                return [[NSAttributedString alloc] initWithString:listType  attributes:@{NSFontAttributeName:[UIFont fontWithName:kNormalFont size:25],
                                                                                          NSForegroundColorAttributeName:[UIColor colorWithRed:0.44 green:0.44 blue:0.44 alpha:1],
                                                                                          //NSBaselineOffsetAttributeName:@1
                                                                                          }];//@"<li>";
            }
            else {
                listType = [NSString stringWithFormat:@"  %@ ",listType];
                return [[NSAttributedString alloc] initWithString:listType  attributes:[self attributesDictionaryForElement:anElement nestedStyles:nil]];//@"<li>";
            }
            
            
        case MMElementTypeBlockquote:
            return [[NSAttributedString alloc] initWithString:@"" attributes:@{}];//@"<blockquote>\n";
        case MMElementTypeCodeBlock:
            return [[NSAttributedString alloc] initWithString:@"" attributes:@{}];//@"<pre><code>";
        case MMElementTypeLineBreak:
            return [[NSAttributedString alloc] initWithString:@"" attributes:@{}];//@"<br />";
        case MMElementTypeHorizontalRule:
            return [[NSAttributedString alloc] initWithString:@"" attributes:@{}];//@"\n<hr />\n";
        case MMElementTypeStrong:
            return [[NSAttributedString alloc] initWithString:@"" attributes:@{}];//@"<strong>";
        case MMElementTypeEm:
            return [[NSAttributedString alloc] initWithString:@"" attributes:@{}];//@"<em>";
        case MMElementTypeCodeSpan:
            return [[NSAttributedString alloc] initWithString:@"" attributes:@{}];//@"<code>";
        case MMElementTypeImage:
            return [[NSAttributedString alloc] initWithString:@"" attributes:@{}];//@"<code>";
        case MMElementTypeLink:
            return [[NSAttributedString alloc] initWithString:@"" attributes:@{}];//@"<code>";
        case MMElementTypeMailTo:
            return [[NSAttributedString alloc] initWithString:@"" attributes:@{}];//@"<code>";
        case MMElementTypeEntity:
            return [[NSAttributedString alloc] initWithString:anElement.stringValue attributes:@{}];
        case MMElementTypeMention:
            return [[NSAttributedString alloc] initWithString:@" " attributes:@{}];
        case MMElementTypeRedboothLink:
            if (anElement.title) {
                return [[NSAttributedString alloc] initWithString:anElement.title attributes:@{NSLinkAttributeName:anElement.href}];
            }
            return [[NSAttributedString alloc] initWithString:@"" attributes:@{}];
            
        default:
            return [[NSAttributedString alloc] initWithString:@"" attributes:@{}];
    }
}

+ (NSString *)endStringForElement:(MMElement *)anElement
{
    switch (anElement.type)
    {
        case MMElementTypeHeader:
            return [NSString stringWithFormat:@"\n"];
        case MMElementTypeParagraph:
            return @"\n\n";
        case MMElementTypeBulletedList:
            return @"\n";
        case MMElementTypeNumberedList:
            return @"\n";
        case MMElementTypeListItem:
            return @"\n";
        case MMElementTypeBlockquote:
            return @"\n";
        case MMElementTypeCodeBlock:
            return @"\n";
        case MMElementTypeStrong:
            return @"";
        case MMElementTypeEm:
            return @"";
        case MMElementTypeCodeSpan:
            return @"";
        case MMElementTypeLink:
            return @"";
        case MMElementTypeMention:
            return @" ";
        default:
            return @"";
    }
}

+ (NSDictionary *)attributesDictionaryForElement:(MMElement *)anElement nestedStyles:(NSMutableArray *)nestedStyles
{
    NSMutableDictionary *dictionary = [@{} mutableCopy];
    switch (anElement.type)
    {
        case MMElementTypeHeader:
            switch (anElement.level) {
                case 1:
                    return @{NSFontAttributeName:[UIFont fontWithName:kSemiboldFont size:20],
                             NSForegroundColorAttributeName:[UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1],
                             NSBaselineOffsetAttributeName:@10
                             };
                case 2:
                    return @{NSFontAttributeName:[UIFont fontWithName:kSemiboldFont size:16],
                             NSForegroundColorAttributeName:[UIColor colorWithRed:0.44 green:0.44 blue:0.44 alpha:1],
                             NSBaselineOffsetAttributeName:@10
                             };
                case 3:
                    return @{NSFontAttributeName:[UIFont fontWithName:kSemiboldFont size:13],
                             NSForegroundColorAttributeName:[UIColor colorWithRed:0.44 green:0.44 blue:0.44 alpha:1],
                             NSBaselineOffsetAttributeName:@15
                             };
                case 4:
                    return @{NSFontAttributeName:[UIFont fontWithName:kItalicFont size:13],
                             NSForegroundColorAttributeName:[UIColor colorWithRed:0.44 green:0.44 blue:0.44 alpha:1],
                             NSBaselineOffsetAttributeName:@15
                             };
                case 5:
                    return @{NSFontAttributeName:[UIFont fontWithName:kItalicFont size:13],
                             NSForegroundColorAttributeName:[UIColor colorWithRed:0.44 green:0.44 blue:0.44 alpha:1],
                             NSBaselineOffsetAttributeName:@15
                             };
                case 6:
                    return @{NSFontAttributeName:[UIFont fontWithName:kItalicFont size:13],
                             NSForegroundColorAttributeName:[UIColor colorWithRed:0.44 green:0.44 blue:0.44 alpha:1],
                             NSBaselineOffsetAttributeName:@15
                             };
                default:
                    break;
            }
            
        case MMElementTypeParagraph:
            if (nestedStyles.count > 1) {
                if ([nestedStyles containsObject:@(MMElementTypeBlockquote)]) {
                    return @{NSFontAttributeName:[UIFont fontWithName:kItalicFont size:13],
                             NSForegroundColorAttributeName:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1]};
                }
            }
            return @{NSFontAttributeName:[UIFont fontWithName:kNormalFont size:13],
                     NSForegroundColorAttributeName:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1]};
        case MMElementTypeBulletedList:
            return @{NSFontAttributeName:[UIFont fontWithName:kNormalFont size:13],
                     NSForegroundColorAttributeName:[UIColor colorWithRed:0.44 green:0.44 blue:0.44 alpha:1],
                     //NSBaselineOffsetAttributeName:@8
                     };
        case MMElementTypeNumberedList:
            return @{NSFontAttributeName:[UIFont fontWithName:kNormalFont size:13],
                     NSForegroundColorAttributeName:[UIColor colorWithRed:0.44 green:0.44 blue:0.44 alpha:1],
                     NSBaselineOffsetAttributeName:@8
                     };
        case MMElementTypeListItem:
            return @{NSFontAttributeName:[UIFont fontWithName:kNormalFont size:13],
                     NSForegroundColorAttributeName:[UIColor colorWithRed:0.44 green:0.44 blue:0.44 alpha:1],
                     NSBaselineOffsetAttributeName:@6
                     };
        case MMElementTypeBlockquote:
            return @{NSFontAttributeName:[UIFont fontWithName:kItalicFont size:13],
                     NSForegroundColorAttributeName:[UIColor colorWithRed:0.44 green:0.44 blue:0.44 alpha:1]};
        case MMElementTypeCodeBlock:
            return @{NSFontAttributeName:[UIFont fontWithName:@"Courier" size:13],
                     NSForegroundColorAttributeName:[UIColor colorWithRed:0.44 green:0.44 blue:0.44 alpha:1]};
        case MMElementTypeStrong:
            [dictionary setObject:[UIFont fontWithName:kBoldFont size:13] forKey:NSFontAttributeName];
            [dictionary setObject:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1] forKey:NSForegroundColorAttributeName];
            
            if ([nestedStyles containsObject:@(MMElementTypeEm)] || [nestedStyles containsObject:@(MMElementTypeBlockquote)] ) {
                [dictionary setObject:[UIFont fontWithName:kBoldItalicFont size:13] forKey:NSFontAttributeName];
            }
            if ([nestedStyles containsObject:@(MMElementTypeListItem)]) {
                [dictionary setObject:@6 forKey:NSBaselineOffsetAttributeName];
                [dictionary setObject:[UIColor colorWithRed:0.44 green:0.44 blue:0.44 alpha:1] forKey:NSForegroundColorAttributeName];
            }
            return dictionary;
        case MMElementTypeEm:
            [dictionary setObject:[UIFont fontWithName:kItalicFont size:13] forKey:NSFontAttributeName];
            [dictionary setObject:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1] forKey:NSForegroundColorAttributeName];
            
            if ([nestedStyles containsObject:@(MMElementTypeStrong)]) {
                [dictionary setObject:[UIFont fontWithName:kBoldItalicFont size:13] forKey:NSFontAttributeName];
            }
            if ([nestedStyles containsObject:@(MMElementTypeListItem)]) {
                [dictionary setObject:@6 forKey:NSBaselineOffsetAttributeName];
                [dictionary setObject:[UIColor colorWithRed:0.44 green:0.44 blue:0.44 alpha:1] forKey:NSForegroundColorAttributeName];
            }
            return dictionary;
        case MMElementTypeCodeSpan:
            return @{NSFontAttributeName:[UIFont fontWithName:@"Courier" size:13],
                     NSForegroundColorAttributeName:[UIColor colorWithRed:0.44 green:0.44 blue:0.44 alpha:1]};
        case MMElementTypeRedboothLink:
        case MMElementTypeLink:
            return @{NSFontAttributeName:[UIFont fontWithName:kNormalFont size:13],
                     NSForegroundColorAttributeName:[UIColor colorWithRed:0.13 green:0.65 blue:0.72 alpha:1],
                     NSLinkAttributeName:anElement.href};
        case MMElementTypeMention:
            [dictionary setObject:[UIFont fontWithName:kNormalFont size:13] forKey:NSFontAttributeName];
            [dictionary setObject:[UIColor colorWithRed:1/255.0f green:118/255.0f blue:119/255.0f alpha:1.0f] forKey:NSForegroundColorAttributeName];
            //[dictionary setObject:[UIColor colorWithRed:0.827 green:0.925 blue:0.941 alpha:1] forKey:NSBackgroundColorAttributeName];
            if ([nestedStyles containsObject:@(MMElementTypeListItem)]) {
                [dictionary setObject:@6 forKey:NSBaselineOffsetAttributeName];
            }
            return dictionary;
        default:
            return @{NSFontAttributeName:[UIFont fontWithName:kNormalFont size:13],
                     NSForegroundColorAttributeName:[UIColor colorWithRed:0.44 green:0.44 blue:0.44 alpha:1]};
    }
}



@end
