globals
//globals from GameStatus:
constant boolean LIBRARY_GameStatus=true
        //-------------------------------------------------------------------
        // A game cache will be used to determine if the game is an online
        // multiplayer game.
        //
constant string GameStatus___CACHE_PATH= "GAME_STATUS"
        
        //-------------------------------------------------------------------
constant integer GAME_STATUS_OFFLINE= 0
constant integer GAME_STATUS_ONLINE= 1
constant integer GAME_STATUS_REPLAY= 2
        
        //-------------------------------------------------------------------
        // If ReloadGameCachesFromDisk returns true, cheats can be used (it's
        // an offline game).
        //
integer GameStatus___status= IntegerTertiaryOp(ReloadGameCachesFromDisk(), GAME_STATUS_OFFLINE, GAME_STATUS_REPLAY)
integer GameStatus___n= - 1
trigger GameStatus___t= CreateTrigger()
triggeraction array GameStatus___funcs
//endglobals from GameStatus
    // User-defined
timer udg_pst= null
integer udg_isPause= 0
dialog udg_pauseDialog= null
button udg_btn= null
timerdialog udg_timerDialog= null
player udg_pausePlayer= null
integer array udg_playerPauses
boolean udg_allowEnd= false
integer array udg_playerScore
integer udg_winnerteam= 0
string udg_li

    // Generated
trigger gg_trg_Melee_Initialization= null
trigger gg_trg_GS= null
trigger gg_trg_Untitled_Trigger_001= null

trigger l__library_init

//JASSHelper struct globals:

endglobals


//library GameStatus:
    
    //=======================================================================
    function GetGameStatus takes nothing returns integer
        return GameStatus___status
    endfunction
    
    //=======================================================================
    function OnGameStatusFound takes code func returns nothing
        set GameStatus___n=GameStatus___n + 1
        set GameStatus___funcs[GameStatus___n]=TriggerAddAction(GameStatus___t, func)
    endfunction
    
    function GameStatus___Execute takes nothing returns nothing
        call TriggerExecute(GameStatus___t)
        loop
            exitwhen GameStatus___n < 0
            call TriggerRemoveAction(GameStatus___t, GameStatus___funcs[GameStatus___n])
            set GameStatus___funcs[GameStatus___n]=null
            set GameStatus___n=GameStatus___n - 1
        endloop
        call DestroyTrigger(GameStatus___t)
        set GameStatus___t=null
    endfunction
    
    //=======================================================================
     function GameStatus___failSafePrivateFunction takes nothing returns nothing
        call TriggerSleepAction(0)
        call GameStatus___Execute()
    endfunction
    
    //=======================================================================
    function GameStatus___Ini takes nothing returns nothing
        local boolean b= false
        local integer i= 12
        local gamecache g
        local string s= ""
        if bj_isSinglePlayer then
            //Execute a failsafe function because a replay of an offline
            //single-player game will crash the thread if it uses a
            //TriggerSyncReady/TriggerSleepAction which wasn't originally
            //in the game.
            call ExecuteFunc("GameStatus___failSafePrivateFunction")
            if GameStatus___status != GAME_STATUS_OFFLINE then
                call TriggerSyncReady()
                //If the thread didn't crash, the game is an online single
                //player game or is a replay of one. Better just say "online"
                //to be safe because no one has found a way to detect it that
                //can't be abused.
                set GameStatus___status=GAME_STATUS_ONLINE
            endif
        else
            //Flush the cache just in case it didn't get to that point
            //last time.
            call FlushGameCache(InitGameCache(GameStatus___CACHE_PATH))
            set g=InitGameCache(GameStatus___CACHE_PATH)
            loop
                set i=i - 1
                set s=I2S(i)
                if GetLocalPlayer() == Player(i) then
                    //Broadcast the boolean to all players.
                    call StoreBoolean(g, "", s, true)
                    call SyncStoredBoolean(g, "", s)
                endif
                exitwhen i == 0
            endloop
            call TriggerSyncReady()
            loop
                //A replay will show only 1 player has the boolean.
                if GetStoredBoolean(g, "", I2S(i)) then
                    if b then
                        set GameStatus___status=GAME_STATUS_ONLINE
                        exitwhen true
                    endif
                    set b=true
                endif
                set i=i + 1
                exitwhen i == 12
            endloop
            call FlushGameCache(g)
            set g=null
            call GameStatus___Execute()
        endif
    endfunction
    

//library GameStatus ends
//===========================================================================
// 
// CRAPPY
// 
//   Warcraft III map script
//   Generated by the Warcraft III World Editor
//   Date: Mon Jul 07 20:38:46 2014
//   Map Author: Blizzard Entertainment
// 
//===========================================================================

//***************************************************************************
//*
//*  Global Variables
//*
//***************************************************************************


function InitGlobals takes nothing returns nothing
    local integer i= 0
    set udg_pst=CreateTimer()
    set udg_isPause=0
    set udg_pauseDialog=DialogCreate()
    set i=0
    loop
        exitwhen ( i > 12 )
        set udg_playerPauses[i]=0
        set i=i + 1
    endloop

    set udg_allowEnd=true
    set i=0
    loop
        exitwhen ( i > 12 )
        set udg_playerScore[i]=0
        set i=i + 1
    endloop

    set udg_winnerteam=- 1
    set udg_li=""
endfunction

//***************************************************************************
//*
//*  Unit Item Tables
//*
//***************************************************************************

function Unit000007_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 4), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

        // Item set 1
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000015_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 6), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

        // Item set 1
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000022_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 2), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000034_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000041_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 4), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

        // Item set 1
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000043_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 4), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

        // Item set 1
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000044_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 2), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000046_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000052_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 5), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000053_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 5), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000055_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000057_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 4), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

        // Item set 1
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000058_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 6), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

        // Item set 1
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000063_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 2), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000066_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 6), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

        // Item set 1
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000069_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 6), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

        // Item set 1
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000077_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 2), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000078_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000081_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 4), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000085_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 4), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction


//***************************************************************************
//*
//*  Unit Creation
//*
//***************************************************************************

