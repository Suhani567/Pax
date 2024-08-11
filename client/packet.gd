extends Object

var action: String
var payloads: Array


func _init(_action: String, _payloads: Array):
	action = _action
	payloads = _payloads


func tostring() -> String:
	var serlialize_dict: Dictionary = {"a": action}
	for i in range(len(payloads)):
		serlialize_dict["p%d" % i] = payloads[i]
	var data: String = JSON.stringify(serlialize_dict)
	return data


static func json_to_action_payloads(json_str: String) -> Array:
	var action: String
	var payloads: Array = []
	var test_json_conv = JSON.new()
	test_json_conv.parse(json_str)
	var obj_dict: Dictionary = test_json_conv.result

	for key in obj_dict.keys():
		var value = obj_dict[key]
		if key == "a":
			action = value
		elif key.begins_with("p"):
			var index: int = key.substr(1).to_int()
			payloads.insert(index, value)

	return [action, payloads]

