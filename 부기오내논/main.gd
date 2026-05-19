extends Control

const BACKGROUND_SEA := Color(0.73, 0.91, 0.97)
const GEMINI_MODELS: Array[String] = [
	"gemini-2.0-flash-lite",
	"gemini-2.5-flash-lite",
	"gemini-2.5-flash",
]
const API_KEY_PATH := "res://API_KEY.txt"
const LOADING_REPLY_TEXT := "부기가 열심히 고민하고 있어요... 🐢 뽀글뽀글..."
const SYSTEM_PROMPT := (
	"너는 다정하고 느긋한 바다거북이 '부기'야. "
	+ "유저의 거대한 목표를 자기 자비(Self-Compassion)를 바탕으로 "
	+ "거대한 목표를 당장 누워서도 할 수 있을 만큼 아주 하찮고 달성하기 쉬운 4단계의 행동으로 쪼개서 제안해 줘"
	#+ "대답은 모바일 화면에서 한눈에 읽기 편하도록 절대 길게 늘어놓지 마. "
	#+ "핵심만 간결하게 3~4문장 이내로 줄여서 대답하고, "
	#+ "4단계 물장구도 아주 짧고 직관적인 단어 위주로 요약해 줘."
)
const MAX_RETRIES_PER_MODEL := 3
const RETRY_BASE_DELAY_SEC := 2.0
const USER_BUBBLE_COLOR := Color(0.42, 0.44, 0.48)
const BOOGI_BUBBLE_COLOR := Color(0.58, 0.78, 0.96)
const USER_TEXT_COLOR := Color(0.96, 0.96, 0.97)
const BOOGI_TEXT_COLOR := Color(0.12, 0.22, 0.32)
const BUBBLE_CORNER_RADIUS := 14

var conversation_history: Array = []

var _http_request: HTTPRequest
var _retry_timer: Timer
var _chat_scroll: ScrollContainer
var chat_log: VBoxContainer
var _goal_input: TextEdit
var _splash_button: Button
var _loading_bubble: Node
var _last_prompt: String = ""
var _active_model_index: int = 0
var _retry_count: int = 0
var _pending_retry_model_index: int = 0
var _pending_retry_count: int = 0


func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)

	_http_request = HTTPRequest.new()
	add_child(_http_request)
	_http_request.request_completed.connect(_on_request_completed)

	_retry_timer = Timer.new()
	_retry_timer.one_shot = true
	_retry_timer.timeout.connect(_on_retry_timer_timeout)
	add_child(_retry_timer)

	setup_ui()
	add_chat_bubble("안녕! 나는 부기야. 오늘의 목표를 적고 물장구를 쳐 봐! 🐢", false)
	print("부기야 안녕! 드디어 첫 물장구를 쳤어!")


func setup_ui() -> void:
	var background := ColorRect.new()
	background.set_anchors_preset(PRESET_FULL_RECT)
	background.color = BACKGROUND_SEA
	background.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	add_child(margin)

	var layout := VBoxContainer.new()
	layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_theme_constant_override("separation", 12)
	margin.add_child(layout)

	var profile_row := CenterContainer.new()
	layout.add_child(profile_row)

	var profile := TextureRect.new()
	profile.custom_minimum_size = Vector2(100.0, 100.0)
	profile.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	profile.texture = load("res://icon.svg")
	profile_row.add_child(profile)

	var title := Label.new()
	title.text = "Boogi On & On"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 22)
	layout.add_child(title)

	_chat_scroll = ScrollContainer.new()
	_chat_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_chat_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_chat_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_chat_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_chat_scroll.resized.connect(_sync_chat_log_width)
	layout.add_child(_chat_scroll)

	chat_log = VBoxContainer.new()
	chat_log.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chat_log.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	chat_log.add_theme_constant_override("separation", 10)
	_chat_scroll.add_child(chat_log)

	_goal_input = TextEdit.new()
	_goal_input.placeholder_text = "오늘의 목표를 적어 보세요..."
	_goal_input.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	_goal_input.scroll_fit_content_height = true
	_goal_input.custom_minimum_size = Vector2(0.0, 88.0)
	_goal_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.add_child(_goal_input)

	_splash_button = Button.new()
	_splash_button.text = "물장구 치기"
	_splash_button.custom_minimum_size = Vector2(0.0, 48.0)
	_splash_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_splash_button.pressed.connect(_on_splash_button_pressed)
	layout.add_child(_splash_button)

	call_deferred("_sync_chat_log_width")


func _sync_chat_log_width() -> void:
	if _chat_scroll == null or chat_log == null:
		return
	chat_log.custom_minimum_size.x = maxf(0.0, _chat_scroll.size.x)


func _make_user_turn(text: String) -> Dictionary:
	return {
		"role": "user",
		"parts": [{"text": text}],
	}


func _make_model_turn(text: String) -> Dictionary:
	return {
		"role": "model",
		"parts": [{"text": text}],
	}


func _build_request_contents(user_text: String) -> Array:
	var contents: Array = []
	contents.assign(conversation_history)
	contents.append(_make_user_turn(user_text))
	return contents


