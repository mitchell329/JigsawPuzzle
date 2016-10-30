//
//  GameSetting.m
//  JigsawPuzzle-OC
//
//  Created by Admin on 10/30/16.
//  Copyright © 2016 Mitchell. All rights reserved.
//

#import "GameSetting.h"

@implementation GameSetting
- (id) initGame:(int)level{
    self = [super init];
    if(self){
        self.difficultLevel = level;
    }
    return self;
};
- (void) initAllGame:(int)level image:(UIImage *)defaultImage{
    self.imagePointer = defaultImage;
    self.difficultLevel = level;
};
- (int) getDifficultLevel{
    return self.difficultLevel;
};

- (void) setImage:(UIImage *)defaultImage{
    self.imagePointer = defaultImage;
};

- (UIImage *) getImage{
    return self.imagePointer;
};
@end
