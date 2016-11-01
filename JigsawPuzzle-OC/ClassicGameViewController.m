//
//  ClassicGameViewController.m
//  JigsawPuzzle-OC
//
//  Created by Shuai Yuan on 26/10/16.
//  Copyright © 2016 Mitchell. All rights reserved.
//

#import "ClassicGameViewController.h"
#import <UIKit/UIKit.h>

@interface ClassicGameViewController ()
{
    CGFloat imageSize;
    CGFloat tileSize;
    CGFloat gridSize;
    NSMutableArray *tilesOuterArray;
    NSMutableArray *originalPositionOuterArray;
    NSMutableArray *currentPositionOuterArray;
    CGRect emptyRect;
    CGPoint emptyTilePosition;
    int grid;
    int steps;
    int ruffleSteps;
}
@end

@implementation ClassicGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        [_imageGridView.superview removeConstraint:_imageGridViewLeadingConstraint];
        [_imageGridView.superview removeConstraint:_imageGridViewTrailingConstraint];
        NSLayoutConstraint *imageGridViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.imageGridView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:screenHeight / 2];
        NSLayoutConstraint *centerHorizontallyConstraint = [NSLayoutConstraint constraintWithItem:_imageGridView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_imageGridView.superview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
        [self.view addConstraint:centerHorizontallyConstraint];
        [_imageGridView addConstraint:imageGridViewHeightConstraint];
    }
    
    grid = self.settings.getDifficultLevel + 3;
    ruffleSteps = pow(3, grid);
    steps = 0;
    _stepsLabel.text = [@(steps) stringValue];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    self.thumbImageView.image = self.settings.getImage;
    [self generateTiles:self.settings.getImage intoGrid:grid];
    [self ruffleTiles];
    [self displayTiles];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)generateTiles : (UIImage *)image intoGrid:(int)number
{
    
    imageSize = _imageGridView.frame.size.height;
    gridSize = imageSize / number;
    tileSize = gridSize - 1;
    tilesOuterArray = [NSMutableArray arrayWithCapacity:number];
    originalPositionOuterArray = [NSMutableArray arrayWithCapacity:number];
    currentPositionOuterArray = [NSMutableArray arrayWithCapacity:number];
    
    UIGraphicsBeginImageContext(CGSizeMake(imageSize, imageSize));
    [image drawInRect:CGRectMake(0, 0, imageSize, imageSize)];
    UIImage *newSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    for (int i = 0; i < grid; i++) {
        NSMutableArray *originalPositionInnerArray = [NSMutableArray arrayWithCapacity:number];
        NSMutableArray *currentPositionInnerArray = [NSMutableArray arrayWithCapacity:number];
        NSMutableArray *tilesInnerArray = [NSMutableArray arrayWithCapacity:number];
        
        for (int j = 0; j < grid; j++) {
            UIImageView *tile = [self cropImage:newSizeImage atPosition:CGPointMake(i, j)];
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTile:)];
            singleTap.numberOfTapsRequired = 1;
            [tile setUserInteractionEnabled:YES];
            [tile addGestureRecognizer:singleTap];
            
            [tilesInnerArray addObject:tile];
            [originalPositionInnerArray addObject:[NSValue valueWithCGPoint:CGPointMake(i, j)]];
            [currentPositionInnerArray addObject:[NSValue valueWithCGPoint:CGPointMake(i, j)]];
        }
        
        [tilesOuterArray addObject:tilesInnerArray];
        [originalPositionOuterArray addObject:originalPositionInnerArray];
        [currentPositionOuterArray addObject:currentPositionInnerArray];
    }
    
    emptyTilePosition = CGPointMake(grid - 1, grid - 1);
}

- (UIImageView *)cropImage : (UIImage *)image atPosition: (CGPoint)position
{
    CGRect cropRect = CGRectMake(position.y * gridSize, position.x * gridSize, tileSize, tileSize);
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, cropRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    UIImageView *croppedImageView = [[UIImageView alloc] initWithImage:croppedImage];
    croppedImageView.frame = cropRect;
    
    return croppedImageView;
}

