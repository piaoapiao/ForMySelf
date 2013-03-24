//
//  ViewController.m
//  ForMySelf
//
//  Created by wgdadmin on 13-3-17.
//  Copyright (c) 2013年 wgdadmin. All rights reserved.
//

#import "ViewController.h"
#import "KSLabel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(50, 50, 100, 30)];
    [btn setTitle:@"Click" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    _contentLabelView = [[KSLabel alloc] init];
      _contentLabelView.text = @"bug bug bug";
    _contentLabelView.drawGradient = YES;
    _contentLabelView.drawOutline = YES;
    _contentLabelView.userInteractionEnabled = YES;
   // _contentLabelView.backgroundColor = [UIColor clearColor];
    _contentLabelView.font = [UIFont systemFontOfSize:22];
    //  _contentLabelView.font = [UIFont systemFontOfSize:32];
    _contentLabelView.numberOfLines = 0;
    [_contentLabelView setTextAlignment:NSTextAlignmentCenter];
    
    [self.view addSubview:_contentLabelView];
    
    _contentLabelView.frame = CGRectMake(100,100,200,50);

    
    _contentLabelView.rotateEnabled = YES;
    _contentLabelView.panEnabled = YES;
    _contentLabelView.scaleEnabled = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)click:(id)sender
{
    NSLog(@"click");
    _contentLabelView.frame = CGRectMake(100, 100,200,50);
}

@end
