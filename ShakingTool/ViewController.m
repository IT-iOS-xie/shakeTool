//
//  ViewController.m
//  ShakingTool
//
//  Created by xie on 2017/12/28.
//  Copyright © 2017年 abadou. All rights reserved.
//

#import "ViewController.h"

#import <AudioToolbox/AudioToolbox.h>
@interface ViewController ()
{
    SystemSoundID sound;
}

@property (weak, nonatomic) IBOutlet UIButton *testBtn;
@property (weak, nonatomic) IBOutlet UIButton *goonBtn;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
//振动计时器
@property (weak, nonatomic) IBOutlet UIButton *progressBtn;
@property (weak, nonatomic) IBOutlet UIImageView *backImage;
@property (nonatomic,strong)NSTimer *_vibrationTimer;
@end

@implementation ViewController


@synthesize _vibrationTimer;

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"1669" ofType:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &sound);
    AudioServicesAddSystemSoundCompletion(sound, NULL, NULL, soundCompleteCallback, NULL);
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    AudioServicesPlaySystemSound(sound);
    
    
    /**
     初始化计时器  每一秒振动一次
     
     @param playkSystemSound 振动方法
     @return
     */
    _vibrationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(playkSystemSound) userInfo:nil repeats:YES];
    [_vibrationTimer setFireDate:[NSDate distantFuture]];
    
    
    self.testBtn.layer.cornerRadius = 40;
    self.testBtn.layer.masksToBounds = YES;
    self.goonBtn.layer.cornerRadius = 40;
    self.goonBtn.layer.masksToBounds = YES;
    self.closeBtn.layer.cornerRadius = 40;
    self.closeBtn.layer.masksToBounds = YES;
   
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(progreeChanged:)];
    
    [self.progressBtn addGestureRecognizer:pan];

    self.progressBtn.layer.cornerRadius =10;
    self.progressBtn.layer.masksToBounds = YES;
    
    self.backImage.layer.cornerRadius = 4;
    self.backImage.layer.masksToBounds = YES;
    
}


-(void)progreeChanged:(UIPanGestureRecognizer *)recognizer{
    // Figure out where the user is trying to drag the view.
    
    CGPoint translation = [recognizer translationInView:self.view];
    
   
        

    CGPoint newCenter = CGPointMake(recognizer.view.center.x+ translation.x,
                                    recognizer.view.center.y);//    限制屏幕范围：
    newCenter.y = MAX(recognizer.view.frame.size.height/2, newCenter.y);
    newCenter.y = MIN(self.view.frame.size.height - recognizer.view.frame.size.height/2,  newCenter.y);
    newCenter.x = MAX(recognizer.view.frame.size.width/2, newCenter.x);
    newCenter.x = MIN(self.view.frame.size.width - recognizer.view.frame.size.width/2,newCenter.x);
    
    if (newCenter.x> self.backImage.frame.origin.x + recognizer.view.frame.size.width/2 && newCenter.x<self.backImage.frame.origin.x -recognizer.view.frame.size.width/2 + self.backImage.frame.size.width) {
        recognizer.view.center = newCenter;
        [recognizer setTranslation:CGPointZero inView:self.view];
        
        
        float value =  (newCenter.x - self.backImage.frame.origin.x-recognizer.view.frame.size.width/2)/ (self.backImage.frame.size.width-recognizer.view.frame.size.width) ;
        NSLog(@"%.2f",value);
        [_vibrationTimer invalidate];
        
        AudioServicesRemoveSystemSoundCompletion(sound);
        AudioServicesDisposeSystemSoundID(sound);
        
        value = value<0.1 ? 2 : value;
        
        _vibrationTimer = [NSTimer scheduledTimerWithTimeInterval:1/(value *5)  target:self selector:@selector(playkSystemSound) userInfo:nil repeats:YES];
    }
   
    
}
- (IBAction)testBtnSound:(id)sender {
    [_vibrationTimer setFireDate:[NSDate distantPast]];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_vibrationTimer setFireDate:[NSDate distantFuture]];
        
    });
    
}
//开始响铃及振动
-(IBAction)startShakeSound:(id)sender{
    [_vibrationTimer setFireDate:[NSDate distantPast]];
   
}
//振动
- (void)playkSystemSound{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}
//停止响铃及振动
-(IBAction)stopShakeSound:(id)sender{
    
//    [_vibrationTimer invalidate];
    [_vibrationTimer setFireDate:[NSDate distantFuture]];
//    AudioServicesRemoveSystemSoundCompletion(sound);
//    AudioServicesDisposeSystemSoundID(sound);
    
}
//响铃回调方法
void soundCompleteCallback(SystemSoundID sound,void * clientData) {
    AudioServicesPlaySystemSound(sound);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(UIImage*) createImageWithColor:(UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
