extends Control

const BACKGROUND_SEA := Color(0.73, 0.91, 0.97)
## 부하가 낮은 모델을 먼저 시도해 'high demand' 오류를 줄입니다.
const GEMINI_MODELS: Array[String] = [
	"gemini-2.0-flash-lite",
	"gemini-2.5-flash-lite",
	"gemini-2.5-flash",
]
const API_KEY_PATH := "res://API_KEY.txt"
const LOADING_REPLY_TEXT := "부기가 열심히 고민하고 있어요... 🐢 뽀글뽀글..."
const INITIAL_REPLY_TEXT := "물장구를 치면 부기의 대답이 여기에 나타나요."
const MAX_RETRIES_PER_MODEL := 3
const RETRY_BASE_DELAY_SEC := 2.0

var _http_request: HTTPRequest
var _retry_timer: Timer
var _goal_input: LineEdit
var _splash_button: Button
var _reply_label: RichTextLabel
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
	print("부기야 안녕! 드디어 첫 물장구를 쳤어!")


func setup_ui() -> void:
	var background := ColorRect.new()
	background.set_anchors_preset(PRESET_FULL_RECT)
	background.color = BACKGROUND_SEA
	background.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 36)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 28)
	add_child(margin)

	var layout := VBoxContainer.new()
	layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.alignment = BoxContainer.ALIGNMENT_CENTER
	layout.add_theme_constant_override("separation", 20)
	margin.add_child(layout)

	var title := Label.new()
	title.text = "Boogi On & On"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	layout.add_child(title)

	_goal_input = LineEdit.new()
	_goal_input.placeholder_text = "오늘의 목표를 적어 보세요..."
	_goal_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	_goal_input.custom_minimum_size = Vector2(0.0, 44.0)
	_goal_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.add_child(_goal_input)

	_splash_button = Button.new()
	_splash_button.text = "물장구 치기"
	_splash_button.custom_minimum_size = Vector2(220.0, 48.0)
	_splash_button.pressed.connect(_on_splash_button_pressed)
	layout.add_child(_splash_button)

	_reply_label = RichTextLabel.new()
	_reply_label.text = INITIAL_REPLY_TEXT
	_reply_label.bbcode_enabled = false
	_reply_label.scroll_active = true
	_reply_label.fit_content = false
	_reply_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_reply_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_reply_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_reply_label.custom_minimum_size = Vector2(0.0, 120.0)
	layout.add_child(_reply_label)


func _set_button_busy(busy: bool) -> void:
	_splash_button.disabled = busy
	_splash_button.text = "물장구 치는 중..." if busy else "물장구 치기"


func _set_loading_state() -> void:
	_reply_label.text = LOADING_REPLY_TEXT
	_set_button_busy(true)


func _show_reply(message: String) -> void:
	_reply_label.text = message


func _finish_request() -> void:
	_retry_timer.stop()
	_set_button_busy(false)


func _load_api_key() -> String:
	if not FileAccess.file_exists(API_KEY_PATH):
		var message := "API_KEY.txt 파일을 찾을 수 없습니다. 프로젝트 루트(res://API_KEY.txt)에 API 키를 저장해 주세요."
		push_error(message)
		return ""

	var file := FileAccess.open(API_KEY_PATH, FileAccess.READ)
	if file == null:
		var message := "API_KEY.txt 파일을 열 수 없습니다: %s" % error_string(FileAccess.get_open_error())
		push_error(message)
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
	if key.is_empty():
		push_error("API_KEY.txt가 비어 있습니다.")
		return ""
	if not key.begins_with("AIza"):
		push_error("API 키 형식이 올바르지 않습니다. AIza로 시작하는 키만 저장해 주세요.")
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
	_show_reply(
		"부기 서버가 지금 많이 바빠요... 🐢\n약 %d초 후에 자동으로 다시 시도할게요."
		% int(ceil(delay_sec))
	)
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
		_show_reply("다른 모델(%s)로 다시 시도할게요... 🐢" % model)

	var url := "%s?key=%s" % [_gemini_endpoint(model), api_key]
	var payload := {
		"contents": [
			{
				"parts": [
					{"text": prompt}
				]
			}
		]
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
		_show_reply(reply)

	_finish_request()


func _on_splash_button_pressed() -> void:
	var goal_text := _goal_input.text.strip_edges()
	print("유저의 목표: %s" % goal_text)
	_goal_input.text = ""

	if goal_text.is_empty():
		_show_reply("목표를 입력한 뒤 물장구를 쳐 주세요.")
		return

	_retry_timer.stop()
	_set_loading_state()
	_send_gemini_request(goal_text, 0, 0)
