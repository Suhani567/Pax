extends Node

const Packet = preload("res://packet.gd")

signal connected
signal data
signal disconnected
signal error

# WebSocketClient instance
var _client = WebSocketPeer.new()


func _ready():
	# Connect signals with clear and descriptive names
	_client.connect("connection_established",Callable( self, "_on_connected"))
	_client.connect("data_received", Callable( self, "_on_data_received"))
	_client.connect("connection_closed", Callable( self, "_on_connection_closed"))
	_client.connect("connection_error", Callable( self, "_on_connection_error"))


func connect_to_server(hostname: String, port: int) -> void:
	# Build a well-formatted WebSocket URL
	var websocket_url = "ws://" + hostname + ":" + str(port)  # Use str() for string conversion

	# Attempt connection and handle errors gracefully
	var err = _client.connect_to_url(websocket_url)
	if err != OK:
		print("Error connecting:", err)
		set_process(false)
		emit_signal("error", err)


func send_packet(packet: Packet) -> void:
	# Convert packet to a UTF-8 buffer and handle potential errors
	var packet_buffer = packet.tostring().to_utf8_buffer()
	if not packet_buffer:
		print("Error creating packet buffer")
		return  # Early return to avoid sending empty data

	_client.get_peer(1).put_packet(packet_buffer)
	print("Sent packet:", packet.tostring())


func _on_connected(proto = ""):
	print("Connected with protocol:", proto)
	emit_signal("connected")


func _on_data_received():
	# Retrieve data safely and handle potential errors
	var data = _client.get_peer(1).get_packet()
	if not data:
		print("Error getting data from server")
		return  # Early return to avoid potential issues

	var string_data = data.get_string_from_utf8()
	print("Got data from server:", string_data)
	emit_signal("data", string_data)


func _on_connection_closed(was_clean = false):
	print("Closed, clean:", was_clean)
	set_process(false)
	emit_signal("disconnected", was_clean)


func _on_connection_error(error_code):
	# Handle connection errors with informative message
	print("Connection error:", error_code)
	set_process(false)
	emit_signal("error", error_code)  # Pass the error code for handling


func _process(delta):
	_client.poll()
