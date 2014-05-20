//
//  MMGenerator.m
//  MMMarkdown
//
//  Copyright (c) 2012 Matt Diephouse.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "MMGenerator.h"


#import "MMDocument.h"
#import "MMElement.h"

// This value is used to estimate the length of the HTML output. The length of the markdown document
// is multplied by it to create an NSMutableString with an initial capacity.
//static const Float64 kHTMLDocumentLengthMultiplier = 1.25;
static  NSString *kNormalFont      = @"OpenSans";
static  NSString *kBoldFont        = @"OpenSans-Bold";
static  NSString *kLightFont       = @"OpenSans-Light";
static  NSString *kSemiboldFont    = @"OpenSans-Semibold";
static  NSString *kItalicFont      = @"OpenSans-Italic";
static  NSString *kBoldItalicFont  = @"OpenSans-BoldItalic";


static NSString * __HTMLEscapedString(NSString *aString)
{
    NSMutableString *result = [aString mutableCopy];
    
    [result replaceOccurrencesOfString:@"&"
                            withString:@"&amp;"
                               options:NSLiteralSearch
                                 range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"\""
                            withString:@"&quot;"
                               options:NSLiteralSearch
                                 range:NSMakeRange(0, result.length)];
    
    return result;
}

static NSString *__obfuscatedEmailAddress(NSString *anAddress)
{
    NSMutableString *result = [NSMutableString new];
    
    NSString *(^decimal)(unichar c) = ^(unichar c){ return [NSString stringWithFormat:@"&#%d;", c];  };
    NSString *(^hex)(unichar c)     = ^(unichar c){ return [NSString stringWithFormat:@"&#x%x;", c]; };
    NSString *(^raw)(unichar c)     = ^(unichar c){ return [NSString stringWithCharacters:&c length:1]; };
    NSArray *encoders = [NSArray arrayWithObjects:decimal, hex, raw, nil];
    
    for (NSUInteger idx=0; idx<anAddress.length; idx++)
    {
        unichar character = [anAddress characterAtIndex:idx];
        NSString *(^encoder)(unichar c);
        if (character == '@')
        {
            // Make sure that the @ gets encoded
            encoder = [encoders objectAtIndex:arc4random_uniform(2)];
        }
        else
        {
            int r = arc4random_uniform(100);
            encoder = [encoders objectAtIndex:(r >= 90) ? 2 : (r >= 45) ? 1 : 0];
        }
        [result appendString:encoder(character)];
    }
    
    return result;
}

static NSAttributedString * __HTMLStartTagForElement(MMElement *anElement, NSString *listStart)
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
            if ([listStart isEqualToString:@"- "] || [listStart isEqualToString:@"* "] || [listStart isEqualToString:@"+ "] ) {
                listStart = @"  • ";
                return [[NSAttributedString alloc] initWithString:listStart  attributes:@{NSFontAttributeName:[UIFont fontWithName:kNormalFont size:25],
                                                                                          NSForegroundColorAttributeName:[UIColor colorWithRed:0.44 green:0.44 blue:0.44 alpha:1],
                                                                                          //NSBaselineOffsetAttributeName:@1
                                                                                          }];//@"<li>";
            }
            else {
                listStart = [NSString stringWithFormat:@"  %@ ",listStart];
                return [[NSAttributedString alloc] initWithString:listStart  attributes:@{NSFontAttributeName:[UIFont fontWithName:kNormalFont size:13],
                                                                                          NSForegroundColorAttributeName:[UIColor colorWithRed:0.44 green:0.44 blue:0.44 alpha:1],
                                                                                          NSBaselineOffsetAttributeName:@6
                                                                                          }];//@"<li>";
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
            if (anElement.title != nil)
//            {
//                return [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"<img src=\"%@\" alt=\"%@\" title=\"%@\" />",
//                                                            __HTMLEscapedString(anElement.href),
//                                                            __HTMLEscapedString(anElement.stringValue),
//                                                            __HTMLEscapedString(anElement.title)] attributes:@{}];
//            }
//            return [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"<img src=\"%@\" alt=\"%@\" />",
//                                                               __HTMLEscapedString(anElement.href),
//                                                               __HTMLEscapedString(anElement.stringValue)] attributes:@{}];
        case MMElementTypeLink:
            return [[NSAttributedString alloc] initWithString:@"" attributes:@{}];//@"<code>";
//            if (anElement.title != nil)
//            {
//                
//                return [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"<a title=\"%@\" href=\"%@\">",
//                                                                   __HTMLEscapedString(anElement.title), __HTMLEscapedString(anElement.href)] attributes:@{}];
//            }
//            return  [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"<a href=\"%@\">", __HTMLEscapedString(anElement.href)] attributes:@{}];
        case MMElementTypeMailTo:

            return  [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"<a href=\"%@\">%@</a>",
                                                                __obfuscatedEmailAddress([NSString stringWithFormat:@"mailto:%@", anElement.href]),
                                                                __obfuscatedEmailAddress(anElement.href)] attributes:@{}];
        case MMElementTypeEntity:
            return [[NSAttributedString alloc] initWithString:anElement.stringValue attributes:@{}];
        case MMELEmentTypeMention:
            return [[NSAttributedString alloc] initWithString:@" " attributes:@{}];
        default:
            return [[NSAttributedString alloc] initWithString:@"" attributes:@{}];
    }
}

