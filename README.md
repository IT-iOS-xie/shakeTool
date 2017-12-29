# shakeTool
掘金地址：https://juejin.im/post/5a45f8b7f265da430c122409
**闲来无事，分享一个妹子使用利器，`shakeTool`感觉污污的，记得在大学时候用安卓手机的时候见过类似的app，简单写了一个demo，喜欢的朋友欢迎分享转发。**
我们先来看一下效果图

![](https://user-gold-cdn.xitu.io/2017/12/29/160a156d7a991796?w=375&h=663&f=png&s=22746)

功能很简单，分为三种：


* 1.体验单次：故名思议，就是体验一下震动的赶脚


* 2.持续：不停的震动，哈哈


* 3.关闭：停止振动棒工作


下边的滑块是自己写的`slider`，估计是系统的`slider`太丑，而且滑动不灵敏。
demo已经上传到github，可以下载安装，记得真机运行 
[https://github.com/IT-iOS-xie/shakeTool.git]()

接下来简单说一下实现思路：
1.震动来源，导入`AudioToolbox`库

```
#import <AudioToolbox/AudioToolbox.h>
```
这里我们使用的类均来自于`AudioServices`的方法

2.如果你喜欢特变的震动背景乐，可以通过下边实现
  
```
 NSString *path = [[NSBundle mainBundle] pathForResource:@"1669" ofType:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &sound);
    AudioServicesAddSystemSoundCompletion(sound, NULL, NULL, soundCompleteCallback, NULL);
    AudioServicesPlaySystemSound(sound);
```
3.实现震动效果

```
  AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
```
这里`kSystemSoundID_Vibrate`即`service`中的震动效果

4.因为要实现持续震动，所以需要创建全局的` NSTimer`来控制开始，暂停。

```
_vibrationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(playkSystemSound) userInfo:nil repeats:YES];
```
5.实例的时候需要暂停定时器的运转
```
[_vibrationTimer setFireDate:[NSDate distantFuture]];
```
在恰当的实际可以重新开启震动效果

```
 [_vibrationTimer setFireDate:[NSDate distantPast]];
```
6.滑动滑块的时候我们要控制震动的节奏
添加一个`UIImageView`和一个`Button`，按钮添加滑动手势

```
 UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(progreeChanged:)];
    
[self.progressBtn addGestureRecognizer:pan];
```
7.实现滑动过程中调整滑块位置，并调整震动节奏

```
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
        
        value = value< 0.1 ? 2 : value;
        
        _vibrationTimer = [NSTimer scheduledTimerWithTimeInterval:1/(value *5)  target:self selector:@selector(playkSystemSound) userInfo:nil repeats:YES];
    }
   
    
}
```
8.单次体验
简单的加了一个延时操作，用于销毁定时器

```
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_vibrationTimer setFireDate:[NSDate distantFuture]];
        
    });
```



**大功告成**


demo下载

[https://github.com/IT-iOS-xie/shakeTool.git]()