- (void) ruffleTiles
{
    int i, j;
    int k = 0;
    while (k < ruffleSteps) {
        CGPoint randomPosition = [self getRandomPosition];
        i = (int)randomPosition.x;
        j = (int)randomPosition.y;
        
        if ((i == emptyTilePosition.x - 1 && j == emptyTilePosition.y - 1) ||
            (i == emptyTilePosition.x - 1 && j == emptyTilePosition.y + 1) ||
            (i == emptyTilePosition.x + 1 && j == emptyTilePosition.y - 1) ||
            (i == emptyTilePosition.x + 1 && j == emptyTilePosition.y + 1) ||
            (i == emptyTilePosition.x && j == emptyTilePosition.y)) {
            continue;
        }
        
        //move tile
        [self swapTileAt:CGPointMake(i, j) withTileAt:emptyTilePosition];
        
        //update current tile position
        [self swapPosition:CGPointMake(i, j) with:emptyTilePosition];
        
        //update empty tile position
        emptyTilePosition = CGPointMake(i, j);
        
        k++;
    }
}

- (void) displayTiles
{
    for (int i = 0; i < grid; i++) {
        for (int j = 0; j < grid; j++) {
            if (!(i == emptyTilePosition.x && j == emptyTilePosition.y)) {
                UIImageView *tile = tilesOuterArray[i][j];
                [_imageGridView addSubview:tile];
            }
        }
    }
}

- (CGPoint) getRandomPosition
{
    int x, y;
    if (emptyTilePosition.x == 0) {
        x = arc4random() % 2;
    }
    else if (emptyTilePosition.x == grid - 1) {
        x = (emptyTilePosition.x - 1) + arc4random() % 2;
    }
    else {
        x = (emptyTilePosition.x - 1) + arc4random() % 3;
    }
    
    if (emptyTilePosition.y == 0) {
        y = arc4random() % 2;
    }
    else if (emptyTilePosition.y == grid - 1) {
        y = (emptyTilePosition.y - 1) + arc4random() % 2;
    }
    else {
        y = (emptyTilePosition.y - 1) + arc4random() % 3;
    }
    
    return CGPointMake(x, y);
}

- (void)tapTile : (UITapGestureRecognizer *)sender
{
    UIView *tappedTile = sender.view;
    CGPoint tappedPosition = tappedTile.frame.origin;
    CGPoint location = [sender locationInView:[sender.view superview]];
    int indexOuter = location.y / gridSize;
    int indexInner = location.x / gridSize;
    
    if ([self isWithInEmptyTile:CGPointMake(location.x - gridSize, location.y)]) {
        tappedTile.frame = CGRectMake(tappedPosition.x - gridSize, tappedPosition.y, tileSize, tileSize);
        [self swapPosition:CGPointMake(indexOuter, indexInner) with:CGPointMake(indexOuter, indexInner - 1)];
    }
    else if ([self isWithInEmptyTile:CGPointMake(location.x + gridSize, location.y)]) {
        tappedTile.frame = CGRectMake(tappedPosition.x + gridSize, tappedPosition.y, tileSize, tileSize);
        [self swapPosition:CGPointMake(indexOuter, indexInner) with:CGPointMake(indexOuter, indexInner + 1)];
    }
    else if ([self isWithInEmptyTile:CGPointMake(location.x, location.y - gridSize)]) {
        tappedTile.frame = CGRectMake(tappedPosition.x, tappedPosition.y - gridSize, tileSize, tileSize);
        [self swapPosition:CGPointMake(indexOuter, indexInner) with:CGPointMake(indexOuter - 1, indexInner)];
    }
    else if ([self isWithInEmptyTile:CGPointMake(location.x, location.y + gridSize)]) {
        tappedTile.frame = CGRectMake(tappedPosition.x, tappedPosition.y + gridSize, tileSize, tileSize);
        [self swapPosition:CGPointMake(indexOuter, indexInner) with:CGPointMake(indexOuter + 1, indexInner)];
    }
    else return;
    
    emptyTilePosition = CGPointMake(indexOuter, indexInner);
    _stepsLabel.text = [@(++steps) stringValue];
    
    if ([self isWin]) {
        [self popupAlert:@"You Win!"];
    }
}

- (BOOL) isWithInEmptyTile : (CGPoint)point
{
    if (point.x > (emptyTilePosition.y * gridSize) && point.x < ((emptyTilePosition.y + 1) * gridSize) &&
        point.y > (emptyTilePosition.x * gridSize) && point.y < ((emptyTilePosition.x + 1) * gridSize)) {
        return true;
    }
    else return false;
}

