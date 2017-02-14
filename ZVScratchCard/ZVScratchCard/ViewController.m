//
//  ViewController.m
//  ZVScratchCard
//
//  Created by victor on 17/1/13.
//  Copyright © 2017年 victor. All rights reserved.
//

#import "ViewController.h"
#import "ZVScratchCardView.h"
@interface ViewController ()
{
    ZVScratchCardView *v;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    v = [[ZVScratchCardView alloc]initWithFrame:CGRectMake(100, 100, 200, 300)];
    v.surfaceView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"test1.jpg"]];
    v.innerView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"test2.jpg"]];
    [v startDrawing];
    [self.view addSubview:v];
    UIButton *btn  = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(10, 300, 100, 50);
    [self.view addSubview:btn];
    [btn setTitle:@"重置" forState:UIControlStateNormal];
    
    UIButton *btn2  = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn2 addTarget:self action:@selector(btn2Click) forControlEvents:UIControlEventTouchUpInside];
    btn2.frame = CGRectMake(10, 400, 100, 50);
    [self.view addSubview:btn2];
    [btn2 setTitle:@"刮开" forState:UIControlStateNormal];
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)btnClick{
    [v resetScratch];
}
-(void)btn2Click{
    [v openScratch];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
