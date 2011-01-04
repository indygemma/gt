#ifndef __APP__
#define __APP__

#include "main.h"
#include <sys/time.h> // warning linux only?
#include "pworld.h"

struct ParticleEntity {
    Ogre::SceneNode *   node;
    cyclone::Particle * particle;
    bool                isActive;
    bool                isTransient;
    timeval             spawnTime; // this might be linux-specific
};

typedef std::vector<ParticleEntity*>   vpe_t;
typedef vpe_t::iterator                vpe_t_it;
typedef cyclone::ParticleForceRegistry pfr_t;

class SampleApp : public ExampleApplication
{
public:
    SampleApp();
    ~SampleApp();

    void spawnBox(int x, int y, int z);

    void spawnParticles();
    ParticleEntity* spawnParticle(Vector3 start, Vector3 direction, bool isTransient);
    void spawnRod(cyclone::Particle* p1, cyclone::Particle* p2);
    void setupParticleDistanceContacts();
    void sweepParticles();
    void destroyParticles();
    void destroyParticle(ParticleEntity*);
    void update(const FrameEvent& evt);
    void setBuoyancy(float maxDepth, float volume, float waterHeight, float liquidDensity) { _particleBuoyancy = cyclone::ParticleBuoyancy(maxDepth, volume, waterHeight, liquidDensity); }
    void spawnBall();
    void shootBall();

    void addEntity(const char *name, const char *filename, const char *nodename,
                   int x, int y, int z);


    int on_mouseclick_ref;
    int on_scenesetup_ref;

private:

    cyclone::ParticleGravity  _particleGravity;
    cyclone::ParticleBuoyancy _particleBuoyancy;
    cyclone::ParticleWorld*   _world;
    ParticleEntity*           _ball;
    pfr_t _forceRegistry;
    vpe_t _particles;

protected:
    virtual void createCamera(void);
    virtual void createViewPorts(void);
    void createScene(void);
    void createFrameListener(void);
};

#endif
