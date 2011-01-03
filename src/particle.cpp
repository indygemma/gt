#include "particle.h"
//#include <assert.h>
#include <math.h>


////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////



using namespace cyclone;

/*
* --------------------------------------------------------------------------
* FUNCTIONS DECLARED IN HEADER:
* --------------------------------------------------------------------------
*/




void cyclone::Particle::integrate(Ogre::Real duration)
{
    // We don't integrate things with zero mass.
    if (inverseMass <= 0.0f) return;

//    assert(duration > 0.0);

    // Update linear position.
    //position.addScaledVector(velocity, duration);
	position.x +=velocity.x*duration;
	position.y +=velocity.y*duration;
	position.z +=velocity.z*duration;

    // Work out the acceleration from the force
	Ogre::Vector3 resultingAcc = acceleration;
    //resultingAcc.addScaledVector(forceAccum, inverseMass);
	resultingAcc.x += forceAccum.x * inverseMass;
	resultingAcc.y += forceAccum.y * inverseMass;
	resultingAcc.z += forceAccum.z * inverseMass;

    // Update linear velocity from the acceleration.
    //velocity.addScaledVector(resultingAcc, duration);
	velocity.x += resultingAcc.x * duration;
	velocity.y += resultingAcc.y * duration;
	velocity.z += resultingAcc.z * duration;


    // Impose drag.
   // velocity *= real_pow(damping, duration);
	velocity.x *= Ogre::Math::Pow(damping, duration);
	velocity.y *= Ogre::Math::Pow(damping, duration);
	velocity.z *= Ogre::Math::Pow(damping, duration);

    // Clear the forces.
    clearAccumulator();
}



void cyclone::Particle::setMass(const Ogre::Real mass)
{
    assert(mass != 0);
	cyclone::Particle::inverseMass = ((Ogre::Real)1.0)/mass;
}



Ogre::Real cyclone::Particle::getMass() const
{
    if (inverseMass == 0) {
        return 9999999;//REAL_MAX;
    } else {
		return ((Ogre::Real)1.0)/inverseMass;
    }
}

void cyclone::Particle::setInverseMass(const Ogre::Real inverseMass)
{
    cyclone::Particle::inverseMass = inverseMass;
}

Ogre::Real cyclone::Particle::getInverseMass() const
{
    return inverseMass;
}

bool cyclone::Particle::hasFiniteMass() const
{
    return inverseMass >= 0.0f;
}

void cyclone::Particle::setDamping(const Ogre::Real damping)
{
    cyclone::Particle::damping = damping;
}

Ogre::Real cyclone::Particle::getDamping() const
{
    return damping;
}

void cyclone::Particle::setPosition(const Ogre::Vector3 &position)
{
    cyclone::Particle::position = position;
}

void cyclone::Particle::setPosition(const Ogre::Real x, const Ogre::Real y, const Ogre::Real z)
{
    position.x = x;
    position.y = y;
    position.z = z;
}

void cyclone::Particle::getPosition(Ogre::Vector3 *position) const
{
    *position = cyclone::Particle::position;
}

Ogre::Vector3 cyclone::Particle::getPosition() const
{
    return position;
}

void cyclone::Particle::setVelocity(const Ogre::Vector3 &velocity)
{
    cyclone::Particle::velocity = velocity;
}

void cyclone::Particle::setVelocity(const Ogre::Real x, const Ogre::Real y, const Ogre::Real z)
{
    velocity.x = x;
    velocity.y = y;
    velocity.z = z;
}

void cyclone::Particle::getVelocity(Ogre::Vector3 *velocity) const
{
    *velocity = cyclone::Particle::velocity;
}

Ogre::Vector3 cyclone::Particle::getVelocity() const
{
    return velocity;
}

void cyclone::Particle::setAcceleration(const Ogre::Vector3 &acceleration)
{
    cyclone::Particle::acceleration = acceleration;
}

void cyclone::Particle::setAcceleration(const Ogre::Real x, const Ogre::Real y, const Ogre::Real z)
{
    acceleration.x = x;
    acceleration.y = y;
    acceleration.z = z;
}

void cyclone::Particle::getAcceleration(Ogre::Vector3 *acceleration) const
{
    *acceleration = cyclone::Particle::acceleration;
}

Ogre::Vector3 cyclone::Particle::getAcceleration() const
{
    return acceleration;
}

void cyclone::Particle::clearAccumulator()
{
    //forceAccum.clear();
	forceAccum.x = 0;
	forceAccum.y = 0;
	forceAccum.z = 0;
}

void cyclone::Particle::addForce(const Ogre::Vector3 &force)
{
    forceAccum.x += force.x;
	forceAccum.y += force.y;
	forceAccum.z += force.z;
}







////////////////////////////////////////////
