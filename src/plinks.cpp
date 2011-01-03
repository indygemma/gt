#include "plinks.h"

using namespace cyclone;

Ogre::Real ParticleLink::currentLength() const
{
	Ogre::Vector3 relativePos = particle[0]->getPosition() -
                          particle[1]->getPosition();
    return relativePos.length();
}

unsigned ParticleCable::addContact(ParticleContact *contact,
                                    unsigned limit) const
{
    // Find the length of the cable
	Ogre::Real length = currentLength();

    // Check if we're over-extended
    if (length < maxLength)
    {
        return 0;
    }

    // Otherwise return the contact
    contact->particle[0] = particle[0];
    contact->particle[1] = particle[1];

    // Calculate the normal
	Ogre::Vector3 normal = particle[1]->getPosition() - particle[0]->getPosition();
    normal.normalise();
    contact->contactNormal = normal;

    contact->penetration = length-maxLength;
    contact->restitution = restitution;

    return 1;
}

unsigned ParticleRod::addContact(ParticleContact *contact,
                                  unsigned limit) const
{
    // Find the length of the rod
	Ogre::Real currentLen = currentLength();

    // Check if we're over-extended
    if (currentLen == length)
    {
        return 0;
    }

    // Otherwise return the contact
    contact->particle[0] = particle[0];
    contact->particle[1] = particle[1];

    // Calculate the normal
	Ogre::Vector3 normal = particle[1]->getPosition() - particle[0]->getPosition();
    normal.normalise();

    // The contact normal depends on whether we're extending or compressing
    if (currentLen > length) {
        contact->contactNormal = normal;
        contact->penetration = currentLen - length;
    } else {
        contact->contactNormal = normal * -1;
        contact->penetration = length - currentLen;
    }

    // Always use zero restitution (no bounciness)
    contact->restitution = 0;

    return 1;
}

Ogre::Real ParticleConstraint::currentLength() const
{
	Ogre::Vector3 relativePos = particle->getPosition() - anchor;
    return relativePos.length();
}

unsigned ParticleCableConstraint::addContact(ParticleContact *contact,
                                   unsigned limit) const
{
    // Find the length of the cable
	Ogre::Real length = currentLength();

    // Check if we're over-extended
    if (length < maxLength)
    {
        return 0;
    }

    // Otherwise return the contact
    contact->particle[0] = particle;
    contact->particle[1] = 0;

    // Calculate the normal
	Ogre::Vector3 normal = anchor - particle->getPosition();
    normal.normalise();
    contact->contactNormal = normal;

    contact->penetration = length-maxLength;
    contact->restitution = restitution;

    return 1;
}

unsigned ParticleRodConstraint::addContact(ParticleContact *contact,
                                 unsigned limit) const
{
    // Find the length of the rod
	Ogre::Real currentLen = currentLength();

    // Check if we're over-extended
    if (currentLen == length)
    {
        return 0;
    }

    // Otherwise return the contact
    contact->particle[0] = particle;
    contact->particle[1] = 0;

    // Calculate the normal
	Ogre::Vector3 normal = anchor - particle->getPosition();
    normal.normalise();

    // The contact normal depends on whether we're extending or compressing
    if (currentLen > length) {
        contact->contactNormal = normal;
        contact->penetration = currentLen - length;
    } else {
        contact->contactNormal = normal * -1;
        contact->penetration = length - currentLen;
    }

    // Always use zero restitution (no bounciness)
    contact->restitution = 0;

    return 1;
}



//--------------------------------------------------------------

unsigned ParticleSeperation::addContact(ParticleContact *contact,
                                  unsigned limit) const
{
    // Find the length of the rod
	Ogre::Real currentLen = currentLength();

    // Check if we're over-extended
    if (currentLen >= length)
    {
        return 0;
    }

    // Otherwise return the contact
    contact->particle[0] = particle[0];
    contact->particle[1] = particle[1];

    // Calculate the normal
	Ogre::Vector3 normal = particle[1]->getPosition() - particle[0]->getPosition();
    normal.normalise();

    // The contact normal depends on whether we're extending or compressing
    if (currentLen < length) {
        contact->contactNormal = normal * -1;
        contact->penetration = length - currentLen;
    }

    // Always use zero restitution (no bounciness)
    contact->restitution = 0;

    return 1;
}
