#include "main.h"

// NOTE: linux only it seems. need some win32-specific timing code if I decide to port later
// from http://www.gnu.org/s/libc/manual/html_node/Elapsed-Time.html
/* Subtract the `struct timeval' values X and Y,
    storing the result in RESULT.
    Return 1 if the difference is negative, otherwise 0.  */
int timeval_subtract (timeval* result,timeval* x,timeval* y)
{
    /* Perform the carry for the later subtraction by updating y. */
    if (x->tv_usec < y->tv_usec) {
        int nsec = (y->tv_usec - x->tv_usec) / 1000000 + 1;
        y->tv_usec -= 1000000 * nsec;
        y->tv_sec += nsec;
    }
    if (x->tv_usec - y->tv_usec > 1000000) {
        int nsec = (x->tv_usec - y->tv_usec) / 1000000;
        y->tv_usec += 1000000 * nsec;
        y->tv_sec -= nsec;
    }

    /* Compute the time remaining to wait.
       tv_usec is certainly positive. */
    result->tv_sec = x->tv_sec - y->tv_sec;
    result->tv_usec = x->tv_usec - y->tv_usec;

    /* Return 1 if result is negative. */
    return x->tv_sec < y->tv_sec;
}

Vector3 cycloneVec2OgreVec(cyclone::Vector3 vec) {
    return Vector3( vec.x, vec.y, vec.z );
}

SampleApp::SampleApp():
_particleGravity(cyclone::ParticleGravity(cyclone::Vector3(0, -9.81, 0))),
_particleBuoyancy(cyclone::ParticleBuoyancy(5, 0.1, -10, 1000)),
_world(new cyclone::ParticleWorld(1000))
{
}

SampleApp::~SampleApp() {
    destroyParticles();
}

void SampleApp::createCamera(void) {
    mCamera = mSceneMgr->createCamera("PlayerCam");
    mCamera->setPosition(Vector3(0,500,700));
    mCamera->lookAt(Vector3(0,0,0));
    mCamera->setNearClipDistance(5);

}

void SampleApp::createViewPorts(void) {
    Viewport* vport = mWindow->addViewport(mCamera);
    vport->setBackgroundColour(ColourValue(0,0,0));
    mCamera->setAspectRatio(Real(vport->getActualWidth()) / Real(vport->getActualHeight()));
}

void SampleApp::spawnBox(int x, int y, int z) {
    int d = 100;
    cyclone::Particle *p1 = spawnParticle(Vector3(x  ,y  ,z  ), Vector3(0,0,0));
    cyclone::Particle *p2 = spawnParticle(Vector3(x+d,y  ,z  ), Vector3(0,0,0));
    cyclone::Particle *p3 = spawnParticle(Vector3(x+d,y  ,z+d), Vector3(0,0,0));
    cyclone::Particle *p4 = spawnParticle(Vector3(x  ,y  ,z+d), Vector3(0,0,0));
    cyclone::Particle *p5 = spawnParticle(Vector3(x  ,y+d,z  ), Vector3(0,0,0));
    cyclone::Particle *p6 = spawnParticle(Vector3(x+d,y+d,z  ), Vector3(0,0,0));
    cyclone::Particle *p7 = spawnParticle(Vector3(x+d,y+d,z+d), Vector3(0,0,0));
    cyclone::Particle *p8 = spawnParticle(Vector3(x  ,y+d,z+d), Vector3(0,0,0));

    // TODO: setup rods between the particle points
    spawnRod(p1,p2);
    spawnRod(p2,p3);
    spawnRod(p3,p4);
    spawnRod(p1,p4);

    spawnRod(p5,p6);
    spawnRod(p6,p7);
    spawnRod(p7,p8);
    spawnRod(p5,p8);

    spawnRod(p1,p5);
    spawnRod(p2,p6);
    spawnRod(p3,p7);
    spawnRod(p4,p8);

    spawnRod(p1,p7);
    spawnRod(p2,p8);
    spawnRod(p3,p5);
    spawnRod(p4,p6);

    spawnRod(p1,p6);
    spawnRod(p2,p7);
    spawnRod(p3,p8);
    spawnRod(p4,p5);

    spawnRod(p1,p3);
    spawnRod(p2,p4);
    spawnRod(p5,p7);
    spawnRod(p6,p8);

    // TODO: add to forceregistry (gravity to all particles)
    // TODO: add the rods to the contact generators

}

