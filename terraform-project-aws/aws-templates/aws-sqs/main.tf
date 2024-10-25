variable "queue_names" {
  type = list(string)
  default = [
    "queue1",
    "queue2",
    "queue3",
    "queue4",
    "queue5",
    "queue6",
    "queue7",
    "queue8",
    "queue9",
    "queue10",
    "queue11",
    "queue12",
    "queue13",
    "queue14",
    "queue15",
    "queue16",
    "queue17",
    "queue18"
  ]
}

resource "aws_sqs_queue" "sqs_queues" {
  count = length(var.queue_names)

  name = "${var.environment}-${var.queue_names[count.index]}"
}