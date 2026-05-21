extends Control

const BACKGROUND_HEALING := Color(0.9098, 0.9569, 0.9725) # #E8F4F8
const API_KEY_PATH := "res://API_KEY.txt"
const CHAT_SAVE_PATH := "user://boogi_chat_save.json"
const WELCOME_MESSAGE := "안녕! 나는 부기야. 오늘의 목표를 적고 물장구를 쳐 봐! 🐢"
const LOADING_REPLY_TEXT := "부기가 열심히 고민하고 있어요... 🐢 뽀글뽀글..."
const SYSTEM_PROMPT := (
	"너는 다정하고 느긋한 바다거북이 '부기'야. "
	+ "유저의 거대한 목표를 자기 자비(Self-Compassion)를 바탕으로 "
	+ "거대한 목표를 당장 누워서도 할 수 있을 만큼 아주 하찮고 달성하기 쉬운 4단계의 행동으로 쪼개서 제안해 줘"
)
const USER_BUBBLE_BG := Color(1.0, 1.0, 1.0)
const BOOGI_BUBBLE_BG := Color(0.698, 0.9216, 0.949)
const USER_TEXT_COLOR := Color(0.2902, 0.2902, 0.2902)
const BOOGI_TEXT_COLOR := Color(0.1765, 0.3098, 0.3451)
const USER_BUBBLE_BORDER := Color(0.8471, 0.9098, 0.9333)
const BUBBLE_CORNER_RADIUS := 15
const BUBBLE_CONTENT_MARGIN := 15
const BOOGI_ICON := preload("res://icon.svg")
const BUTTON_BG := Color(0.35, 0.65, 0.78)
const BUTTON_TEXT := Color(1.0, 1.0, 1.0)

var conversation_history: Array = []

var _http_request: HTTPRequest
var _chat_scroll: ScrollContainer
var chat_log: VBoxContainer
var _goal_input: TextEdit
var _splash_button: Button
var _loading_bubble: Node


func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	load_chat_data()
	setup_ui()

	_http_request = HTTPRequest.new()
	add_child(_http_request)
	_http_request.request_completed.connect(_on_request_completed)

	restore_chat_bubbles()
	print("부기야 안녕! 드디어 첫 물장구를 쳤어!")


func _apply_full_rect(control: Control) -> void:
	control.set_anchors_preset(Control.PRESET_FULL_RECT)
	control.offset_left = 0.0
	control.offset_top = 0.0
	control.offset_right = 0.0
	control.offset_bottom = 0.0


