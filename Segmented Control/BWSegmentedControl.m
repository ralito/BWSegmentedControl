//
//  BWSegmentedControl
//
//  BWSegmentedControl.m
//
//  Created by Mendy Krinsky on 6/2/15.
//  Copyright (c) 2015 Mendy Krinsky. All rights reserved.
//
//  Licensed under the MIT license.

#pragma mark - Imports

#import "BWSegmentedControl.h"
#import "BWSegment.h"

@interface BWSegmentedControl()

@property (nonatomic, strong) UIImageView *selectedItemIndicator;
@property (nonatomic, readwrite) NSUInteger selectedItemIndex;
@property (nonatomic, readonly) CGFloat itemWidth;
@property (nonatomic, readonly) CGFloat upperViewHeight;
@property (nonatomic) CGRect  topRect;
@property (nonatomic) CGFloat selectedItemIndicatorCornerRadius;
@property (nonatomic) CGFloat topRectCornerRadius;
@property (nonatomic) CGFloat interItemSpacing;

@end

@implementation BWSegmentedControl

- (instancetype)initWithItems:(NSArray *)items
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.topColor = [UIColor whiteColor];

        self.selectedItemIndicator = [UIImageView new];
        self.selectedItemIndicatorColor = [UIColor blueColor];

        self.selectedItemIndicator.clipsToBounds = YES;
        self.interItemSpacing = 30;
        self.animationDuration = 0.5;
        self.isSegmentDeselectionEnabled = YES;
        
        self.items = items;
        [self addSubview:self.selectedItemIndicator];
        
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
        [panGestureRecognizer setMinimumNumberOfTouches:1];
        [panGestureRecognizer setMaximumNumberOfTouches:1];
        [self.selectedItemIndicator addGestureRecognizer:panGestureRecognizer];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}

- (instancetype) initWithImages:(NSArray *)images titles:(NSArray *)titles
{
    NSArray *segments = [self createSegmentsWithImages: images titles: titles];
    self = [self initWithItems:segments];
    return self;
}

+ (instancetype)segmentedControlWithImages: (NSArray *)images titles: (NSArray *)titles
{
    return [[self alloc]initWithImages:images titles:titles];
}

///images and titles array must have same number of objects
- (NSArray *)createSegmentsWithImages: (NSArray *)images titles: (NSArray *)titles
{
    NSAssert([images count] == [titles count], @"The images and titles arrays must have the same number of objects");
    
    NSMutableArray *allSegments = [NSMutableArray array];
    
    for (NSInteger index = 0; index < [images count]; index++) {
        BWSegment *segment = [BWSegment new];
        segment.imageView.image = images[index];
        segment.titleLabel.text = titles[index];
        [allSegments addObject:segment];
    }
    return allSegments;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    for (NSInteger i = 0; i < [self.items count]; i++) {
        UIControl *item = self.items[i];
        item.frame = [self frameForItemAtIndex:i];
    }
    
    self.selectedItemIndicator.center = [self centerForIndicatorAtIndex:self.selectedItemIndex];
    
    [self setSelectedItemIndex:self.selectedItemIndex animated:NO moveIndicator:NO];
}

- (CGRect)frameForItemAtIndex:(NSUInteger)index
{
    NSUInteger totalItemCount = [self.items count];
    CGFloat interItemSpacing = (self.bounds.size.width - (self.itemWidth*totalItemCount)) / ((CGFloat)totalItemCount-1.f);
    self.interItemSpacing = interItemSpacing;
    
    CGFloat startX = (self.itemWidth + interItemSpacing) * index;
    return CGRectMake(startX,
                      CGRectGetMinY(self.bounds),
                      self.itemWidth,
                      CGRectGetHeight(self.bounds));
}

- (CGPoint)centerForIndicatorAtIndex: (NSUInteger)index
{
    
    if (!self.isSegmentSelected) {
        return CGPointZero;
    }
    
    CGRect itemRect = [self frameForItemAtIndex:index];
    CGFloat itemCenterX = itemRect.origin.x + [self itemWidth]/2;
    
    return CGPointMake(itemCenterX,
                      CGRectGetHeight(self.topRect)/2);
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGFloat segmentWidth = [[self.items firstObject]sizeThatFits:size].width;
    self.selectedItemIndicator.center = [self centerForIndicatorAtIndex:self.selectedItemIndex];
    
    return CGSizeMake(segmentWidth * [self.items count] + self.interItemSpacing, 47);
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *topPath = [UIBezierPath bezierPathWithRoundedRect:self.topRect cornerRadius:self.topRectCornerRadius];
    [self.topColor setFill];
    [topPath fill];
}