//===========================================================================
function CreateNeutralHostile takes nothing returns nothing
    local player p= Player(PLAYER_NEUTRAL_AGGRESSIVE)
    local unit u
    local integer unitID
    local trigger t
    local real life

    set u=CreateUnit(p, 'nogr', 4161.6, 1505.6, 183.592)
    call SetUnitAcquireRange(u, 200.0)
    set t=CreateTrigger()
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    call TriggerAddAction(t, function Unit000044_DropItems)
    set u=CreateUnit(p, 'nftb', 4224.9, 1662.3, 210.237)
    call SetUnitAcquireRange(u, 200.0)
    set t=CreateTrigger()
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    call TriggerAddAction(t, function Unit000034_DropItems)
    set u=CreateUnit(p, 'nogr', - 4272.3, 1440.5, 334.348)
    call SetUnitAcquireRange(u, 200.0)
    set t=CreateTrigger()
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    call TriggerAddAction(t, function Unit000077_DropItems)
    set u=CreateUnit(p, 'nftb', - 3988.9, - 2177.4, 35.415)
    call SetUnitAcquireRange(u, 200.0)
    set t=CreateTrigger()
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    call TriggerAddAction(t, function Unit000046_DropItems)
    set u=CreateUnit(p, 'nits', 4665.0, 4497.5, 221.508)
    set u=CreateUnit(p, 'nits', 4984.6, 4285.1, 186.559)
    set u=CreateUnit(p, 'nits', - 5235.9, 4225.1, 322.371)
    set u=CreateUnit(p, 'nits', - 5019.8, 4542.1, 294.526)
    set u=CreateUnit(p, 'nomg', - 41.6, 4411.9, 0.000)
    set t=CreateTrigger()
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    call TriggerAddAction(t, function Unit000007_DropItems)
    set u=CreateUnit(p, 'nitp', - 181.0, 4176.1, 262.564)
    set u=CreateUnit(p, 'nitp', 91.4, 4217.6, 285.085)
    set u=CreateUnit(p, 'nitt', - 44.2, 4252.3, 7.581)
    set u=CreateUnit(p, 'nits', 4820.3, - 5022.8, 160.430)
    set u=CreateUnit(p, 'nitp', - 4082.1, - 1938.2, 0.000)
    call SetUnitAcquireRange(u, 200.0)
    set u=CreateUnit(p, 'nitw', - 5140.3, 4457.4, 0.000)
    set t=CreateTrigger()
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    call TriggerAddAction(t, function Unit000066_DropItems)
    set u=CreateUnit(p, 'nits', 4713.2, - 5391.3, 132.585)
    set u=CreateUnit(p, 'nits', - 4881.0, - 5395.4, 44.422)
    set u=CreateUnit(p, 'nogm', - 5080.8, 4064.3, 326.254)
    set u=CreateUnit(p, 'nits', - 5165.2, - 5137.6, 16.577)
    set u=CreateUnit(p, 'nogr', 3923.6, - 2046.0, 183.592)
    call SetUnitAcquireRange(u, 200.0)
    set t=CreateTrigger()
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    call TriggerAddAction(t, function Unit000063_DropItems)
    set u=CreateUnit(p, 'nogm', - 4913.4, 4282.2, 295.700)
    set u=CreateUnit(p, 'nitp', - 133.1, - 5151.5, 65.114)
    set u=CreateUnit(p, 'nitp', 138.5, - 5104.5, 108.096)
    set u=CreateUnit(p, 'nogr', 212.6, - 5298.0, 109.195)
    set u=CreateUnit(p, 'nomg', 3.8, - 5343.1, 86.755)
    set t=CreateTrigger()
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    call TriggerAddAction(t, function Unit000041_DropItems)
    set u=CreateUnit(p, 'nitt', 3.3, - 5183.4, 85.366)
    set u=CreateUnit(p, 'nogr', - 204.7, - 5315.4, 65.501)
    set u=CreateUnit(p, 'nwnr', 4696.2, - 442.1, 170.044)
    call SetUnitAcquireRange(u, 200.0)
    set t=CreateTrigger()
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    call TriggerAddAction(t, function Unit000043_DropItems)
    set u=CreateUnit(p, 'nfps', 4672.6, - 645.7, 156.399)
    call SetUnitState(u, UNIT_STATE_MANA, 0)
    call SetUnitAcquireRange(u, 200.0)
    set u=CreateUnit(p, 'nfps', 4692.0, - 200.0, 199.950)
    call SetUnitState(u, UNIT_STATE_MANA, 0)
    call SetUnitAcquireRange(u, 200.0)
    set u=CreateUnit(p, 'nfpl', 4520.7, - 412.5, 179.074)
    call SetUnitAcquireRange(u, 200.0)
    set u=CreateUnit(p, 'nftb', 3986.9, - 1889.2, 210.237)
    call SetUnitAcquireRange(u, 200.0)
    set t=CreateTrigger()
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    call TriggerAddAction(t, function Unit000055_DropItems)
    set u=CreateUnit(p, 'nfps', - 5019.1, - 203.4, 330.578)
    call SetUnitState(u, UNIT_STATE_MANA, 0)
    call SetUnitAcquireRange(u, 200.0)
    set u=CreateUnit(p, 'nfps', - 5083.6, - 644.8, 14.129)
    call SetUnitState(u, UNIT_STATE_MANA, 0)
    call SetUnitAcquireRange(u, 200.0)
    set u=CreateUnit(p, 'nfpl', - 4891.7, - 450.8, 353.252)
    call SetUnitAcquireRange(u, 200.0)
    set u=CreateUnit(p, 'nftb', - 4281.8, 1276.6, 0.993)
    call SetUnitAcquireRange(u, 200.0)
    set t=CreateTrigger()
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    call TriggerAddAction(t, function Unit000078_DropItems)
    set u=CreateUnit(p, 'nitp', - 4218.5, 1613.0, 325.578)
    call SetUnitAcquireRange(u, 200.0)
    set u=CreateUnit(p, 'nogr', - 3940.0, - 2015.6, 8.770)
    call SetUnitAcquireRange(u, 200.0)
    set t=CreateTrigger()
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    call TriggerAddAction(t, function Unit000022_DropItems)
    set u=CreateUnit(p, 'nitp', 4058.1, - 2135.8, 174.822)
    call SetUnitAcquireRange(u, 200.0)
    set u=CreateUnit(p, 'nitp', 4296.1, 1415.7, 174.822)
    call SetUnitAcquireRange(u, 200.0)
    set u=CreateUnit(p, 'nitw', 4898.4, 4404.6, 199.152)
    set t=CreateTrigger()
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    call TriggerAddAction(t, function Unit000069_DropItems)
    set u=CreateUnit(p, 'nogm', 4506.0, 4340.5, 218.180)
    set u=CreateUnit(p, 'nogm', 4725.9, 4175.7, 174.716)
    set u=CreateUnit(p, 'nitw', 4801.5, - 5273.4, 198.059)
    set t=CreateTrigger()
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    call TriggerAddAction(t, function Unit000015_DropItems)
    set u=CreateUnit(p, 'nogm', 4623.1, - 4918.0, 164.313)
    set u=CreateUnit(p, 'nogm', 4531.5, - 5177.2, 133.758)
    set u=CreateUnit(p, 'nogm', - 146.9, 2349.1, 275.819)
    call SetUnitAcquireRange(u, 200.0)
    set u=CreateUnit(p, 'nogm', 231.4, 2486.4, 291.966)
    call SetUnitAcquireRange(u, 200.0)
    set u=CreateUnit(p, 'nitp', - 252.1, 2528.5, 241.430)
    call SetUnitAcquireRange(u, 200.0)
    set u=CreateUnit(p, 'nitw', 46.5, 2366.8, 276.449)
    call SetUnitAcquireRange(u, 200.0)
    set t=CreateTrigger()
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    call TriggerAddAction(t, function Unit000053_DropItems)
    set u=CreateUnit(p, 'nitr', 200.5, 2310.9, 275.070)
    call SetUnitAcquireRange(u, 200.0)
    set u=CreateUnit(p, 'nitw', - 59.8, - 3318.6, 96.449)
    call SetUnitAcquireRange(u, 200.0)
    set t=CreateTrigger()
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    call TriggerAddAction(t, function Unit000052_DropItems)
    set u=CreateUnit(p, 'nogr', - 251.2, 4371.1, 275.727)
    set u=CreateUnit(p, 'nitr', - 213.8, - 3262.7, 95.070)
    call SetUnitAcquireRange(u, 200.0)
    set u=CreateUnit(p, 'nitp', 238.8, - 3480.3, 61.430)
    call SetUnitAcquireRange(u, 200.0)
    set u=CreateUnit(p, 'nogr', 166.4, 4380.0, 275.727)
    set u=CreateUnit(p, 'nitw', - 5097.9, - 5268.6, 82.051)
    set t=CreateTrigger()
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    call TriggerAddAction(t, function Unit000058_DropItems)
    set u=CreateUnit(p, 'nogm', - 4700.3, - 5264.0, 48.305)
    set u=CreateUnit(p, 'nogm', - 4893.0, - 5068.1, 17.751)
    set u=CreateUnit(p, 'nwnr', - 5046.6, - 466.0, 9.270)
    call SetUnitAcquireRange(u, 200.0)
    set t=CreateTrigger()
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    call TriggerAddAction(t, function Unit000057_DropItems)
    set u=CreateUnit(p, 'nomg', - 1528.1, - 426.7, 188.560)
    call SetUnitAcquireRange(u, 200.0)
    set t=CreateTrigger()
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    call TriggerAddAction(t, function Unit000081_DropItems)
    set u=CreateUnit(p, 'nogm', - 244.8, - 3438.1, 111.966)
    call SetUnitAcquireRange(u, 200.0)
    set u=CreateUnit(p, 'nogm', 133.6, - 3300.9, 95.819)
    call SetUnitAcquireRange(u, 200.0)
    set u=CreateUnit(p, 'nogr', - 1590.5, - 206.4, 160.820)
    call SetUnitAcquireRange(u, 200.0)
    set u=CreateUnit(p, 'nogr', - 1586.8, - 583.8, 183.410)
    call SetUnitAcquireRange(u, 200.0)
    set u=CreateUnit(p, 'nitt', - 1436.2, - 536.9, 185.660)
    call SetUnitAcquireRange(u, 200.0)
    set u=CreateUnit(p, 'nomg', 1765.8, - 439.3, 7.560)
    call SetUnitAcquireRange(u, 200.0)
    set t=CreateTrigger()
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    call TriggerAddAction(t, function Unit000085_DropItems)
    set u=CreateUnit(p, 'nogr', 1837.0, - 242.3, 345.700)
    call SetUnitAcquireRange(u, 200.0)
    set u=CreateUnit(p, 'nogr', 1829.0, - 623.7, 11.200)
    call SetUnitAcquireRange(u, 200.0)
    set u=CreateUnit(p, 'nitt', 1678.6, - 571.0, 4.120)
    call SetUnitAcquireRange(u, 200.0)
    set u=CreateUnit(p, 'nitt', 1670.2, - 228.8, 342.730)
    call SetUnitAcquireRange(u, 200.0)
    set u=CreateUnit(p, 'nitt', - 1439.6, - 237.9, 180.620)
    call SetUnitAcquireRange(u, 200.0)
