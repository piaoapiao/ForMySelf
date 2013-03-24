//
//  KSLabel.h
//  TestColor
//
//  Created by zyun2 on 12-12-28.
//  Copyright (c) 2012年 ziyun.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSLabel : UILabel<UIGestureRecognizerDelegate>
{
    BOOL drawOutline;
    BOOL drawGradient;
    CGPoint moveTranslation;
}

@property BOOL drawOutline;
@property BOOL drawGradient;
@property (nonatomic,retain)    UIImage *image;


@property   (nonatomic,assign) BOOL rotateEnabled;
@property   (nonatomic,assign) BOOL panEnabled;
@property   (nonatomic,assign) BOOL scaleEnabled;

@property   (nonatomic,assign) CGFloat minimumScale;
@property   (nonatomic,assign) CGFloat maximumScale;

@property   (nonatomic,assign) CGFloat rotation;
@property   (nonatomic,assign) CGFloat scale;
@end
