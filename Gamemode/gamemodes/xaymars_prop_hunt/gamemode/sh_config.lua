if !file.IsDir("prop_hunt", "DATA") then file.CreateDir("prop_hunt") end

-- These are Models that the Prop team can not become.
-- Usually you'd put invisible or impossible to hit models in here.
BANNED_PROP_MODELS = {
	"models/props/cs_assault/dollar.mdl",
	"models/props/cs_assault/money.mdl",
	"models/props/cs_office/snowman_arm.mdl",
	"models/props_junk/garbage_plasticbottle001a.mdl",
	"models/props/cs_office/projector_remote.mdl"
}
if (! file.Exists("prop_hunt/banned_props.txt", "DATA")) then
	file.Write("prop_hunt/banned_props.txt", util.TableToKeyValues(BANNED_PROP_MODELS))
end
local fileContent = file.Read("prop_hunt/banned_props.txt", "DATA");
if fileContent then
	local fileTable = util.KeyValuesToTable(fileContent)
	if fileTable then BANNED_PROP_MODELS = fileTable end
end

-- Sounds played by members of the losing team at the end of the round.
LOSS_SOUNDS = {
	"bot/aw_hell.wav",
	"bot/aww_man.wav",
	"bot/anyone_see_anything.wav",
	"bot/anyone_see_them.wav",
	"bot/come_out_and_fight_like_a_man.wav",
	"bot/come_out_wherever_you_are.wav",
	"bot/he_got_away.wav",
	"bot/he_got_away2.wav",
	"bot/i_dont_know_where_he_went.wav",
	"bot/i_got_nothing.wav",
	"bot/nothing_happening_over_here.wav",
	"bot/nothing_here.wav",
	"bot/nothing_moving_over_here.wav",
	"bot/thats_not_good.wav",
	"bot/theres_too_many.wav",
	"bot/theres_too_many_of_them.wav",
	"bot/theyre_all_over_the_place2.wav",
	"bot/theyre_everywhere2.wav",
	"bot/too_many2.wav",
	"bot/what_happened.wav",
	"bot/what_have_you_done.wav",
	"bot/where_are_they.wav",
	"bot/where_are_you_hiding.wav"
}
if (! file.Exists("prop_hunt/sounds_loss.txt", "DATA")) then
	file.Write("prop_hunt/sounds_loss.txt", util.TableToKeyValues(LOSS_SOUNDS))
end
local fileContent = file.Read("prop_hunt/sounds_loss.txt", "DATA");
if fileContent then
	local fileTable = util.KeyValuesToTable(fileContent)
	if fileTable then LOSS_SOUNDS = fileTable end
end

-- Sounds played by members of the winning team at the end of the round.
VICTORY_SOUNDS = {
	"bot/and_thats_how_its_done.wav",
	"bot/come_to_papa.wav",
	"bot/do_not_mess_with_me.wav",
	"bot/dropped_him.wav",
	"bot/enemy_down.wav",
	"bot/enemy_down2.wav",
	"bot/good_job_team.wav",
	"bot/got_him.wav",
	"bot/hes_broken.wav",
	"bot/hes_dead.wav",
	"bot/hes_done.wav",
	"bot/hes_down.wav",
	"bot/its_a_party.wav",
	"bot/i_am_dangerous.wav",
	"bot/i_am_on_fire.wav",
	"bot/i_got_more_where_that_came_from.wav",
	"bot/i_wasnt_worried_for_a_minute.wav",
	"bot/killed_him.wav",
	"bot/look_out_brag.wav",
	"bot/made_him_cry.wav",
	"bot/oh_yea.wav",
	"bot/oh_yea2.wav",
	"bot/owned.wav",
	"bot/ruined_his_day.wav",
	"bot/tag_them_and_bag_them.wav",
	"bot/thats_the_way_this_is_done.wav",
	"bot/that_was_a_close_one.wav",
	"bot/that_was_it.wav",
	"bot/that_was_the_last_guy.wav",
	"bot/that_was_the_last_one.wav",
	"bot/they_never_knew_what_hit_them.wav",
	"bot/they_will_not_escape.wav",
	"bot/they_wont_get_away.wav",
	"bot/they_wont_get_away2.wav",
	"bot/this_is_my_house.wav",
	"bot/took_him_down.wav",
	"bot/took_him_out.wav",
	"bot/took_him_out2.wav",
	"bot/wasted_him.wav",
	"bot/way_to_be_team.wav",
	"bot/well_done.wav",
	"bot/we_owned_them.wav",
	"bot/whew_that_was_close.wav",
	"bot/whoo.wav",
	"bot/whoo2.wav",
	"bot/whos_the_man.wav",
	"bot/who_wants_some_more.wav",
	"bot/yesss.wav",
	"bot/yesss2.wav"
}
if (! file.Exists("prop_hunt/sounds_victory.txt", "DATA")) then
	file.Write("prop_hunt/sounds_victory.txt", util.TableToKeyValues(VICTORY_SOUNDS))