endfunction

//===========================================================================
function CreateNeutralPassiveBuildings takes nothing returns nothing
    local player p= Player(PLAYER_NEUTRAL_PASSIVE)
    local unit u
    local integer unitID
    local trigger t
    local real life

    set u=CreateUnit(p, 'ngol', - 5440.0, 4672.0, 270.000)
    call SetResourceAmount(u, 14000)
    set u=CreateUnit(p, 'ngol', 5312.0, 4672.0, 270.000)
    call SetResourceAmount(u, 14000)
    set u=CreateUnit(p, 'ngme', - 1216.0, - 448.0, 270.000)
    set u=CreateUnit(p, 'ngme', 1472.0, - 448.0, 270.000)
    set u=CreateUnit(p, 'nfoh', 0.0, 2688.0, 270.000)
    set u=CreateUnit(p, 'ngol', 512.0, - 5824.0, 270.000)
    call SetResourceAmount(u, 10000)
    set u=CreateUnit(p, 'ngol', 5312.0, - 5504.0, 270.000)
    call SetResourceAmount(u, 14000)
    set u=CreateUnit(p, 'ngol', - 5312.0, - 448.0, 270.000)
    call SetResourceAmount(u, 15000)
    set u=CreateUnit(p, 'ngol', 5056.0, - 512.0, 270.000)
    call SetResourceAmount(u, 15000)
    set u=CreateUnit(p, 'ngol', - 512.0, - 5824.0, 270.000)
    call SetResourceAmount(u, 10000)
    set u=CreateUnit(p, 'ngol', 512.0, 4800.0, 270.000)
    call SetResourceAmount(u, 10000)
    set u=CreateUnit(p, 'ngol', - 512.0, 4800.0, 270.000)
    call SetResourceAmount(u, 10000)
    set u=CreateUnit(p, 'nfoh', 0.0, - 3584.0, 270.000)
    set u=CreateUnit(p, 'ntav', 128.0, - 256.0, 270.000)
    call SetUnitColor(u, ConvertPlayerColor(0))
    set u=CreateUnit(p, 'ngol', - 5440.0, - 5504.0, 270.000)
    call SetResourceAmount(u, 14000)
