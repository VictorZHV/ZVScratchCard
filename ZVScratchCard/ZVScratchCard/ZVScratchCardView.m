//
//  ZVScratchCardView.m
//  ZVScratchCard
//
//  Created by victor on 17/1/13.
//  Copyright © 2017年 victor. All rights reserved.
//

#import "ZVScratchCardView.h"
//刮开过的四边形超过此范围才会完全刮开
#define TOP_WIDTH_PERCENT (0.5)
#define TOP_HEIGHT_PERCENT (1.0/6.0)
#define LEFT_WIDTH_PERCENT (2.0/6.0)
#define LEFT_HEIGHT_PERCENT (0.5)
#define BOTTOM_WIDTH_PERCENT (0.5)
#define BOTTOM_HEIGHT_PERCENT (1.0/6.0)
#define RIGHT_WIDTH_PERCENT (2.0/6.0)
#define RIGHT_HEIGHT_PERCENT (0.5)
@interface ZVScratchCardView()
{
    CAShapeLayer *_layers;//初始layer
    
}
@property (nonatomic, assign) CGMutablePathRef path;
@end

@implementation ZVScratchCardView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame surfaceView:(UIView *)surfaceView innerView:(UIView *)innerView{
    self = [super initWithFrame:frame];
    if (self) {
        _surfaceView = surfaceView;
        _innerView = innerView;
    }
    return self;
}
-(void)startDrawing{
    _surfaceView.userInteractionEnabled = YES;
    _surfaceView.frame = self.bounds;
    _innerView.frame = self.bounds;
    _innerView.userInteractionEnabled = YES;
    [self addSubview:_surfaceView];
    [self addSubview:_innerView];
    if (_percent == 0) {
        _percent = 0.5;
    }
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(touchBeganAndMove:)];
    UISwipeGestureRecognizerDirection num[4] = {
        UISwipeGestureRecognizerDirectionRight,
        UISwipeGestureRecognizerDirectionLeft,
        UISwipeGestureRecognizerDirectionUp,
        UISwipeGestureRecognizerDirectionDown
    };
    //创建四个方向的滑动手势
    for (int i = 0; i < 4; i++) {
        //创建一个滑动手势
        UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(touchBeganAndMove:)];
        [_innerView addGestureRecognizer:swipeGesture];
        swipeGesture.direction = num[i];
    }
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchBeganAndMove:)];
    [_innerView addGestureRecognizer:panGesture];
    
    [_innerView addGestureRecognizer:tapGesture];
    
    _layers = [[CAShapeLayer alloc]init];
    _layers = [CAShapeLayer layer];
    _layers.frame = self.bounds;
    _layers.lineCap = kCALineCapRound;
    _layers.lineJoin = kCALineJoinRound;
    _layers.lineWidth = 8.f;
    _layers.strokeColor = [UIColor blueColor].CGColor;
    _layers.fillColor = nil;
    [self.layer addSublayer:_layers];
    self.innerView.layer.mask = _layers;
    self.path = CGPathCreateMutable();
}
-(void)dealloc{
    if (self.path) {
        CGPathRelease(self.path);
    }
}
-(void)touchBeganAndMove:(UIGestureRecognizer *)sender{
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        CGPoint point = [sender locationInView:self];
        CGPathMoveToPoint(self.path, NULL, point.x, point.y);
        CGMutablePathRef path = CGPathCreateMutableCopy(self.path);
        _layers.path = path;
        CGPathRelease(path);
    }else if (sender.state == UIGestureRecognizerStateChanged){
        CGPoint point = [sender locationInView:self];
        CGPathAddLineToPoint(self.path, NULL, point.x, point.y);
        CGMutablePathRef path = CGPathCreateMutableCopy(self.path);
        _layers.path = path;
        CGPathRelease(path);
    }else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled){
        [self checkScratchWithPath:self.path];
    }
}
//重置刮刮卡
-(void)resetScratch{
    self.path = CGPathCreateMutable();
    //移除已经刷过的layer
    _layers.path = nil;
    //设置为初始状态
    _innerView.layer.mask = _layers;
}
//打开
-(void)openScratch{
    _innerView.layer.mask = nil;
}
//根据路径检查是否可以全部刮开
- (void)checkScratchWithPath:(CGPathRef)path
{
    CGRect rect = CGPathGetPathBoundingBox(path);
    
    NSArray *pointsArray = [self getPointsArray];
    for (NSValue *value in pointsArray) {
        CGPoint point = [value CGPointValue];
        if (!CGRectContainsPoint(rect, point)) {
            return;
        }
    }
    NSLog(@"完成");
    [self openScratch];
}

- (NSArray *)getPointsArray
{
    NSMutableArray *array = [NSMutableArray array];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGPoint topPoint = CGPointMake(width/2, height/6);
    CGPoint leftPoint = CGPointMake(width/6*2, height/2);
    CGPoint bottomPoint = CGPointMake(width/2, height-height/6);
    CGPoint rightPoint = CGPointMake(width-width/6*2, height/2);
    
    [array addObject:[NSValue valueWithCGPoint:topPoint]];
    [array addObject:[NSValue valueWithCGPoint:leftPoint]];
    [array addObject:[NSValue valueWithCGPoint:bottomPoint]];
    [array addObject:[NSValue valueWithCGPoint:rightPoint]];
    
    return array;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
