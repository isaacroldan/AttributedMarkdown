//
//  KoaViewController.m
//  KoaMarkdownRenderDemo
//
//  Created by Isaac Roldanon 16/05/14.
//  Copyright (c) 2014 Isaac Roldan. All rights reserved.
//

#import "KoaViewController.h"
#import "MMMarkdown.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "NSString+RBMarkdown.h"

@interface KoaViewController ()


@end

@implementation KoaViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //RBMagicTextView *myView = [RBMagicTextView new];
    
    UITextView *myView = [UITextView new];
    myView.frame = CGRectMake(50, 20, 320-50, self.view.frame.size.height-20);
    [self.view addSubview:myView];
    NSString *markdown = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Example" ofType:@"md"]  encoding:NSUTF8StringEncoding error:nil];

    NSError *error = nil;
    markdown = [markdown markdownizedString];
    NSAttributedString *stylie = [MMMarkdown attributedStringWithMarkdown:markdown attributesDelegate:nil extensions:MMMarkdownExtensionsNone error:&error];
    [myView setAttributedText:stylie];
}

@end
