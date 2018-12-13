//
//  ZVScratchCardView.m
//  ZVScratchCard
//
//  Created by victor on 17/1/13.
//  Copyright © 2017年 victor. All rights reserved.
//

#import "ZVScratchCardView.h"
//刮开过的四边形的rect包含此这四个点才会完全刮开
#define TOP_X_PERCENT (0.5)
#define TOP_Y_PERCENT (1.0/6.0)
#define LEFT_X_PERCENT (2.0/6.0)
#define LEFT_Y_PERCENT (0.5)
#define BOTTOM_X_PERCENT (0.5)
#define BOTTOM_Y_PERCENT (5.0/6.0)
#define RIGHT_X_PERCENT (4.0/6.0)
#define RIGHT_Y_PERCENT (0.5)
//画笔宽度
#define LINE_WIDTH 18.f
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
-(void)setInnerView:(UIView *)innerView{
    _innerView = innerView;
    _innerView.frame = self.bounds;
    _innerView.userInteractionEnabled = YES;
    [self addSubview:_innerView];
    _layers = [CAShapeLayer layer];
    _layers.frame = self.bounds;
    _layers.lineCap = kCALineCapRound;
    _layers.lineJoin = kCALineJoinRound;
    _layers.lineWidth = LINE_WIDTH;
    _layers.strokeColor = [UIColor blueColor].CGColor;
    _layers.fillColor = nil;
    self.innerView.layer.mask = _layers;
    self.path = CGPathCreateMutable();
}
-(void)setSurfaceView:(UIView *)surfaceView{
    _surfaceView = surfaceView;
    _surfaceView.userInteractionEnabled = YES;
    _surfaceView.frame = self.bounds;
    [self addSubview:_surfaceView];
}
-(CGFloat)percent{
    if (_percent == 0) {
        _percent = 0.5;
    }
    return _percent;
}
-(void)dealloc{
    if (self.path) {
        CGPathRelease(self.path);
    }
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint point = [[touches anyObject] locationInView:self];
    CGPathMoveToPoint(self.path, NULL, point.x, point.y);
}
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint point = [[touches anyObject] locationInView:self];
    CGPathAddLineToPoint(self.path, NULL, point.x, point.y);
    CGMutablePathRef path = CGPathCreateMutableCopy(self.path);
    _layers.path = path;
    CGPathRelease(path);
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self checkScratchState];
}
-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self checkScratchState];
}
//MARK:刮刮卡各种方法处理
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
//检查是否刮开
- (void)checkScratchState{
    if (self.scratchLogicType == ScratchLogicTypeFourPoint) {
        [self checkScratchWithPath:self.path];
    }else{
        CGFloat scratchPercent = 1 - [self getAlphaPercentWithView:_innerView];
        if (scratchPercent >= self.percent) {
            [self openScratch];
        }
    }
}
//MARK:方案一：根据四点包含检查是否可以全部刮开
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
    
    CGPoint topPoint = CGPointMake(width*TOP_X_PERCENT, height*TOP_Y_PERCENT);
    CGPoint leftPoint = CGPointMake(width*LEFT_X_PERCENT, height*LEFT_Y_PERCENT);
    CGPoint bottomPoint = CGPointMake(width*BOTTOM_X_PERCENT, height*BOTTOM_Y_PERCENT);
    CGPoint rightPoint = CGPointMake(width*RIGHT_X_PERCENT, height*RIGHT_Y_PERCENT);
    
    [array addObject:[NSValue valueWithCGPoint:topPoint]];
    [array addObject:[NSValue valueWithCGPoint:leftPoint]];
    [array addObject:[NSValue valueWithCGPoint:bottomPoint]];
    [array addObject:[NSValue valueWithCGPoint:rightPoint]];
    
    return array;
}

//MARK:方案二：根据刮掉面积计算

//获取透明像素占总像素的百分比
- (CGFloat)getAlphaPercentWithView:(UIView *)view {
    UIImage *image = [self makeImageWithView:view];
    //计算像素总个数
    NSInteger width = (NSInteger)image.size.width;
    NSInteger height = (NSInteger)image.size.height;
    NSInteger bitmapByteCount = width * height;
    
    int bitmapInfo = kCGImageAlphaOnly;
    //得到所有像素数据
    GLubyte*pixelData = (GLubyte*)malloc(bitmapByteCount);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(pixelData, width, height, 8, width, colorSpace, bitmapInfo);
    CGRect rect = CGRectMake(0, 0, width, height);
    CGContextClearRect(context, rect);
    CGContextDrawImage(context, rect, image.CGImage);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    //计算透明像素个数
    NSInteger alphaPixelCount = 0;
    for (int i = 0; i < width; i ++) {
        for (int j = 0; j < height; j ++) {
            if (pixelData[j * width + i] == 0) {
                alphaPixelCount += 1;
            }
        }
    }
    free(pixelData);
    NSLog(@"%f",floor(alphaPixelCount) / floor(bitmapByteCount));
    return floor(alphaPixelCount) / floor(bitmapByteCount);//Float(alphaPixelCount) / Float(bitmapByteCount);
}
//将view转换为UIImage
- (UIImage *)makeImageWithView:(UIView *)view

{
    CGSize s = view.bounds.size;
    
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了，关键就是第三个参数。
    
    UIGraphicsBeginImageContextWithOptions(s, NO, [UIScreen mainScreen].scale);
    
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
