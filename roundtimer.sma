/* Round Timer Plugin
 * Shows time remaining in scoreboard and plays voice countdown
 */

#include <amxmodx>
#include <amxmisc>

new g_iRoundTime
new g_iRoundStart

public plugin_init()
{
    register_plugin("Round Timer", "1.0", "Custom")
    
    // Set the round time from mp_timelimit (in minutes, convert to seconds)
    g_iRoundTime = get_cvar_num("mp_timelimit") * 60
    
    // Start the timer
    set_task(1.0, "check_time", 0, "", 0, "b")
    
    // Hook player scoreboard
    register_event("StatusValue", "show_time", "be", "1=2")
}

public plugin_cfg()
{
    g_iRoundStart = get_systime()
}

public check_time()
{
    new iElapsed = get_systime() - g_iRoundStart
    new iRemaining = g_iRoundTime - iElapsed
    
    // Voice countdown for last 10 seconds
    if(iRemaining <= 10 && iRemaining > 0)
    {
        new szNumber[16]
        num_to_word(iRemaining, szNumber, 15)
        
        client_cmd(0, "spk ^"vox/%s^"", szNumber)
        
        if(iRemaining == 10)
            client_print(0, print_chat, "[Round Timer] 10 seconds remaining!")
    }
    
    // Round end
    if(iRemaining <= 0)
    {
        client_cmd(0, "spk ^"vox/time is up^"")
        client_print(0, print_chat, "[Round Timer] Time is up! Changing map...")
        
        // Trigger map change
        server_cmd("mp_timelimit 0.1")
    }
}

public show_time(id)
{
    new iElapsed = get_systime() - g_iRoundStart
    new iRemaining = g_iRoundTime - iElapsed
    
    if(iRemaining < 0)
        iRemaining = 0
    
    new iMinutes = iRemaining / 60
    new iSeconds = iRemaining % 60
    
    set_hudmessage(255, 255, 255, -1.0, 0.01, 0, 0.0, 1.0, 0.0, 0.0, 4)
    show_hudmessage(id, "Time Remaining: %02d:%02d", iMinutes, iSeconds)
}
