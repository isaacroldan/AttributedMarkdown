//
//  VSAnimatedGIFResponseSerializer.m
//  KoaMarkdownRenderDemo
//
//  Created by Isaac Roldan on 21/05/14.
//  Copyright (c) 2014 Isaac Roldan. All rights reserved.
//

#import "VSAnimatedGIFResponseSerializer.h"
#import <YLGIFImage.h>
//#import "UIImage+animatedGIF.h"

@implementation VSAnimatedGIFResponseSerializer

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.acceptableContentTypes = [[NSSet alloc] initWithObjects: @"image/gif", nil];
    return self;
}

+ (NSSet *)acceptablePathExtensions {
    static NSSet * _acceptablePathExtension = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _acceptablePathExtension = [[NSSet alloc] initWithObjects:@"gif", nil];
    });
    
    return _acceptablePathExtension;
}


- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        if ([(NSError *)(*error) code] == NSURLErrorCannotDecodeContentData) {
            return nil;
        }
    }
    return [YLGIFImage imageWithData:data];
}

@end