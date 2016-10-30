//
//  GameSetting.h
//  JigsawPuzzle-OC
//
//  Created by Admin on 10/30/16.
//  Copyright © 2016 Mitchell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameSetting : NSObject

@property (nonatomic) int difficultLevel;
@property (nonatomic) UIImage* imagePointer;
- (id) initGame:(int)level;
- (void) initAllGame:(int)level image:(UIImage *)defaultImage;
- (void) setImage:(UIImage *) defaultImage;
- (UIImage *) getImage;
- (void) setDifficultLevel:(int)difficultLevel;
- (int) getDifficultLevel;
@end
