//
//  FCViewController.m
//  FCLivelyButton
//
//  Created by 付晨曦 on 2017/7/10.
//  Copyright © 2017年 付晨曦. All rights reserved.
//

#import "FCViewController.h"
#import "FCLivelyButton.h"

@interface FCViewController ()

@property (weak, nonatomic) IBOutlet FCLivelyButton *hamburgerBtn;
@property (weak, nonatomic) IBOutlet FCLivelyButton *closeBtn;
@property (weak, nonatomic) IBOutlet FCLivelyButton *circleCloseBtn;
@property (weak, nonatomic) IBOutlet FCLivelyButton *plusBtn;
@property (weak, nonatomic) IBOutlet FCLivelyButton *circlePlusBtn;
@property (weak, nonatomic) IBOutlet FCLivelyButton *caretUpBtn;
@property (weak, nonatomic) IBOutlet FCLivelyButton *careDownBtn;
@property (weak, nonatomic) IBOutlet FCLivelyButton *caretLeftBtn;
@property (weak, nonatomic) IBOutlet FCLivelyButton *caretRightBtn;
@property (weak, nonatomic) IBOutlet FCLivelyButton *arrowLeftBtn;
@property (weak, nonatomic) IBOutlet FCLivelyButton *arrowRightBtn;

@property (weak, nonatomic) IBOutlet FCLivelyButton *changeBtn;
@end

@implementation FCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"LivelyButton";
    [self.hamburgerBtn setStyle:FCLivelyButtonStyleHamburger animated:NO];
    [self.closeBtn setStyle:FCLivelyButtonStyleClose animated:NO];
    [self.circleCloseBtn setStyle:FCLivelyButtonStyleCircleClose animated:NO];
    [self.plusBtn setStyle:FCLivelyButtonStylePlus animated:NO];
    [self.circlePlusBtn setStyle:FCLivelyButtonStyleCirclePlus animated:NO];
    [self.caretUpBtn setStyle:FCLivelyButtonStyleCaretUp animated:NO];
    [self.careDownBtn setStyle:FCLivelyButtonStyleCaretDown animated:NO];
    [self.caretLeftBtn setStyle:FCLivelyButtonStyleCaretLeft animated:NO];
    [self.caretRightBtn setStyle:FCLivelyButtonStyleCaretRight animated:NO];
    [self.arrowLeftBtn setStyle:FCLivelyButtonStyleArrowLeft animated:NO];
    [self.arrowRightBtn setStyle:FCLivelyButtonStyleArrowRight animated:NO];
    
    
    [self.changeBtn setStyle:FCLivelyButtonStyleHamburger animated:NO];
    [self.changeBtn setOptions:@{FCLivelyButtonLineWidth : @(3)}];
    
    FCLivelyButton *rightBtn = [[FCLivelyButton alloc] initWithFrame:CGRectMake(0, 0, 38, 38)];
    rightBtn.contentEdgeInsets = UIEdgeInsetsMake(5, 2, 5, 2);
    [rightBtn setStyle:FCLivelyButtonStylePlus animated:YES];
    [rightBtn addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
}

- (IBAction)changeButtonStyle:(FCLivelyButton *)sender {
    
    [self.changeBtn setStyle:sender.buttonStyle animated:YES];
}



- (IBAction)buttonEvent:(FCLivelyButton *)sender {
    
    FCLivelyButtonStyle style = (sender.buttonStyle + 1) % 11;
    [sender setStyle:style animated:YES];
}

@end