func setup_ui() -> void:
	var ui_root := MarginContainer.new()
	ui_root.name = "UIRoot"
	_apply_full_rect(ui_root)
	ui_root.mouse_filter = Control.MOUSE_FILTER_PASS
	ui_root.add_theme_constant_override("margin_left", 12)
	ui_root.add_theme_constant_override("margin_top", 12)
	ui_root.add_theme_constant_override("margin_right", 12)
	ui_root.add_theme_constant_override("margin_bottom", 12)
	add_child(ui_root)

	var layout := VBoxContainer.new()
	layout.name = "MainLayout"
	layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_theme_constant_override("separation", 12)
	ui_root.add_child(layout)

	var profile_row := CenterContainer.new()
	profile_row.custom_minimum_size = Vector2(0.0, 112.0)
	layout.add_child(profile_row)

	var profile_wrap := PanelContainer.new()
	var profile_style := StyleBoxFlat.new()
	profile_style.bg_color = Color(1.0, 1.0, 1.0, 0.7)
	profile_style.set_corner_radius_all(52)
	profile_style.set_border_width_all(2)
	profile_style.border_color = Color(0.75, 0.88, 0.95)
	profile_wrap.add_theme_stylebox_override("panel", profile_style)
	profile_wrap.custom_minimum_size = Vector2(104.0, 104.0)
	profile_row.add_child(profile_wrap)

	var profile_center := CenterContainer.new()
	profile_center.custom_minimum_size = Vector2(104.0, 104.0)
	profile_wrap.add_child(profile_center)

	var profile := TextureRect.new()
	profile.custom_minimum_size = Vector2(88.0, 88.0)
	profile.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	profile.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	profile.texture = BOOGI_ICON
	profile.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	profile_center.add_child(profile)

	var title := Label.new()
	title.text = "Boogi On & On"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 22)
	layout.add_child(title)

	_chat_scroll = ScrollContainer.new()
	_chat_scroll.name = "ChatScroll"
	_chat_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_chat_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL # 스크롤 영역만 최대한 늘어남
	_chat_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_chat_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	layout.add_child(_chat_scroll)

	chat_log = VBoxContainer.new()
	chat_log.name = "ChatLog"
	chat_log.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chat_log.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	chat_log.add_theme_constant_override("separation", 15)
	_chat_scroll.add_child(chat_log)

	# --- 입력창과 버튼을 나란히 묶는 모바일형 하단 바 ---
	var bottom_bar := HBoxContainer.new()
	bottom_bar.name = "BottomBar"
	bottom_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_bar.size_flags_vertical = Control.SIZE_SHRINK_END # 바닥에 고정
	layout.add_child(bottom_bar)

	_goal_input = TextEdit.new()
	_goal_input.name = "GoalInput"
	_goal_input.placeholder_text = "오늘의 목표를 적어 보세요..."
	_goal_input.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	_goal_input.scroll_fit_content_height = true # 여러 줄 입력시 자연스럽게 늘어남
	_goal_input.custom_minimum_size = Vector2(0.0, 52.0)
	_goal_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL # 입력창이 가로폭 대부분 차지
	_goal_input.size_flags_vertical = Control.SIZE_FILL
	_apply_input_theme(_goal_input)
	bottom_bar.add_child(_goal_input)

	_splash_button = Button.new()
	_splash_button.name = "SplashButton"
	_splash_button.text = "물장구 💦"
	_splash_button.custom_minimum_size = Vector2(90.0, 52.0)
	_splash_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	_splash_button.size_flags_vertical = Control.SIZE_FILL
	_splash_button.pressed.connect(_on_splash_button_pressed)
	bottom_bar.add_child(_splash_button)
	call_deferred("_apply_button_theme", _splash_button)

	var background := ColorRect.new()
	background.name = "Background"
	_apply_full_rect(background)
	background.color = BACKGROUND_HEALING
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.z_index = -10
	add_child(background)
	move_child(background, 0)


func _make_ui_font() -> Font:
	var font := SystemFont.new()
	font.font_names = PackedStringArray([
		"Malgun Gothic",
		"Apple SD Gothic Neo",
		"Noto Sans CJK KR",
		"Segoe UI",
	])
	font.font_weight = 600
	return font


func _make_user_turn(text: String) -> Dictionary:
	return {"role": "user", "parts": [{"text": text}]}

func _make_model_turn(text: String) -> Dictionary:
	return {"role": "model", "parts": [{"text": text}]}


func _apply_input_theme(input: TextEdit) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 1.0, 1.0, 0.92)
	style.set_corner_radius_all(12)
	style.content_margin_left = 12
	style.content_margin_top = 10
	style.content_margin_right = 12
	style.content_margin_bottom = 10
	style.set_border_width_all(1)
	style.border_color = USER_BUBBLE_BORDER
	input.add_theme_stylebox_override("normal", style)
	input.add_theme_stylebox_override("focus", style)
	input.add_theme_font_override("font", _make_ui_font())
	input.add_theme_font_size_override("font_size", 16)
	input.add_theme_color_override("font_color", USER_TEXT_COLOR)
	input.add_theme_color_override("font_placeholder_color", Color(0.55, 0.6, 0.65))


func _apply_button_theme(button: Button) -> void:
	if button == null: return
	button.text = "물장구 💦" if not button.disabled else "..."
	button.flat = false

	var normal := StyleBoxFlat.new()
	normal.bg_color = BUTTON_BG
	normal.set_corner_radius_all(12)
	var ui_font := _make_ui_font()
	button.add_theme_font_override("font", ui_font)
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", normal)
	button.add_theme_stylebox_override("pressed", normal)
	button.add_theme_stylebox_override("disabled", normal)
	button.add_theme_color_override("font_color", BUTTON_TEXT)


func _build_request_contents() -> Array:
	var contents: Array = []
	contents.assign(conversation_history)
	return contents


func _turn_is_user(turn: Dictionary) -> bool:
	return str(turn.get("role", "")).to_lower() == "user"

