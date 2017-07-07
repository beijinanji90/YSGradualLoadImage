//
//  ViewController.m
//  YSGradualLoadImage
//
//  Created by chenfenglong on 2017/7/7.
//  Copyright © 2017年 chenfenglong. All rights reserved.
//

#import "ViewController.h"
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>

@interface ViewController ()
{
    CGImageSourceRef _incrementallyImgSource;
    NSTimer *_timer;
    NSData *_imageData;
    NSInteger _allFillLength;
    NSInteger _startLocation;
    NSInteger _spacing;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)dealloc
{
    _timer = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //初始化ImageView
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.backgroundColor = [UIColor grayColor];
    
    //初始化一个CGImageSource
    _incrementallyImgSource = CGImageSourceCreateIncremental(NULL);
    
    //加载一个一个本地图片
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"largeImage" ofType:@"jpg"];
    
    //用“NSDataReadingMappedIfSafe”，这个把文件映射到虚拟内存中，并不会全部加载内存中
    _imageData = [NSData dataWithContentsOfFile:imagePath options:NSDataReadingMappedIfSafe error:nil];
    
    //初始化一个“定时器”
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(updateImage) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    
    //初始化一个
    _allFillLength = _imageData.length;
    _startLocation = 0;
    _spacing = (NSInteger)(_allFillLength * 0.1);
}

- (void)updateImage
{
    BOOL isFinished = NO;
    if ((_startLocation + _spacing) > _allFillLength)
    {
        _spacing = _allFillLength - _startLocation;
        isFinished = YES;
        [_timer invalidate];
    }
    else
    {
        _startLocation = _startLocation + _spacing;
    }
    
    NSData *piceData = [_imageData subdataWithRange:NSMakeRange(0, _startLocation)];
    
    CGImageSourceUpdateData(_incrementallyImgSource, (CFDataRef)piceData, isFinished);
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(_incrementallyImgSource, 0, NULL);
    self.imageView.image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
}


@end
