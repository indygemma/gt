#include "main.h"

#ifdef __cplusplus
extern "C" {
#endif

#if OGRE_PLATFORM == OGRE_PLATFORM_WIN32
#define WIN32_LEAN_AND_MEAN
#include "windows.h"
int WINAPI WinMain(HINSTANCE hInst, HINSTANCE, LPSTR strCmdLine, int)
#else
int main(int argc, char **argv)
#endif
{
    srand(time(NULL));
    try {
        SampleApp app;
        app.go();
    } catch (Ogre::Exception& e) {
#if OGRE_PLATFORM == OGRE_PLATFORM_WIN32
        MessageBoxA(NULL, e.getFullDescription().c_str(), "An exception has occured!", MB_OK | MB_ICONERROR | MB_TASKMODAL);
#else
        std::cerr << "Exception:\n";
        std::cerr << e.getFullDescription().c_str() << "\n";
#endif
        return 1;
    }

    return 0;
}

#ifdef __cplusplus
}
#endif