#pragma mark - Segment indicator

- (void)tapGestureRecognized: (UITapGestureRecognizer *)tapGestureRecognizer
{
    
    self.isSegmentSelected = true;
    
    CGPoint location = [tapGestureRecognizer locationInView:self];
    
    for (BWSegment *item in self.items) {
        
        if (CGRectContainsPoint(item.frame, location)) {
            
            NSUInteger selectedItemIndex = [self.items indexOfObject:item];

            if (selectedItemIndex != self.selectedItemIndex) {
                [self setSelectedItemIndex:selectedItemIndex animated:YES];
                [self sendActionsForControlEvents:UIControlEventValueChanged];
            } else if (self.isSegmentDeselectionEnabled) {
                [self deselectSelectedItemAnimated:true];
                [self sendActionsForControlEvents:UIControlEventValueChanged];
            }
        }
    }
}

- (void)panGestureRecognized:(UIPanGestureRecognizer *)panGestureRecognizer
{
    self.isSegmentSelected = true;
    
    CGPoint translation = [panGestureRecognizer translationInView:panGestureRecognizer.view.superview];
    
    // Find the difference in horizontal position between the current and previous touches
    CGFloat xDiff = translation.x;
    
    self.selectedItemIndicator.center = CGPointMake(self.selectedItemIndicator.center.x + xDiff, self.selectedItemIndicator.center.y);
    
    [panGestureRecognizer setTranslation:CGPointMake(0, 0) inView:panGestureRecognizer.view.superview];
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        for (NSUInteger index = 0; index < [self.items count]; index++) {
            
            BWSegment *item = self.items[index];
            
            if (CGRectContainsPoint(item.frame, self.selectedItemIndicator.center)) {
                if (index != self.selectedItemIndex) {
                    self.selectedItemIndex = index;
                    [self sendActionsForControlEvents:UIControlEventValueChanged];
                }
                [self moveSelectedSegmentIndicatorToSegmentAtIndex:self.selectedItemIndex animated:YES];
                return;
            }
        }
        
        if (self.selectedItemIndicator.center.x > self.bounds.size.width) {
            self.selectedItemIndex = (self.items.count - 1);
            [self sendActionsForControlEvents:UIControlEventValueChanged];
            [self moveSelectedSegmentIndicatorToSegmentAtIndex:self.selectedItemIndex animated:YES];
        } else if (self.selectedItemIndicator.center.x < 0) {
            self.selectedItemIndex = 0;
            [self sendActionsForControlEvents:UIControlEventValueChanged];
            [self moveSelectedSegmentIndicatorToSegmentAtIndex:self.selectedItemIndex animated:YES];
        }
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    [super hitTest:point withEvent:event];
    if (CGRectContainsPoint(self.selectedItemIndicator.frame, point)) {
        return self.selectedItemIndicator;
    }
    return self;
}

- (void)moveSelectedSegmentIndicatorToSegmentAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    __weak typeof(self)weakSelf = self;
    
    void (^animationsBlock)(void) = ^{
        weakSelf.selectedItemIndicator.alpha = weakSelf.isSegmentSelected ? 1 : 0;
        weakSelf.selectedItemIndicator.center = [weakSelf centerForIndicatorAtIndex:index];
        };
 
    if (!animated) {
        animationsBlock();
        return;
    }
    
    CGFloat horizontalMovement = fabs(weakSelf.selectedItemIndicator.center.x) - fabs([weakSelf centerForIndicatorAtIndex:index].x);
    NSTimeInterval duration = self.animationDuration/CGRectGetWidth(self.bounds);
    
    [UIView animateWithDuration:fabs(duration*horizontalMovement) delay:0 options:UIViewAnimationOptionCurveEaseOut animations:animationsBlock completion:nil];
}

