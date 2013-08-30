/*
 Copyright (c) 2013 yvt
 
 This file is part of OpenSpades.
 
 OpenSpades is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 OpenSpades is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with OpenSpades.  If not, see <http://www.gnu.org/licenses/>.
 
 */

#pragma once

#define FALL_SLOW_DOWN	0.24f
#define FALL_DAMAGE_VELOCITY	0.58f
#define FALL_DAMAGE_SCALAR	4096
#define MINERANGE	3
#define SCPITCH 128
#define MAXSCANDIST 128
#define MAXSCANSQ (MAXSCANDIST*MAXSCANDIST)
#define BOUNCE_SOUND_THRESHOLD 0.1f
#define TC_CAPTURE_RATE 0.05f
#define TC_CAPTURE_DISTANCE 16.f

enum WeaponType {
	RIFLE_WEAPON,
	SMG_WEAPON,
	SHOTGUN_WEAPON
};

enum BlockActionType {
	BlockActionCreate,
	BlockActionTool, // gun and spade
	BlockActionDig,
	BlockActionGrenade
};

// "Hit Packet" and weapon damage query
enum HitType {
	HitTypeTorso,
	HitTypeHead,
	HitTypeArms,
	HitTypeLegs,
	HitTypeBlock, // used for block damage query
	HitTypeMelee 
};

enum HurtType {
	HurtTypeFall = 0,
	HurtTypeWeapon
};

enum KillType {
	KillTypeWeapon = 0,
	KillTypeHeadshot,
	KillTypeMelee,
	KillTypeGrenade,
	KillTypeFall,
	KillTypeTeamChange,
	KillTypeClassChange
};

