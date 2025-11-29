extends Area2D

# 인스펙터 창에서 바로 조절할 수 있도록 @export 를 사용합니다.
## 바람이 불 확률 (0.0 ~ 1.0 사이, 0.7은 70%)
@export var wind_active_chance: float = 0.5

## 바람의 최소 세기
@export var min_wind_strength: float = 50.0

## 바람의 최대 세기
@export var max_wind_strength: float = 200.0

# 현재 바람의 방향과 세기를 저장하는 변수 (UI 등에 표시할 때 유용)
var current_wind_vector: Vector2 = Vector2.ZERO

func _ready():
	# Area2D가 중력 지점(Point)이 아니라 방향(Vector)으로 작동하도록 설정
	self.gravity_point = false
	
	# 게임 시작 시 첫 바람 설정
	update_wind()

# 턴이 바뀔 때마다 호출될 함수
# WindArea.gd 스크립트의 update_wind 함수만 수정합니다.

# 턴이 바뀔 때마다 호출될 함수
func update_wind():
	# 1. 바람이 불지 결정 (예: 70% 확률)
	if randf() > wind_active_chance:
		# 바람이 불지 않음
		current_wind_vector = Vector2.ZERO
	else:
		# 2. 바람이 붊: 세기와 방향(좌/우)을 랜덤으로 결정
		
		# 랜덤한 세기
		var random_strength = randf_range(min_wind_strength, max_wind_strength)
		
		# 랜덤한 방향 (좌/우 50% 확률)
		var direction_vector: Vector2
		if randf() < 0.5:
			direction_vector = Vector2.LEFT  # (-1, 0)
		else:
			direction_vector = Vector2.RIGHT # (1, 0)
		
		# 방향과 세기를 곱하여 최종 바람 벡터 계산
		current_wind_vector = direction_vector * random_strength

	# 3. 계산된 바람 값을 Area2D의 gravity 속성에 적용
	if current_wind_vector == Vector2.ZERO:
		# 바람이 0이면 중력(힘)을 0으로 설정
		self.gravity = 0
		self.gravity_direction = Vector2.ZERO
	else:
		# Area2D의 중력(힘)은 '세기'와 '방향'으로 나뉘어 있습니다.
		self.gravity = current_wind_vector.length()
		self.gravity_direction = current_wind_vector.normalized()

	# (디버그용) 현재 바람 상태 출력
	print("새로운 바람 설정: ", current_wind_vector, " (세기: ", self.gravity, ", 방향: ", self.gravity_direction, ")")

	# (선택 사항) UI에 바람 정보를 업데이트하는 신호 발생
	# emit_signal("wind_updated", current_wind_vector)
