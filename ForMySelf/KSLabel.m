//
//  KSLabel.m
//  TestColor
//
//  Created by zyun2 on 12-12-28.
//  Copyright (c) 2012年 ziyun.com. All rights reserved.
//

#define TT_RELEASE_SAFELY(__POINTER) { if(nil != __POINTER) [__POINTER release]; __POINTER = nil; }

#import "KSLabel.h"


#import "QuartzCore/QuartzCore.h"
static const NSTimeInterval kAnimationIntervalTransform = 0.2;
@interface KSLabel ()

@property (retain, nonatomic) IBOutlet UIRotationGestureRecognizer *rotationRecognizer;
@property (retain, nonatomic) IBOutlet UIPanGestureRecognizer *panRecognizer;
@property (retain, nonatomic) IBOutlet UIPinchGestureRecognizer *pinchRecognizer;
@property(nonatomic,assign) CGPoint rotationCenter;
@property(nonatomic,assign) CGPoint touchCenter;

@property(nonatomic,assign) NSUInteger gestureCount;

@property(nonatomic,assign) CGPoint scaleCenter;
@end

@implementation KSLabel
@synthesize rotationRecognizer = _rotationRecognizer;
@synthesize panRecognizer = _panRecognizer;
@synthesize pinchRecognizer = _pinchRecognizer;

@synthesize  rotateEnabled = _rotateEnabled;
@synthesize  panEnabled = _panEnabled;
@synthesize  scaleEnabled = _scaleEnabled ;

@synthesize touchCenter = _touchCenter;
@synthesize rotationCenter = _rotationCenter;
@synthesize gestureCount = _gestureCount;

@synthesize scale = _scale;
@synthesize scaleCenter = _scaleCenter;

@synthesize minimumScale = _minimumScale;
@synthesize maximumScale = _maximumScale;

//@implementation KSLabel
@synthesize  drawOutline;
@synthesize  drawGradient;
@synthesize  image;

@synthesize rotation = _rotation;

-(void)dealloc
{
    TT_RELEASE_SAFELY(image);
    [super dealloc];
}

- (void)drawTextInRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    CGContextSetTextDrawingMode(context, kCGTextFill);

    
    // Draw the text without an outline
    [super drawTextInRect:rect];
    
    CGImageRef alphaMask = NULL;
    
    if (drawGradient) {
        // Create a mask from the text
        alphaMask = CGBitmapContextCreateImage(context);
        
        // clear the image
        CGContextClearRect(context, rect);
        
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 0, rect.size.height);
        
        // invert everything because CoreGraphics works with an inverted coordinate system
        CGContextScaleCTM(context, 1.0, -1.0);
        
        // Clip the current context to our alphaMask
        CGContextClipToMask(context, rect, alphaMask);
        
        // Create the gradient with these colors
//        CGFloat colors [] = {
//            22.0f/255.0f, 107.0f/255.0f, 168.0f/255.0f, 1.0,
//            71.0f/255.0f, 160.0f/255.0f, 220.0f/255.0f, 1.0
//        };
        
        CGFloat colors [] = {
            255.0f/255.0f, 255.0f/255.0f, 255.0f/255.0f, 1.0,
            255.0f/255.0f, 255.0f/255.0f, 255.0f/255.0f, 1.0
        };
        
        CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
        CGColorSpaceRelease(baseSpace), baseSpace = NULL;
        
        CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
        CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
        
        // Draw the gradient
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
        CGGradientRelease(gradient), gradient = NULL;
        CGContextRestoreGState(context);
        
        // Clean up because ARC doesnt handle CG
        CGImageRelease(alphaMask);
    }
    
    if (drawOutline) {
        // Create a mask from the text (with the gradient)
        alphaMask = CGBitmapContextCreateImage(context);
        
        // Outline width
        CGContextSetLineWidth(context, 3);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        
        // Set the drawing method to stroke
        CGContextSetTextDrawingMode(context, kCGTextStroke);
        
        // Outline color
        self.textColor = [UIColor blackColor];
        
        // notice the +1 for the y-coordinate. this is to account for the face that the outline appears to be thicker on top
        [super drawTextInRect:CGRectMake(rect.origin.x, rect.origin.y+1, rect.size.width, rect.size.height)];
        
        // Draw the saved image over the outline
        // and invert everything because CoreGraphics works with an inverted coordinate system
        CGContextTranslateCTM(context, 0, rect.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextDrawImage(context, rect, alphaMask);
        CGImageRef imageRef=CGBitmapContextCreateImage(context);
        
        self.image = [UIImage imageWithCGImage:imageRef];
       // self.image = [UIImage imageWithCGImage:alphaMask];
//       UIImageWriteToSavedPhotosAlbum(<#UIImage *image#>, <#id completionTarget#>, <#SEL completionSelector#>, <#void *contextInfo#>)
        
 //       UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
        
        CGImageRelease(imageRef);
        // Clean up because ARC doesnt handle CG
        CGImageRelease(alphaMask);
    }
}