end
local fileContent = file.Read("prop_hunt/sounds_victory.txt", "DATA");
if fileContent then
	local fileTable = util.KeyValuesToTable(fileContent)
	if fileTable then VICTORY_SOUNDS = fileTable end
end

-- Taunts played when Hunters hit their Spare1 binding.
HUNTER_TAUNTS = {
	"bot/a_bunch_of_them.wav",
	"bot/come_out_and_fight_like_a_man.wav",
	"bot/come_out_wherever_you_are.wav",
	"bot/come_to_papa.wav",
	"bot/dont_worry_hell_get_it.wav",
	"bot/hang_on_i_heard_something.wav",
	"bot/hang_on_im_coming.wav",
	"bot/i_dont_think_so.wav",
	"bot/i_have_the_hostages.wav",
	"bot/i_see_our_target.wav",
	"bot/im_waiting_here.wav",
	"bot/keeping_an_eye_on_the_hostages.wav",
	"bot/nnno_sir.wav",
	"bot/spotted_the_delivery_boy.wav",
	"bot/target_acquired.wav",
	"bot/target_spotted.wav",
	"bot/you_heard_the_man_lets_go.wav"
}
if (! file.Exists("prop_hunt/sounds_taunt_hunter.txt", "DATA")) then
	file.Write("prop_hunt/sounds_taunt_hunter.txt", util.TableToKeyValues(HUNTER_TAUNTS))
end
local fileContent = file.Read("prop_hunt/sounds_taunt_hunter.txt", "DATA");
if fileContent then
	local fileTable = util.KeyValuesToTable(fileContent)
	if fileTable then HUNTER_TAUNTS = fileTable end
end

