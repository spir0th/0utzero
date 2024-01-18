extends Node

const GAME_NAME = "0utZero"
const GAME_AUTHORS = "spirothXYZ, Iyxan23"
const GAME_LICENSE = "GNU Public License v3"
const GAME_COPYRIGHT_YEAR = "2023"
const GAME_VERSION = "0.0.9"
const GAME_VERSION_INT = 9

const CONFIG_OVERRIDE_PATH = "user://override.cfg"
const SETTINGS_WINDOW_WIDTH = "display/window/size/width"
const SETTINGS_WINDOW_HEIGHT = "display/window/size/height"
const SETTINGS_WINDOW_MIN_WIDTH = "display/window/size/min_width"
const SETTINGS_WINDOW_MIN_HEIGHT = "display/window/size/min_height"
const SETTINGS_WINDOW_FULLSCREEN = "display/window/size/fullscreen"
const SETTINGS_WINDOW_BORDERLESS = "display/window/size/borderless"
const SETTINGS_WINDOW_MAXIMIZED = "display/window/size/maximized"
const SETTINGS_WINDOW_POSITION_WIDTH = "display/window/position/width"
const SETTINGS_WINDOW_POSITION_HEIGHT = "display/window/position/height"
const SETTINGS_UI_STRETCH_MODE = "display/window/stretch/mode"
const SETTINGS_UI_STRETCH_ASPECT = "display/window/stretch/aspect"
const SETTINGS_UI_SCALE = "display/window/stretch/shrink"

const MAP_TESTLEVEL_01 = "res://scenes/levels/TestLevel01.tscn"
const MAP_TESTLEVEL_02 = "res://scenes/levels/TestLevel02.tscn"
const MAP_GAME = "res://Game.tscn"
const MAP_MAIN_SCENE = MAP_GAME

const OBJ_PHONEBRICK = "res://scenes/objects/PhoneBrick.tscn"

const OBJ_GROUP_PICKUP = "Pickup"
const OBJ_GROUP_INTERACTABLE = "Interactable"
