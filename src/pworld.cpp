//#include <cstdlib>
#include "pworld.h"

using namespace cyclone;

ParticleWorld::ParticleWorld(unsigned maxContacts, unsigned iterations)
:
resolver(iterations),
maxContacts(maxContacts)
{
    contacts = new ParticleContact[maxContacts];
    calculateIterations = (iterations == 0);

}

ParticleWorld::~ParticleWorld()
{
    delete[] contacts;
}


void ParticleWorld::addParticle(cyclone::Particle *particle){
	particles.push_back(particle);
}



void ParticleWorld::startFrame()
{
    for (Particles::iterator p = particles.begin();
        p != particles.end();
        p++)
    {
        // Remove all forces from the accumulator
        (*p)->clearAccumulator();
    }
}


void ParticleWorld::randomValues(cyclone::Particle *particle){
	particle->setPosition(Ogre::Vector3(0,10,0));
	particle->setVelocity(Ogre::Vector3(Ogre::Math::RangeRandom(-10,10),Ogre::Math::RangeRandom(5,20),Ogre::Math::RangeRandom(-10,10)));
	//particle->setVelocity(Ogre::Vector3(0,0,0));
	particle->setAcceleration(Ogre::Vector3(0,0,0));
	particle->setMass(100.0);
	particle->setInverseMass(1.0);
	//particle->setAcceleration(Ogre::Vector3(0, 0, 0));
	particle->setDamping(Ogre::Real(0.5));
}




unsigned ParticleWorld::generateContacts()
{
    unsigned limit = maxContacts;


	ParticleContact *nextContact = contacts;

    for (ContactGenerators::iterator g = contactGenerators.begin();
        g != contactGenerators.end();
        g++)
    {
        unsigned used =(*g)->addContact(nextContact, limit);

		/*cyclone::GroundContacts *gc = new cyclone::GroundContacts();
		gc->init(&particles);
		gc->addContact(nextContact, limit);		
		*/
        limit -= used;
        nextContact += used;		

        // We've run out of contacts to fill. This means we're missing
        // contacts.
        if (limit <= 0) break;
    }
	

    // Return the number of contacts used.
    return maxContacts - limit;
}

void ParticleWorld::integrate(Ogre::Real duration)
{
    for (Particles::iterator p = particles.begin();
        p != particles.end();
        p++)
    {
        // Remove all forces from the accumulator
        (*p)->integrate(duration);
    }
}

void ParticleWorld::runPhysics(Ogre::Real duration)
{
    // First apply the force generators
    registry.updateForces(duration);

    // Then integrate the objects
    integrate(duration);

    // Generate contacts
    unsigned usedContacts = generateContacts();

    // And process them
    if (usedContacts)
    {
        if (calculateIterations) resolver.setIterations(usedContacts * 2);
        resolver.resolveContacts(contacts, usedContacts, duration);
    }
}

ParticleWorld::Particles& ParticleWorld::getParticles()
{
    return particles;
}

ParticleWorld::ContactGenerators& ParticleWorld::getContactGenerators()
{
    return contactGenerators;
}

ParticleForceRegistry& ParticleWorld::getForceRegistry()
{
    return registry;
}

void GroundContacts::init(cyclone::ParticleWorld::Particles *particles)
{
    GroundContacts::particles = particles;
}


unsigned GroundContacts::addContact(cyclone::ParticleContact *contact,
                                    unsigned limit) const
{
    unsigned count = 0;
	for (cyclone::ParticleWorld::Particles::iterator p = particles->begin();
        p != particles->end();
        p++)
    {
        Ogre::Real y = (*p)->getPosition().y;
        if (y < 0.0f)
        {
			contact->contactNormal = Ogre::Vector3::UNIT_Y;
            contact->particle[0] = *p;
            contact->particle[1] = NULL;
            contact->penetration = -y;
            contact->restitution = 0.3;
            contact++;
            count++;
        }
        if (count >= limit) return count;
    }
    return count;
}



//-----------------------------------------------------------------------

void AllContacts::init(cyclone::ParticleWorld::Particles *particles)
{
    AllContacts::particles = particles;
}


unsigned AllContacts::addContact(cyclone::ParticleContact *contact,
                                    unsigned limit) const
{
    unsigned count = 0;
	for (cyclone::ParticleWorld::Particles::iterator p = particles->begin();
        p != particles->end();
        p++)
    {
		for (cyclone::ParticleWorld::Particles::iterator p1 = particles->begin();
			p1 != particles->end();
			p1++)
		{
		
		cyclone::Particle *p01 = *p;
		cyclone::Particle *p02 = *p1;

		Ogre::Vector3 relativePos = p01->getPosition() - p02->getPosition();
		Ogre::Real length = relativePos.length();
		
		if((length < 1) && (p01->getPosition() != p02->getPosition())){
			
			contact->particle[0] = p01;
			contact->particle[1] = p02;

		 // Calculate the normal
			Ogre::Vector3 normal = p02->getPosition() - p01->getPosition();
			normal.normalise();

			// The contact normal depends on whether we're extending or compressing
  
			 contact->contactNormal = normal * -1;
			 contact->penetration = 1 - length;
    

			// Always use zero restitution (no bounciness)
			 contact->restitution = 0;

            contact++;
            count++;
        }

        if (count >= limit) return count;
    }
	}
    return count;
}
