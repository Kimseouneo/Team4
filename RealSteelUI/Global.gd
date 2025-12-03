extends Node

# 게임 설정 변수들
var selected_mode = "" # "tutorial", "pve", "pvp"
var selected_map = ""  # "cyberpunk", "desert"
var p1_name = "Player 1"
var p2_name = "Player 2"

# 맵 씬의 파일 경로 (실제 파일 경로에 맞게 수정해주세요)
var scene_paths = {
	"tutorial": "res://maps/PracticeMap.tscn",
	"cyberpunk": "res://map/CyberPunk.tscn",
	"desert": "res://maps/DesertMap.tscn"
}