func _append_conversation_turn(user_text: String, model_text: String) -> void:
	conversation_history.append(_make_user_turn(user_text))
	conversation_history.append(_make_model_turn(model_text))


func _create_bubble_style(is_user: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(BUBBLE_CORNER_RADIUS)
	style.content_margin_left = 14
	style.content_margin_top = 10
	style.content_margin_right = 14
	style.content_margin_bottom = 10
	style.bg_color = USER_BUBBLE_COLOR if is_user else BOOGI_BUBBLE_COLOR
	return style


func _create_bubble_row(text: String, is_user: bool) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _create_bubble_style(is_user))

	var bubble := RichTextLabel.new()
	bubble.bbcode_enabled = false
	bubble.fit_content = true
	bubble.scroll_active = false
	bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bubble.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bubble.text = text
	bubble.add_theme_color_override(
		"default_color",
		USER_TEXT_COLOR if is_user else BOOGI_TEXT_COLOR,
	)

	panel.add_child(bubble)
	row.add_child(panel)
	return row


func add_chat_bubble(text: String, is_user: bool) -> void:
	chat_log.add_child(_create_bubble_row(text, is_user))
	call_deferred("_scroll_chat_to_bottom")


func _scroll_chat_to_bottom() -> void:
	await get_tree().process_frame
	_sync_chat_log_width()
	await get_tree().process_frame
	var scroll_bar := _chat_scroll.get_v_scroll_bar()
	scroll_bar.value = scroll_bar.max_value


func _set_button_busy(busy: bool) -> void:
	_splash_button.disabled = busy
	_splash_button.text = "물장구 치는 중..." if busy else "물장구 치기"


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
	_retry_timer.stop()
	_clear_loading_bubble()
	_set_button_busy(false)


func _load_api_key() -> String:
	if not FileAccess.file_exists(API_KEY_PATH):
		push_error("API_KEY.txt 파일을 찾을 수 없습니다.")
		return ""

	var file := FileAccess.open(API_KEY_PATH, FileAccess.READ)
	if file == null:
		push_error("API_KEY.txt 파일을 열 수 없습니다.")
		return ""

	var raw := file.get_as_text()
	if raw.begins_with("\ufeff"):
		raw = raw.substr(1)

	var key := raw.strip_edges()
	if key.length() >= 2:
		if (key.begins_with('"') and key.ends_with('"')) or (key.begins_with("'") and key.ends_with("'")):
			key = key.substr(1, key.length() - 2).strip_edges()
	if key.begins_with("key="):
		key = key.substr(4).strip_edges()

	key = key.replace(" ", "").replace("\n", "").replace("\r", "").replace("\t", "")
	if key.is_empty() or not key.begins_with("AIza"):
		push_error("API_KEY.txt에 유효한 API 키가 없습니다.")
		return ""

	return key


func _gemini_endpoint(model: String) -> String:
	return "https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent" % model


func _parse_api_error(body: PackedByteArray) -> Dictionary:
	var json := JSON.new()
	if json.parse(body.get_string_from_utf8()) != OK:
		return {}
	if not json.data is Dictionary:
		return {}
	return json.data.get("error", {})


func _parse_retry_seconds(error: Dictionary) -> float:
	for detail in error.get("details", []):
		if not detail is Dictionary:
			continue
		if detail.get("@type", "").ends_with("RetryInfo"):
			var delay: String = detail.get("retryDelay", "0s")
			if delay.ends_with("s"):
				return float(delay.trim_suffix("s"))
	return -1.0


func _is_retryable_error(response_code: int, api_error: Dictionary) -> bool:
	if response_code in [429, 500, 502, 503]:
		return true

	var status := str(api_error.get("status", "")).to_upper()
	if status in ["UNAVAILABLE", "RESOURCE_EXHAUSTED", "INTERNAL"]:
		return true

	var message := str(api_error.get("message", "")).to_lower()
	return (
		"high demand" in message
		or "overloaded" in message
		or "try again" in message
		or "temporarily" in message
	)


func _retry_delay_seconds(retry_count: int, api_error: Dictionary) -> float:
	var server_delay := _parse_retry_seconds(api_error)
	if server_delay > 0.0:
		return server_delay
	return RETRY_BASE_DELAY_SEC * pow(2.0, float(retry_count)) + randf_range(0.2, 0.8)


func _schedule_retry(delay_sec: float, model_index: int, retry_count: int) -> void:
	_pending_retry_model_index = model_index
	_pending_retry_count = retry_count
	_clear_loading_bubble()
	add_chat_bubble(
		"부기 서버가 지금 많이 바빠요... 🐢\n약 %d초 후에 자동으로 다시 시도할게요."
		% int(ceil(delay_sec)),
		false,
	)
	_set_button_busy(true)
	_retry_timer.wait_time = delay_sec
	_retry_timer.start()


func _on_retry_timer_timeout() -> void:
	_set_loading_state()
	_send_gemini_request(_last_prompt, _pending_retry_model_index, _pending_retry_count)


