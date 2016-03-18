//
//  Hitbox.cpp
//  Assignment2
//
//  Created by Santo Tallarico on 2016-03-17.
//  Copyright © 2016 Santo Tallarico. All rights reserved.
//

#include "Hitbox.hpp"

Hitbox::Hitbox() {
    width = 0;
    height = 0;
    x = 0;
    y = 0;
}

Hitbox::Hitbox(float w, float h, float xx, float yy) {
    width = w;
    height = h;
    x = xx;
    y = yy;
}

bool Hitbox::Collide(Hitbox box) {
    float topLeftX = x - width / 2;
    float topLeftY = y - height / 2;
    float boxTopLeftX = box.x - box.width / 2;
    float boxTopLeftY = box.y - box.height / 2;
    
    if (topLeftX < boxTopLeftX + box.width &&
        topLeftX + width > boxTopLeftX &&
        topLeftY < boxTopLeftY + box.height &&
        height + topLeftY > boxTopLeftY) {
        return true;
    }
    else {
        return false;
    }
}

 Hitbox Hitbox::GetHitboxFromModel() {
    float top = FLT_MAX;
    float bottom = -FLT_MAX;
    float left = FLT_MAX;
    float right = -FLT_MAX;
    for (int i = 0; i < 1; i++) {
        /*let temp = _object.positions + Int(index);
        if (index % 3 == 0) {
            if (temp.memory < left) {
                left = temp.memory;
            }
            else if (temp.memory > right) {
                right = temp.memory;
            }
        }
        else if (index % 3 == 2) {
            if (temp.memory < top) {
                top = temp.memory;
            }
            else if (temp.memory > bottom) {
                bottom = temp.memory;
            }
        }*/
    }
    
    float tempw = right - left;
    float temph = bottom - top;
    
    if (tempw <= 0) {
        tempw = 0.0001f;
    }
    if (temph <= 0) {
        temph = 0.0001f;
    }
    
    return Hitbox(tempw, temph, 1, 1);
}