//
//  PhysicsEngine.cpp
//  Assignment2
//
//  Created by Santo Tallarico on 2016-03-17.
//  Copyright © 2016 Santo Tallarico. All rights reserved.
//

#include "PhysicsEngine.hpp"

PhysicsEngine::PhysicsEngine() {
    
}

void PhysicsEngine::Update() {
    for (int i = 0; i < hitboxes.size(); i++) {
        if (model->hitbox.Collide(hitboxes[i])) {
            model->Collide();
        }
    }
}