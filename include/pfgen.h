#ifndef CYCLONE_PFGEN_H
#define CYCLONE_PFGEN_H

//#include "core.h"
#include "plinks.h"
//#include <rigidbody.h>
//#include <vector>

namespace cyclone {

    /**
* A force generator can be asked to add a force to one or more
* particles.
*/
    class ParticleForceGenerator
    {
    public:

        /**
* Overload this in implementations of the interface to calculate
* and update the force applied to the given particle.
*/
		virtual void updateForce(Particle *particle, Ogre::Real duration) = 0;
    };

    /**
* A force generator that applies a gravitational force. One instance
* can be used for multiple particles.
*/
    class ParticleGravity : public ParticleForceGenerator
    {
        /** Holds the acceleration due to gravity. */
		Ogre::Vector3 gravity;

    public:

        /** Creates the generator with the given acceleration. */
		ParticleGravity(const Ogre::Vector3 &gravity);

        /** Applies the gravitational force to the given particle. */
		virtual void updateForce(Particle *particle, Ogre::Real duration);
    };

    /**
* A force generator that applies a drag force. One instance
* can be used for multiple particles.
*/
    class ParticleDrag : public ParticleForceGenerator
    {
        /** Holds the velocity drag coeffificent. */
		Ogre::Real k1;

        /** Holds the velocity squared drag coeffificent. */
		Ogre::Real k2;

    public:

        /** Creates the generator with the given coefficients. */
		ParticleDrag(Ogre::Real k1, Ogre::Real k2);

        /** Applies the drag force to the given particle. */
		virtual void updateForce(Particle *particle, Ogre::Real duration);
    };

    /**
* A force generator that applies a Spring force, where
* one end is attached to a fixed point in space.
*/
    class ParticleAnchoredSpring : public ParticleForceGenerator
    {
    protected:
        /** The location of the anchored end of the spring. */
		Ogre::Vector3 *anchor;

        /** Holds the sprint constant. */
		Ogre::Real springConstant;

        /** Holds the rest length of the spring. */
		Ogre::Real restLength;

    public:
        ParticleAnchoredSpring();

        /** Creates a new spring with the given parameters. */
		ParticleAnchoredSpring(Ogre::Vector3 *anchor,
			Ogre::Real springConstant,
			Ogre::Real restLength);

        /** Retrieve the anchor point. */
		const Ogre::Vector3* getAnchor() const { return anchor; }

        /** Set the spring's properties. */
		void init(Ogre::Vector3 *anchor,
			Ogre::Real springConstant,
			Ogre::Real restLength);

        /** Applies the spring force to the given particle. */
		virtual void updateForce(Particle *particle, Ogre::Real duration);
    };

    /**
* A force generator that applies a bungee force, where
* one end is attached to a fixed point in space.
*/
    class ParticleAnchoredBungee : public ParticleAnchoredSpring
    {
    public:
        /** Applies the spring force to the given particle. */
		virtual void updateForce(Particle *particle, Ogre::Real duration);
    };

    /**
* A force generator that fakes a stiff spring force, and where
* one end is attached to a fixed point in space.
*/
    class ParticleFakeSpring : public ParticleForceGenerator
    {
        /** The location of the anchored end of the spring. */
		Ogre::Vector3 *anchor;

        /** Holds the sprint constant. */
		Ogre::Real springConstant;

        /** Holds the damping on the oscillation of the spring. */
		Ogre::Real damping;

    public:

        /** Creates a new spring with the given parameters. */
		ParticleFakeSpring(Ogre::Vector3 *anchor, Ogre::Real springConstant,
			Ogre::Real damping);

        /** Applies the spring force to the given particle. */
		virtual void updateForce(Particle *particle, Ogre::Real duration);
    };

    /**
* A force generator that applies a Spring force.
*/
    class ParticleSpring : public ParticleForceGenerator
    {
        /** The particle at the other end of the spring. */
        Particle *other;

        /** Holds the sprint constant. */
		Ogre::Real springConstant;

        /** Holds the rest length of the spring. */
		Ogre::Real restLength;

    public:

        /** Creates a new spring with the given parameters. */
        ParticleSpring(Particle *other,
			Ogre::Real springConstant, Ogre::Real restLength);

        /** Applies the spring force to the given particle. */
		virtual void updateForce(Particle *particle, Ogre::Real duration);
    };

    /**
* A force generator that applies a spring force only
* when extended.
*/
    class ParticleBungee : public ParticleForceGenerator
    {
        /** The particle at the other end of the spring. */
        Particle *other;

        /** Holds the sprint constant. */
		Ogre::Real springConstant;

        /**
* Holds the length of the bungee at the point it begins to
* generator a force.
*/
		Ogre::Real restLength;

    public:

        /** Creates a new bungee with the given parameters. */
        ParticleBungee(Particle *other,
			Ogre::Real springConstant, Ogre::Real restLength);

        /** Applies the spring force to the given particle. */
		virtual void updateForce(Particle *particle, Ogre::Real duration);
    };

    /**
* A force generator that applies a buoyancy force for a plane of
* liquid parrallel to XZ plane.
*/
    class ParticleBuoyancy : public ParticleForceGenerator
    {
        /**
* The maximum submersion depth of the object before
* it generates its maximum boyancy force.
*/
		Ogre::Real maxDepth;

        /**
* The volume of the object.
*/
		Ogre::Real volume;

        /**
* The height of the water plane above y=0. The plane will be
* parrallel to the XZ plane.
*/
		Ogre::Real waterHeight;

        /**
* The density of the liquid. Pure water has a density of
* 1000kg per cubic meter.
*/
		Ogre::Real liquidDensity;

    public:

        /** Creates a new buoyancy force with the given parameters. */
		ParticleBuoyancy(Ogre::Real maxDepth, Ogre::Real volume, Ogre::Real waterHeight,
			Ogre::Real liquidDensity = 1000.0f);

        /** Applies the buoyancy force to the given particle. */
		virtual void updateForce(Particle *particle, Ogre::Real duration);
    };

    /**
* Holds all the force generators and the particles they apply to.
*/
    class ParticleForceRegistry
    {
    protected:

        /**
* Keeps track of one force generator and the particle it
* applies to.
*/
        struct ParticleForceRegistration
        {
            Particle *particle;
            ParticleForceGenerator *fg;
        };

        /**
* Holds the list of registrations.
*/
        typedef std::vector<ParticleForceRegistration> Registry;
        Registry registrations;

    public:
        /**
* Registers the given force generator to apply to the
* given particle.
*/
        void add(Particle* particle, ParticleForceGenerator *fg);

        /**
* Removes the given registered pair from the registry.
* If the pair is not registered, this method will have
* no effect.
*/
        void remove(Particle* particle, ParticleForceGenerator *fg);

        /**
* Clears all registrations from the registry. This will
* not delete the particles or the force generators
* themselves, just the records of their connection.
*/
        void clear();

        /**
* Calls all the force generators to update the forces of
* their corresponding particles.
*/
		void updateForces(Ogre::Real duration);
    };






}




#endif // CYCLONE_PFGEN_H
