--[[
	The MIT License (MIT)
	
	Copyright (c) 2015 Project Kube

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
--]]

--! Client Files
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("sh_init.lua")

--! Include shared lua.
include "sh_init.lua"

--! Include server lua.
include "server/config.lua"
include "server/console/variables.lua"
include "compat/compat_tauntpackloader.lua"

-- ------------------------------------------------------------------------- --
--! Gamemode
-- ------------------------------------------------------------------------- --

-- GameStates
GM_STATES_SETUP			= 0
GM_STATES_HIDE			= 1
GM_STATES_SEEK			= 2
GM_STATES_SHAMING		= 3 -- Do your best, hiders!

--! Initialize 
function GM:Initialize()
	self.State = GM_STATES_SETUP
	self.StatePrev = self.State
	
	--! Run any hooked functions that addons have registered for Prop Hunt.
	hook.Run("OnPropHuntInitialized")
end

--! Check Victory and Loss conditions
function GM:Think()
	if (self.State == GM_STATES_SETUP) then
		--! GameState: Setup
		-- Here we do all the stuff that would be ridiculous to do while playing.
		if (self.StatePrev != self.State) then
			game.CleanUpMap()
			
			-- Assign correct teams depending on Sub-Gamemode.
			if (self.Config.Modes.SwapTeams == 1) then
				for i,pl in ipairs(player.GetAll()) do
					if (pl:Team() == TEAM_HIDERS) then
						pl:SetTeam(TEAM_SEEKERS)
					elseif (pl:Team() == TEAM_SEEKERS) then
						pl:SetTeam(TEAM_HIDERS)
					end
				end
			elseif (self.Config.Modes.RandomizeTeams == 1) then
				local plys = player.GetAll()
				--local plyCount = 
				
			elseif (self.Config.Modes.TheDeadHunt == 1) then
				
			end
			
			-- Respawn players
			for i,pl in ipairs(player.GetAll()) do
				pl:Respawn()
			end
		end
		
		-- Advanced to next GameState if we have enough players
		self.StatePrev = self.State
		self.State = GM_STATES_HIDE
	elseif (self.State == GM_STATES_HIDE) then
		
	elseif (self.State == GM_STATES_SEEK) then
		
	elseif (self.State == GM_STATES_SHAMING) then
		
	else
		-- Invalid State, we have to reset
		self.StatePrev = self.State
		self.State = GM_STATES_SETUP
	end
end

-- ------------------------------------------------------------------------- --
--! LEGACY CODE - TO BE REPLACED SOON
-- ------------------------------------------------------------------------- --
function GM:AllowPlayerPickup(player, entity)
	return true
end

function AnnounceVictory(players, force)
	for i,pl in ipairs(players) do
		if pl:Alive() || force || pl:Team() == TEAM_SPECTATOR then
			announcer = table.Random(VICTORY_SOUNDS);
			print("Prop Hunt: '"..pl:GetName().."' announcing victory with '"..announcer.."'.")
			pl:EmitSound(announcer, 200, 100, 0.5, CHAN_VOICE2) 
		end
	end
end

function AnnounceLoss(players, force)
	for i,pl in ipairs(players) do
		if pl:Alive() || force || pl:Team() == TEAM_SPECTATOR then
			announcer = table.Random(LOSS_SOUNDS);
			print("Prop Hunt: '"..pl:GetName().."' announcing loss with '"..announcer.."'.")
			pl:EmitSound(announcer, 100, 100, 0.5, CHAN_VOICE2)
		end
	end
end

-- If there is a mapfile send it to the client (sometimes servers want to change settings for certain maps)
if file.Exists("maps/"..game.GetMap()..".lua", "LUA") then
	AddCSLuaFile("maps/"..game.GetMap()..".lua")
end


-- Server only constants
EXPLOITABLE_DOORS = {
	"func_door",
	"prop_door_rotating", 
	"func_door_rotating"
}
USABLE_PROP_ENTITIES = {
	"prop_physics",
	"prop_physics_multiplayer"
}

-- Send the required resources to the client
for _, announcer in pairs(LOSS_SOUNDS) do resource.AddFile("sound/"..announcer) end
for _, announcer in pairs(VICTORY_SOUNDS) do resource.AddFile("source/"..announcer) end
for _, taunt in pairs(HUNTER_TAUNTS) do resource.AddFile("sound/"..taunt) end
for _, taunt in pairs(PROP_TAUNTS) do resource.AddFile("sound/"..taunt) end

