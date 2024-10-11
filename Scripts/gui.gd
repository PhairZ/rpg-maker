class_name GUIManager
extends CanvasLayer


signal dialogue_continue

@export var char_per_sec := 20.0

var dialogue_state := 0
enum DialogueState{
	DIALOGUE_STOPPED,
	DIALOGUE_PLAYING,
	DIALOGUE_WAITING,
}


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact") and dialogue_state != DialogueState.DIALOGUE_STOPPED:
		get_viewport().set_input_as_handled()
		dialogue_state = DialogueState.DIALOGUE_WAITING
		dialogue_continue.emit()


func play_dialogue(content: String, speaker:= "") -> void:
	if not content: return
	
	dialogue_state = DialogueState.DIALOGUE_PLAYING
	get_tree().paused = true
	if speaker:
		$DialogueBox/Speaker.show()
		$DialogueBox/Speaker/Label.text = speaker
	
	$DialogueBox/TextBox.show()
	var text_box := $DialogueBox/TextBox/MarginContainer/Label
	text_box.text = ""
	for character in content:
		text_box.text += character
		await get_tree().create_timer(1.0/char_per_sec).timeout
		if dialogue_state == DialogueState.DIALOGUE_WAITING:
			text_box.text = content
			break
	
	dialogue_state = DialogueState.DIALOGUE_WAITING
	await dialogue_continue
	
	dialogue_state = DialogueState.DIALOGUE_STOPPED
	get_tree().paused = false
	$DialogueBox/Speaker.hide()
	$DialogueBox/TextBox.hide()
