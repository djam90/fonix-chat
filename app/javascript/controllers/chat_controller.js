import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

// Sends and receives chat messages over the ChatChannel websocket.
export default class extends Controller {
  static targets = [ "messages", "input", "submit", "status", "error", "empty" ]
  static values = { currentUserId: Number }

  connect() {
    this.messagesTarget.querySelectorAll(".message").forEach(message => this.decorate(message))
    this.scrollToBottom()

    this.subscription = consumer.subscriptions.create("ChatChannel", {
      connected: () => this.setConnected(true),
      disconnected: () => this.setConnected(false),
      rejected: () => this.setStatus("Unable to join the chat", "error"),
      received: data => this.received(data)
    })
  }

  disconnect() {
    this.subscription?.unsubscribe()
  }

  submit(event) {
    event.preventDefault()

    const body = this.inputTarget.value.trim()
    if (!body || !this.connected) return

    this.subscription.perform("speak", { body })
    this.clearError()
    this.inputTarget.value = ""
    this.inputTarget.focus()
  }

  // Enter sends, Shift+Enter adds a new line.
  submitOnEnter(event) {
    if (event.shiftKey || event.isComposing) return
    this.submit(event)
  }

  received(data) {
    if (data.error) return this.showError(data.error)
    if (document.getElementById(`message_${data.id}`)) return

    const stickToBottom = this.isScrolledToBottom()
    this.messagesTarget.insertAdjacentHTML("beforeend", data.html)
    if (this.hasEmptyTarget) this.emptyTarget.remove()

    const message = document.getElementById(`message_${data.id}`)
    this.decorate(message)
    if (stickToBottom || message.classList.contains("message--own")) this.scrollToBottom()
  }

  setConnected(connected) {
    this.connected = connected
    this.submitTarget.disabled = !connected
    this.setStatus(connected ? "Connected" : "Reconnecting...", connected ? "online" : "offline")
  }

  setStatus(text, state) {
    this.statusTarget.textContent = text
    this.statusTarget.dataset.state = state
  }

  // Marks the viewer's own messages and shows timestamps in their local time zone.
  decorate(message) {
    if (Number(message.dataset.authorId) === this.currentUserIdValue) {
      message.classList.add("message--own")
    }

    const time = message.querySelector("time")
    if (time) {
      time.textContent = new Date(time.dateTime).toLocaleString([], {
        day: "numeric", month: "short", hour: "2-digit", minute: "2-digit"
      })
    }
  }

  showError(error) {
    this.errorTarget.textContent = error
    this.errorTarget.hidden = false
  }

  clearError() {
    this.errorTarget.hidden = true
  }

  isScrolledToBottom() {
    const { scrollTop, scrollHeight, clientHeight } = this.messagesTarget
    return scrollHeight - scrollTop - clientHeight < 40
  }

  scrollToBottom() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }
}
