#include "pfgen.h"

using namespace cyclone;


void ParticleForceRegistry::updateForces(Ogre::Real duration)
{
    Registry::iterator i = registrations.begin();
    for (; i != registrations.end(); i++)
    {
        i->fg->updateForce(i->particle, duration);
    }
}

void ParticleForceRegistry::add(Particle* particle, ParticleForceGenerator *fg)
{
    ParticleForceRegistry::ParticleForceRegistration registration;
    registration.particle = particle;
    registration.fg = fg;
    registrations.push_back(registration);
}

ParticleGravity::ParticleGravity(const Ogre::Vector3& gravity)
: gravity(gravity)
{
}

void ParticleGravity::updateForce(Particle* particle, Ogre::Real duration)
{
    // Check that we do not have infinite mass
    if (!particle->hasFiniteMass()) return;

    // Apply the mass-scaled force to the particle
    particle->addForce(gravity * particle->getMass());
}

ParticleDrag::ParticleDrag(Ogre::Real k1, Ogre::Real k2)
: k1(k1), k2(k2)
{
}

void ParticleDrag::updateForce(Particle* particle, Ogre::Real duration)
{
	Ogre::Vector3 force;
    particle->getVelocity(&force);

    // Calculate the total drag coefficient
	Ogre::Real dragCoeff = force.length();
    dragCoeff = k1 * dragCoeff + k2 * dragCoeff * dragCoeff;

    // Calculate the final force and apply it
    force.normalise();
    force *= -dragCoeff;
    particle->addForce(force);
}

ParticleSpring::ParticleSpring(Particle *other, Ogre::Real sc, Ogre::Real rl)
: other(other), springConstant(sc), restLength(rl)
{
}

void ParticleSpring::updateForce(Particle* particle, Ogre::Real duration)
{
    // Calculate the vector of the spring
	Ogre::Vector3 force;
    particle->getPosition(&force);
    force -= other->getPosition();

    // Calculate the magnitude of the force
	Ogre::Real magnitude = force.length();
	magnitude = Ogre::Math::Abs(magnitude - restLength);
    magnitude *= springConstant;

    // Calculate the final force and apply it
    force.normalise();
    force *= -magnitude;
    particle->addForce(force);
}

ParticleBuoyancy::ParticleBuoyancy(Ogre::Real maxDepth,
								   Ogre::Real volume,
								   Ogre::Real waterHeight,
								   Ogre::Real liquidDensity)
:
maxDepth(maxDepth), volume(volume),
waterHeight(waterHeight), liquidDensity(liquidDensity)
{
}

void ParticleBuoyancy::updateForce(Particle* particle, Ogre::Real duration)
{
    // Calculate the submersion depth
	Ogre::Real depth = particle->getPosition().y;

    // Check if we're out of the water
    if (depth >= waterHeight + maxDepth) return;
	Ogre::Vector3 force(0,0,0);

    // Check if we're at maximum depth
    if (depth <= waterHeight - maxDepth)
    {
        force.y = liquidDensity * volume;
        particle->addForce(force);
        return;
    }

    // Otherwise we are partly submerged
    force.y = liquidDensity * volume *
        (depth - maxDepth - waterHeight) / 2 * maxDepth;
    particle->addForce(force);
}

ParticleBungee::ParticleBungee(Particle *other, Ogre::Real sc, Ogre::Real rl)
: other(other), springConstant(sc), restLength(rl)
{
}

void ParticleBungee::updateForce(Particle* particle, Ogre::Real duration)
{
    // Calculate the vector of the spring
	Ogre::Vector3 force;
    particle->getPosition(&force);
    force -= other->getPosition();

    // Check if the bungee is compressed
	Ogre::Real magnitude = force.length();
    if (magnitude <= restLength) return;

    // Calculate the magnitude of the force
    magnitude = springConstant * (restLength - magnitude);

    // Calculate the final force and apply it
    force.normalise();
    force *= -magnitude;
    particle->addForce(force);
}

ParticleFakeSpring::ParticleFakeSpring(Ogre::Vector3 *anchor, Ogre::Real sc, Ogre::Real d)
: anchor(anchor), springConstant(sc), damping(d)
{
}

void ParticleFakeSpring::updateForce(Particle* particle, Ogre::Real duration)
{
    // Check that we do not have infinite mass
    if (!particle->hasFiniteMass()) return;

    // Calculate the relative position of the particle to the anchor
	Ogre::Vector3 position;
    particle->getPosition(&position);
    position -= *anchor;

    // Calculate the constants and check they are in bounds.
	Ogre::Real gamma = 0.5f * Ogre::Math::Sqrt(4 * springConstant - damping*damping);
    if (gamma == 0.0f) return;
	Ogre::Vector3 c = position * (damping / (2.0f * gamma)) +
        particle->getVelocity() * (1.0f / gamma);

    // Calculate the target position
	Ogre::Vector3 target = position * Ogre::Math::Cos(gamma * duration) +
        c * Ogre::Math::Sin(gamma * duration);
	target *= Ogre::Math::Exp(-0.5f * duration * damping);

    // Calculate the resulting acceleration and therefore the force
	Ogre::Vector3 accel = (target - position) * (1.0f / duration*duration) -
        particle->getVelocity() * duration;
    particle->addForce(accel * particle->getMass());
}

ParticleAnchoredSpring::ParticleAnchoredSpring()
{
}

ParticleAnchoredSpring::ParticleAnchoredSpring(Ogre::Vector3 *anchor,
											   Ogre::Real sc, Ogre::Real rl)
: anchor(anchor), springConstant(sc), restLength(rl)
{
}

void ParticleAnchoredSpring::init(Ogre::Vector3 *anchor, Ogre::Real springConstant,
								  Ogre::Real restLength)
{
    ParticleAnchoredSpring::anchor = anchor;
    ParticleAnchoredSpring::springConstant = springConstant;
    ParticleAnchoredSpring::restLength = restLength;
}

void ParticleAnchoredBungee::updateForce(Particle* particle, Ogre::Real duration)
{
    // Calculate the vector of the spring
	Ogre::Vector3 force;
    particle->getPosition(&force);
    force -= *anchor;

    // Calculate the magnitude of the force
	Ogre::Real magnitude = force.length();
    if (magnitude < restLength) return;

    magnitude = magnitude - restLength;
    magnitude *= springConstant;

    // Calculate the final force and apply it
    force.normalise();
    force *= -magnitude;
    particle->addForce(force);
}

void ParticleAnchoredSpring::updateForce(Particle* particle, Ogre::Real duration)
{
    // Calculate the vector of the spring
	Ogre::Vector3 force;
    particle->getPosition(&force);
    force -= *anchor;

    // Calculate the magnitude of the force
	Ogre::Real magnitude = force.length();
    magnitude = (restLength - magnitude) * springConstant;

    // Calculate the final force and apply it
    force.normalise();
    force *= magnitude;
    particle->addForce(force);
}


