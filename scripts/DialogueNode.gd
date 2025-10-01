extends Resource
class_name DialogueNode

@export var text: String = ""
@export var choices: Array = [] # Array of {"text": String, "next_node": DialogueNode}
