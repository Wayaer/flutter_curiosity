package flutter.curiosity

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel

class CuriosityEvent(binaryMessenger: BinaryMessenger) : EventChannel
.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null
    private val eventName = "curiosity/event"
    private var curiosityEvent: EventChannel? = null

    init {
        curiosityEvent = EventChannel(binaryMessenger, eventName)
        curiosityEvent!!.setStreamHandler(this)
    }


    fun sendMessage(arguments: Any?) {
        eventSink?.success(arguments)
    }

    fun dispose() {
        eventSink?.endOfStream()
        curiosityEvent?.setStreamHandler(null)
        curiosityEvent = null
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink?.endOfStream()
    }
}