endfunction

//===========================================================================
function CreatePlayerBuildings takes nothing returns nothing
endfunction

//===========================================================================
function CreatePlayerUnits takes nothing returns nothing
endfunction

//===========================================================================
function CreateAllUnits takes nothing returns nothing
    call CreateNeutralPassiveBuildings()
    call CreatePlayerBuildings()
    call CreateNeutralHostile()
    call CreatePlayerUnits()
endfunction

//***************************************************************************
//*
//*  Triggers
//*
//***************************************************************************

//===========================================================================
// Trigger: Melee Initialization
//
// Default melee game initialization for all players
//===========================================================================
//TESH.scrollpos=586
//TESH.alwaysfold=0
function getHCL takes nothing returns string
        local integer i
        local integer j
        local integer h
        local integer v
        local string chars= "abcdefghijklmnopqrstuvwxyz0123456789 -=,."
        local integer array map
        local boolean array blocked
        local string command= ""

        //precompute mapping [have to avoid invalid and normal handicaps]
        set blocked[0]=true
        set blocked[50]=true
        set blocked[60]=true
        set blocked[70]=true
        set blocked[80]=true
        set blocked[90]=true
        set blocked[100]=true
        set i=0
        set j=0
        loop
            if blocked[j] then
                set j=j + 1
            endif
            exitwhen j >= 256
            set map[j]=i
            set i=i + 1
            set j=j + 1
        endloop
        
        //Extract command string from player handicaps
        set i=0
        loop
            exitwhen i >= 12
            set h=R2I(100 * GetPlayerHandicap(Player(i)) + 0.5)
            if not blocked[h] then
                set h=map[h]
                set v=h / 6
                set h=h - v * 6
                call SetPlayerHandicap(Player(i), 0.5 + h / 10.0)
                set command=command + SubString(chars, v, v + 1)
            endif
            set i=i + 1
        endloop

     return command
endfunction
    
function pack takes string value returns string
        local integer j
        local integer i= 0
        local string result= ""
        local string c
        local string ESCAPED_CHARS= " \\"
        
        loop //for each character in argument string
            exitwhen i >= StringLength(value)
            set c=SubString(value, i, i + 1)
            set j=0
            loop //for each character in escaped chars string
                exitwhen j >= StringLength(ESCAPED_CHARS)
                //escape control characters
                if c == SubString(ESCAPED_CHARS, j, j + 1) then
                    set c="\\" + c
                    exitwhen true
                endif
                set j=j + 1
            endloop
            set result=result + c
            set i=i + 1
        endloop
        return result
endfunction

function initPlayerFlag takes nothing returns nothing
    local integer i
    local gamecache g= InitGameCache("MMD.Dat")

        set i=0
        loop
            exitwhen i >= 12
            if GetPlayerController(Player(i)) == MAP_CONTROL_USER and GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
                call StoreInteger(g, "val:999" + I2S(i), "init pid " + I2S(i) + " " + pack(GetPlayerName(Player(i))), 1)
                call StoreInteger(g, "chk:999" + I2S(i), "999" + I2S(i), 1)
 
                call SyncStoredInteger(g, "val:999" + I2S(i), "init pid " + I2S(i) + " " + pack(GetPlayerName(Player(i))))
                call SyncStoredInteger(g, "chk:999" + I2S(i), "999" + I2S(i))

            endif
            set i=i + 1
        endloop

        set i=0
        loop
            exitwhen i >= 12
            if GetPlayerController(Player(i)) == MAP_CONTROL_USER and GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
                call StoreInteger(g, "val:1", "FlagP " + I2S(GetPlayerId(Player(i))) + " winner", 1)
                call StoreInteger(g, "chk:1", "1", 1)

                call SyncStoredInteger(g, "val:1", "FlagP " + I2S(GetPlayerId(Player(i))) + " winner")
                call SyncStoredInteger(g, "chk:1", "1")
            endif
            set i=i + 1
        endloop

    call FlushGameCache(g)
    set g=null
endfunction

function flagPlayer takes player p,string s returns nothing
    local integer i
    local gamecache g= InitGameCache("MMD.Dat")

    call StoreInteger(g, "val:1", "FlagP " + I2S(GetPlayerId(p)) + " " + s, 1)
    call SyncStoredInteger(g, "val:1", "FlagP " + I2S(GetPlayerId(p)) + " " + s)
    call FlushGameCache(g)
    set g=null

endfunction



function myLose takes integer ievent returns nothing
    local boolean gameover= true
    local integer i= 0
    local integer team= - 1

    call flagPlayer(GetTriggerPlayer() , "loser")


    set i=0
    loop
        exitwhen i >= 12
        if GetPlayerController(Player(i)) == MAP_CONTROL_USER and GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING and Player(i) != GetTriggerPlayer() then
            if team < 0 then
                set team=GetPlayerTeam(Player(i))
            endif
            
            if team != GetPlayerTeam(Player(i)) then
                set gameover=false
            endif
        endif
        set i=i + 1
    endloop
        
    if gameover then
        call DisplayTextToForce(GetPlayersAll(), "|cff43A9FFW3A|cffffffffrena game over! Submitting results..")
        call PolledWait(1)
    endif


    if ievent == 1 then
        call MeleeTriggerActionPlayerDefeated()
    elseif ievent == 2 then
        call MeleeTriggerActionPlayerLeft()
    endif

    