void SampleApp::spawnParticles() {
    spawnParticle(Vector3(rand() % 200, 300, rand() % 200), Vector3(0,0,0));
}

cyclone::Particle* SampleApp::spawnParticle(Vector3 start, Vector3 direction) {
    // create an ogre representation of the particle
    Entity* ent = mSceneMgr->createEntity("sphere.mesh");
    ent->setCastShadows(true);

    int pos_x = start.x,
    pos_y     = start.y,
    pos_z     = start.z;

    SceneNode* node = mSceneMgr->getRootSceneNode()->createChildSceneNode(Vector3(pos_x, pos_y, pos_z));
    node->attachObject(ent);
    node->setScale(0.005, 0.005, 0.005); // TODO: modify these parameters
    ent->setMaterialName("Examples/SphereMappedRustySteel");

    // add this particle to the list of spawned particles, because we have to track active/non-active ones
    ParticleEntity* pe = new ParticleEntity;
    pe->node     = node;
    pe->isActive = true;
    gettimeofday(&pe->spawnTime, NULL);

    cyclone::Particle* particle = new cyclone::Particle();
    particle->setVelocity(cyclone::Vector3(0,0,0));
    particle->setMass(5); // TODO: modify these parameters
    particle->setPosition(pos_x, pos_y, pos_z);
    particle->setAcceleration(cyclone::Vector3(0,0,0));
    particle->setDamping(0.75); // TODO: modify these parameters

    pe->particle = particle;

    _world->addParticle(particle);
    _world->getForceRegistry().add(particle, &_particleGravity);
    // _world->getContactGenerators().push_back(rod)

    //_forceRegistry.add(particle, &_particleGravity);

    _particles.push_back(pe);

    return particle;
}

void SampleApp::spawnRod(cyclone::Particle* p1, cyclone::Particle* p2) {
    cyclone::ParticleRod *rod = new cyclone::ParticleRod();
    rod->particle[0] = p1;
    rod->particle[1] = p2;
    rod->length = Math::Sqrt(8);

    _world->getContactGenerators().push_back(rod);
}

void SampleApp::setupParticleDistanceContacts() {
    cyclone::ParticleWorld::Particles allParticles = _world->getParticles();
    cyclone::ParticleWorld::Particles allParticles2 = _world->getParticles();
    cyclone::ParticleSeperation *ps01;
    for (cyclone::ParticleWorld::Particles::iterator p = allParticles.begin();
        p != allParticles.end();
        p++)
    {
        for (cyclone::ParticleWorld::Particles::iterator p2 = allParticles2.begin();
        p2 != allParticles2.end();
        p2++)
        {
        cyclone::Particle *p01 = *p;
        cyclone::Particle *p02 = *p2;
        if(p01->getPosition() != p02->getPosition()){

                ps01 = new cyclone::ParticleSeperation();
                ps01->particle[0] = *p;
                ps01->particle[1] = *p2;
                ps01->length = 2.0;
                _world->getContactGenerators().push_back(ps01);
            }
        }
    }
}

void SampleApp::sweepParticles() {
    std::cout << "Going over particles and cleaning up" << std::endl;
    timeval now, diff;
    vpe_t particles_tmp;
    gettimeofday(&now, NULL);
    for (vpe_t_it it=_particles.begin(); it != _particles.end(); it++) {
        ParticleEntity* pe = (*it);
        timeval_subtract(&diff, &pe->spawnTime, &now);
        if (abs(diff.tv_sec) > 15) {
            std::cout << "15 seconds passed for particle " << pe << ". Removing..." << std::endl;;
            destroyParticle(pe);
        } else {
            particles_tmp.push_back(pe);
        }
    }
    _particles.clear();
    _particles = particles_tmp;
}

