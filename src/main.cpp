#include "main.h"

script_t *SCRIPT;
SampleApp *APP;

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
    // NOTE: somehow when defining script as a public member of SampleApp, Listener won't return the correct reference to lua refs. No problem if the ref is called within SampleApp
    // I think this has to do with the map, with char* as key. the address might have changed
    SCRIPT = script_new();
    script_bind(SCRIPT);
    script_run(SCRIPT, "autoexec.lua");
    std::cout << script_stack_size(SCRIPT) << std::endl;
    printf("address of script: %d\n", SCRIPT);
    //std::cout << script_stack_size(SCRIPT) << std::endl;
    //lua_pushinteger(SCRIPT->L, 1);
    //script_pcallback(SCRIPT, "game.on_mouseclick", 1, 0);
    //script_stack_pop(SCRIPT, 0);
    //std::cout << script_stack_size(SCRIPT) << std::endl;

    srand(time(NULL));
    try {
        APP = new SampleApp();
        APP->go();
    } catch (Ogre::Exception& e) {
#if OGRE_PLATFORM == OGRE_PLATFORM_WIN32
        MessageBoxA(NULL, e.getFullDescription().c_str(), "An exception has occured!", MB_OK | MB_ICONERROR | MB_TASKMODAL);
#else
        std::cerr << "Exception:\n";
        std::cerr << e.getFullDescription().c_str() << "\n";
#endif
        return 1;
    }

    delete APP;
    script_free(SCRIPT);

    return 0;
}

#ifdef __cplusplus
}
#endif