-- Called alot
function GM:CheckPlayerDeathRoundEnd()
	if !GAMEMODE.RoundBased || !GAMEMODE:InRound() then 
		return
	end

	local Teams = GAMEMODE:GetTeamAliveCounts()

	if table.Count(Teams) == 0 then
		GAMEMODE:RoundEndWithResult(1001, "Draw, everyone loses!")
		AnnounceLoss(player.GetAll(), true)
		return
	end

	if table.Count(Teams) == 1 then
		-- Play victory and loss sounds.
		if Teams[0] == TEAM_HUNTERS then
			AnnounceVictory(team.GetPlayers(TEAM_HUNTERS))
			AnnounceLoss(team.GetPlayers(TEAM_PROPS))
		elseif Teams[0] == TEAM_PROPS then
			AnnounceLoss(team.GetPlayers(TEAM_HUNTERS))
			AnnounceVictory(team.GetPlayers(TEAM_PROPS))
		end
		
		local TeamID = table.GetFirstKey(Teams)
		GAMEMODE:RoundEndWithResult(TeamID, team.GetName(TeamID).." win!")
		return
	end
end


-- Called when an entity takes damage
function EntityTakeDamage(ent, dmginfo)
    local att = dmginfo:GetAttacker()
	if GAMEMODE:InRound() && ent && ent:GetClass() != "ph_prop" && !ent:IsPlayer() && att && att:IsPlayer() && att:Team() == TEAM_HUNTERS && att:Alive() then
		att:SetHealth(att:Health() - GetConVar("HUNTER_FIRE_PENALTY"):GetInt())
		if att:Health() <= 0 then
			MsgAll(att:Name() .. " felt guilty for hurting so many innocent props and committed suicide\n")
			att:Kill()
		end
	end
end
hook.Add("EntityTakeDamage", "PH_EntityTakeDamage", EntityTakeDamage)


-- Called when player tries to pickup a weapon
function GM:PlayerCanPickupWeapon(pl, ent)
 	if pl:Team() != TEAM_HUNTERS then
		return false
	end
	
	return true
end


-- Called when player needs a model
function GM:PlayerSetModel(pl)
	local player_model = pl:GetModel()
	
	if pl:Team() == TEAM_HUNTERS then
		player_model = "models/player/combine_super_soldier.mdl"
	elseif pl:Team() == TEAM_PROPS then
		player_model = "models/Gibs/Antlion_gib_small_3.mdl"
	end
	
	util.PrecacheModel(player_model)
	pl:SetModel(player_model)
end


-- Called when a player tries to use an object
function GM:PlayerUse(pl, ent)
	if !pl:Alive() || pl:Team() == TEAM_SPECTATOR then return false end
	
--	if pl:Team() == TEAM_PROPS && pl:IsOnGround() && !pl:Crouching() && table.HasValue(USABLE_PROP_ENTITIES, ent:GetClass()) && ent:GetModel() then
	if pl:Team() == TEAM_PROPS && table.HasValue(USABLE_PROP_ENTITIES, ent:GetClass()) && ent:GetModel() then
		if table.HasValue(BANNED_PROP_MODELS, ent:GetModel()) then
			pl:ChatPrint("That prop has been banned by the server.")
		elseif ent:GetPhysicsObject():IsValid() then -- && pl.ph_prop:GetModel() != ent:GetModel() then
			local ent_health = math.Clamp(ent:GetPhysicsObject():GetVolume() / 250, 1, 200)
			
			-- Prevent props from gaining health by changing.
			local per = math.min(pl:Health() / pl:GetMaxHealth(), pl.tempHealthPc || 1.0)
			if (pl.tempHealthPc == nil) || (per <= pl.tempHealthPc) then pl.tempHealthPc = per end
			local new_health = math.Clamp(per * ent_health, 1, 200)
			
			pl:SetJumpPower(math.Clamp(ent:GetPhysicsObject():GetVolume() / 333, 200, 600));
			
			-- Set Prop Data
			pl.ph_prop:SetHealth(new_health)
			pl.ph_prop:SetMaxHealth(ent_health) 
			pl.ph_prop:SetModel(ent:GetModel())
			pl.ph_prop:SetSkin(ent:GetSkin())
			
			-- Update Hull and Health
			pl:NewHull(ent:OBBMins(), ent:OBBMaxs())
			pl:SetHealth(new_health)
			pl:SetMaxHealth(ent_health)
			umsg.Start("SetHull", pl)
				umsg.Vector(ent:OBBMins())
				umsg.Vector(ent:OBBMaxs())
				umsg.Short(new_health)
			umsg.End()
		end
	end
	
	-- Prevent the door exploit
	if table.HasValue(EXPLOITABLE_DOORS, ent:GetClass()) && pl.last_door_time && pl.last_door_time + 1 > CurTime() then
		return false
	end
	
	pl.last_door_time = CurTime()
	return true
end


-- Called when player presses [F3]. Plays a taunt for their team
function GM:ShowSpare1(pl)
	if GAMEMODE:InRound() && pl:Alive() && (pl:Team() == TEAM_HUNTERS || pl:Team() == TEAM_PROPS) && pl.last_taunt_time + TAUNT_DELAY <= CurTime() && #PROP_TAUNTS > 1 && #HUNTER_TAUNTS > 1 then