- (void) swapPosition: (CGPoint)current with: (CGPoint)new
{
    int currentIndexI = (int)current.x;
    int currentIndexJ = (int)current.y;
    int newIndexI = (int)new.x;
    int newIndexJ = (int)new.y;
    
    NSMutableArray *currentPositionInnerArray = [NSMutableArray arrayWithArray:currentPositionOuterArray[currentIndexI]];
    
    if (currentIndexI == newIndexI) {
        [currentPositionInnerArray exchangeObjectAtIndex:currentIndexJ withObjectAtIndex:newIndexJ];
        [currentPositionOuterArray replaceObjectAtIndex:currentIndexI withObject:currentPositionInnerArray];
    }
    else {
        NSMutableArray *newPositionInnerArray = [NSMutableArray arrayWithArray:currentPositionOuterArray[newIndexI]];
        id currentObject = [currentPositionInnerArray objectAtIndex:currentIndexJ];
        id newObject = [newPositionInnerArray objectAtIndex:newIndexJ];
        
        [currentPositionInnerArray replaceObjectAtIndex:currentIndexJ withObject:newObject];
        [newPositionInnerArray replaceObjectAtIndex:newIndexJ withObject:currentObject];
        [currentPositionOuterArray replaceObjectAtIndex:currentIndexI withObject:currentPositionInnerArray];
        [currentPositionOuterArray replaceObjectAtIndex:newIndexI withObject:newPositionInnerArray];
    }
}

- (void) swapTileAt: (CGPoint)currentPosition withTileAt: (CGPoint)newPosition;
{
    int currentIndexI = (int)currentPosition.x;
    int currentIndexJ = (int)currentPosition.y;
    int newIndexI = (int)newPosition.x;
    int newIndexJ = (int)newPosition.y;
    
    NSMutableArray *currentTileInnerArray = [NSMutableArray arrayWithArray:tilesOuterArray[currentIndexI]];
    
    UIImageView *currentTile = tilesOuterArray[currentIndexI][currentIndexJ];
    UIImageView *newTile = tilesOuterArray[newIndexI][newIndexJ];
    currentTile.frame = CGRectMake(newIndexJ * gridSize, newIndexI * gridSize, tileSize, tileSize);
    newTile.frame = CGRectMake(currentIndexJ * gridSize, currentIndexI * gridSize, tileSize, tileSize);
    
    if (currentIndexI == newIndexI) {
        [currentTileInnerArray exchangeObjectAtIndex:currentIndexJ withObjectAtIndex:newIndexJ];
        [tilesOuterArray replaceObjectAtIndex:currentIndexI withObject:currentTileInnerArray];
    }
    else {
        NSMutableArray *newTileInnerArray = [NSMutableArray arrayWithArray:tilesOuterArray[newIndexI]];
        id currentTile = [currentTileInnerArray objectAtIndex:currentIndexJ];
        id newTile = [newTileInnerArray objectAtIndex:newIndexJ];
        
        [currentTileInnerArray replaceObjectAtIndex:currentIndexJ withObject:newTile];
        [newTileInnerArray replaceObjectAtIndex:newIndexJ withObject:currentTile];
        [tilesOuterArray replaceObjectAtIndex:currentIndexI withObject:currentTileInnerArray];
        [tilesOuterArray replaceObjectAtIndex:newIndexI withObject:newTileInnerArray];
    }
    
    
}

- (BOOL) isWin
{
    for (int i = 0; i < grid; i++) {
        for (int j = 0; j < grid; j++) {
            if (!(i == grid - 1 && j == grid - 1)) {
                CGPoint originalPosition = [originalPositionOuterArray[i][j] CGPointValue];
                CGPoint currentPosition = [currentPositionOuterArray[i][j] CGPointValue];
                if (!CGPointEqualToPoint(originalPosition, currentPosition)) {
                    return false;
                }
            }
            
        }
    }
    return true;
}

- (void)displayOriginalImage : (UIImage *)image
{
    imageSize = _imageGridView.frame.size.height;
    UIGraphicsBeginImageContext(CGSizeMake(imageSize, imageSize));
    [image drawInRect:CGRectMake(0, 0, imageSize, imageSize)];
    UIImage *newSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageView * completeImageView = [[UIImageView alloc] initWithImage:newSizeImage];
    [_imageGridView addSubview:completeImageView];
}

- (void)popupAlert: (NSString*)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
