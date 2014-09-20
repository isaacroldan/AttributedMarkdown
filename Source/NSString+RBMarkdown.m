//
//  NSString+RBMarkdown.m
//  Redbooth
//
//  Created by Isaac Roldan on 04/07/14.
//  Copyright (c) 2014 teambox. All rights reserved.
//

#import "NSString+RBMarkdown.h"
#import "Project.h"

@implementation NSString (RBMarkdown)

- (NSString*)markdownizedString
{
    return [NSString markdownizedStringWithString:self];
}

- (NSString*)markdownizedStringWithBasicElements
{
    return [NSString basicMarkdownizedStringWithString:self];
}

+ (NSString*)markdownizedStringWithString:(NSString*)string
{
    string = [self parseEmojisInString:string];
    string = [self parseDropboxImagesInString:string];
    string = [self parseCloudAppImagesInString:string];
    string = [self parseImageLinksInString:string];
    string = [self parseRedboothLinksInString:string];
    string = [self parseMentionsInString:string];
    string = [self parseYoutubeVideosInString:string];
    return string;
}

+ (NSString*)basicMarkdownizedStringWithString:(NSString*)string
{
    string = [self parseEmojisInString:string];
    string = [self parseRedboothLinksInString:string];
    string = [self parseMentionsInString:string];
    return string;
}

+ (NSString*)parseEmojisInString:(NSString*)string
{
    return [string emojizedString];
}

/**
 *  Find dropbox images links and transform them to markdown images with the correct URL
 */
+ (NSString*)parseDropboxImagesInString:(NSString*)string
{
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^https?://.*dropbox.com/s/([a-z0-9]*?)/(.*?)\\.(jpg|jpeg|gif|png|bmp)(?:\\s*)$"
                                                                           options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines
                                                                             error:&error];
    
    NSString *modifiedString = [regex stringByReplacingMatchesInString:string options:NSMatchingWithTransparentBounds
                                                                 range:NSMakeRange(0,[string length])
                                                          withTemplate:@"![](https://dl.dropbox.com/s/$1/$2.$3?dl=1)"];
    
    return modifiedString;
}

/**
 *  Find CloudApp images links and transform them to markdown images with the correct URL
 */
+ (NSString*)parseCloudAppImagesInString:(NSString*)string
{
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^https?://cl\\.ly/image/([a-z0-9]*)$"
                                                                           options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines
                                                                             error:&error];
    
    NSString *modifiedString = [regex stringByReplacingMatchesInString:string options:NSMatchingWithTransparentBounds
                                                                 range:NSMakeRange(0,[string length])
                                                          withTemplate:@"![](http://cl.ly/$1/content)"];
    
    return modifiedString;
}

/**
 *  Find images links and transform them to markdown images with the correct URL
 */
+ (NSString*)parseImageLinksInString:(NSString*)string
{
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^(https?://[^\\s]+\\.(?:gif|png|jpeg|jpg)(\\?)*(\\d+)*)(?:\\s*)$"
                                                                           options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines
                                                                             error:&error];
    
    NSString *modifiedString = [regex stringByReplacingMatchesInString:string options:NSMatchingWithTransparentBounds
                                                                 range:NSMakeRange(0,[string length])
                                                          withTemplate:@"![]($0)"];
    
    return modifiedString;
}

/**
 *  Find Redbooth internal links and transform them to markdown with extra info
 */
+ (NSString*)parseRedboothLinksInString:(NSString*)string
{
    // I'm the regex master :3
    NSString *regexString = @"https?://redbooth.com/[a-z0-9\\-]*/?/#!/(notifications|dash/notification|projects)/([a-z0-9\\-\\d]+)/(tasks?|conversations?|pages?|notes)/(\\d+)";
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString
                                                                           options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines
                                                                             error:&error];
    int startLocation = 0;
    while (1) {
        NSTextCheckingResult *result = [regex firstMatchInString:string
                                                         options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines
                                                           range:NSMakeRange(startLocation,[string length]-startLocation)];
        if (!result || [result range].location == NSNotFound) {
            break;
        }
        NSRange matchRange = [result range];
        NSString *matchedURL = [string substringWithRange:[result range]];
        NSString *projectID  = [string substringWithRange:[result rangeAtIndex:2]]; // $2 = project_id
        NSString *objectType = [string substringWithRange:[result rangeAtIndex:3]]; // $3 = object_type
        NSString *objectID   = [string substringWithRange:[result rangeAtIndex:4]]; // $4 = object_id
        Project *project = [Project objectForIdentifier:projectID inContext:[[LFDataModel sharedModel] mainContext]];
        NSString *replacementString = [NSString stringWithFormat:@"@[ %@: %@ #%@ ](%@)",project.name, objectType, objectID, matchedURL];
        replacementString = [replacementString unbreakableString];
        string = [string stringByReplacingCharactersInRange:matchRange withString:replacementString];
        startLocation = (int)matchRange.location + (int)replacementString.length;
    }
    return string;
}

/**
 *  Find Redbooth mentions and transform them to markdown links with extra info (custom format @[]() )
 */
+ (NSString*)parseMentionsInString:(NSString*)string
{
    NSString *regexString = @"(^|\\W)@([\\w._-]+(?:(?<!\\w)(?=\\w)|(?<=\\w)(?!\\w)|(?<=-)(?!-)))";
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString
                                                                           options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines
                                                                             error:&error];
    int startLocation = 0;
    while (1) {
        NSTextCheckingResult *result = [regex firstMatchInString:string
                                                         options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines
                                                           range:NSMakeRange(startLocation,[string length]-startLocation)];
        if (!result || [result range].location == NSNotFound) {
            break;
        }
        NSRange matchRange = [result range];
        NSString *firstSpace = [string substringWithRange:[result rangeAtIndex:1]];
        NSString *username  = [string substringWithRange:[result rangeAtIndex:2]];    // $2 = user_name
        NSString *replacementString;
        if ([username isEqualToString:@"all"]) {
            replacementString = [NSString stringWithFormat:@"@[ %@ ](/users/)", @"@all"];
        }
        else {
            User *mentionedUser = [User userForUsername:username];
            if (mentionedUser) {
                replacementString = [NSString stringWithFormat:@"@[ %@ ](/users/%@)", mentionedUser.fullName, mentionedUser.userID];
            }
            else {
                return string;
            }
        }
        replacementString = [replacementString unbreakableString];
        replacementString = [firstSpace stringByAppendingString:replacementString]; //We have to mantain the matched space before the mention.
        
        string = [string stringByReplacingCharactersInRange:matchRange withString:replacementString];
        startLocation = (int)matchRange.location + (int)replacementString.length;
    }
    return string;
}

+ (NSString*)parseYoutubeVideosInString:(NSString*)string
{
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([^\"]|\\A)https?://(?:www\\.)?youtu(?:be\\.com/watch\\?v=|\\.be/)([\\w-]+)(&(amp;)?(?:[\\w\\?=-]|\\+)*)?([^\"]|\\z)"
                                                                           options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines
                                                                             error:&error];
    
    NSString *modifiedString = [regex stringByReplacingMatchesInString:string options:NSMatchingWithTransparentBounds
                                                                 range:NSMakeRange(0,[string length])
                                                          withTemplate:@"@[YOUTUBE_VIDEO]($2)"];
    
    return modifiedString;
}

/**
 *  Change spaces for unbreakable spaces in the given string.
 *
 *  // \u00A0 = Unbreakable Space in UNICODE
 */
- (NSString*)unbreakableString
{
    return [self stringByReplacingOccurrencesOfString:@" " withString:@"\u00A0"];
}


@end