endfunction

function myLose_0 takes nothing returns nothing
    call myLose(0)
endfunction

function myLose_1 takes nothing returns nothing
    call myLose(1)
endfunction

function myLose_2 takes nothing returns nothing
    call myLose(2)
endfunction


function myChkLose takes nothing returns nothing
   if ( GetPlayerStructureCount(GetTriggerPlayer(), true) == 0 ) then
       call myLose(0)
   endif
endfunction



function myMeleeInitVictoryDefeat takes nothing returns nothing
    local trigger trig
    local integer index
    local player indexPlayer

    // Create a timer window for the "finish soon" timeout period, it has no timer
    // because it is driven by real time (outside of the game state to avoid desyncs)
    set bj_finishSoonTimerDialog=CreateTimerDialog(null)

    // Set a trigger to fire when we receive a "finish soon" game event
    set trig=CreateTrigger()
    call TriggerRegisterGameEvent(trig, EVENT_GAME_TOURNAMENT_FINISH_SOON)
    call TriggerAddAction(trig, function MeleeTriggerTournamentFinishSoon)

    // Set a trigger to fire when we receive a "finish now" game event
    set trig=CreateTrigger()
    call TriggerRegisterGameEvent(trig, EVENT_GAME_TOURNAMENT_FINISH_NOW)
    call TriggerAddAction(trig, function MeleeTriggerTournamentFinishNow)

    // Set up each player's mortality code.
    set index=0
    loop
        set indexPlayer=Player(index)

        // Make sure this player slot is playing.
        if ( GetPlayerSlotState(indexPlayer) == PLAYER_SLOT_STATE_PLAYING ) then
            set bj_meleeDefeated[index]=false
            set bj_meleeVictoried[index]=false

            // Create a timer and timer window in case the player is crippled.
            set bj_playerIsCrippled[index]=false
            set bj_playerIsExposed[index]=false
            set bj_crippledTimer[index]=CreateTimer()
            set bj_crippledTimerWindows[index]=CreateTimerDialog(bj_crippledTimer[index])
            call TimerDialogSetTitle(bj_crippledTimerWindows[index], MeleeGetCrippledTimerMessage(indexPlayer))

            // Set a trigger to fire whenever a building is cancelled for this player.
            set trig=CreateTrigger()
            call TriggerRegisterPlayerUnitEvent(trig, indexPlayer, EVENT_PLAYER_UNIT_CONSTRUCT_CANCEL, null)
            call TriggerAddAction(trig, function myChkLose)
            call TriggerAddAction(trig, function MeleeTriggerActionConstructCancel)

            // Set a trigger to fire whenever a unit dies for this player.
            set trig=CreateTrigger()
            call TriggerRegisterPlayerUnitEvent(trig, indexPlayer, EVENT_PLAYER_UNIT_DEATH, null)
            call TriggerAddAction(trig, function myChkLose)
            call TriggerAddAction(trig, function MeleeTriggerActionUnitDeath)

            // Set a trigger to fire whenever a unit begins construction for this player
            set trig=CreateTrigger()
            call TriggerRegisterPlayerUnitEvent(trig, indexPlayer, EVENT_PLAYER_UNIT_CONSTRUCT_START, null)
            call TriggerAddAction(trig, function MeleeTriggerActionUnitConstructionStart)

            // Set a trigger to fire whenever this player defeats-out
            set trig=CreateTrigger()
            call TriggerRegisterPlayerEvent(trig, indexPlayer, EVENT_PLAYER_DEFEAT)
            call TriggerAddAction(trig, function myLose_1)
//            call TriggerAddAction(trig, function MeleeTriggerActionPlayerDefeated)

            // Set a trigger to fire whenever this player leaves
            set trig=CreateTrigger()
            call TriggerRegisterPlayerEvent(trig, indexPlayer, EVENT_PLAYER_LEAVE)
            call TriggerAddAction(trig, function myLose_2)
//            call TriggerAddAction(trig, function MeleeTriggerActionPlayerLeft)

            // Set a trigger to fire whenever this player changes his/her alliances.
            set trig=CreateTrigger()
            call TriggerRegisterPlayerAllianceChange(trig, indexPlayer, ALLIANCE_PASSIVE)
            call TriggerRegisterPlayerStateEvent(trig, indexPlayer, PLAYER_STATE_ALLIED_VICTORY, EQUAL, 1)
            call TriggerAddAction(trig, function MeleeTriggerActionAllianceChange)
        else
            set bj_meleeDefeated[index]=true
            set bj_meleeVictoried[index]=false

            // Handle leave events for observers
            if ( IsPlayerObserver(indexPlayer) ) then
                // Set a trigger to fire whenever this player leaves
                set trig=CreateTrigger()
                call TriggerRegisterPlayerEvent(trig, indexPlayer, EVENT_PLAYER_LEAVE)
                call TriggerAddAction(trig, function myLose_2)
//                call TriggerAddAction(trig, function MeleeTriggerActionPlayerLeft)
            endif
        endif

        set index=index + 1
        exitwhen index == bj_MAX_PLAYERS
    endloop

    // Test for victory / defeat at startup, in case the user has already won / lost.
    // Allow for a short time to pass first, so that the map can finish loading.
    call TimerStart(CreateTimer(), 2.0, false, function MeleeTriggerActionAllianceChange)
endfunction


function Trig_Melee_Initialization_Actions takes nothing returns nothing
    call MeleeStartingVisibility()
    call MeleeStartingHeroLimit()
    call MeleeGrantHeroItems()
    call MeleeStartingResources()
    call MeleeClearExcessUnits()
    call MeleeStartingUnits()
    call MeleeStartingAI()
    call myMeleeInitVictoryDefeat()
    
    call initPlayerFlag()
endfunction