- (void)setRotateEnabled:(BOOL)rotateEnabled
{
    self.rotationRecognizer.enabled = rotateEnabled;
    self.rotationRecognizer.delegate = self;
    [self addGestureRecognizer:self.rotationRecognizer];
}


-(void)setPanEnabled:(BOOL)panEnabled
{
    self.panRecognizer.enabled = panEnabled;
    self.panRecognizer.delegate = self;
    [self addGestureRecognizer:self.panRecognizer];
}

- (void)setScaleEnabled:(BOOL)scaleEnabled
{
    self.pinchRecognizer.enabled = scaleEnabled;
    self.pinchRecognizer.delegate = self;
    [self addGestureRecognizer:self.pinchRecognizer];
}




-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        _rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
        _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        _pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
        self.scale = 1;
    }
    return self;
}

-(void)setText:(NSString *)text
{
    [super setText:text];
    CGSize  size = [text sizeWithFont:self.font constrainedToSize:CGSizeMake(self.superview.frame.size.width*5/6, 480)];
    
     self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,self.superview.frame.size.width*5/6, size.height +30);
//    if(size.height == 27 && size.height == 20)
//    {
//        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,320, size.height +10);
//    }
//    else
//    {
//        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width+10, size.height +10);
//    }
}

#pragma mark Touches

- (void)handleTouches:(NSSet*)touches
{
    self.touchCenter = CGPointZero;
    if(touches.count < 2) return;
    
    [touches enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        NSLog(@"enumerateObjectsUsingBlock");
        UITouch *touch = (UITouch*)obj;
        CGPoint touchLocation = [touch locationInView:self];
        self.touchCenter = CGPointMake(self.touchCenter.x + touchLocation.x, self.touchCenter.y +touchLocation.y);
    }];
    self.touchCenter = CGPointMake(self.touchCenter.x/touches.count, self.touchCenter.y/touches.count);
    NSLog(@"noTBlock");
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self handleTouches:[event allTouches]];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self handleTouches:[event allTouches]];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self handleTouches:[event allTouches]];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self handleTouches:[event allTouches]];
}

- (IBAction)handleRotation:(UIRotationGestureRecognizer*)recognizer
{
    if([self handleGestureState:recognizer.state]) {
        if(recognizer.state == UIGestureRecognizerStateBegan){
            self.rotationCenter = self.touchCenter;
        }
        CGFloat deltaX = self.rotationCenter.x-self.bounds.size.width/2;
        CGFloat deltaY = self.rotationCenter.y-self.bounds.size.height/2;
        
        CGAffineTransform transform =  CGAffineTransformTranslate(self.transform,deltaX,deltaY);
        transform = CGAffineTransformRotate(transform, recognizer.rotation);
        transform = CGAffineTransformTranslate(transform, -deltaX, -deltaY);
        self.transform = transform;
        
        self.rotation = self.rotation + recognizer.rotation;
        
        recognizer.rotation = 0;
    }
}


