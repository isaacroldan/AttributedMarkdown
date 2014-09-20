//
//  MMAttributesHelper.m
//  KoaMarkdownRenderDemo
//
//  Created by Isaac Roldan on 20/05/14.
//  Copyright (c) 2014 Isaac Roldan. All rights reserved.
//

#import "MMAttributesHelper.h"
#import "MMElement.h"
#import <CoreText/CoreText.h>
#import "MMMarkdownStyleSheet.h"

#define emptyAttributedString [[NSAttributedString alloc] initWithString:@"" attributes:@{}];
#define spaceAttributedString [[NSAttributedString alloc] initWithString:@" " attributes:@{}];


@implementation MMAttributesHelper

+ (NSAttributedString *)startStringForElement:(MMElement *)anElement listType:(NSString *)listType nestedStyles:(NSMutableArray *)nestedStyles
{
    
    NSAttributedString *attString;
    if (anElement.type == MMElementTypeImage) {
        NSString *gifString = [NSString stringWithFormat:@"<IMAGE>%@<IMAGE>",anElement.href];
        attString = [[NSAttributedString alloc] initWithString:gifString attributes:@{}];
    }
    else if (anElement.type == MMElementTypeYoutubeVideo) {
        NSString *youtubeString = [NSString stringWithFormat:@"<YOUTUBE>%@<YOUTUBE>",anElement.href];
        attString = [[NSAttributedString alloc] initWithString:youtubeString attributes:@{}];
    }
    
    NSMutableAttributedString *auxString;
    NSMutableDictionary *attributesDictionary;
    switch (anElement.type) {
        case MMElementTypeListItem: //@"<li>";
                listType = anElement.title;
            attributesDictionary = [self attributesDictionaryForElement:anElement nestedStyles:nil];
            [attributesDictionary setObject:[self paragraphStyleForElement:anElement startString:YES nestedStyles:nestedStyles] forKey:NSParagraphStyleAttributeName];
            return [[NSAttributedString alloc] initWithString:anElement.title attributes:attributesDictionary];
            
        case MMElementTypeEntity:
            return [[NSAttributedString alloc] initWithString:anElement.stringValue attributes:@{}];
        
        case MMElementTypeMention:
            if (anElement.title) { //The title should have the Full Name of the User
                return [[NSAttributedString alloc] initWithString:anElement.title attributes:[self attributesDictionaryForElement:anElement nestedStyles:nil]];
            }
            return emptyAttributedString;
        
        case MMElementTypeRedboothLink:
            return [[NSAttributedString alloc] initWithString:anElement.title attributes:[self attributesDictionaryForElement:anElement nestedStyles:nil]];
        
        case MMElementTypeYoutubeVideo:
        case MMElementTypeImage:
            return attString;
            
        case MMElementTypeCodeSpan: //@"<code>"
            auxString = [[NSMutableAttributedString alloc] initWithString:@"\u00A0" attributes:@{}];
            [auxString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\u00A0" attributes:[self attributesDictionaryForElement:anElement nestedStyles:nil]]];
            return auxString;

        case MMElementTypeCodeBlock: //@"<pre><code>"
        case MMElementTypeBlockquote: //@"<blockquote>
        case MMElementTypeParagraph: //@"<p>";
        case MMElementTypeHeader:
        case MMElementTypeBulletedList: //@"<ul>"
        case MMElementTypeNumberedList: //@"<ol>
        case MMElementTypeLineBreak: //@"<br />
        case MMElementTypeHorizontalRule: //@"\n<hr />"
        case MMElementTypeStrong: //@"<strong>"
        case MMElementTypeEm: //@"<em>"
        case MMElementTypeLink:
        case MMElementTypeMailTo:
        default:
            return emptyAttributedString
    }
}

+ (NSAttributedString *)endStringForElement:(MMElement *)anElement nestedStyles:(NSMutableArray *)nestedStyles
{
    NSMutableAttributedString *auxString;
    switch (anElement.type)
    {
        case MMElementTypeParagraph:
        case MMElementTypeCodeBlock:
            return [[NSAttributedString alloc] initWithString:@"\n\n" attributes:@{}];
        case MMElementTypeListItem:
        case MMElementTypeHeader:
        case MMElementTypeBulletedList:
        case MMElementTypeNumberedList:
        case MMElementTypeBlockquote:
            return [[NSAttributedString alloc] initWithString:@"\n" attributes:@{}];
        case MMElementTypeCodeSpan:
            auxString = [[NSMutableAttributedString alloc] initWithString:@"\u00A0" attributes:[self attributesDictionaryForElement:anElement nestedStyles:nil]];
            [auxString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\u00A0\u00A0" attributes:@{}]];
            return auxString;
        case MMElementTypeStrong:
        case MMElementTypeEm:
        case MMElementTypeLink:
        case MMElementTypeMention:
        default:
            return emptyAttributedString
    }
}

+ (NSDictionary *)attributesDictionaryForElement:(MMElement *)anElement nestedStyles:(NSMutableArray *)nestedStyles
{
    NSMutableDictionary *attributesDictionary = [NSMutableDictionary new];
    NSMutableParagraphStyle *paragraphStyle = [self paragraphStyleForElement:anElement startString:NO nestedStyles:nestedStyles];
    
    //Most common attributes
    [attributesDictionary setObject:mm_Color_Paragraph forKey:NSForegroundColorAttributeName];
    [attributesDictionary setObject:mm_Font_mainFont forKey:NSFontAttributeName];
    [attributesDictionary setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    [attributesDictionary setObject:@(anElement.type) forKey:@"ElementType"];

    switch (anElement.type) {
        case MMElementTypeHeader:
            switch (anElement.level) {
                case 1:
                    [attributesDictionary setObject:mm_Font_Semibold_Big forKey:NSFontAttributeName];
                    [attributesDictionary setObject:mm_Color_DarkGrey69 forKey:NSForegroundColorAttributeName];
                    [attributesDictionary setObject:mm_Baseline_Offset_Medium forKey:NSBaselineOffsetAttributeName];
                    return attributesDictionary;
                case 2:
                    [attributesDictionary setObject:mm_Font_Semibold_Medium forKey:NSFontAttributeName];
                    [attributesDictionary setObject:mm_Baseline_Offset_Medium forKey:NSBaselineOffsetAttributeName];
                    return attributesDictionary;
                case 3:
                    [attributesDictionary setObject:mm_Font_Semibold_Normal forKey:NSFontAttributeName];
                    [attributesDictionary setObject:mm_Baseline_Offset_Big forKey:NSBaselineOffsetAttributeName];
                    return attributesDictionary;
                case 4:
                case 5:
                case 6:
                    [attributesDictionary setObject:mm_Font_Italic_Normal forKey:NSFontAttributeName];
                    [attributesDictionary setObject:mm_Baseline_Offset_Big forKey:NSBaselineOffsetAttributeName];
                    return attributesDictionary;
                default:
                    break;
            }
            
        case MMElementTypeParagraph:
            if (nestedStyles.count > 1 && [nestedStyles containsObject:@(MMElementTypeBlockquote)]) {
                [attributesDictionary setObject:mm_Font_Italic_Normal forKey:NSFontAttributeName];
                [attributesDictionary setObject:mm_Color_White forKey:NSBackgroundColorAttributeName];
                [attributesDictionary setObject:mm_Color_LightGrey238 forKey:@"BackgroundBorderColor"];
                [attributesDictionary setObject:@(MMElementTypeBlockquote) forKey:@"ElementType"];
            }
            return attributesDictionary;
            
        case MMElementTypeBulletedList:
        case MMElementTypeNumberedList:
        case MMElementTypeListItem:
            return attributesDictionary;

        case MMElementTypeBlockquote:
            [attributesDictionary setObject:mm_Font_Italic_Normal forKey:NSFontAttributeName];
            [attributesDictionary setObject:mm_Color_White forKey:NSBackgroundColorAttributeName];
            [attributesDictionary setObject:mm_Color_LightGrey238 forKey:@"BackgroundBorderColor"];
            return attributesDictionary;
            
        case MMElementTypeCodeBlock:
            [attributesDictionary setObject:mm_Font_Monospace_Normal forKey:NSFontAttributeName];
            [attributesDictionary setObject:mm_Color_LightGrey250 forKey:NSBackgroundColorAttributeName];
            [attributesDictionary setObject:mm_Color_LightGrey230 forKey:@"BackgroundBorderColor"];
            return attributesDictionary;
            
        case MMElementTypeStrong:
            [attributesDictionary setObject:mm_Font_Bold_Normal forKey:NSFontAttributeName];
            [attributesDictionary setObject:mm_Color_DarkGrey51 forKey:NSForegroundColorAttributeName];
            
            if ([nestedStyles containsObject:@(MMElementTypeEm)] || [nestedStyles containsObject:@(MMElementTypeBlockquote)] ) {
                [attributesDictionary setObject:mm_Font_BoldItalic_Normal forKey:NSFontAttributeName];
            }
            if ([nestedStyles containsObject:@(MMElementTypeListItem)]) {
                [attributesDictionary setObject:mm_Color_Paragraph forKey:NSForegroundColorAttributeName];
            }
            return attributesDictionary;
            
        case MMElementTypeEm:
            [attributesDictionary setObject:mm_Font_Italic_Normal forKey:NSFontAttributeName];
            [attributesDictionary setObject:mm_Color_DarkGrey51 forKey:NSForegroundColorAttributeName];
            
            if ([nestedStyles containsObject:@(MMElementTypeStrong)]) {
                [attributesDictionary setObject:mm_Font_BoldItalic_Normal forKey:NSFontAttributeName];
            }
            if ([nestedStyles containsObject:@(MMElementTypeListItem)]) {
                [attributesDictionary setObject:mm_Color_Paragraph forKey:NSForegroundColorAttributeName];
            }
            return attributesDictionary;
            
        case MMElementTypeCodeSpan:
            [attributesDictionary setObject:mm_Font_Monospace_Normal forKey:NSFontAttributeName];
            [attributesDictionary setObject:mm_Color_LightGrey250 forKey:NSBackgroundColorAttributeName];
            [attributesDictionary setObject:mm_Color_LightGrey230 forKey:@"BackgroundBorderColor"];
            return attributesDictionary;
            
        case MMElementTypeRedboothLink:
            [attributesDictionary setObject:mm_Color_BlueMention_Foreground forKey:NSForegroundColorAttributeName];
            [attributesDictionary setObject:mm_Color_BlueMention_Background forKey:NSBackgroundColorAttributeName];
            [attributesDictionary setObject:anElement.href forKey:NSLinkAttributeName];
            return attributesDictionary;
            
        case MMElementTypeLink:
            [attributesDictionary setObject:mm_Color_BlueLink forKey:NSForegroundColorAttributeName];
            //[attributesDictionary setObject:anElement.href forKey:NSLinkAttributeName];
            return attributesDictionary;

        case MMElementTypeMention:
            [attributesDictionary setObject:mm_Color_BlueMention_Foreground forKey:NSForegroundColorAttributeName];
            [attributesDictionary setObject:mm_Color_BlueMention_Background forKey:NSBackgroundColorAttributeName];
            [attributesDictionary setObject:anElement.href forKey:NSLinkAttributeName];
            return attributesDictionary;
            
        default:
            return attributesDictionary;
    }
}

+ (NSMutableParagraphStyle*)paragraphStyleForElement:(MMElement*)element startString:(BOOL)isStartString nestedStyles:(NSMutableArray*)nestedStyles
{
    //Common styles
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.paragraphSpacingBefore = 0.0;
    paragraphStyle.paragraphSpacing = 0.0;
    paragraphStyle.headIndent = 0.0;
    paragraphStyle.tailIndent = 0.0;
    paragraphStyle.lineHeightMultiple = 0.0;
    paragraphStyle.lineSpacing = 4;
    paragraphStyle.minimumLineHeight = 0.0;
    paragraphStyle.maximumLineHeight = 0.0;
    paragraphStyle.alignment = 4;
    paragraphStyle.baseWritingDirection = -1;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;

    switch (element.type) {
        case MMElementTypeListItem:
            if (isStartString) {
                paragraphStyle.defaultTabInterval = 100;
                paragraphStyle.firstLineHeadIndent = 13;
                paragraphStyle.headIndent = 27.0;
            }
            else {
                paragraphStyle.defaultTabInterval = 36.0;
                paragraphStyle.firstLineHeadIndent = 27.0;
                paragraphStyle.lineSpacing = 0;
                paragraphStyle.headIndent = 27.0;
            }
            paragraphStyle.paragraphSpacing = 5;
            break;
        case MMElementTypeBlockquote:
            paragraphStyle.headIndent = 18;
            paragraphStyle.firstLineHeadIndent = 18;
            break;
        case MMElementTypeParagraph:
            if (nestedStyles.count > 1 && [nestedStyles containsObject:@(MMElementTypeBlockquote)]) {
                paragraphStyle.headIndent = 18;
                paragraphStyle.firstLineHeadIndent = 18;
            }
            break;
        case MMElementTypeCodeBlock:
            paragraphStyle.headIndent = 14;
            paragraphStyle.firstLineHeadIndent = 14;
            paragraphStyle.tailIndent = -14;
            break;
        case MMElementTypeCodeSpan:
            paragraphStyle.headIndent = 10;
            paragraphStyle.firstLineHeadIndent = 10;
            break;
        default:
            break;
    }
    
    return paragraphStyle;
}

@end