function gg_trg_Melee_Initialization_5s_Actions takes nothing returns nothing
    local integer i
    local integer array teamscore
    local integer winnerteam
    local integer tteam

    set winnerteam=- 1

    set i=0
    loop
        exitwhen i >= 12
        set teamscore[i]=0
        set i=i + 1
    endloop

    set i=0
    loop
        exitwhen i >= 12
        if GetPlayerController(Player(i)) == MAP_CONTROL_USER and GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
            set udg_playerScore[i]=GetTournamentScore(Player(i))
            set tteam=GetPlayerTeam(Player(i))
            set teamscore[tteam]=teamscore[tteam] + udg_playerScore[i]

            if GetLastCreatedLeaderboard() != null then
                call LeaderboardSetPlayerItemValueBJ(Player(i), GetLastCreatedLeaderboard(), udg_playerScore[i])
            endif
        endif
        set i=i + 1
    endloop

    set i=0
    loop
        exitwhen i >= 12
        if teamscore[i] > 0 then
             if winnerteam == - 1 or teamscore[i] > teamscore[winnerteam] then
                  set winnerteam=i
             endif
        endif
        set i=i + 1
    endloop

    if winnerteam != udg_winnerteam then
        call flagPlayer(GetLocalPlayer() , I2S(winnerteam))
        set udg_winnerteam=winnerteam
    endif
endfunction


function Trig_Tournament_Initialization_End_Actions takes nothing returns nothing
    if udg_allowEnd == true then
        call DisplayTextToForce(GetPlayersAll(), "Gametime elapsed!")
        call gg_trg_Melee_Initialization_5s_Actions()
        call MeleeTournamentFinishNowRuleA(1)
    endif
endfunction

function refreshPauseTextExec takes nothing returns nothing
    local timer t=GetExpiredTimer()
    call PauseTimer(t)
    call DestroyTimer(t)
    set t=null
    call ExecuteFunc("refreshPauseText")
endfunction

function hidePauseDialog takes player p returns nothing
    local integer i= 0
    if udg_pauseDialog != null then
        if p == null then
            loop
                exitwhen i >= 12
                if GetPlayerController(Player(i)) == MAP_CONTROL_USER and GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
                    call DialogDisplay(Player(i), udg_pauseDialog, false)
                endif
                set i=i + 1
            endloop

            call DialogDestroy(udg_pauseDialog)
            set udg_pauseDialog=null
        else
            call DialogDisplay(p, udg_pauseDialog, false)
        endif
    endif
endfunction

function endPause takes nothing returns nothing
    local integer i=0
    
    if udg_isPause > 0 then

        if udg_timerDialog != null then
            call TimerDialogDisplay(udg_timerDialog, false)
            call DestroyTimerDialog(udg_timerDialog)
            set udg_timerDialog=null
        endif
    
        call ClearTextMessages()
        call PauseTimer(udg_pst)
        call DestroyTimer(udg_pst)
        set udg_pst=null
        call PauseAllUnitsBJ(false)
        call SetTimeOfDayScalePercentBJ(100)
        call CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 0.0, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 0.00, 0.00, 0.00, 0)
        call hidePauseDialog(null)
        if GetTriggerPlayer() != null then
            call DisplayTimedTextToForce(GetPlayersAll(), 5, "|cffff0000Player " + GetPlayerName(GetTriggerPlayer()) + " resumed the game!")
        else
            call DisplayTimedTextToForce(GetPlayersAll(), 5, "|cffff0000Pause-time elapsed. Game auto-resumed!")
        endif
    endif
    set udg_isPause=0
endfunction

function pauseButtonClicked takes nothing returns nothing
    if ( GetClickedButtonBJ() == udg_btn ) then
        call endPause()
    else
        call hidePauseDialog(GetTriggerPlayer())
        call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0.8, 0.7, TimerGetRemaining(udg_pst), "                     |cffff0000GAME PAUSED!")
        call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0.8, 0.7, TimerGetRemaining(udg_pst), "    ")
        call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0.8, 0.7, TimerGetRemaining(udg_pst), "   Type |cff9999ff!resume|r or |cff9999ff!r|r to resume the game")

    endif
endfunction

function refreshPauseText takes nothing returns nothing
    local timer txt
    set txt=CreateTimer()
    if udg_isPause > 0 then
        
        call DialogSetMessage(udg_pauseDialog, "            Game paused |n|n|cffffffff Game paused by " + GetPlayerName(udg_pausePlayer) + "|n " + I2S(udg_playerPauses[GetPlayerId(udg_pausePlayer)]) + " pauses left for " + GetPlayerName(udg_pausePlayer) + "|r|n|n |cff9999ffAuto-Resume after 90 sec.|r")
        call TimerStart(txt, 1, false, function refreshPauseTextExec)
    else
        call PauseTimer(udg_pst)
        call DestroyTimer(udg_pst)
        set udg_pst=null
    endif
endfunction
     
function showPause takes nothing returns nothing
    local integer i
    local trigger gg_trg_Tournament_Initialization_Pause_Button= CreateTrigger()
    if udg_isPause <= 0 then
        set udg_pausePlayer=GetTriggerPlayer()
        if udg_playerPauses[GetPlayerId(udg_pausePlayer)] <= 0 then
            call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0, 0, 5, "|cffff0000No pause left! You used all your pauses.")
        else
            
            
            set udg_playerPauses[GetPlayerId(udg_pausePlayer)]=udg_playerPauses[GetPlayerId(udg_pausePlayer)] - 1
            
            set udg_pauseDialog=DialogCreate()
            set udg_pst=CreateTimer()
            set udg_isPause=1
            call TimerStart(udg_pst, 90, false, function endPause)
            call PauseAllUnitsBJ(true)
            call SetTimeOfDayScalePercentBJ(0)
            call CinematicFadeBJ(bj_CINEFADETYPE_FADEOUT, 0.0, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 0.00, 0.00, 0.00, 0)
            call DialogClear(udg_pauseDialog)
            call refreshPauseText()
            call DialogAddButton(udg_pauseDialog, "Enter chat", 'C')
            set udg_btn=DialogAddButton(udg_pauseDialog, "|cffffffffR|resume game", 'R')
        
            
            set i=0
            loop
                exitwhen i >= 12
                if GetPlayerController(Player(i)) == MAP_CONTROL_USER and GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
                    call DialogDisplay(Player(i), udg_pauseDialog, true)
                endif
                set i=i + 1
            endloop
            
            if udg_timerDialog == null then
                set udg_timerDialog=CreateTimerDialogBJ(udg_pst, "Auto-Resume in:")
                call TimerDialogDisplay(udg_timerDialog, true)
            endif
                        
                
            call TriggerRegisterDialogEventBJ(gg_trg_Tournament_Initialization_Pause_Button, udg_pauseDialog)
            call TriggerAddAction(gg_trg_Tournament_Initialization_Pause_Button, function pauseButtonClicked)
        endif
    endif

