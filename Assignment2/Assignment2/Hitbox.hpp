//
//  Hitbox.hpp
//  Assignment2
//
//  Created by Santo Tallarico on 2016-03-17.
//  Copyright © 2016 Santo Tallarico. All rights reserved.
//

#ifndef Hitbox_hpp
#define Hitbox_hpp

#include <stdio.h>
#include <cfloat>

class Hitbox {
public:
    float width;
    float height;
    float x;
    float y;
    
    Hitbox();
    Hitbox(float w, float h, float xx, float yy);
    bool Collide(Hitbox box);
    static Hitbox GetHitboxFromModel();
};

#endif /* Hitbox_hpp */