func _extract_turn_text(turn: Variant) -> String:
	if not turn is Dictionary: return ""
	var parts: Variant = turn.get("parts", [])
	if not parts is Array or parts.is_empty(): return ""
	var first_part: Variant = parts[0]
	if not first_part is Dictionary: return ""
	return str(first_part.get("text", "")).strip_edges()

func _is_valid_turn(turn: Variant) -> bool:
	if not turn is Dictionary: return false
	var role := str(turn.get("role", "")).to_lower()
	if role != "user" and role != "model": return false
	return not _extract_turn_text(turn).is_empty()


func save_chat_data() -> void:
	var json_text := JSON.stringify(conversation_history)
	var file := FileAccess.open(CHAT_SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(json_text)

func load_chat_data() -> void:
	conversation_history.clear()
	if not FileAccess.file_exists(CHAT_SAVE_PATH): return
	var file := FileAccess.open(CHAT_SAVE_PATH, FileAccess.READ)
	if file == null: return
	var json := JSON.new()
	if json.parse(file.get_as_text()) == OK and json.data is Array:
		var restored: Array = []
		for turn in json.data:
			if _is_valid_turn(turn):
				restored.append(turn)
		conversation_history.assign(restored)


func restore_chat_bubbles() -> void:
	if conversation_history.is_empty():
		add_chat_bubble(WELCOME_MESSAGE, false)
		return
	for turn in conversation_history:
		var text := _extract_turn_text(turn)
		if not text.is_empty():
			add_chat_bubble(text, _turn_is_user(turn), false)
	call_deferred("_scroll_chat_to_bottom")


func _append_user_turn(user_text: String) -> void:
	conversation_history.append(_make_user_turn(user_text))
	save_chat_data()

func _append_model_turn(model_text: String) -> void:
	conversation_history.append(_make_model_turn(model_text))
	save_chat_data()


func _create_bubble_style(is_user: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(BUBBLE_CORNER_RADIUS)
	style.content_margin_left = BUBBLE_CONTENT_MARGIN
	style.content_margin_top = BUBBLE_CONTENT_MARGIN
	style.content_margin_right = BUBBLE_CONTENT_MARGIN
	style.content_margin_bottom = BUBBLE_CONTENT_MARGIN
	style.anti_aliasing = true

	if is_user:
		style.bg_color = USER_BUBBLE_BG
		style.border_color = USER_BUBBLE_BORDER
		style.set_border_width_all(2)
		style.shadow_color = Color(0.45, 0.62, 0.72, 0.22)
	else:
		style.bg_color = BOOGI_BUBBLE_BG
		style.shadow_color = Color(0.45, 0.68, 0.78, 0.1)

	style.shadow_size = 5
	style.shadow_offset = Vector2(0.0, 2.0)
	return style


func _create_bubble_label(text: String, is_user: bool) -> Label:
	var bubble := Label.new()
	bubble.text = text
	bubble.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bubble.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	
	# [핵심 수정] 글자 수가 적으면 딱 맞게, 많으면 240px에서 줄바꿈!
	if text.length() < 14:
		bubble.autowrap_mode = TextServer.AUTOWRAP_OFF
	else:
		bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		bubble.custom_minimum_size = Vector2(240, 0)
		
	bubble.add_theme_font_override("font", _make_ui_font())
	bubble.add_theme_font_size_override("font_size", 16)
	bubble.add_theme_color_override(
		"font_color",
		USER_TEXT_COLOR if is_user else BOOGI_TEXT_COLOR,
	)
	return bubble


func _create_bubble_panel(text: String, is_user: bool) -> PanelContainer:
	var panel := PanelContainer.new()
	# 유저면 오른쪽으로 붙고, 부기면 왼쪽으로 붙게 설정
	panel.size_flags_horizontal = Control.SIZE_SHRINK_END if is_user else Control.SIZE_SHRINK_BEGIN
	panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

	var style_box := _create_bubble_style(is_user)
	panel.add_theme_stylebox_override("panel", style_box)
	panel.add_child(_create_bubble_label(text, is_user))
	return panel


func _create_bubble_row(text: String, is_user: bool) -> MarginContainer:
	var row := MarginContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# 모바일 메신저처럼 반대편에 여백을 줘서 줄바꿈 유도
	if is_user:
		row.add_theme_constant_override("margin_left", 60)
		row.add_theme_constant_override("margin_right", 0)
	else:
		row.add_theme_constant_override("margin_left", 0)
		row.add_theme_constant_override("margin_right", 60)

	row.add_child(_create_bubble_panel(text, is_user))
	return row


func add_chat_bubble(text: String, is_user: bool, auto_scroll: bool = true) -> void:
	if chat_log == null: return
	chat_log.add_child(_create_bubble_row(text, is_user))
	if auto_scroll:
		call_deferred("_scroll_chat_to_bottom")


func _scroll_chat_to_bottom() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var scroll_bar := _chat_scroll.get_v_scroll_bar()
	scroll_bar.value = scroll_bar.max_value


func _set_button_busy(busy: bool) -> void:
	_splash_button.disabled = busy
	_apply_button_theme(_splash_button)

func _clear_loading_bubble() -> void:
	if _loading_bubble != null and is_instance_valid(_loading_bubble):
		_loading_bubble.queue_free()
	_loading_bubble = null

func _set_loading_state() -> void:
	_clear_loading_bubble()
	_set_button_busy(true)
	_loading_bubble = _create_bubble_row(LOADING_REPLY_TEXT, false)
	chat_log.add_child(_loading_bubble)
	call_deferred("_scroll_chat_to_bottom")

func _show_reply(message: String) -> void:
	_clear_loading_bubble()
	add_chat_bubble(message, false)

func _finish_request() -> void:
	_clear_loading_bubble()
	_set_button_busy(false)


func _load_api_key() -> String:
	if not FileAccess.file_exists(API_KEY_PATH): return ""
	var file := FileAccess.open(API_KEY_PATH, FileAccess.READ)
	if file == null: return ""
	var raw := file.get_as_text()
	if raw.begins_with("\ufeff"): raw = raw.substr(1)
	var key := raw.strip_edges()
	if key.length() >= 2:
		if (key.begins_with('"') and key.ends_with('"')) or (key.begins_with("'") and key.ends_with("'")):
			key = key.substr(1, key.length() - 2).strip_edges()
	if key.begins_with("key="): key = key.substr(4).strip_edges()
	return key.replace(" ", "").replace("\n", "").replace("\r", "").replace("\t", "")

func _gemini_endpoint() -> String:
	return "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"

func _send_gemini_request() -> void:
	var api_key := _load_api_key()
	if api_key.is_empty():
		_show_reply("API_KEY.txt를 확인해 주세요.")
		_finish_request()
		return

	var url := "%s?key=%s" % [_gemini_endpoint(), api_key]
	var payload := {
		"systemInstruction": {"parts": [{"text": SYSTEM_PROMPT}]},
		"contents": _build_request_contents(),
	}
	var err := _http_request.request(url, PackedStringArray(["Content-Type: application/json"]), HTTPClient.METHOD_POST, JSON.stringify(payload))
	if err != OK:
		_show_reply("통신 에러가 발생했어요.")
		_finish_request()

func _extract_gemini_text(response_body: PackedByteArray) -> String:
	var json := JSON.new()
	if json.parse(response_body.get_string_from_utf8()) != OK: return ""
	var data: Variant = json.data
	if not data is Dictionary or data.has("error"): return ""
	var candidates: Array = data.get("candidates", [])
	if candidates.is_empty(): return ""
	var parts: Array = candidates[0].get("content", {}).get("parts", [])
	if parts.is_empty(): return ""
	return str(parts[0].get("text", ""))

func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		_show_reply("통신에 실패했어요. (코드: %d)" % response_code)
		_finish_request()
		return
	var reply := _extract_gemini_text(body)
	if reply.is_empty():
		_show_reply("대답을 해석하지 못했어요.")
	else:
		_append_model_turn(reply)
		_show_reply(reply)
	_finish_request()


func _on_splash_button_pressed() -> void:
	var goal_text := _goal_input.text.strip_edges()
	if goal_text.is_empty(): return
	_append_user_turn(goal_text)
	add_chat_bubble(goal_text, true)
	_goal_input.text = ""
	_set_loading_state()
	_send_gemini_request()
