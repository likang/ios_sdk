//
//  ViewController.m
//  AdjustTestApp
//
//  Created by Pedro on 23.08.17.
//  Copyright © 2017 adjust. All rights reserved.
//

#import "ViewController.h"
#import "Adjust.h"
#import "ATLTestLibrary.h"
#import "ATAAdjustCommandExecutor.h"
#import "ADJAdjustFactory.h"

@interface ViewController ()
@property (nonatomic, strong) ATLTestLibrary * testLibrary;
@property (nonatomic, strong) ATAAdjustCommandExecutor * adjustCommandExecutor;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.adjustCommandExecutor = [[ATAAdjustCommandExecutor alloc] init];
    NSString * baseUrl = @"http://127.0.0.1:8080";
    [ADJAdjustFactory setTestingMode:baseUrl];

    self.testLibrary = [ATLTestLibrary testLibraryWithBaseUrl:baseUrl andCommandDelegate:self.adjustCommandExecutor];
    //[self.testLibrary setTests:@"current/Test_example"];
    [self startTestSession];
}

- (void)startTestSession {
    [self.testLibrary startTestSession:@"ios4.12.0"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)restartTestClick:(UIButton *)sender {
    [self startTestSession];
}


@end