static NSString * __HTMLEndTagForElement(MMElement *anElement)
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
        case MMELEmentTypeMention:
            return @" ";
        default:
            return @"";
    }
}

static NSDictionary *__stringAttributesForElement(MMElement *anElement, NSMutableArray *stylesArray)
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
            if (stylesArray.count > 1) {
                if ([stylesArray containsObject:@(MMElementTypeBlockquote)]) {
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
            
            if ([stylesArray containsObject:@(MMElementTypeEm)] || [stylesArray containsObject:@(MMElementTypeBlockquote)] ) {
                [dictionary setObject:[UIFont fontWithName:kBoldItalicFont size:13] forKey:NSFontAttributeName];
            }
            if ([stylesArray containsObject:@(MMElementTypeListItem)]) {
                [dictionary setObject:@6 forKey:NSBaselineOffsetAttributeName];
                [dictionary setObject:[UIColor colorWithRed:0.44 green:0.44 blue:0.44 alpha:1] forKey:NSForegroundColorAttributeName];
            }
            return dictionary;
        case MMElementTypeEm:
            [dictionary setObject:[UIFont fontWithName:kItalicFont size:13] forKey:NSFontAttributeName];
            [dictionary setObject:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1] forKey:NSForegroundColorAttributeName];
            
            if ([stylesArray containsObject:@(MMElementTypeStrong)]) {
                [dictionary setObject:[UIFont fontWithName:kBoldItalicFont size:13] forKey:NSFontAttributeName];
            }
            if ([stylesArray containsObject:@(MMElementTypeListItem)]) {
                [dictionary setObject:@6 forKey:NSBaselineOffsetAttributeName];
                [dictionary setObject:[UIColor colorWithRed:0.44 green:0.44 blue:0.44 alpha:1] forKey:NSForegroundColorAttributeName];
            }
            return dictionary;
        case MMElementTypeCodeSpan:
            return @{NSFontAttributeName:[UIFont fontWithName:@"Courier" size:13],
                     NSForegroundColorAttributeName:[UIColor colorWithRed:0.44 green:0.44 blue:0.44 alpha:1]};
        case MMElementTypeLink:
            return @{NSFontAttributeName:[UIFont fontWithName:kNormalFont size:13],
                     NSForegroundColorAttributeName:[UIColor colorWithRed:0.13 green:0.65 blue:0.72 alpha:1],
                     NSLinkAttributeName:anElement.href};
        case MMELEmentTypeMention:
            [dictionary setObject:[UIFont fontWithName:kNormalFont size:13] forKey:NSFontAttributeName];
            [dictionary setObject:[UIColor colorWithRed:1/255.0f green:118/255.0f blue:119/255.0f alpha:1.0f] forKey:NSForegroundColorAttributeName];
            //[dictionary setObject:[UIColor colorWithRed:0.827 green:0.925 blue:0.941 alpha:1] forKey:NSBackgroundColorAttributeName];
            if ([stylesArray containsObject:@(MMElementTypeListItem)]) {
                [dictionary setObject:@6 forKey:NSBaselineOffsetAttributeName];
            }
            return dictionary;
        default:
            return @{NSFontAttributeName:[UIFont fontWithName:kNormalFont size:13],
                     NSForegroundColorAttributeName:[UIColor colorWithRed:0.44 green:0.44 blue:0.44 alpha:1]};
    }
}

