#include "main.h"
#include <iostream>

bool MyListener::processUnbufferedKeyInput(const FrameEvent& evt) {
    if (mKeyboard->isKeyDown(OIS::KC_SPACE)) {
        mSpaceKeyDown = true;
    } else if (mSpaceKeyDown) {
        lua_pushstring(SCRIPT->L, "space");
        script_pcallback(SCRIPT, mApp->on_keypressed_ref, 1, 0);
        mSpaceKeyDown = false;
    }

    if(mKeyboard->isKeyDown(OIS::KC_L) && mTimeUntilNextToggle <= 0)
        {
            std::stringstream ss;
            ss << "screenshot_" << ++mNumScreenShots << ".png";
            mWindow->writeContentsToFile(ss.str());
            mTimeUntilNextToggle = 0.5;
            mDebugText = "Saved: " + ss.str();
        }
    return ExampleFrameListener::processUnbufferedKeyInput(evt);
}

bool MyListener::processUnbufferedMouseInput(const FrameEvent& evt) {
    const OIS::MouseState &ms = mMouse->getMouseState();
    if (ms.buttonDown( OIS::MB_Left ) ) {
        mLeftMouseDown = true;
    } else if (ms.buttonDown( OIS::MB_Right ) ) {
        mRightMouseDown = true;
    } else if (ms.buttonDown( OIS::MB_Middle ) ) {
        mMiddleMouseDown = true;
    } else if (mLeftMouseDown) {
        // left mouse released. initiate click
        //std::cout << "PRESSED LEFT MOUSE KEY: Spawning Particles" << std::endl;
        //mApp->spawnBox(0,400,0);

        // run callback
        lua_pushinteger(SCRIPT->L, 1);
        lua_pushinteger(SCRIPT->L, ms.X.abs);
        lua_pushinteger(SCRIPT->L, ms.Y.abs);
        lua_pushinteger(SCRIPT->L, ms.Z.abs);
        script_pcallback(SCRIPT, mApp->on_mouseclick_ref, 4, 0);
        script_stack_pop(SCRIPT, 0);

        mLeftMouseDown = false;
    } else if (mRightMouseDown) {
        //mApp->shootBall();

        // run callback
        lua_pushinteger(SCRIPT->L, 2);
        lua_pushinteger(SCRIPT->L, ms.X.abs);
        lua_pushinteger(SCRIPT->L, ms.Y.abs);
        lua_pushinteger(SCRIPT->L, ms.Z.abs);
        script_pcallback(SCRIPT, mApp->on_mouseclick_ref, 4, 0);
        script_stack_pop(SCRIPT, 0);

        mRightMouseDown = false;
    } else if (mMiddleMouseDown) {
        // run callback
        lua_pushinteger(SCRIPT->L, 3);
        lua_pushinteger(SCRIPT->L, ms.X.abs);
        lua_pushinteger(SCRIPT->L, ms.Y.abs);
        lua_pushinteger(SCRIPT->L, ms.Z.abs);
        script_pcallback(SCRIPT, mApp->on_mouseclick_ref, 4, 0);
        script_stack_pop(SCRIPT, 0);
        mMiddleMouseDown = false;
    }
    return ExampleFrameListener::processUnbufferedMouseInput(evt);
}

bool MyListener::frameStarted(const FrameEvent& evt)
{
    return ExampleFrameListener::frameStarted(evt);
}

bool MyListener::frameRenderingQueued(const FrameEvent& evt)
{
    mTimer += evt.timeSinceLastFrame;
    //if (mTimer >= 1.0) {
        //// sweep particles every second
        //std::cout << "Time accumulated: " << mTimer << std::endl;
        //mApp->sweepParticles();
        //mTimer = 0.0;
    //}
    mApp->update(evt);
    return ExampleFrameListener::frameRenderingQueued(evt);
}

bool MyListener::frameEnded(const FrameEvent& evt)
{
    return ExampleFrameListener::frameEnded(evt);
}
