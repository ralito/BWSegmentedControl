//
//  BWSegmentedControl
//
//  BWSegment.m
//
//  Created by Mendy Krinsky on 6/2/15.
//  Copyright (c) 2015 Mendy Krinsky. All rights reserved.
//
//  Licensed under the MIT license.

#import "BWSegment.h"

@interface BWSegment ()

@end

@implementation BWSegment

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont fontWithName:@"helvetica" size:13.0];
        self.imageHeight = 20;
        [self addSubview:self.imageView];
        [self addSubview:self.titleLabel];
        
//        self.backgroundColor = [UIColor blackColor]
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    self.imageView.frame = CGRectMake((CGRectGetWidth(bounds) - self.imageHeight)/2,
                                      CGRectGetMinY(bounds),
                                      self.imageHeight,
                                      self.imageHeight);
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.titleLabel sizeToFit];
    self.titleLabel.center = CGPointMake(self.imageView.center.x, CGRectGetHeight(bounds) - CGRectGetHeight(self.titleLabel.frame));
}

- (CGSize)sizeThatFits:(CGSize)size{
    CGSize imageSize = [self.imageView sizeThatFits:size];
    CGSize labelSize = [self.titleLabel sizeThatFits:size];
    return CGSizeMake(imageSize.width, imageSize.height - labelSize.height);
}

@end
