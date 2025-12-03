extends Control

# 노드들을 미리 변수에 담아둡니다. (노드 경로는 실제 트리에 맞게 확인 필요)
@onready var title_screen = $TitleScreen
@onready var mode_select = $ModeSelect
@onready var name_input = $NameInput
@onready var map_select = $MapSelect

# 이름 입력창 노드
@onready var p1_input = $NameInput/VBoxContainer/LineEdit1
@onready var p2_input = $NameInput/VBoxContainer/LineEdit2

func _ready():
	# 게임 시작 시 타이틀만 보이고 나머지는 숨김
	show_screen(title_screen)

# 화면 전환을 담당하는 도우미 함수
func show_screen(target_screen: Control):
	title_screen.visible = false
	mode_select.visible = false
	name_input.visible = false
	map_select.visible = false
	
	target_screen.visible = true

# --- 시그널 연결 함수들 ---

# 1. Game Start 버튼 클릭
func _on_game_start_pressed():
	show_screen(mode_select)

# 2. 모드 선택 버튼들 클릭
func _on_tutorial_pressed():
	Global.selected_mode = "tutorial"
	Global.selected_map = "tutorial"
	start_game()

func _on_pve_pressed():
	Global.selected_mode = "pve"
	show_screen(map_select) # 이름 입력 건너뛰고 맵 선택으로

func _on_pvp_pressed():
	Global.selected_mode = "pvp"
	show_screen(map_select)

# 3. 이름 입력 후 Next 버튼 클릭
func _on_name_next_pressed():
	# 입력된 이름 저장 (비어있으면 기본값)
	if p1_input.text != "": Global.p1_name = p1_input.text
	if p2_input.text != "": Global.p2_name = p2_input.text
	
	start_game()

func go_next_after_map():
	if Global.selected_mode == "pvp":
		# PVP면 아직 할 일이 남았음 -> 이름 입력 화면으로 이동
		show_screen(name_input)
	else:
		# PVE면 준비 끝 -> 게임 시작
		start_game()
		
# 4. 맵 선택 버튼들 클릭
func _on_cyberpunk_pressed():
	Global.selected_map = "cyberpunk"
	go_next_after_map()

func _on_desert_pressed():
	Global.selected_map = "desert"
	go_next_after_map()

# 게임 씬 로드 함수
func start_game():
	var map_path = Global.scene_paths.get(Global.selected_map)
	if map_path:
		get_tree().change_scene_to_file(map_path)
	else:
		print("맵 경로를 찾을 수 없습니다!")

func _on_next_pressed() -> void:
	pass # Replace with function body.
	
# 1. 모드 선택 화면에서 뒤로 가기 -> 타이틀 화면으로
func _on_mode_back_btn_pressed():
	show_screen(title_screen)

# 2. 맵 선택 화면에서 뒤로 가기 -> 모드 선택 화면으로
func _on_map_back_btn_pressed():
	# 맵 선택을 취소하고 다시 모드를 고르러 감
	Global.selected_mode = "" # (선택사항) 모드 정보 초기화
	show_screen(mode_select)

# 3. 이름 입력 화면에서 뒤로 가기 -> 맵 선택 화면으로
# (아까 로직을 PVP -> 맵 -> 이름 순서로 바꿨으므로, 뒤로 가면 맵 선택이 나와야 함)
func _on_name_back_btn_pressed():
	show_screen(map_select)
