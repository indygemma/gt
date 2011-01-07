#ifndef __MY_LISTENER__
#define __MY_LISTENER__

#include "ExampleApplication.h"

class SampleApp;

class MyListener : public ExampleFrameListener
{
private:
    SampleApp* mApp;
    bool       mLeftMouseDown;
    bool       mRightMouseDown;
    bool       mMiddleMouseDown;
    bool       mSpaceKeyDown;
    Ogre::Real mTimer;

public:
    MyListener(SampleApp* app,RenderWindow* win, Camera* cam):
    ExampleFrameListener(win, cam), mLeftMouseDown(false), mTimer(0.0)
    {
        this->mApp = app;
    }

    virtual bool processUnbufferedMouseInput(const FrameEvent& evt);
    virtual bool processUnbufferedKeyInput(const FrameEvent& evt);
    virtual bool frameStarted(const FrameEvent& evt);
    virtual bool frameRenderingQueued(const FrameEvent& evt);
    bool frameEnded(const FrameEvent& evt);
};

#endif
