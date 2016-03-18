//
//  PhysicsEngine.hpp
//  Assignment2
//
//  Created by Santo Tallarico on 2016-03-17.
//  Copyright © 2016 Santo Tallarico. All rights reserved.
//

#ifndef PhysicsEngine_hpp
#define PhysicsEngine_hpp

#include <stdio.h>
#include <vector>
#include "Hitbox.hpp"
#include "Model.hpp"

using std::vector;

class PhysicsEngine {
public:
    vector<Hitbox> hitboxes;
    Model model;
    
    PhysicsEngine();
    void Update();
};

#endif /* PhysicsEngine_hpp */
