extends Control

## 파스텔톤 연하늘색 (바다색)
const BACKGROUND_SEA := Color(0.73, 0.91, 0.97)
## 무료 티어에서 gemini-2.0-flash 한도는 0이라, 2.5 계열을 우선 사용합니다.
const GEMINI_MODELS: Array[String] = [
	"gemini-2.5-flash",
	"gemini-2.0-flash-lite",
]
const API_KEY_PATH := "res://API_KEY.txt"

var _http_request: HTTPRequest
var _goal_input: LineEdit
var _splash_button: Button
var _last_prompt: String = ""
var _active_model_index: int = 0


func _ready() -> void:
	_http_request = HTTPRequest.new()
	add_child(_http_request)
	_http_request.request_completed.connect(_on_request_completed)

	set_anchors_preset(PRESET_FULL_RECT)

	# 배경색
	var background := ColorRect.new()
	background.set_anchors_preset(PRESET_FULL_RECT)
	background.color = BACKGROUND_SEA
	background.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(background)

	# 초기 인사
	print("부기야 안녕! 드디어 첫 물장구를 쳤어!")

	# 화면 중앙 상단 UI
	var ui := VBoxContainer.new()
	ui.set_anchors_preset(PRESET_CENTER_TOP)
	ui.offset_top = 64.0
	ui.grow_horizontal = GROW_DIRECTION_BOTH
	ui.alignment = BoxContainer.ALIGNMENT_CENTER
	ui.add_theme_constant_override("separation", 16)
	add_child(ui)

	var title := Label.new()
	title.text = "Boogi On & On"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	ui.add_child(title)

	_goal_input = LineEdit.new()
	_goal_input.custom_minimum_size = Vector2(380, 44)
	_goal_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui.add_child(_goal_input)

	_splash_button = Button.new()
	_splash_button.text = "물장구 치기"
	_splash_button.custom_minimum_size = Vector2(220, 48)
	_splash_button.pressed.connect(_on_splash_button_pressed)
	ui.add_child(_splash_button)


func _load_api_key() -> String:
	if not FileAccess.file_exists(API_KEY_PATH):
		var message := "API_KEY.txt 파일을 찾을 수 없습니다. 프로젝트 루트(res://API_KEY.txt)에 API 키를 저장해 주세요."
		push_error(message)
		print(message)
		return ""

	var file := FileAccess.open(API_KEY_PATH, FileAccess.READ)
	if file == null:
		var message := "API_KEY.txt 파일을 열 수 없습니다: %s" % error_string(FileAccess.get_open_error())
		push_error(message)
		print(message)
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
		var empty_message := "API_KEY.txt가 비어 있습니다. Google AI Studio에서 발급한 API 키만 한 줄로 넣어 주세요."
		push_error(empty_message)
		print(empty_message)
		return ""
	if not key.begins_with("AIza"):
		var format_message := "API 키 형식이 올바르지 않습니다. AIza로 시작하는 키만 API_KEY.txt에 저장해 주세요."
		push_error(format_message)
		print(format_message)
		return ""

	return key


func _set_button_busy(busy: bool) -> void:
	_splash_button.disabled = busy
	_splash_button.text = "물장구 치는 중..." if busy else "물장구 치기"


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


func _print_quota_help(error: Dictionary) -> void:
	var retry_seconds := _parse_retry_seconds(error)
	var model_name: String = GEMINI_MODELS[_active_model_index]
	var message := (
		"Gemini 무료 사용 한도에 걸렸어요 (모델: %s). "
		% model_name
	)
	if retry_seconds > 0.0:
		message += "약 %d초 뒤에 다시 시도해 주세요. " % int(ceil(retry_seconds))
	message += "사용량: https://ai.dev/rate-limit"
	print(message)


func _send_gemini_request(prompt: String, model_index: int = 0) -> void:
	_last_prompt = prompt
	_active_model_index = model_index

	var api_key := _load_api_key()
	if api_key.is_empty():
		_set_button_busy(false)
		return

	if model_index >= GEMINI_MODELS.size():
		print("사용 가능한 Gemini 모델을 모두 시도했지만 응답하지 못했습니다.")
		_set_button_busy(false)
		return

	var model := GEMINI_MODELS[model_index]
	var url := "%s?key=%s" % [_gemini_endpoint(model), api_key]
	if model_index > 0:
		print("대체 모델로 재시도: %s" % model)
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
		push_error("Gemini API 요청 시작 실패: %s" % error_string(err))
		print("Gemini API 요청 시작 실패: %s" % error_string(err))
		_set_button_busy(false)


func _extract_gemini_text(response_body: PackedByteArray) -> String:
	var json := JSON.new()
	var parse_err := json.parse(response_body.get_string_from_utf8())
	if parse_err != OK:
		print("Gemini 응답 JSON 파싱 실패.")
		return ""

	var data: Variant = json.data
	if not data is Dictionary:
		print("Gemini 응답 형식이 올바르지 않습니다.")
		return ""

	if data.has("error"):
		print("Gemini API 오류: %s" % data["error"])
		return ""

	var candidates: Array = data.get("candidates", [])
	if candidates.is_empty():
		print("Gemini 응답에 candidates가 없습니다.")
		return ""

	var content: Dictionary = candidates[0].get("content", {})
	var parts: Array = content.get("parts", [])
	if parts.is_empty():
		print("Gemini 응답에 텍스트 parts가 없습니다.")
		return ""

	return str(parts[0].get("text", ""))


func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	_set_button_busy(false)

	if result != HTTPRequest.RESULT_SUCCESS:
		print("HTTP 통신 실패 (result=%d)" % result)
		return

	if response_code != 200:
		var api_error := _parse_api_error(body)
		if response_code == 429:
			_print_quota_help(api_error)
			if _active_model_index + 1 < GEMINI_MODELS.size():
				_set_button_busy(true)
				_send_gemini_request(_last_prompt, _active_model_index + 1)
				return
		elif api_error.is_empty():
			print("Gemini API HTTP 오류 %d: %s" % [response_code, body.get_string_from_utf8()])
		else:
			print("Gemini API HTTP 오류 %d: %s" % [response_code, api_error.get("message", api_error)])
		return

	var reply := _extract_gemini_text(body)
	if reply.is_empty():
		print("부기의 대답을 가져오지 못했습니다.")
		return

	print("부기의 대답: %s" % reply)


func _on_splash_button_pressed() -> void:
	var goal_text := _goal_input.text.strip_edges()
	print("유저의 목표: %s" % goal_text)
	_goal_input.text = ""

	if goal_text.is_empty():
		print("목표를 입력한 뒤 물장구를 쳐 주세요.")
		return

	_set_button_busy(true)
	_send_gemini_request(goal_text)