func _format_quota_message(error: Dictionary) -> String:
	var retry_seconds := _parse_retry_seconds(error)
	var model_name: String = GEMINI_MODELS[_active_model_index]
	var message := "Gemini 무료 사용 한도에 걸렸어요 (모델: %s).\n" % model_name
	if retry_seconds > 0.0:
		message += "약 %d초 뒤에 다시 시도해 주세요.\n" % int(ceil(retry_seconds))
	message += "사용량: https://ai.dev/rate-limit"
	return message


func _format_overload_message(error: Dictionary) -> String:
	var retry_seconds := _parse_retry_seconds(error)
	var message := (
		"지금 Gemini 서버가 너무 붐빕니다. 🐢\n"
		+ "잠시 후 '물장구 치기'를 다시 눌러 주세요.\n"
	)
	if retry_seconds > 0.0:
		message += "(권장 대기: 약 %d초)\n" % int(ceil(retry_seconds))
	message += "\n자동 재시도를 모두 마쳤어요."
	return message


func _send_gemini_request(prompt: String, model_index: int = 0, retry_count: int = 0) -> void:
	_last_prompt = prompt
	_active_model_index = model_index
	_retry_count = retry_count

	var api_key := _load_api_key()
	if api_key.is_empty():
		_show_reply("API 키를 불러오지 못했어요. API_KEY.txt를 확인해 주세요.")
		_finish_request()
		return

	if model_index >= GEMINI_MODELS.size():
		_show_reply("사용 가능한 Gemini 모델을 모두 시도했지만 응답하지 못했어요.")
		_finish_request()
		return

	var model: String = GEMINI_MODELS[model_index]
	if retry_count == 0 and model_index > 0:
		_clear_loading_bubble()
		add_chat_bubble("다른 모델(%s)로 다시 시도할게요... 🐢" % model, false)

	var url := "%s?key=%s" % [_gemini_endpoint(model), api_key]
	var payload := {
		"systemInstruction": {
			"parts": [{"text": SYSTEM_PROMPT}],
		},
		"contents": _build_request_contents(prompt),
	}
	var body := JSON.stringify(payload)
	var headers := PackedStringArray(["Content-Type: application/json"])
	var err := _http_request.request(url, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		_show_reply("요청을 시작하지 못했어요: %s" % error_string(err))
		_finish_request()


func _extract_gemini_text(response_body: PackedByteArray) -> String:
	var json := JSON.new()
	var parse_err := json.parse(response_body.get_string_from_utf8())
	if parse_err != OK:
		return ""

	var data: Variant = json.data
	if not data is Dictionary:
		return ""

	if data.has("error"):
		return ""

	var candidates: Array = data.get("candidates", [])
	if candidates.is_empty():
		return ""

	var content: Dictionary = candidates[0].get("content", {})
	var parts: Array = content.get("parts", [])
	if parts.is_empty():
		return ""

	return str(parts[0].get("text", ""))


func _handle_api_failure(response_code: int, api_error: Dictionary) -> void:
	if response_code == 429 and _active_model_index + 1 < GEMINI_MODELS.size():
		_send_gemini_request(_last_prompt, _active_model_index + 1, 0)
		return

	if _is_retryable_error(response_code, api_error):
		if _retry_count < MAX_RETRIES_PER_MODEL:
			var delay_sec := _retry_delay_seconds(_retry_count, api_error)
			_schedule_retry(delay_sec, _active_model_index, _retry_count + 1)
			return
		if _active_model_index + 1 < GEMINI_MODELS.size():
			_send_gemini_request(_last_prompt, _active_model_index + 1, 0)
			return
		if response_code == 429:
			_show_reply(_format_quota_message(api_error))
		else:
			_show_reply(_format_overload_message(api_error))
		_finish_request()
		return

	if api_error.is_empty():
		_show_reply("Gemini API 오류 %d가 발생했어요." % response_code)
	else:
		_show_reply("Gemini API 오류: %s" % str(api_error.get("message", api_error)))
	_finish_request()


func _on_request_completed(
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray,
) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		_show_reply("네트워크 통신에 실패했어요. 인터넷 연결을 확인해 주세요.")
		_finish_request()
		return

	if response_code != 200:
		_handle_api_failure(response_code, _parse_api_error(body))
		return

	var reply := _extract_gemini_text(body)
	if reply.is_empty():
		_show_reply("부기의 대답을 가져오지 못했어요. 잠시 후 다시 시도해 주세요.")
	else:
		_append_conversation_turn(_last_prompt, reply)
		_show_reply(reply)

	_finish_request()


func _on_splash_button_pressed() -> void:
	var goal_text := _goal_input.text.strip_edges()
	print("유저의 목표: %s" % goal_text)

	if goal_text.is_empty():
		add_chat_bubble("목표를 입력한 뒤 물장구를 쳐 주세요.", false)
		return

	add_chat_bubble(goal_text, true)
	_goal_input.text = ""

	_retry_timer.stop()
	_set_loading_state()
	_send_gemini_request(goal_text, 0, 0)