-- Taunts played when Props hit their Spare1 binding.
PROP_TAUNTS = {
--	"ambient/alarms/apc_alarm_loop1.wav",
	"ambient/alarms/apc_alarm_pass1.wav",
--	"ambient/alarms/citadel_alert_loop2.wav",
--	"ambient/alarms/city_firebell_loop1.wav",
--	"ambient/alarms/city_siren_loop2.wav",
--	"ambient/alarms/combine_bank_alarm_loop1.wav",
--	"ambient/alarms/combine_bank_alarm_loop4.wav",
--	"ambient/alarms/klaxon1.wav",
	"ambient/alarms/manhack_alert_pass1.wav",
	"ambient/alarms/razortrain_horn1.wav",
	"ambient/alarms/scanner_alert_pass1.wav",
--	"ambient/alarms/siren.wav",
--	"ambient/alarms/train_crossing_bell_loop1.wav",
	"ambient/alarms/train_horn2.wav",
	"ambient/alarms/train_horn_distant1.wav",
	"ambient/alarms/warningbell1.wav",
--	"ambient/chatter/cb_radio_chatter_1.wav",
--	"ambient/chatter/cb_radio_chatter_2.wav",
--	"ambient/chatter/cb_radio_chatter_3.wav",
	"ambient/energy/whiteflash.wav",
	"ambient/intro/alyxremove.wav",
	"ambient/intro/logosfx.wav",
--	"ambient/levels/labs/teleport_alarm_loop1.wav",
	"ambient/levels/launch/1stfiringwarning.wav",
	"ambient/levels/launch/rockettakeoffblast.wav",
--	"ambient/levels/outland/basealarmloop.wav",
--	"ambient/machines/60hzhum.wav",
	"ambient/misc/ambulance1.wav",
	"ambient/misc/carhonk1.wav",
	"ambient/misc/carhonk2.wav",
	"ambient/misc/carhonk3.wav",
--	"ambient/music/bongo.wav",
--	"ambient/music/country_rock_am_radio_loop.wav",
--	"ambient/music/cubanmusic1.wav",
--	"ambient/music/dustmusic1.wav",
--	"ambient/music/dustmusic2.wav",
--	"ambient/music/dustmusic3.wav",
--	"ambient/music/flamenco.wav",
--	"ambient/music/latin.wav",
--	"ambient/music/mirame_radio_thru_wall.wav",
--	"ambient/music/piano1.wav",
--	"ambient/music/piano2.wav",
	"ambient/outro/gunshipcrash.wav",
	"ambient/3dmeagle.wav",
--	"ambient/guit1.wav",
--	"ambient/opera.wav",
--	"ambient/sheep.wav",
	"beams/beamstart5.wav",
	"buttons/bell1.wav",
	"buttons/weapon_cant_buy.wav",
	"common/bass.wav",
	"common/bugreporter_failed.wav",
	"common/warning.wav",
	"doors/door_squeek1.wav",
	"friends/friend_join.wav",
	"friends/friend_online.wav",
	"friends/message.wav",
	"hostage/hunuse/comeback.wav",
	"hostage/hunuse/dontleaveme.wav",
	"hostage/hunuse/yeahillstay.wav",
	"items/gift_drop.wav",
	"music/radio1.mp3",
	"phx/eggcrack.wav",
	"plats/elevbell1.wav",
	"player/headshot1.wav",
	"player/headshot2.wav",
	"player/sprayer.wav",
	"radio/enemydown.wav",
	"radio/go.wav",
	"radio/locknload.wav",
	"radio/negative.wav",
	"radio/rounddraw.wav",
	"radio/takepoint.wav",
	"resource/warning.wav",
--	"test/temp/soundscape_test/tv_music.wav",
	"ui/achievement_earned.wav",
	"ui/freeze_cam.wav",
	"vehicles/junker/radar_ping_friendly1.wav",
	"weapons/c4/c4_beep1.wav",
	"weapons/c4/c4_click.wav",
	"weapons/awp/awp1.wav",
	"vo/canals/female01/gunboat_giveemhell.wav",
	"vo/canals/female01/gunboat_justintime.wav",
	"vo/canals/female01/stn6_incoming.wav",
	"vo/canals/male01/gunboat_giveemhell.wav",
	"vo/canals/male01/gunboat_justintime.wav",
	"vo/canals/male01/stn6_incoming.wav",
	"vo/canals/al_radio_stn6.wav",
	"vo/canals/arrest_getgoing.wav",
	"vo/canals/arrest_helpme.wav",
	"vo/canals/arrest_lookingforyou.wav",
	"vo/canals/boxcar_lethimhelp.wav",
	"vo/canals/matt_closecall.wav",
	"vo/canals/premassacre.wav",
	"vo/ravenholm/aimforhead.wav",
	"vo/ravenholm/bucket_patience.wav",
	"vo/ravenholm/madlaugh01.wav",
	"vo/ravenholm/madlaugh02.wav",
	"vo/ravenholm/madlaugh03.wav",
	"vo/ravenholm/madlaugh04.wav",
	"weapons/strider_buster/ol12_stickybombcreator.wav",
	"weapons/c4/c4_explode1.wav",
	"weapons/357/357_fire2.wav",
	"weapons/357/357_fire3.wav",
	"weapons/scout/scout_fire-1.wav",
	"weapons/smokegrenade/sg_explode.wav",
	"weapons/grenade_launcher1.wav",
	"weapons/explode3.wav",
	"weapons/underwater_explode3.wav",
	"items/nvg_on.wav",
	"hostage/huse/letsdoit.wav",
	"hostage/huse/illfollow.wav",
	"hostage/huse/getouttahere.wav",
	"doors/door_screen_move1.wav",
	"doors/heavy_metal_stop1.wav",
	"doors/default_move.wav",
	"common/stuck2.wav",
	"ambient/water_splash1.wav",
	"ambient/water_splash2.wav",
	"ambient/water_splash3.wav",
	"ambient/weather/thunder1.wav",
	"ambient/weather/thunder2.wav",
	"ambient/weather/thunder3.wav",
	"ambient/weather/thunder4.wav",
	"ambient/weather/thunder5.wav",
	"ambient/weather/thunder6.wav",
	"ambient/outro/thunder7.wav",
	"ambient/voices/crying_loop1.wav",
	"ambient/voices/playground_memory.wav",
	"ambient/voices/f_scream1.wav",
	"ambient/voices/m_scream1.wav",
	"ambient/voices/cough1.wav",
	"ambient/voices/cough2.wav",
	"ambient/voices/cough3.wav",
	"ambient/voices/cough4.wav",
	"ambient/overhead/plane1.wav",
	"ambient/overhead/plane2.wav",
	"ambient/overhead/plane3.wav",
	"ambient/overhead/hel1.wav",
	"ambient/overhead/hel2.wav",
	"ambient/misc/truck_backup1.wav",
	"ambient/misc/truck_drive1.wav",
	"ambient/misc/truck_drive2.wav",
	"ambient/machines/pneumatic_drill_1.wav",
	"ambient/machines/pneumatic_drill_2.wav",
	"ambient/machines/pneumatic_drill_3.wav",
	"ambient/machines/pneumatic_drill_4.wav",
	"ambient/machines/station_train_squeel.wav",
	"ambient/machines/ticktock.wav",
	"ambient/creatures/teddy.wav",
	"ambient/creatures/town_child_scream1.wav",
	"ambient/creatures/town_moan1.wav",
	"ambient/creatures/town_muffled_cry1.wav",
	"ambient/creatures/town_scared_breathing1.wav",
	"ambient/creatures/town_scared_breathing2.wav",
	"ambient/creatures/town_scared_sob1.wav",
	"ambient/creatures/town_scared_sob2.wav",
	"ambient/creatures/town_zombie_call1.wav"
}
if (! file.Exists("prop_hunt/sounds_taunt_prop.txt", "DATA")) then
	file.Write("prop_hunt/sounds_taunt_prop.txt", util.TableToKeyValues(PROP_TAUNTS))
