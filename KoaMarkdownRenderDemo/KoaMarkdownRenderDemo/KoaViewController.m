//
//  KoaViewController.m
//  KoaMarkdownRenderDemo
//
//  Created by Isaac Roldan on 16/05/14.
//  Copyright (c) 2014 Isaac Roldan. All rights reserved.
//

#import "KoaViewController.h"
#import "MMMarkdown.h"

@interface KoaViewController ()

@end

@implementation KoaViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITextView *myView = [UITextView new];
    myView.frame = self.view.frame;
    myView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:myView];
    for (NSString* family in [UIFont familyNames])
    {
        NSLog(@"%@", family);
        
        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            NSLog(@"  %@", name);
        }
    }
    NSString *markdown = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Example" ofType:@"md"]  encoding:NSUTF8StringEncoding error:nil];

    NSError *error = nil;
    NSMutableAttributedString *stylie = [MMMarkdown HTMLStringWithMarkdown:markdown error:&error];
    myView.attributedText = stylie;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
