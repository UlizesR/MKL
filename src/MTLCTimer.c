#include "Include/MTLCTimer.h"
#include <mach/mach_time.h>
#include <stdio.h>
#include <unistd.h>

static uint64_t _gStartTime;
static int _gInitialized = 0;

void MTLCInitTimer()
{
    if (!_gInitialized)
    {
        _gStartTime = mach_absolute_time();
        mach_timebase_info_data_t timebase_info;
        if (mach_timebase_info(&timebase_info) == KERN_SUCCESS)
        {
            _gInitialized = 1;
        }
        else
        {
            fprintf(stderr, "Error: Unable to get timebase info.\n");
        }
    }
}

unsigned int MTLCGetTicks()
{
    if (!_gInitialized)
    {
        return 0;
    }

    uint64_t current_time = mach_absolute_time();
    uint64_t elapsed_time = current_time - _gStartTime;

    // Convert elapsed time to milliseconds
    mach_timebase_info_data_t timebase_info;
    mach_timebase_info(&timebase_info);
    elapsed_time *= timebase_info.numer;
    elapsed_time /= timebase_info.denom;

    return (unsigned int)(elapsed_time / 1000000); // Convert to milliseconds
}

unsigned int MTLCTicks(int fps)
{
    if (!_gInitialized)
    {
        return 0;
    }

    static uint64_t previous_time = 0;
    uint64_t current_time = mach_absolute_time();
    uint64_t elapsed_time = current_time - previous_time;

    // Convert elapsed time to milliseconds
    mach_timebase_info_data_t timebase_info;
    mach_timebase_info(&timebase_info);
    elapsed_time *= timebase_info.numer;
    elapsed_time /= timebase_info.denom;
    unsigned int elapsed_ms = (unsigned int)(elapsed_time / 1000000);

    // Calculate the target frame time in milliseconds
    unsigned int target_frame_time = 1000 / fps;

    // Update the previous time
    previous_time = current_time;

    // Sleep only if the frame time is greater than the elapsed time
    if (target_frame_time > elapsed_ms)
    {
        usleep((target_frame_time - elapsed_ms) * 1000); // Sleep in microseconds
    }

    return elapsed_ms;
}

#define MAX_FPS_SAMPLES 10

unsigned int fps_samples[MAX_FPS_SAMPLES]; // Array to store FPS samples
int fps_sample_index = 0; // Index to track the current sample position

// Function to compute the average framerate
float MTLCGetFPS() {
    static unsigned int frame_count = 0;
    static unsigned int last_frame_time = 0;
    static float average_fps = 0.0;

    // Calculate elapsed time since the last frame
    unsigned int current_time = MTLCGetTicks();
    unsigned int elapsed_time = current_time - last_frame_time;
    last_frame_time = current_time;

    // Calculate the instantaneous framerate and store it in the array
    float instantaneous_fps = 1000.0 / (float)elapsed_time;
    fps_samples[fps_sample_index] = (unsigned int)instantaneous_fps;
    fps_sample_index = (fps_sample_index + 1) % MAX_FPS_SAMPLES;

    // Calculate the average framerate based on the last ten samples
    if (frame_count < MAX_FPS_SAMPLES) {
        frame_count++;
    }

    unsigned int sum_fps = 0;
    for (int i = 0; i < frame_count; i++) {
        sum_fps += fps_samples[i];
    }

    average_fps = (float)sum_fps / (float)frame_count;
    return average_fps;
}