end
local fileContent = file.Read("prop_hunt/sounds_taunt_prop.txt", "DATA");
if fileContent then
	local fileTable = util.KeyValuesToTable(fileContent)
	if fileTable then PROP_TAUNTS = fileTable end
end

-- Maximum time (in minutes) for this fretta gamemode (Default: 30)
GAME_TIME = math.max(GetConVarNumber("mp_timelimit"),1)

-- Number of seconds hunters are blinded/locked at the beginning of the map (Default: 30)
CreateConVar("HUNTER_BLINDLOCK_TIME", "30", FCVAR_REPLICATED)

--Create the convars here
-- Health points removed from hunters when they shoot  (Default: 5)
CreateConVar( "HUNTER_FIRE_PENALTY", "5", FCVAR_REPLICATED)

-- How much health to give back to the Hunter after killing a prop (Default: 20)
CreateConVar( "HUNTER_KILL_BONUS", "20", FCVAR_REPLICATED)

--Whether or not we include grenade launcher ammo (default: 1)
CreateConVar( "WEAPONS_ALLOW_GRENADE", "1", FCVAR_REPLICATED)

-- Seconds a player has to wait before they can taunt again (Default: 5)
TAUNT_DELAY = 2

-- Rounds played on a map (Default: 10)
ROUNDS_PER_MAP = 60

-- Time (in seconds) for each round (Default: 300)
ROUND_TIME = 300

-- Determains if players should be team swapped every round [0 = No, 1 = Yes] (Default: 1)
SWAP_TEAMS_EVERY_ROUND = 1

-- Update above values with values from configuration.
if (! file.Exists("prop_hunt/config.txt", "DATA")) then
	file.Write("prop_hunt/config.txt", util.TableToKeyValues({
--		GAME_TIME = 30,
		TAUNT_DELAY = 2,
		ROUNDS_PER_MAP = 60,
		ROUND_TIME = 300,
		SWAP_TEAM_EVERY_ROUND = 1
	}))
end
local fileContent = file.Read("prop_hunt/config.txt", "DATA");
if fileContent then
	local fileTable = util.KeyValuesToTable(fileContent)
	if fileTable then
--		if fileTable.GAME_TIME then GAME_TIME = fileTable.GAME_TIME end
		if fileTable.TAUNT_DELAY then TAUNT_DELAY = fileTable.TAUNT_DELAY end
		if fileTable.ROUNDS_PER_MAP then ROUNDS_PER_MAP = fileTable.ROUNDS_PER_MAP end
		if fileTable.ROUND_TIME then ROUND_TIME = fileTable.ROUND_TIME end
		if fileTable.SWAP_TEAM_EVERY_ROUND then ROUND_TIME = fileTable.SWAP_TEAM_EVERY_ROUND end
	end
end

GAME_TIME = math.max(GetConVarNumber("mp_timelimit"),1)
