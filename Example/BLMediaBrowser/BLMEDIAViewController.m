//
//  BLMEDIAViewController.m
//  BLMediaBrowser
//
//  Created by wolf_childer@163.com on 05/28/2020.
//  Copyright (c) 2020 wolf_childer@163.com. All rights reserved.
//

#import "BLMEDIAViewController.h"
#import "BLWebImageCollectionViewVC.h"
#import "BLLocalImageCollectionViewVC.h"
#import "BLLocalImageVC.h"
#import "BLStyleVC.h"

@interface BLMEDIAViewController ()

@end

@implementation BLMEDIAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.view setBackgroundColor:[UIColor redColor]];
    
    UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 44)];
    [btn1 setTitle:@"collection" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(collectionViewClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake(100, 200, 100, 44)];
    [btn2 setTitle:@"local" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(localBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    
    UIButton *btn3 = [[UIButton alloc] initWithFrame:CGRectMake(100, 300, 100, 44)];
    [btn3 setTitle:@"style" forState:UIControlStateNormal];
    [btn3 addTarget:self action:@selector(styleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn3];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)collectionViewClick:(id)sender {
    BLLocalImageCollectionViewVC *lcv = [[BLLocalImageCollectionViewVC alloc]init];
    [self.navigationController pushViewController:lcv animated:YES];
}

- (void)localBtnClick:(id)sender {
    BLLocalImageVC *lvc = [[BLLocalImageVC alloc]init];
    [self.navigationController pushViewController:lvc animated:YES];
}

- (void)styleBtnClick:(id)sender {
    BLStyleVC *svc = [[BLStyleVC alloc]init];
    [self.navigationController pushViewController:svc animated:YES];
}

@end