endfunction

function showLeaderboard takes nothing returns nothing
    local integer i
    call CreateLeaderboardBJ(GetPlayersAll(), "Game-Score (highest win)")
            set i=0
            loop
                exitwhen i >= 12
                if GetPlayerController(Player(i)) == MAP_CONTROL_USER and GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
                    call LeaderboardAddItemBJ(Player(i), GetLastCreatedLeaderboard(), GetPlayerName(Player(i)), udg_playerScore[i])
                endif
                set i=i + 1
            endloop
endfunction


function endGameByTimer takes nothing returns nothing
    set udg_allowEnd=true
    call endPause()
    call Trig_Tournament_Initialization_End_Actions()
endfunction


function psMeleeTriggerTournamentFinishSoon takes nothing returns nothing
    // Note: We may get this trigger multiple times
    local integer playerIndex
    local player indexPlayer
    local real timeRemaining= 300
    local trigger gg_trg_Tournament_Initialization_End
    local timer eottimer

    set udg_allowEnd=false

    if not bj_finishSoonAllExposed then
        set bj_finishSoonAllExposed=true

        // Reset all crippled players and their timers, and hide the local crippled timer dialog
        set playerIndex=0
        loop
            set indexPlayer=Player(playerIndex)
            if bj_playerIsCrippled[playerIndex] then
                // Uncripple the player
                set bj_playerIsCrippled[playerIndex]=false
                call PauseTimer(bj_crippledTimer[playerIndex])

                if ( GetLocalPlayer() == indexPlayer ) then
                    // Use only local code (no net traffic) within this block to avoid desyncs.

                    // Hide the timer window.
                    call TimerDialogDisplay(bj_crippledTimerWindows[playerIndex], false)
                endif

            endif
            set playerIndex=playerIndex + 1
            exitwhen playerIndex == bj_MAX_PLAYERS
        endloop

        // Expose all players
        call MeleeExposeAllPlayers()
    endif

    set eottimer=CreateTimer()
    call TimerStart(eottimer, timeRemaining, false, function endGameByTimer)
    set bj_finishSoonTimerDialog=CreateTimerDialogBJ(eottimer, "Gametime left:")
    call TimerDialogDisplay(bj_finishSoonTimerDialog, true)



endfunction

function Trig_Tournament_Initialization_Actions takes nothing returns nothing
    call DisplayTextToForce(GetPlayersAll(), "The game will end in 5 minutes!")
    call psMeleeTriggerTournamentFinishSoon()
endfunction


//===========================================================================
function InitTrig_Melee_Initialization takes nothing returns nothing
    local trigger gg_trg_Tournament_Initialization= CreateTrigger()
    local trigger gg_trg_Tournament_Initialization_End= CreateTrigger()
    local trigger gg_trg_Tournament_Initialization_End_Leaderboard= CreateTrigger()
    local trigger gg_trg_Melee_Initialization_5s= CreateTrigger()
    local trigger gg_trg_Tournament_Initialization_Pause= CreateTrigger()
    local trigger gg_trg_Tournament_Initialization_Pause_End= CreateTrigger()
    local trigger gg_trg_Tournament_Initialization_Resume= CreateTrigger()
    local integer i
    local string hcl_command
    local real gametime
    set gametime=1800.00
    
    set gg_trg_Melee_Initialization=CreateTrigger()
    call TriggerAddAction(gg_trg_Melee_Initialization, function Trig_Melee_Initialization_Actions)

    set hcl_command=getHCL()
    if StringLength(hcl_command) > 0 then
        if ( SubString(hcl_command, 0, 1) == "t" ) then

//            call DisplayTextToForce( GetPlayersAll(), "Tournament Mode" )
        
            call TriggerRegisterTimerEventSingle(gg_trg_Tournament_Initialization, gametime - 300.0)
            call TriggerAddAction(gg_trg_Tournament_Initialization, function Trig_Tournament_Initialization_Actions)
    
            call TriggerRegisterTimerEventSingle(gg_trg_Tournament_Initialization_End_Leaderboard, gametime - 60.0)
            call TriggerAddAction(gg_trg_Tournament_Initialization_End_Leaderboard, function showLeaderboard)

            set udg_allowEnd=true

            call TriggerRegisterTimerEventSingle(gg_trg_Tournament_Initialization_End, gametime)
            call TriggerAddAction(gg_trg_Tournament_Initialization_End, function endPause)
            call TriggerAddAction(gg_trg_Tournament_Initialization_End, function Trig_Tournament_Initialization_End_Actions)
            
        
            set i=0
            loop
                exitwhen i >= 12
                if ( GetPlayerController(Player(i)) == MAP_CONTROL_USER and GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING ) then
                    call TriggerRegisterPlayerChatEvent(gg_trg_Tournament_Initialization_Pause, Player(i), "!pause", true)
                    call TriggerRegisterPlayerChatEvent(gg_trg_Tournament_Initialization_Pause, Player(i), "!p", true)
                  
                    call TriggerRegisterPlayerChatEvent(gg_trg_Tournament_Initialization_Resume, Player(i), "!r", true)
                    call TriggerRegisterPlayerChatEvent(gg_trg_Tournament_Initialization_Resume, Player(i), "!resume", true)
                    
                    set udg_playerPauses[i]=3
                endif
                set i=i + 1
            endloop
            
            call TriggerAddAction(gg_trg_Tournament_Initialization_Pause, function showPause)
            call TriggerAddAction(gg_trg_Tournament_Initialization_Resume, function endPause)

        endif
    endif
    
    
    call TriggerRegisterTimerEventPeriodic(gg_trg_Melee_Initialization_5s, 5.00)
    call TriggerAddAction(gg_trg_Melee_Initialization_5s, function gg_trg_Melee_Initialization_5s_Actions)
    
    
