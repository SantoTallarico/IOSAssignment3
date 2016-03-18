//
//  Model.cpp
//  Assignment2
//
//  Created by Santo Tallarico on 2016-03-17.
//  Copyright © 2016 Santo Tallarico. All rights reserved.
//

#include "Model.hpp"

Model::Model() {
    directions.push_back((vector_float3){1, 0, 0});
    directions.push_back((vector_float3){0, 0, 1});
    directions.push_back((vector_float3){-1, 0, 0});
    directions.push_back((vector_float3){0, 0, -1});
    direction = directions[rand() % 4];
}

void Model::Update() {
    if (rand() % 50 == 0) {
        direction = directions[rand() % 4];
    }
    position += direction / 25;
    hitbox.x += direction.x / 25;
    hitbox.y += direction.z / 25;
    if (position.z <= -7)
    {
        position.z = -6.99f;
        hitbox.y = -6.99f;
        direction = directions[rand() % 4];
    }
    if (position.z > 0)
    {
        position.z = -0.01f;
        hitbox.y = -0.01f;
        direction = directions[rand() % 4];
    }
}

void Model::Collide() {
    position -= direction / 10;
    hitbox.x -= direction.x / 10;
    hitbox.y -= direction.z / 10;
    direction = directions[rand() % 4];
}