void SampleApp::destroyParticles() {
    for (vpe_t_it it=_particles.begin();it!=_particles.end();it++) {
        ParticleEntity* pe = (*it);
        if (pe != NULL)
            destroyParticle(pe);
    }
    _particles.clear();
}

void SampleApp::destroyParticle(ParticleEntity* pe) {
    pe->node->detachAllObjects();
    // NOTE: don't delete pe->node. Let the SceneManager handle that, otherwise this causes memory leak & segfault @clearScene
    delete pe;
    pe = NULL;
}

void SampleApp::update(const FrameEvent& evt) {
    if (evt.timeSinceLastFrame <= 0) {
        // do nothing if 0 or less
        return;
    }
    //_forceRegistry.updateForces(evt.timeSinceLastFrame);
    _world->startFrame();
    _world->runPhysics(evt.timeSinceLastFrame);
    for (vpe_t_it it = _particles.begin(); it != _particles.end(); it++) {
        ParticleEntity* pe = (*it);
        //std::cout << "Handling particle: " << pe << std::endl;
        if (pe->particle != NULL) {
            //std::cout << "Entered particle: " << pe << std::endl;
            cyclone::Vector3 oldVec3 = pe->particle->getPosition();
            //std::cout << "old position: " << oldVec3.x << " " << oldVec3.y << " " << oldVec3.z  << std::endl;
            pe->particle->integrate(evt.timeSinceLastFrame);
            cyclone::Vector3 newVec3 = pe->particle->getPosition();
            //std::cout << "new position: " << newVec3.x << " " << newVec3.y << " " << newVec3.z  << std::endl;
            pe->node->setPosition(cycloneVec2OgreVec(pe->particle->getPosition()));
        }
    }
}

void SampleApp::createScene(void)
{
    Entity* ent;
    Light* light;

    mSceneMgr->setAmbientLight( ColourValue( 1,1,1 ) );
    mSceneMgr->setShadowTechnique( SHADOWTYPE_STENCIL_ADDITIVE );

    spawnBox(0,400,0);

    // setup ground contacts
    cyclone::GroundContacts *ground_contact = new cyclone::GroundContacts();
    ground_contact->init(&_world->getParticles());
    _world->getContactGenerators().push_back(ground_contact);

    // setup particle distance contacts, when they stray too much afar
    setupParticleDistanceContacts();

    Plane plane(Vector3::UNIT_Y, 0);

    MeshManager::getSingleton().createPlane("ground",
        ResourceGroupManager::DEFAULT_RESOURCE_GROUP_NAME, plane,
        500, 500, 20, 20, true, 1, 5, 5, Vector3::UNIT_Z);

    ent = mSceneMgr->createEntity("GroundEntity", "ground");
    SceneNode* node = mSceneMgr->getRootSceneNode()->createChildSceneNode();
    node->attachObject(ent);
    node->setScale(2, 0, 2);
    node->setPosition(Vector3(0, -0.5, 0));
    ent->setMaterialName("Examples/Rockwall");
    ent->setCastShadows(false);

    light = mSceneMgr->createLight("Light3");
    light->setType(Light::LT_DIRECTIONAL);
    light->setDiffuseColour(ColourValue( .25, .25, 0));
    light->setSpecularColour(ColourValue( .25, .25, 0));
    light->setDirection(Vector3( 0, -1, 1 ));
}

void SampleApp::createFrameListener(void)
{
    mFrameListener = new MyListener(this, mWindow, mCamera);
    mFrameListener->showDebugOverlay(true);
    mRoot->addFrameListener(mFrameListener);
}
