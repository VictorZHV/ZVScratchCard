//
//  ZVScratchCardView.h
//  ZVScratchCard
//
//  Created by victor on 17/1/13.
//  Copyright © 2017年 victor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZVScratchCardView;
@protocol ZVScratchCardViewDelegate  <NSObject>
//刮开
-(void)ZVScratchCardView:(ZVScratchCardView *)scratchCardView didScratchedWithPercent:(CGFloat)percent;
@end

@interface ZVScratchCardView : UIView
@property (nonatomic,strong)UIView *innerView;
@property (nonatomic,strong)UIView *surfaceView;
@property (nonatomic,assign)CGFloat percent;//(0~1)刮到多少则全部刮开
-(instancetype)initWithFrame:(CGRect)frame surfaceView:(UIView *)surfaceView innerView:(UIView *)innerView;
//开始绘制
-(void)startDrawing;
//重置
-(void)resetScratch;
//刮开
-(void)openScratch;
@end
