extends Resource
class_name DialogueNode

@export var text: String = ""
@export var choices: Array = [] # Array of {"id": String, "text": String, "next_node": DialogueNode}