- (IBAction)handlePan:(UIPanGestureRecognizer*)recognizer
{
    
    if([self handleGestureState:recognizer.state]) {
        CGPoint translation = [recognizer translationInView:self.superview];
        moveTranslation = translation;
        NSLog(@"X:%f Y:%f",translation.x,translation.y);
      //  CGAffineTransform transform = CGAffineTransformTranslate( self.transform, translation.x, translation.y);
        float x = 0;
        float y  = 0;
        float xx = 0;
        float xy = 0;
        float yx = 0;
        float yy = 0;
        

//        if((![self outRightBeside]&& translation.x*cos(self.rotation)+translation.y*sin(self.rotation) >0)
//           ||(![self outLeftBeside]&& translation.x*cos(self.rotation)+translation.y*sin(self.rotation) <0)

//        if((![self outRightBeside]&& translation.x>=0)
//           && (![self outLeftBeside]&& translation.x <=0)
//           )

        if((![self outRightBeside] && ![self outLeftBeside]) &&(![self outTopBeside] && ![self outBottomBeside]))
        {
            [self outLeftBeside];
            
            yx = translation.y*(sin(self.rotation));
            yy = translation.y*(cos(self.rotation));
            xx = translation.x*(cos(self.rotation));
            xy = -translation.x*(sin(self.rotation));
        }
        if((![self outRightBeside] && ![self outLeftBeside]) &&!(![self outTopBeside] && ![self outBottomBeside]))
        {
            [self outLeftBeside];
            
            xx = translation.x*(cos(self.rotation));
            xy = -translation.x*(sin(self.rotation));
        }
        if(!(![self outRightBeside] && ![self outLeftBeside]) &&(![self outTopBeside] && ![self outBottomBeside]))
        {
            [self outLeftBeside];
            
            yx = translation.y*(sin(self.rotation));
            yy = translation.y*(cos(self.rotation));
//            xx = translation.x*(cos(self.rotation));
//            xy = -translation.x*(sin(self.rotation));
        }
        if(!(![self outRightBeside] && ![self outLeftBeside]) &&!(![self outTopBeside] && ![self outBottomBeside]))
        {
            [self outLeftBeside];
            
//            yx = translation.y*(sin(self.rotation));
//            yy = translation.y*(cos(self.rotation));
//            xx = translation.x*(cos(self.rotation));
//            xy = -translation.x*(sin(self.rotation));
        }


        x = xx + yx;
        y = xy + yy;
        
        NSLog(@"xx%f xy:%f yx:%f yy:%f",xx,xy,yx,yy);
        
        NSLog(@"x :%f y:%f w:%f h:%f",self.frame.origin.x,self.frame.origin.y,self.frame.size.width,self.frame.size.height);

        
//        CGAffineTransform transform = CGAffineTransformMakeTranslation((translation.x*cos(self.rotation)+translation.y*sin(self.rotation))/2,(translation.y*cos(self.rotation)-translation.x*sin(self.rotation))/2);
        
        NSLog(@"real x:%f y:%f",x,y);
        
        CGAffineTransform transform = CGAffineTransformMakeTranslation(x/(self.scale),y/(self.scale));
     //   NSLog(@"self.scale:%f",self.scale);
    //      CGAffineTransform transform = CGAffineTransformMakeTranslation(x,y);
        
        transform = CGAffineTransformConcat(transform,self.transform);
        
        self.transform = transform;
        
        [recognizer setTranslation:CGPointMake(0, 0) inView:self.superview];
        
      //  NSLog(@"x:%f y:%f w:%f h:%f",self.frame.origin.x,self.frame.origin.y,self.frame.size.width,self.frame.size.height);
        
    }
}