@interface MMGenerator ()
- (void) _generateHTMLForElement:(MMElement *)anElement
                      inDocument:(MMDocument *)aDocument
                            HTML:(NSMutableAttributedString *)theHTML
                        location:(NSUInteger *)aLocation
                     stylesArray:(NSMutableArray *)stylesArray;
@end

@implementation MMGenerator

//==================================================================================================
#pragma mark -
#pragma mark Public Methods
//==================================================================================================

- (NSMutableAttributedString *)generateHTML:(MMDocument *)aDocument
{
    //NSString   *markdown = aDocument.markdown;
    NSUInteger  location = 0;
    //NSUInteger  length   = markdown.length;
    
    //NSMutableString *HTML = [NSMutableString stringWithCapacity:length * kHTMLDocumentLengthMultiplier];
    NSMutableAttributedString *HTML = [[NSMutableAttributedString alloc] init];
    for (MMElement *element in aDocument.elements) {
        if (element.type == MMElementTypeHTML) {
            [HTML appendAttributedString:[[NSAttributedString alloc] initWithString:[aDocument.markdown substringWithRange:element.range]]];
        }
        else {
            [self _generateHTMLForElement:element
                               inDocument:aDocument
                                     HTML:HTML
                                 location:&location
                               styesArray:[@[@(element.type)] mutableCopy]];
        }
    }
    
    return HTML;
}


//==================================================================================================
#pragma mark -
#pragma mark Public Methods
//==================================================================================================

- (void)_generateHTMLForElement:(MMElement *)anElement
                     inDocument:(MMDocument *)aDocument
                           HTML:(NSMutableAttributedString *)theHTML
                       location:(NSUInteger *)aLocation
                     styesArray:(NSMutableArray *)stylesArray
{
    NSString *markdown = aDocument.markdown;
    NSString *startOfList = [markdown substringWithRange:NSMakeRange(anElement.range.location, 2)];
    
    NSAttributedString *startTag = __HTMLStartTagForElement(anElement, startOfList);
    NSString *endTag   = __HTMLEndTagForElement(anElement);

    NSLog(@"%@",stylesArray);
    if (startTag)
        [theHTML appendAttributedString:startTag];
    
    for (MMElement *child in anElement.children) {
        int start = (int)theHTML.length;
        int end = (int)child.range.length;

        if (child.type == MMElementTypeNone) {
            NSString *markdown = aDocument.markdown;
            if (child.range.length == 0) {
                [theHTML appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
            }
            else {
                [theHTML appendAttributedString:[[NSAttributedString alloc] initWithString:[markdown substringWithRange:child.range]]];
                [theHTML addAttributes:__stringAttributesForElement(anElement, stylesArray) range:NSMakeRange(start, end)];
                NSLog(@"%@",[markdown substringWithRange:child.range]);
            }
        }
        else if (child.type == MMElementTypeHTML) {
            [theHTML appendAttributedString:[[NSAttributedString alloc] initWithString:[aDocument.markdown substringWithRange:child.range]]];
            [theHTML addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"OpenSans" size:20] range:NSMakeRange(start, end)];
        }
        else {
            [stylesArray addObject:@(child.type)];
            [self _generateHTMLForElement:child
                               inDocument:aDocument
                                     HTML:theHTML
                                 location:aLocation
                               styesArray:[stylesArray mutableCopy]];
        }
    }

    if (endTag)
        [theHTML appendAttributedString:[[NSAttributedString alloc] initWithString:endTag]];
}


@end