#pragma mark - Properties

- (CGFloat)itemWidth
{
    return CGRectGetWidth(self.frame) / [self.items count];
}

- (void)setItems:(NSArray *)items{

    for( UIControl *control in _items ) {
        [control removeFromSuperview];
    }
    _items = items;
    
    if ([_items count] == 0) {
        return;
    }
    
    for (UIControl *control in _items) {
        [self addSubview:control];
    }
}

#pragma mark Top Rect

- (CGRect)topRect
{
    if (CGRectEqualToRect(_topRect, CGRectZero)) {
        BWSegment *firstSegment = [self.items firstObject];
        
        _topRect = CGRectZero;
        _topRect.origin.y = CGRectGetMinY(self.bounds);
        _topRect.origin.x = firstSegment.titleLabel.frame.origin.x;
        _topRect.size.height = self.upperViewHeight;
        _topRect.size.width = CGRectGetWidth(self.bounds) - _topRect.origin.x * 2;
    }
    return _topRect;
}

- (CGFloat)topRectCornerRadius
{
    return CGRectGetHeight(self.bounds)/2;
}

- (void)setTopColor:(UIColor *)topColor
{
    _topColor = topColor;
    [self setNeedsDisplay];
}

- (CGFloat)upperViewHeight{
    BWSegment *item = [self.items firstObject];
    return item.imageHeight;
}

#pragma mark selectedItemIndicator

- (CGFloat)selectedItemIndicatorCornerRadius{
    return self.selectedItemIndicator.frame.size.width/2;
}

///Public
- (void)setSelectedItemIndex:(NSUInteger)selectedItemIndex animated: (BOOL) animated{
    [self setSelectedItemIndex:selectedItemIndex animated:animated moveIndicator:YES];
}

- (void)deselectSelectedItemAnimated: (BOOL) animated{
    if (self.isSegmentDeselectionEnabled) {
        self.isSegmentSelected = false;
        [self setSelectedItemIndex:NSUIntegerMax animated:animated moveIndicator:YES];
    }
}

///Private
- (void)setSelectedItemIndex:(NSUInteger)selectedItemIndex animated: (BOOL) animated moveIndicator: (BOOL)moveIndicator{
    
    self.selectedItemIndex = selectedItemIndex;
    if (moveIndicator) {
        [self moveSelectedSegmentIndicatorToSegmentAtIndex:self.selectedItemIndex animated:animated];
    }
    [self setNeedsDisplay];
}

///Private
- (void)setSelectedItemIndex:(NSUInteger)selectedItemIndex{
    
    _selectedItemIndex = selectedItemIndex;
    
    for (NSUInteger i = 0; i < [self.items count]; i++) {
        BWSegment *item = self.items[i];
        BOOL isSelectedItem = i == selectedItemIndex;
        item.titleLabel.textColor = isSelectedItem ? item.imageView.tintColor : item.titleLabelDefaultColor;
        item.selected = isSelectedItem ? YES : NO;
    }
    [self setNeedsDisplay];
}

- (void)setSelectedItemIndicatorColor:(UIColor *)selectedItemIndicatorColor
{
    _selectedItemIndicatorColor = selectedItemIndicatorColor;
    self.selectedItemIndicator.backgroundColor = _selectedItemIndicatorColor;
}

- (void)setSelectedItemIndicatorImage:(UIImage *)selectedItemIndicatorImage
{
    _selectedItemIndicatorImage = selectedItemIndicatorImage;
    self.selectedItemIndicator.image = _selectedItemIndicatorImage;
    self.selectedItemIndicator.contentMode = UIViewContentModeCenter;
    self.selectedItemIndicator.frame = CGRectMake(0, 0, _selectedItemIndicatorImage.size.width*1.5, _selectedItemIndicatorImage.size.height*1.5);
}

- (void)setSegmentImageTintColor:(UIColor *)segmentImageTintColor{
    _segmentImageTintColor = segmentImageTintColor;
    
    for (BWSegment *item in self.items) {
        UIImage *originalImage = item.imageView.image;
        item.imageView.image = [originalImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        item.imageView.tintColor = _segmentImageTintColor;
    }
    [self setNeedsDisplay];
}

@end