-(BOOL)outLeftBeside
{
    NSLog(@"outLeftBeside:%d",self.frame.origin.x + self.frame.size.width/2  + moveTranslation.x <= 0 ?YES:NO);
    NSLog(@"self.frame.origin.x:%f",self.frame.origin.x);
    NSLog(@"self.frame.size.width/2:%f",self.frame.size.width/2);
    NSLog(@"moveTranslation.:%f",moveTranslation.y);
     NSLog(@"offset.:%f",self.frame.origin.x + self.frame.size.width/2 +moveTranslation.x);
  //   self.frame.origin.x + self.frame.size.width/2 +moveTranslation.x
NSLog(@"outLeftBeside:%d",self.frame.origin.x + self.frame.size.width/2 +moveTranslation.x <=0?YES:NO);
 //   return self.frame.origin.x + self.frame.size.width/2 +moveTranslation.x <=0;
       return self.frame.origin.x + self.frame.size.width/2 +moveTranslation.x  <=0;
}

-(BOOL)outRightBeside
{
        NSLog(@"outRightBeside:%d",self.frame.origin.x + self.frame.size.width/2  + moveTranslation.x> self.superview.frame.size.width ?YES:NO);
    return self.frame.origin.x + self.frame.size.width/2 + moveTranslation.x>= self.superview.frame.size.width;
}

-(BOOL)outTopBeside
{
    NSLog(@"outTopBeside:%d",self.frame.origin.y + self.frame.size.height/2 +moveTranslation.y <0 ?YES:NO);
    return self.frame.origin.y + self.frame.size.height/2 +moveTranslation.y <=0;
}

-(BOOL)outBottomBeside
{
    NSLog(@"outBottomBeside:%d",self.frame.origin.y + self.frame.size.height/2 +moveTranslation.y  > self.superview.frame.size.height ?YES:NO);    
    return self.frame.origin.y + self.frame.size.height/2  +moveTranslation.y  >= self.superview.frame.size.height;

}




- (BOOL)handleGestureState:(UIGestureRecognizerState)state
{
    BOOL handle = YES;
    switch (state) {
        case UIGestureRecognizerStateBegan:
            self.gestureCount++;
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            self.gestureCount--;
            handle = NO;
            if(self.gestureCount == 0) {
                CGFloat scale = self.scale;
                if(self.minimumScale != 0 && self.scale < self.minimumScale) {
                    scale = self.minimumScale;
                } else if(self.maximumScale != 0 && self.scale > self.maximumScale) {
                    scale = self.maximumScale;
                }
                if(scale != self.scale) {
                    CGFloat deltaX = self.scaleCenter.x-self.bounds.size.width/2.0;
                    CGFloat deltaY = self.scaleCenter.y-self.bounds.size.height/2.0;
                    
                    CGAffineTransform transform =  CGAffineTransformTranslate(self.transform, deltaX, deltaY);
                    transform = CGAffineTransformScale(transform, scale/self.scale , scale/self.scale);
                    transform = CGAffineTransformTranslate(transform, -deltaX, -deltaY);
                    self.superview.userInteractionEnabled = NO;
                    [UIView animateWithDuration:kAnimationIntervalTransform delay:0 options:UIViewAnimationCurveEaseOut animations:^{
                        self.transform = transform;
                    } completion:^(BOOL finished) {
                        self.superview.userInteractionEnabled = YES;
                        self.scale = scale;
                    }];
                    
                }
            }
        } break;
        default:
            break;
    }
    return handle;
}

- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer
{
    if([self handleGestureState:recognizer.state]) {
        if(recognizer.state == UIGestureRecognizerStateBegan){
            self.scaleCenter = self.touchCenter;
        }
        CGFloat deltaX = self.scaleCenter.x-self.bounds.size.width/2.0;
        CGFloat deltaY = self.scaleCenter.y-self.bounds.size.height/2.0;
        
        CGAffineTransform transform =  CGAffineTransformTranslate(self.transform, deltaX, deltaY);
        transform = CGAffineTransformScale(transform, recognizer.scale, recognizer.scale);
        transform = CGAffineTransformTranslate(transform, -deltaX, -deltaY);
        
        NSLog(@"recognizer.scale:%f",recognizer.scale);
        self.scale *= recognizer.scale;
        
        if(0.6< self.scale &&self.scale <10)
        {
            self.transform = transform;
        }
        else
        {
            self.scale /= recognizer.scale;
        }
        
        recognizer.scale = 1;
    }
}

#pragma mark gestureDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