endfunction
//===========================================================================
// Trigger: GS
//===========================================================================
//TESH.scrollpos=0
//TESH.alwaysfold=0

//===========================================================================
// Trigger: Untitled Trigger 001
//===========================================================================
function Trig_Untitled_Trigger_001_Actions takes nothing returns nothing
endfunction

//===========================================================================
function InitTrig_Untitled_Trigger_001 takes nothing returns nothing
    set gg_trg_Untitled_Trigger_001=CreateTrigger()
    call TriggerRegisterPlayerStateEvent(gg_trg_Untitled_Trigger_001, Player(0), PLAYER_STATE_RESOURCE_FOOD_USED, GREATER_THAN_OR_EQUAL, 1000.00)
    call TriggerAddAction(gg_trg_Untitled_Trigger_001, function Trig_Untitled_Trigger_001_Actions)
endfunction

//===========================================================================
function InitCustomTriggers takes nothing returns nothing
    call InitTrig_Melee_Initialization()
    //Function not found: call InitTrig_GS()
    call InitTrig_Untitled_Trigger_001()
endfunction

//===========================================================================
function RunInitializationTriggers takes nothing returns nothing
    call ConditionalTriggerExecute(gg_trg_Melee_Initialization)
endfunction

//***************************************************************************
//*
//*  Players
//*
//***************************************************************************

function InitCustomPlayerSlots takes nothing returns nothing

    // Player 0
    call SetPlayerStartLocation(Player(0), 0)
    call SetPlayerColor(Player(0), ConvertPlayerColor(0))
    call SetPlayerRacePreference(Player(0), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(0), true)
    call SetPlayerController(Player(0), MAP_CONTROL_USER)

    // Player 1
    call SetPlayerStartLocation(Player(1), 1)
    call SetPlayerColor(Player(1), ConvertPlayerColor(1))
    call SetPlayerRacePreference(Player(1), RACE_PREF_ORC)
    call SetPlayerRaceSelectable(Player(1), true)
    call SetPlayerController(Player(1), MAP_CONTROL_USER)

    // Player 2
    call SetPlayerStartLocation(Player(2), 2)
    call SetPlayerColor(Player(2), ConvertPlayerColor(2))
    call SetPlayerRacePreference(Player(2), RACE_PREF_UNDEAD)
    call SetPlayerRaceSelectable(Player(2), true)
    call SetPlayerController(Player(2), MAP_CONTROL_USER)

    // Player 3
    call SetPlayerStartLocation(Player(3), 3)
    call SetPlayerColor(Player(3), ConvertPlayerColor(3))
    call SetPlayerRacePreference(Player(3), RACE_PREF_NIGHTELF)
    call SetPlayerRaceSelectable(Player(3), true)
    call SetPlayerController(Player(3), MAP_CONTROL_USER)

endfunction

function InitCustomTeams takes nothing returns nothing
    // Force: TRIGSTR_004
    call SetPlayerTeam(Player(0), 0)
    call SetPlayerTeam(Player(1), 0)
    call SetPlayerTeam(Player(2), 0)
    call SetPlayerTeam(Player(3), 0)

endfunction

function InitAllyPriorities takes nothing returns nothing

    call SetStartLocPrioCount(0, 1)
    call SetStartLocPrio(0, 0, 1, MAP_LOC_PRIO_HIGH)

    call SetStartLocPrioCount(1, 1)
    call SetStartLocPrio(1, 0, 0, MAP_LOC_PRIO_HIGH)

    call SetStartLocPrioCount(2, 1)
    call SetStartLocPrio(2, 0, 3, MAP_LOC_PRIO_HIGH)

    call SetStartLocPrioCount(3, 1)
    call SetStartLocPrio(3, 0, 2, MAP_LOC_PRIO_HIGH)
endfunction

//***************************************************************************
//*
//*  Main Initialization
//*
//***************************************************************************

//===========================================================================
function main takes nothing returns nothing
    call SetCameraBounds(- 6144.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), - 6400.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 6144.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 5888.0 - GetCameraMargin(CAMERA_MARGIN_TOP), - 6144.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 5888.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 6144.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), - 6400.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
    call SetDayNightModels("Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdl", "Environment\\DNC\\DNCLordaeron\\DNCLordaeronUnit\\DNCLordaeronUnit.mdl")
    call NewSoundEnvironment("Default")
    call SetAmbientDaySound("LordaeronWinterDay")
    call SetAmbientNightSound("LordaeronWinterNight")
    call SetMapMusic("Music", true, 0)
    call CreateAllUnits()
    call InitBlizzard()

call ExecuteFunc("GameStatus___Ini")

    call InitGlobals()
    call InitCustomTriggers()
    call ConditionalTriggerExecute(gg_trg_Melee_Initialization) // INLINED!!

endfunction

//***************************************************************************
//*
//*  Map Configuration
//*
//***************************************************************************

function config takes nothing returns nothing
    call SetMapName("TRIGSTR_010")
    call SetMapDescription("TRIGSTR_012")
    call SetPlayers(4)
    call SetTeams(4)
    call SetGamePlacement(MAP_PLACEMENT_TEAMS_TOGETHER)

    call DefineStartLocation(0, - 4800.0, 4224.0)
    call DefineStartLocation(1, 4672.0, 4224.0)
    call DefineStartLocation(2, - 4736.0, - 5184.0)
    call DefineStartLocation(3, 4608.0, - 5120.0)

    // Player setup
    call InitCustomPlayerSlots()
    call SetPlayerSlotAvailable(Player(0), MAP_CONTROL_USER)
    call SetPlayerSlotAvailable(Player(1), MAP_CONTROL_USER)
    call SetPlayerSlotAvailable(Player(2), MAP_CONTROL_USER)
    call SetPlayerSlotAvailable(Player(3), MAP_CONTROL_USER)
    call InitGenericPlayerSlots()
    call InitAllyPriorities()
endfunction




//Struct method generated initializers/callers:

