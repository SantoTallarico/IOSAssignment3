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

 Hitbox Hitbox::GetHitboxFromModel(const float positions[], int size) {
    float top = FLT_MAX;
    float bottom = -FLT_MAX;
    float left = FLT_MAX;
    float right = -FLT_MAX;
    for (int i = 0; i < size; i++) {
        if (i % 3 == 0) {
            if (positions[i] < left) {
                left = positions[i];
            }
            else if (positions[i] > right) {
                right = positions[i];
            }
        }
        else if (i % 3 == 2) {
            if (positions[i] < top) {
                top = positions[i];
            }
            else if (positions[i] > bottom) {
                bottom = positions[i];
            }
        }
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