//
//  FlubbleColors.m
//  Flubble
//
//  Created by Johan Ismael on 11/19/13.
//  Copyright (c) 2013 Johan Ismael. All rights reserved.
//

#import "FlubbleColors.h"

@implementation FlubbleColors

static NSArray *enemyColors;

+ (NSArray *)enemyColors
{
    if (!enemyColors) {
        enemyColors = @[
                        [SKColor colorWithRed:74/255.0 green:217/255.0 blue:217/255.0 alpha:1.0],
                        [SKColor colorWithRed:54/255.0 green:177/255.0 blue:191/255.0 alpha:1.0],
                        [SKColor colorWithRed:202/255.0 green:50/255.0 blue:99/255.0 alpha:1.0],
                        [SKColor colorWithRed:202/255.0 green:50/255.0 blue:99/255.0 alpha:1.0]
                        ];
    }
    return enemyColors;
}

+ (SKColor *)planetColor
{
    return [SKColor colorWithRed:242/255.0 green:56/255.0 blue:90/255.0 alpha:1.0];
}

+ (SKColor *)flubbleColor
{
    return [SKColor colorWithRed:242/255.0 green:131/255.0 blue:107/255.0 alpha:1.0];
}

@end