--		repeat
			if pl:Team() == TEAM_HUNTERS then
				rand_taunt = table.Random(HUNTER_TAUNTS)
			else
				rand_taunt = table.Random(PROP_TAUNTS)
			end
--		until rand_taunt != pl.last_taunt
		
		pl.last_taunt_time = CurTime()
		pl.last_taunt = rand_taunt
		
		print("Prop Hunt: '"..pl:GetName().."' taunting with '"..rand_taunt.."'.")
		local vol = 1.0
		if pl:Team() == TEAM_HUNTERS then vol = vol * 0.5 end
		pl:EmitSound(rand_taunt, 100, 100, vol, CHAN_VOICE2)
	end	
end

-- Allow player to rotate the prop. (Either F4 or ducking)
function GM:ShowSpare2(pl)
	if pl:Alive() && (pl:Team() == TEAM_PROPS) then
		pl.ph_prop:SetApplyNewAngles(!pl.ph_prop:GetApplyNewAngles())
--		pl.ph_prop:SetNewAngles(pl:GetAngles())
	end
end

-- Called when the gamemode is initialized
function Initialize()
	game.ConsoleCommand("mp_flashlight 0\n")
end
hook.Add("Initialize", "PH_Initialize", Initialize)


-- Called when a player leaves
function PlayerDisconnected(pl)
	pl:RemoveProp()
end
hook.Add("PlayerDisconnected", "PH_PlayerDisconnected", PlayerDisconnected)


-- Called when the players spawns
function PlayerSpawn(pl)
	pl:Blind(false)
	pl:RemoveProp()
	pl:SetColor( Color(255, 255, 255, 255))
	pl:SetRenderMode( RENDERMODE_TRANSALPHA )
	pl:UnLock()
	pl:ResetHull()
	pl:SetViewOffset(Vector(0, 0, 64))
	pl:SetViewOffsetDucked(Vector(0, 0, 28))
	pl.last_taunt_time = 0
	pl:SetupHands()
	
	umsg.Start("ResetHull", pl)
	umsg.End()
--	umsg.Start("ThirdPerson", pl)
--	umsg.Bool(pl:Team() == TEAM_PROPS)
--	umsg.Entity(nil)
--	umsg.End()
	
	pl:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
end
hook.Add("PlayerSpawn", "PH_PlayerSpawn", PlayerSpawn)

function GM:PlayerSetHandsModel( ply, ent )
	local simplemodel = player_manager.TranslateToPlayerModelName( ply:GetModel() )
	local info = player_manager.TranslatePlayerHands( simplemodel )
	if ( info ) then
		ent:SetModel( info.model )
		ent:SetSkin( info.skin )
		ent:SetBodyGroups( info.body )
	end
end


-- Removes all weapons on a map
function RemoveWeaponsAndItems()
	for _, wep in pairs(ents.FindByClass("weapon_*")) do
		wep:Remove()
	end
	
	for _, item in pairs(ents.FindByClass("item_*")) do
		item:Remove()
	end
end
hook.Add("InitPostEntity", "PH_RemoveWeaponsAndItems", RemoveWeaponsAndItems)


-- Called when round ends
function RoundEnd()
	for _, pl in pairs(team.GetPlayers(TEAM_HUNTERS)) do
		pl:Blind(false)
		pl:UnLock()
	end
end
hook.Add("RoundEnd", "PH_RoundEnd", RoundEnd)


-- This is called when the round time ends (props win)
function GM:RoundTimerEnd()
	if !GAMEMODE:InRound() then
		return
	end
   
	GAMEMODE:RoundEndWithResult(TEAM_PROPS, "Props win!")
end


-- Called before start of round
function GM:OnPreRoundStart(num)
	game.CleanUpMap()
	
		if GetGlobalInt("RoundNumber") != 1 && (SWAP_TEAMS_EVERY_ROUND == 1 || ((team.GetScore(TEAM_PROPS) + team.GetScore(TEAM_HUNTERS)) > 0 || SWAP_TEAMS_POINTS_ZERO==1)) then
		for _, pl in pairs(player.GetAll()) do
			if pl:Team() == TEAM_PROPS || pl:Team() == TEAM_HUNTERS then
				if pl:Team() == TEAM_PROPS then
					pl:SetTeam(TEAM_HUNTERS)
				else
					pl:SetTeam(TEAM_PROPS)
				end
				
				pl:ChatPrint("Teams have been swapped!")
			end
		end
	end
	
	UTIL_StripAllPlayers()
	UTIL_SpawnAllPlayers()
	UTIL_FreezeAllPlayers()
end
