#include "pcontacts.h"

using namespace cyclone;

// Contact implementation

void ParticleContact::resolve(Ogre::Real duration)
{
    resolveVelocity(duration);
    resolveInterpenetration(duration);
}

Ogre::Real ParticleContact::calculateSeparatingVelocity() const
{
	Ogre::Vector3 relativeVelocity = particle[0]->getVelocity();
    if (particle[1]) relativeVelocity -= particle[1]->getVelocity();
	return relativeVelocity.dotProduct(contactNormal);
}

void ParticleContact::resolveVelocity(Ogre::Real duration)
{
    // Find the velocity in the direction of the contact
	Ogre::Real separatingVelocity = calculateSeparatingVelocity();

    // Check if it needs to be resolved
    if (separatingVelocity > 0)
    {
        // The contact is either separating, or stationary - there's
        // no impulse required.
        return;
    }
	
    // Calculate the new separating velocity
	Ogre::Real newSepVelocity = -separatingVelocity * restitution;

    // Check the velocity build-up due to acceleration only
	Ogre::Vector3 accCausedVelocity = particle[0]->getAcceleration();
    if (particle[1]) accCausedVelocity -= particle[1]->getAcceleration();
	Ogre::Real accCausedSepVelocity = (accCausedVelocity.dotProduct(contactNormal)) * duration;

    // If we've got a closing velocity due to acelleration build-up,
    // remove it from the new separating velocity
    if (accCausedSepVelocity < 0)
    {
        newSepVelocity += restitution * accCausedSepVelocity;

        // Make sure we haven't removed more than was
        // there to remove.
        if (newSepVelocity < 0) newSepVelocity = 0;
    }

	Ogre::Real deltaVelocity = newSepVelocity - separatingVelocity;

    // We apply the change in velocity to each object in proportion to
    // their inverse mass (i.e. those with lower inverse mass [higher
    // actual mass] get less change in velocity)..
	Ogre::Real totalInverseMass = particle[0]->getInverseMass();
    if (particle[1]) totalInverseMass += particle[1]->getInverseMass();

    // If all particles have infinite mass, then impulses have no effect
    if (totalInverseMass <= 0) return;

    // Calculate the impulse to apply
	Ogre::Real impulse = deltaVelocity / totalInverseMass;

    // Find the amount of impulse per unit of inverse mass
	Ogre::Vector3 impulsePerIMass = contactNormal * impulse;

    // Apply impulses: they are applied in the direction of the contact,
    // and are proportional to the inverse mass.
    particle[0]->setVelocity(particle[0]->getVelocity() +
        impulsePerIMass * particle[0]->getInverseMass()
        );
	
    if (particle[1])
    {
        // Particle 1 goes in the opposite direction
        particle[1]->setVelocity(particle[1]->getVelocity() +
            impulsePerIMass * -particle[1]->getInverseMass()
            );
    }
}

void ParticleContact::resolveInterpenetration(Ogre::Real duration)
{
    // If we don't have any penetration, skip this step.
    if (penetration <= 0) return;

    // The movement of each object is based on their inverse mass, so
    // total that.
	Ogre::Real totalInverseMass = particle[0]->getInverseMass();
    if (particle[1]) totalInverseMass += particle[1]->getInverseMass();

    // If all particles have infinite mass, then we do nothing
    if (totalInverseMass <= 0) return;

    // Find the amount of penetration resolution per unit of inverse mass
	Ogre::Vector3 movePerIMass = contactNormal * (penetration / totalInverseMass);

    // Calculate the the movement amounts
    particleMovement[0] = movePerIMass * particle[0]->getInverseMass();
    if (particle[1]) {
        particleMovement[1] = movePerIMass * -particle[1]->getInverseMass();
    } else {
		particleMovement[1].ZERO;
    }

    // Apply the penetration resolution
    particle[0]->setPosition(particle[0]->getPosition() + particleMovement[0]);
    if (particle[1]) {
        particle[1]->setPosition(particle[1]->getPosition() + particleMovement[1]);
    }
}

ParticleContactResolver::ParticleContactResolver(unsigned iterations)
:
iterations(iterations)
{
}

void ParticleContactResolver::setIterations(unsigned iterations)
{
    ParticleContactResolver::iterations = iterations;
}

void ParticleContactResolver::resolveContacts(ParticleContact *contactArray,
                                              unsigned numContacts,
											  Ogre::Real duration)
{
    unsigned i;

    iterationsUsed = 0;
    while(iterationsUsed < iterations)
    {
        // Find the contact with the largest closing velocity;
		Ogre::Real max = 9999999;//REAL_MAX;
        unsigned maxIndex = numContacts;
        for (i = 0; i < numContacts; i++)
        {
			Ogre::Real sepVel = contactArray[i].calculateSeparatingVelocity();
            if (sepVel < max &&
                (sepVel < 0 || contactArray[i].penetration > 0))
            {
                max = sepVel;
                maxIndex = i;
            }
        }

        // Do we have anything worth resolving?
        if (maxIndex == numContacts) break;

        // Resolve this contact
        contactArray[maxIndex].resolve(duration);

        // Update the interpenetrations for all particles
		Ogre::Vector3 *move = contactArray[maxIndex].particleMovement;
        for (i = 0; i < numContacts; i++)
        {
            if (contactArray[i].particle[0] == contactArray[maxIndex].particle[0])
            {
				contactArray[i].penetration -= move[0].dotProduct(contactArray[i].contactNormal);
            }
            else if (contactArray[i].particle[0] == contactArray[maxIndex].particle[1])
            {
                contactArray[i].penetration -= move[1].dotProduct(contactArray[i].contactNormal);
            }
            if (contactArray[i].particle[1])
            {
                if (contactArray[i].particle[1] == contactArray[maxIndex].particle[0])
                {
                    contactArray[i].penetration += move[0].dotProduct(contactArray[i].contactNormal);
                }
                else if (contactArray[i].particle[1] == contactArray[maxIndex].particle[1])
                {
                    contactArray[i].penetration += move[1].dotProduct(contactArray[i].contactNormal);
                }
            }
        }

        iterationsUsed++;
    }
}
