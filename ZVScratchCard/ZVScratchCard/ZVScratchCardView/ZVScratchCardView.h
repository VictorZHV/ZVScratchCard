//
//  ZVScratchCardView.h
//  ZVScratchCard
//
//  Created by victor on 17/1/13.
//  Copyright © 2017年 victor. All rights reserved.
//

#import <UIKit/UIKit.h>

//提供两种刮开方式逻辑：1.ScratchLogicTypeFourPoint 四点逻辑，刮开的线条的方形范围，只有全部包含预先设定的四个点才算刮开
//2.ScratchLogicTypePercent面积逻辑 刮开面积大于总面积的某个设定值就算刮开
typedef NS_ENUM(NSUInteger, ScratchLogicType) {
    ScratchLogicTypePercent,//Default
    ScratchLogicTypeFourPoint
};

@class ZVScratchCardView;
@protocol ZVScratchCardViewDelegate  <NSObject>
//刮开回调
-(void)ZVScratchCardView:(ZVScratchCardView *)scratchCardView didScratchedWithPercent:(CGFloat)percent;
@end

@interface ZVScratchCardView : UIView
//刮开显示
@property (nonatomic,strong)UIView *innerView;
//刮刮卡表面
@property (nonatomic,strong)UIView *surfaceView;
@property (nonatomic,assign)ScratchLogicType scratchLogicType;
@property (nonatomic,assign)CGFloat percent;//(0~1)刮到多少则全部刮开
-(instancetype)initWithFrame:(CGRect)frame surfaceView:(UIView *)surfaceView innerView:(UIView *)innerView;
//重置
-(void)resetScratch;
//刮开
-(void)openScratch;
@end
